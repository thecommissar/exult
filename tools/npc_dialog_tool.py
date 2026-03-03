#!/usr/bin/env python3
"""NPC dialog topic editor.

Mouse-first Tkinter utility for editing dialog topics as a hierarchy.
Includes quick templates, duplicate, move controls, drag-reorder, and
keyboard accelerators.
"""

from __future__ import annotations

import json
import tkinter as tk
from copy import deepcopy
from dataclasses import dataclass, field
from tkinter import filedialog, messagebox, ttk
from typing import Any


@dataclass
class Topic:
    title: str = "new_topic"
    lines: list[str] = field(default_factory=list)
    opens: list[str] = field(default_factory=list)
    flags: dict[str, Any] = field(default_factory=dict)
    children: list["Topic"] = field(default_factory=list)

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> "Topic":
        return cls(
            title=data.get("title", "new_topic"),
            lines=list(data.get("lines", [])),
            opens=list(data.get("opens", [])),
            flags=dict(data.get("flags", {})),
            children=[cls.from_dict(child) for child in data.get("children", [])],
        )

    def to_dict(self) -> dict[str, Any]:
        return {
            "title": self.title,
            "lines": self.lines,
            "opens": self.opens,
            "flags": self.flags,
            "children": [child.to_dict() for child in self.children],
        }


class TopicEditor(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("NPC Dialog Topic Tool")
        self.geometry("1200x760")
        self.minsize(980, 620)

        self.file_path: str | None = None
        self.root_topic = Topic(title="ROOT")
        self.node_map: dict[str, Topic] = {}
        self.current_iid: str | None = None
        self._dragging_iid: str | None = None

        self._build_ui()
        self._bind_shortcuts()
        self._refresh_tree(select_iid=None)

    def _build_ui(self) -> None:
        self.columnconfigure(1, weight=1)
        self.rowconfigure(0, weight=1)

        left = ttk.Frame(self, padding=8)
        left.grid(row=0, column=0, sticky="nsew")
        left.rowconfigure(1, weight=1)

        ttk.Label(left, text="Topics", font=("TkDefaultFont", 10, "bold")).grid(
            row=0, column=0, sticky="w", pady=(0, 6)
        )

        tree_wrap = ttk.Frame(left)
        tree_wrap.grid(row=1, column=0, sticky="nsew")
        tree_wrap.rowconfigure(0, weight=1)
        tree_wrap.columnconfigure(0, weight=1)

        self.tree = ttk.Treeview(tree_wrap, show="tree", selectmode="browse")
        self.tree.grid(row=0, column=0, sticky="nsew")

        yscroll = ttk.Scrollbar(tree_wrap, orient="vertical", command=self.tree.yview)
        yscroll.grid(row=0, column=1, sticky="ns")
        self.tree.configure(yscrollcommand=yscroll.set)

        btns = ttk.Frame(left)
        btns.grid(row=2, column=0, sticky="ew", pady=(8, 0))
        for i in range(2):
            btns.columnconfigure(i, weight=1)

        ttk.Button(btns, text="Add Child", command=self.add_child).grid(row=0, column=0, sticky="ew", padx=(0, 4))
        ttk.Button(btns, text="Delete", command=self.delete_selected).grid(row=0, column=1, sticky="ew")
        ttk.Button(btns, text="Duplicate Topic", command=self.duplicate_selected).grid(
            row=1, column=0, sticky="ew", padx=(0, 4), pady=(4, 0)
        )
        ttk.Button(btns, text="Move Up", command=lambda: self.move_selected(-1)).grid(
            row=1, column=1, sticky="ew", pady=(4, 0)
        )
        ttk.Button(btns, text="Move Down", command=lambda: self.move_selected(1)).grid(
            row=2, column=1, sticky="ew", pady=(4, 0)
        )

        template_box = ttk.LabelFrame(left, text="Quick Insert Templates", padding=6)
        template_box.grid(row=3, column=0, sticky="ew", pady=(8, 0))
        template_box.columnconfigure(0, weight=1)

        ttk.Button(
            template_box,
            text="Basic info topic",
            command=lambda: self.add_template("basic_info"),
        ).grid(row=0, column=0, sticky="ew", pady=(0, 4))
        ttk.Button(
            template_box,
            text="Rumor topic (opens new topic)",
            command=lambda: self.add_template("rumor_open"),
        ).grid(row=1, column=0, sticky="ew", pady=(0, 4))
        ttk.Button(
            template_box,
            text="Gated quest topic",
            command=lambda: self.add_template("gated_quest"),
        ).grid(row=2, column=0, sticky="ew", pady=(0, 4))
        ttk.Button(
            template_box,
            text="Bye branch template",
            command=lambda: self.add_template("bye_branch"),
        ).grid(row=3, column=0, sticky="ew")

        right = ttk.Frame(self, padding=8)
        right.grid(row=0, column=1, sticky="nsew")
        right.columnconfigure(1, weight=1)
        right.rowconfigure(3, weight=1)
        right.rowconfigure(5, weight=1)

        ttk.Label(right, text="Topic Title:").grid(row=0, column=0, sticky="w")
        self.title_var = tk.StringVar()
        title_entry = ttk.Entry(right, textvariable=self.title_var)
        title_entry.grid(row=0, column=1, sticky="ew")

        ttk.Label(right, text="Lines (one per line):").grid(row=1, column=0, sticky="nw", pady=(8, 0))
        self.lines_text = tk.Text(right, height=10, wrap="word")
        self.lines_text.grid(row=1, column=1, sticky="nsew", pady=(8, 0))

        ttk.Label(right, text="Opens (topic ids / names):").grid(row=2, column=0, sticky="nw", pady=(8, 0))
        self.opens_text = tk.Text(right, height=6, wrap="word")
        self.opens_text.grid(row=2, column=1, sticky="nsew", pady=(8, 0))

        ttk.Label(right, text="Flags (JSON object):").grid(row=4, column=0, sticky="nw", pady=(8, 0))
        self.flags_text = tk.Text(right, height=10, wrap="word")
        self.flags_text.grid(row=4, column=1, sticky="nsew", pady=(8, 0))

        action_bar = ttk.Frame(right)
        action_bar.grid(row=6, column=0, columnspan=2, sticky="ew", pady=(8, 0))
        ttk.Button(action_bar, text="Apply Changes", command=self.apply_edits).pack(side="left")
        ttk.Button(action_bar, text="New", command=self.new_file).pack(side="left", padx=(4, 0))
        ttk.Button(action_bar, text="Open", command=self.open_file).pack(side="left", padx=(4, 0))
        ttk.Button(action_bar, text="Save", command=self.save_file).pack(side="left", padx=(4, 0))

        self.tree.bind("<<TreeviewSelect>>", self._on_tree_select)
        self.tree.bind("<ButtonPress-1>", self._on_drag_start)
        self.tree.bind("<B1-Motion>", self._on_drag_motion)
        self.tree.bind("<ButtonRelease-1>", self._on_drag_drop)

    def _bind_shortcuts(self) -> None:
        self.bind("<Control-n>", lambda _e: self.new_file())
        self.bind("<Control-o>", lambda _e: self.open_file())
        self.bind("<Control-s>", lambda _e: self.save_file())
        self.bind("<Control-d>", lambda _e: self.duplicate_selected())
        self.bind("<Control-Shift-Up>", lambda _e: self.move_selected(-1))
        self.bind("<Control-Shift-Down>", lambda _e: self.move_selected(1))
        self.bind("<Delete>", lambda _e: self.delete_selected())

    def _get_selected_iid(self) -> str | None:
        sel = self.tree.selection()
        return sel[0] if sel else None

    def _selected_topic(self) -> Topic | None:
        iid = self._get_selected_iid()
        return self.node_map.get(iid) if iid else None

    def _find_parent_and_index(self, target: Topic, parent: Topic | None = None) -> tuple[Topic, int] | None:
        node = self.root_topic if parent is None else parent
        for idx, child in enumerate(node.children):
            if child is target:
                return node, idx
            found = self._find_parent_and_index(target, child)
            if found:
                return found
        return None

    def _refresh_tree(self, select_iid: str | None) -> None:
        self.tree.delete(*self.tree.get_children())
        self.node_map.clear()

        def walk(parent_iid: str, node: Topic) -> None:
            for child in node.children:
                iid = self.tree.insert(parent_iid, "end", text=child.title)
                self.node_map[iid] = child
                walk(iid, child)

        walk("", self.root_topic)

        target = select_iid if select_iid in self.node_map else None
        if target is None:
            all_nodes = list(self.node_map)
            target = all_nodes[0] if all_nodes else None

        if target:
            self.tree.selection_set(target)
            self.tree.focus(target)
            self.tree.see(target)
            self._load_topic(self.node_map[target])
        else:
            self._clear_editor()

    def _clear_editor(self) -> None:
        self.current_iid = None
        self.title_var.set("")
        self.lines_text.delete("1.0", "end")
        self.opens_text.delete("1.0", "end")
        self.flags_text.delete("1.0", "end")

    def _load_topic(self, topic: Topic) -> None:
        self.title_var.set(topic.title)
        self.lines_text.delete("1.0", "end")
        self.lines_text.insert("1.0", "\n".join(topic.lines))

        self.opens_text.delete("1.0", "end")
        self.opens_text.insert("1.0", "\n".join(topic.opens))

        self.flags_text.delete("1.0", "end")
        self.flags_text.insert("1.0", json.dumps(topic.flags, indent=2))

    def _on_tree_select(self, _event: tk.Event) -> None:
        iid = self._get_selected_iid()
        self.current_iid = iid
        if iid and iid in self.node_map:
            self._load_topic(self.node_map[iid])

    def apply_edits(self) -> None:
        topic = self._selected_topic()
        iid = self._get_selected_iid()
        if not topic or not iid:
            return

        try:
            flags = json.loads(self.flags_text.get("1.0", "end").strip() or "{}")
            if not isinstance(flags, dict):
                raise ValueError("Flags must be a JSON object.")
        except Exception as exc:
            messagebox.showerror("Invalid flags", str(exc))
            return

        topic.title = self.title_var.get().strip() or "new_topic"
        topic.lines = [line.strip() for line in self.lines_text.get("1.0", "end").splitlines() if line.strip()]
        topic.opens = [line.strip() for line in self.opens_text.get("1.0", "end").splitlines() if line.strip()]
        topic.flags = flags

        self.tree.item(iid, text=topic.title)

    def add_child(self) -> None:
        parent_topic = self._selected_topic()
        if parent_topic is None:
            parent_topic = self.root_topic

        new_topic = Topic(title="new_topic", lines=["Hello there."])
        parent_topic.children.append(new_topic)
        self._refresh_tree(select_iid=None)

    def delete_selected(self) -> None:
        topic = self._selected_topic()
        if not topic:
            return
        if not messagebox.askyesno("Delete topic", "Delete selected topic and all child topics?"):
            return

        found = self._find_parent_and_index(topic)
        if not found:
            return

        parent, idx = found
        del parent.children[idx]
        self._refresh_tree(select_iid=None)

    def duplicate_selected(self) -> None:
        topic = self._selected_topic()
        if not topic:
            return

        found = self._find_parent_and_index(topic)
        if not found:
            return

        parent, idx = found
        clone = Topic(
            title=f"{topic.title}_copy",
            lines=deepcopy(topic.lines),
            opens=deepcopy(topic.opens),
            flags=deepcopy(topic.flags),
            children=deepcopy(topic.children),
        )
        parent.children.insert(idx + 1, clone)
        self._refresh_tree(select_iid=None)

    def move_selected(self, direction: int) -> None:
        topic = self._selected_topic()
        if not topic:
            return

        found = self._find_parent_and_index(topic)
        if not found:
            return

        parent, idx = found
        swap_idx = idx + direction
        if swap_idx < 0 or swap_idx >= len(parent.children):
            return

        parent.children[idx], parent.children[swap_idx] = parent.children[swap_idx], parent.children[idx]
        self._refresh_tree(select_iid=None)

    def _on_drag_start(self, event: tk.Event) -> None:
        self._dragging_iid = self.tree.identify_row(event.y)

    def _on_drag_motion(self, event: tk.Event) -> None:
        if self._dragging_iid:
            over = self.tree.identify_row(event.y)
            if over:
                self.tree.selection_set(over)

    def _on_drag_drop(self, event: tk.Event) -> None:
        if not self._dragging_iid:
            return

        source_iid = self._dragging_iid
        target_iid = self.tree.identify_row(event.y)
        self._dragging_iid = None

        if not source_iid or not target_iid or source_iid == target_iid:
            return

        source_topic = self.node_map.get(source_iid)
        target_topic = self.node_map.get(target_iid)
        if not source_topic or not target_topic:
            return

        src_found = self._find_parent_and_index(source_topic)
        tgt_found = self._find_parent_and_index(target_topic)
        if not src_found or not tgt_found:
            return

        src_parent, src_idx = src_found
        tgt_parent, tgt_idx = tgt_found

        if src_parent is not tgt_parent:
            return

        item = src_parent.children.pop(src_idx)
        if src_idx < tgt_idx:
            tgt_idx -= 1
        src_parent.children.insert(tgt_idx, item)
        self._refresh_tree(select_iid=None)

    def add_template(self, template_key: str) -> None:
        template = self._template_topic(template_key)
        parent_topic = self._selected_topic() or self.root_topic
        parent_topic.children.append(template)
        self._refresh_tree(select_iid=None)

    def _template_topic(self, template_key: str) -> Topic:
        if template_key == "basic_info":
            return Topic(
                title="info",
                lines=[
                    "I can tell you a little about this place.",
                    "Ask if you want directions.",
                ],
                flags={"category": "info"},
            )
        if template_key == "rumor_open":
            return Topic(
                title="rumor",
                lines=["Heard any rumors?", "I heard something odd near the old mill..."],
                opens=["old_mill_rumor"],
                flags={"category": "rumor", "importance": "optional"},
            )
        if template_key == "gated_quest":
            return Topic(
                title="quest_gate",
                lines=["I might have work for you, if you've proven yourself."],
                opens=["quest_details"],
                flags={"requires_flag": "met_captain", "sets_flag": "quest_offered"},
            )
        if template_key == "bye_branch":
            return Topic(
                title="bye",
                lines=["Farewell.", "Safe travels."],
                flags={"end_conversation": True},
            )
        return Topic(title="new_topic")

    def new_file(self) -> None:
        self.file_path = None
        self.root_topic = Topic(title="ROOT")
        self._refresh_tree(select_iid=None)

    def open_file(self) -> None:
        path = filedialog.askopenfilename(
            title="Open topic JSON",
            filetypes=[("JSON", "*.json"), ("All files", "*.*")],
        )
        if not path:
            return

        try:
            with open(path, "r", encoding="utf-8") as fh:
                payload = json.load(fh)
            loaded = Topic.from_dict(payload)
            self.root_topic = Topic(title="ROOT", children=loaded.children)
            self.file_path = path
            self._refresh_tree(select_iid=None)
        except Exception as exc:
            messagebox.showerror("Open failed", str(exc))

    def save_file(self) -> None:
        self.apply_edits()
        path = self.file_path
        if not path:
            path = filedialog.asksaveasfilename(
                title="Save topic JSON",
                defaultextension=".json",
                filetypes=[("JSON", "*.json"), ("All files", "*.*")],
            )
            if not path:
                return

        self.file_path = path
        payload = {"title": "ROOT", "children": [child.to_dict() for child in self.root_topic.children]}
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(payload, fh, indent=2)
        messagebox.showinfo("Saved", f"Saved dialog topics to:\n{path}")


if __name__ == "__main__":
    app = TopicEditor()
    app.mainloop()

#!/usr/bin/env python3
"""NPC dialog authoring tool with code generation and an in-app simulator."""

from __future__ import annotations

from dataclasses import dataclass, field
import json
from pathlib import Path
import re
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from typing import Any


@dataclass
class DialogNode:
    topic: str
    lines: list[str] = field(default_factory=list)
    opens_topics: list[str] = field(default_factory=list)
    remove_after_select: bool = True
    is_bye: bool = False
    condition_expr: str = ""
    fail_lines: list[str] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        return {
            "topic": self.topic,
            "lines": list(self.lines),
            "opens_topics": list(self.opens_topics),
            "remove_after_select": self.remove_after_select,
            "is_bye": self.is_bye,
            "condition_expr": self.condition_expr,
            "fail_lines": list(self.fail_lines),
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> "DialogNode":
        return cls(
            topic=str(data.get("topic", "")).strip(),
            lines=[str(v) for v in data.get("lines", []) if str(v).strip()],
            opens_topics=[str(v).strip() for v in data.get("opens_topics", []) if str(v).strip()],
            remove_after_select=bool(data.get("remove_after_select", True)),
            is_bye=bool(data.get("is_bye", False)),
            condition_expr=str(data.get("condition_expr", "")).strip(),
            fail_lines=[str(v) for v in data.get("fail_lines", []) if str(v).strip()],
        )


class UsecodeDialogBuilder(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Ultima 7 NPC Dialog Builder")
        self.geometry("1200x760")

        self.nodes: list[DialogNode] = []
        self.current_project_path: str | None = None

        self.sim_open_topics: set[str] = set()
        self.sim_removed_topics: set[str] = set()
        self.sim_met = False
        self.sim_selected_flags: set[str] = set()
        self.sim_schedule: str = ""
        self.sim_transcript: list[str] = []
        self.sim_ended = False

        self._build_style()
        self._build_layout()
        self.reset_simulator()

    def _build_style(self) -> None:
        style = ttk.Style(self)
        try:
            style.theme_use("clam")
        except tk.TclError:
            pass

        style.configure("Title.TLabel", font=("Segoe UI", 15, "bold"))
        style.configure("Hint.TLabel", foreground="#5b6b82")
        style.configure("Badge.TLabel", background="#eef2ff", foreground="#1e3a8a", padding=(8, 3))

    def _build_layout(self) -> None:
        self.columnconfigure(0, weight=1)
        self.rowconfigure(1, weight=1)

        header = ttk.Frame(self, padding=(14, 12))
        header.grid(row=0, column=0, sticky="ew")
        header.columnconfigure(0, weight=1)

        ttk.Label(header, text="NPC Usecode Dialog Builder", style="Title.TLabel").grid(row=0, column=0, sticky="w")
        ttk.Label(
            header,
            text="Build conversation topics and preview behavior with a simulator.",
            style="Hint.TLabel",
        ).grid(row=1, column=0, sticky="w", pady=(4, 0))

        main = ttk.PanedWindow(self, orient=tk.HORIZONTAL)
        main.grid(row=1, column=0, sticky="nsew", padx=14, pady=(0, 14))

        left = ttk.Frame(main, padding=8)
        right = ttk.Frame(main, padding=8)
        main.add(left, weight=2)
        main.add(right, weight=3)

        self._build_left_panel(left)
        self._build_right_panel(right)

    def _build_left_panel(self, parent: ttk.Frame) -> None:
        parent.rowconfigure(2, weight=1)
        parent.columnconfigure(0, weight=1)

        meta = ttk.LabelFrame(parent, text="NPC Metadata", padding=10)
        meta.grid(row=0, column=0, sticky="ew", pady=(0, 10))
        meta.columnconfigure(1, weight=1)

        ttk.Label(meta, text="Function name:").grid(row=0, column=0, sticky="w", padx=(0, 8), pady=4)
        self.name_var = tk.StringVar(value="Template")
        ttk.Entry(meta, textvariable=self.name_var).grid(row=0, column=1, sticky="ew", pady=4)

        ttk.Label(meta, text="Object id (hex):").grid(row=1, column=0, sticky="w", padx=(0, 8), pady=4)
        self.object_var = tk.StringVar(value="0x000")
        ttk.Entry(meta, textvariable=self.object_var).grid(row=1, column=1, sticky="ew", pady=4)

        ttk.Label(meta, text="First met line:").grid(row=2, column=0, sticky="w", padx=(0, 8), pady=4)
        self.first_line_var = tk.StringVar(value="Usually a description of the npc.")
        ttk.Entry(meta, textvariable=self.first_line_var).grid(row=2, column=1, sticky="ew", pady=4)

        editor = ttk.LabelFrame(parent, text="Topic Editor", padding=10)
        editor.grid(row=1, column=0, sticky="ew", pady=(0, 10))
        editor.columnconfigure(1, weight=1)

        ttk.Label(editor, text="Topic:").grid(row=0, column=0, sticky="w", padx=(0, 8), pady=3)
        self.topic_var = tk.StringVar()
        ttk.Entry(editor, textvariable=self.topic_var).grid(row=0, column=1, sticky="ew", pady=3)

        ttk.Label(editor, text="NPC lines (one per line):").grid(row=1, column=0, sticky="nw", padx=(0, 8), pady=3)
        self.lines_text = tk.Text(editor, height=5, wrap="word")
        self.lines_text.grid(row=1, column=1, sticky="ew", pady=3)

        ttk.Label(editor, text="Opens topics (comma-separated):").grid(row=2, column=0, sticky="w", padx=(0, 8), pady=3)
        self.opens_var = tk.StringVar()
        ttk.Entry(editor, textvariable=self.opens_var).grid(row=2, column=1, sticky="ew", pady=3)

        ttk.Label(editor, text="Condition (optional):").grid(row=3, column=0, sticky="w", padx=(0, 8), pady=3)
        self.condition_var = tk.StringVar()
        ttk.Entry(editor, textvariable=self.condition_var).grid(row=3, column=1, sticky="ew", pady=3)

        ttk.Label(editor, text="Fail lines (one per line):").grid(row=4, column=0, sticky="nw", padx=(0, 8), pady=3)
        self.fail_lines_text = tk.Text(editor, height=3, wrap="word")
        self.fail_lines_text.grid(row=4, column=1, sticky="ew", pady=3)

        self.remove_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(editor, text="Remove topic after selecting", variable=self.remove_var).grid(row=5, column=1, sticky="w", pady=2)

        self.bye_var = tk.BooleanVar(value=False)
        ttk.Checkbutton(editor, text="This topic is the goodbye branch", variable=self.bye_var).grid(row=6, column=1, sticky="w", pady=2)

        btns = ttk.Frame(editor)
        btns.grid(row=7, column=1, sticky="e", pady=(8, 0))
        ttk.Button(btns, text="Add Topic", command=self.add_topic).grid(row=0, column=0, padx=4)
        ttk.Button(btns, text="Update Selected", command=self.update_topic).grid(row=0, column=1, padx=4)
        ttk.Button(btns, text="Delete Selected", command=self.delete_topic).grid(row=0, column=2, padx=4)

        tree_box = ttk.LabelFrame(parent, text="Dialog Tree", padding=8)
        tree_box.grid(row=2, column=0, sticky="nsew")
        tree_box.rowconfigure(0, weight=1)
        tree_box.columnconfigure(0, weight=1)

        self.tree = ttk.Treeview(tree_box, columns=("topic", "opens", "bye"), show="headings", selectmode="browse")
        self.tree.heading("topic", text="Topic")
        self.tree.heading("opens", text="Opens")
        self.tree.heading("bye", text="Bye?")
        self.tree.column("topic", width=120)
        self.tree.column("opens", width=140)
        self.tree.column("bye", width=60, anchor="center")
        self.tree.grid(row=0, column=0, sticky="nsew")
        self.tree.bind("<<TreeviewSelect>>", self.load_selected_topic)

        ys = ttk.Scrollbar(tree_box, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscroll=ys.set)
        ys.grid(row=0, column=1, sticky="ns")

    def _build_right_panel(self, parent: ttk.Frame) -> None:
        parent.rowconfigure(2, weight=1)
        parent.columnconfigure(0, weight=1)

        controls = ttk.Frame(parent)
        controls.grid(row=0, column=0, sticky="ew", pady=(0, 8))
        controls.columnconfigure(0, weight=1)

        ttk.Button(controls, text="Generate Usecode", command=self.generate_preview).grid(row=0, column=1, padx=4)
        ttk.Button(controls, text="Save Project", command=self.save_project_as).grid(row=0, column=2, padx=4)

        notebook = ttk.Notebook(parent)
        notebook.grid(row=1, column=0, sticky="nsew", pady=(0, 8))

        table_tab = ttk.Frame(notebook, padding=8)
        graph_tab = ttk.Frame(notebook, padding=8)
        simulator_tab = ttk.Frame(notebook, padding=8)
        notebook.add(table_tab, text="Table")
        notebook.add(graph_tab, text="Graph")
        notebook.add(simulator_tab, text="Simulator")

        self.table_list = tk.Listbox(table_tab)
        self.table_list.pack(fill=tk.BOTH, expand=True)

        graph_tab.rowconfigure(0, weight=1)
        graph_tab.columnconfigure(0, weight=1)
        self.graph_canvas = tk.Canvas(graph_tab, bg="white")
        self.graph_canvas.grid(row=0, column=0, sticky="nsew")
        self.graph_canvas.bind("<Button-1>", self.on_graph_click)
        self.graph_item_to_index: dict[int, int] = {}

        self._build_simulator(simulator_tab)

        preview_box = ttk.LabelFrame(parent, text="Generated Usecode", padding=8)
        preview_box.grid(row=2, column=0, sticky="nsew")
        preview_box.rowconfigure(0, weight=1)
        preview_box.columnconfigure(0, weight=1)

        self.output = tk.Text(preview_box, wrap="none", height=14)
        self.output.grid(row=0, column=0, sticky="nsew")

    def _build_simulator(self, parent: ttk.Frame) -> None:
        parent.rowconfigure(2, weight=1)
        parent.columnconfigure(0, weight=1)

        header = ttk.Frame(parent)
        header.grid(row=0, column=0, sticky="ew")
        header.columnconfigure(0, weight=1)
        ttk.Button(header, text="Reset", command=self.reset_simulator).grid(row=0, column=1, sticky="e")

        self.sim_warning_var = tk.StringVar(value="")
        ttk.Label(header, textvariable=self.sim_warning_var, foreground="#b42318").grid(row=1, column=0, columnspan=2, sticky="w", pady=(6, 0))

        self.sim_badges_frame = ttk.Frame(parent)
        self.sim_badges_frame.grid(row=1, column=0, sticky="ew", pady=(8, 8))

        transcript_box = ttk.LabelFrame(parent, text="NPC Transcript", padding=8)
        transcript_box.grid(row=2, column=0, sticky="nsew")
        transcript_box.rowconfigure(0, weight=1)
        transcript_box.columnconfigure(0, weight=1)
        self.sim_text = tk.Text(transcript_box, height=10, state=tk.DISABLED, wrap="word")
        self.sim_text.grid(row=0, column=0, sticky="nsew")

        options_box = ttk.LabelFrame(parent, text="Selectable Options", padding=8)
        options_box.grid(row=3, column=0, sticky="ew", pady=(8, 0))
        options_box.columnconfigure(0, weight=1)
        self.sim_options_frame = ttk.Frame(options_box)
        self.sim_options_frame.grid(row=0, column=0, sticky="ew")

    def _available_topics(self) -> list[DialogNode]:
        nodes_by_name = {node.topic: node for node in self.nodes}
        if self.sim_open_topics:
            candidates = [nodes_by_name[name] for name in self.sim_open_topics if name in nodes_by_name]
        else:
            candidates = [n for n in self.nodes if not n.is_bye]
        return [n for n in candidates if n.topic not in self.sim_removed_topics and self._condition_matches(n)]

    def _condition_matches(self, node: DialogNode) -> bool:
        expr = node.condition_expr.strip()
        if not expr:
            return True
        if "MET" in expr and not self.sim_met:
            return False
        flag_tokens = set(re.findall(r"[A-Z][A-Z0-9_]{1,}", expr)) - {"MET", "UI", "TRUE", "FALSE"}
        for token in flag_tokens:
            if token not in self.sim_selected_flags:
                return False
        return True

    def _record_sim_line(self, line: str) -> None:
        self.sim_transcript.append(line)

    def _refresh_simulator_ui(self) -> None:
        self.sim_text.configure(state=tk.NORMAL)
        self.sim_text.delete("1.0", tk.END)
        self.sim_text.insert("1.0", "\n".join(self.sim_transcript))
        self.sim_text.configure(state=tk.DISABLED)

        for child in self.sim_badges_frame.winfo_children():
            child.destroy()
        badges = [f"MET: {'yes' if self.sim_met else 'no'}"]
        if self.sim_selected_flags:
            badges.append("Flags: " + ", ".join(sorted(self.sim_selected_flags)))
        if self.sim_schedule:
            badges.append("Schedule: " + self.sim_schedule)
        for idx, badge in enumerate(badges):
            ttk.Label(self.sim_badges_frame, text=badge, style="Badge.TLabel").grid(row=0, column=idx, padx=(0, 6))

        for child in self.sim_options_frame.winfo_children():
            child.destroy()

        options = self._available_topics()
        for idx, node in enumerate(options):
            ttk.Button(
                self.sim_options_frame,
                text=node.topic,
                command=lambda n=node: self.select_sim_option(n),
            ).grid(row=idx // 3, column=idx % 3, padx=4, pady=4, sticky="ew")

        has_bye = any(node.is_bye for node in self.nodes)
        if not options and not self.sim_ended:
            if has_bye:
                self.sim_warning_var.set("Dead end: no available options from current state.")
            else:
                self.sim_warning_var.set("Dead end: no available options and no bye flow is defined.")
        elif not has_bye:
            self.sim_warning_var.set("Warning: no bye topic is defined, so conversations cannot terminate cleanly.")
        else:
            self.sim_warning_var.set("")

    def reset_simulator(self) -> None:
        self.sim_open_topics.clear()
        self.sim_removed_topics.clear()
        self.sim_selected_flags.clear()
        self.sim_schedule = ""
        self.sim_met = True
        self.sim_ended = False
        self.sim_transcript = [f"NPC: {self.first_line_var.get().strip() or '@...@'}"]
        self._refresh_simulator_ui()

    def select_sim_option(self, node: DialogNode) -> None:
        if self.sim_ended:
            return
        self._record_sim_line(f"Avatar: {node.topic}")

        if node.condition_expr and not self._condition_matches(node):
            for fail in node.fail_lines or ["@Not now.@"]:
                self._record_sim_line(f"NPC: {fail}")
            self._refresh_simulator_ui()
            return

        for line in node.lines or ["@blank@"]:
            self._record_sim_line(f"NPC: {line}")

        for opened in node.opens_topics:
            self.sim_open_topics.add(opened)

        self.sim_selected_flags.update(set(re.findall(r"[A-Z][A-Z0-9_]{1,}", node.condition_expr)))

        if node.remove_after_select:
            self.sim_removed_topics.add(node.topic)

        if node.is_bye:
            self.sim_ended = True
            self._record_sim_line("[Conversation ended]")

        self._refresh_simulator_ui()

    def _node_from_editor(self) -> DialogNode | None:
        topic = self.topic_var.get().strip()
        if not topic:
            messagebox.showerror("Missing topic", "Topic is required.")
            return None
        lines = [ln.strip() for ln in self.lines_text.get("1.0", tk.END).splitlines() if ln.strip()]
        opens = [v.strip() for v in self.opens_var.get().split(",") if v.strip()]
        fail_lines = [ln.strip() for ln in self.fail_lines_text.get("1.0", tk.END).splitlines() if ln.strip()]
        return DialogNode(
            topic=topic,
            lines=lines or (["@Goodbye!@"] if self.bye_var.get() else ["@blank@"]),
            opens_topics=opens,
            remove_after_select=self.remove_var.get(),
            is_bye=self.bye_var.get(),
            condition_expr=self.condition_var.get().strip(),
            fail_lines=fail_lines,
        )

    def add_topic(self) -> None:
        node = self._node_from_editor()
        if node is None:
            return
        self.nodes.append(node)
        self._refresh_tree(select_idx=len(self.nodes) - 1)

    def update_topic(self) -> None:
        sel = self.tree.selection()
        if not sel:
            return
        node = self._node_from_editor()
        if node is None:
            return
        self.nodes[int(sel[0])] = node
        self._refresh_tree(select_idx=int(sel[0]))

    def delete_topic(self) -> None:
        sel = self.tree.selection()
        if not sel:
            return
        del self.nodes[int(sel[0])]
        self._refresh_tree()

    def _refresh_tree(self, select_idx: int | None = None) -> None:
        for iid in self.tree.get_children():
            self.tree.delete(iid)
        self.table_list.delete(0, tk.END)
        for idx, node in enumerate(self.nodes):
            self.tree.insert("", "end", iid=str(idx), values=(node.topic, ", ".join(node.opens_topics), "Yes" if node.is_bye else "No"))
            self.table_list.insert(tk.END, f"{node.topic} -> [{', '.join(node.opens_topics)}]")

        if select_idx is not None and 0 <= select_idx < len(self.nodes):
            self.tree.selection_set(str(select_idx))
            self.tree.focus(str(select_idx))
            self.load_selected_topic()
        self.draw_graph()
        self._refresh_simulator_ui()

    def draw_graph(self) -> None:
        self.graph_canvas.delete("all")
        self.graph_item_to_index.clear()
        width = max(self.graph_canvas.winfo_width(), 600)
        start_x = 70
        end_x = width - 170
        y_gap = 60
        positions: dict[str, tuple[int, int]] = {}

        for idx, node in enumerate(self.nodes):
            x = start_x if idx % 2 == 0 else end_x
            y = 35 + idx * y_gap
            positions[node.topic] = (x, y)

        for node in self.nodes:
            x1, y1 = positions[node.topic]
            for target in node.opens_topics:
                if target in positions:
                    x2, y2 = positions[target]
                    self.graph_canvas.create_line(x1 + 70, y1 + 16, x2 + 70, y2 + 16, fill="#7c8798", arrow=tk.LAST)

        for idx, node in enumerate(self.nodes):
            x, y = positions[node.topic]
            fill = "#dbeafe" if not node.is_bye else "#fee2e2"
            rect = self.graph_canvas.create_rectangle(x, y, x + 145, y + 32, fill=fill, outline="#1f2937")
            text = self.graph_canvas.create_text(x + 72, y + 16, text=node.topic)
            self.graph_item_to_index[rect] = idx
            self.graph_item_to_index[text] = idx

    def on_graph_click(self, event: tk.Event) -> None:
        item = self.graph_canvas.find_closest(event.x, event.y)
        idx = self.graph_item_to_index.get(item[0]) if item else None
        if idx is None:
            return
        self.tree.selection_set(str(idx))
        self.tree.focus(str(idx))
        self.load_selected_topic()

    def load_selected_topic(self, _event: tk.Event | None = None) -> None:
        sel = self.tree.selection()
        if not sel:
            return
        node = self.nodes[int(sel[0])]
        self.topic_var.set(node.topic)
        self.lines_text.delete("1.0", tk.END)
        self.lines_text.insert("1.0", "\n".join(node.lines))
        self.opens_var.set(", ".join(node.opens_topics))
        self.remove_var.set(node.remove_after_select)
        self.bye_var.set(node.is_bye)
        self.condition_var.set(node.condition_expr)
        self.fail_lines_text.delete("1.0", tk.END)
        self.fail_lines_text.insert("1.0", "\n".join(node.fail_lines))

    def generate_preview(self) -> None:
        self.output.delete("1.0", tk.END)
        self.output.insert("1.0", self._build_usecode())

    def _render_case(self, node: DialogNode) -> str:
        if node.is_bye:
            return self._render_bye_case(node)
        remove = "(remove)" if node.remove_after_select else ""
        lines = "\n".join(f'\t\t\t\tsay("{self._esc(ln)}");' for ln in node.lines)
        add_line = ""
        if node.opens_topics:
            opens = ", ".join(f'"{self._esc(t)}"' for t in node.opens_topics)
            add_line = f"\n\t\t\t\tadd([{opens}]);"
        return f'\t\t\tcase "{self._esc(node.topic)}"{remove}:\n{lines}{add_line}\n\t\t\t\tbreak;\n'

    def _build_usecode(self) -> str:
        name = self.name_var.get().strip() or "Template"
        obj = self.object_var.get().strip() or "0x000"
        first_line = self.first_line_var.get().strip() or "Usually a description of the npc."

        options = [n.topic for n in self.nodes if not n.is_bye]
        if not any(n.is_bye for n in self.nodes):
            options.append("bye")
        options_literal = ", ".join(f'"{self._esc(t)}"' for t in options)

        case_blocks = [self._render_case(node) for node in self.nodes]
        if not any(n.is_bye for n in self.nodes):
            case_blocks.append(self._render_bye_case(None))

        cases = "\n".join(case_blocks)
        return f'''// Generated by npc_dialog_tool.py

void {name} object# ({obj}) ()
{{
\tif (event == DOUBLECLICK)
\t{{
\t\tif (!UI_get_item_flag(item, MET))
\t\t{{
\t\t\titem.say("{self._esc(first_line)}");
\t\t\tUI_set_item_flag(item, MET);
\t\t}}
\n\t\tvar options = [{options_literal}];
\t\tconverse(options)
\t\t{{
{cases}\t\t}}
\t}}
}}
'''

    def _render_bye_case(self, node: DialogNode | None) -> str:
        lines = [f'\t\t\t\tsay("{self._esc(ln)}");' for ln in (node.lines if node else ["@Goodbye!@"]) ]
        lines.append("\t\t\t\tbreak;")
        return '\t\t\tcase "bye":\n' + "\n".join(lines) + "\n"

    @staticmethod
    def _esc(text: str) -> str:
        return text.replace("\\", "\\\\").replace('"', '\\"')

    def save_project_as(self) -> None:
        path = filedialog.asksaveasfilename(defaultextension=".npcdlg", filetypes=[("NPC Dialog Project", "*.npcdlg")])
        if not path:
            return
        data = {
            "name": self.name_var.get(),
            "object_id": self.object_var.get(),
            "first_line": self.first_line_var.get(),
            "nodes": [node.to_dict() for node in self.nodes],
        }
        Path(path).write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    app = UsecodeDialogBuilder()
    app.mainloop()


if __name__ == "__main__":
    main()

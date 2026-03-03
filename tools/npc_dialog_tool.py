#!/usr/bin/env python3
"""NPC dialog editor with JSON project persistence and separate .uc export."""

from __future__ import annotations

from dataclasses import dataclass, field
import json
from pathlib import Path
import tkinter as tk
from tkinter import filedialog, messagebox
from typing import Any

PROJECT_EXTENSION = ".npcdlg"
PROJECT_FILE_TYPES = [
    ("NPC Dialog Project", f"*{PROJECT_EXTENSION}"),
    ("JSON files", "*.json"),
    ("All files", "*.*"),
]
UC_FILE_TYPES = [
    ("Usecode Files", "*.uc"),
    ("All files", "*.*"),
]
"""GUI tool for generating Ultima 7 NPC usecode dialog scaffolding."""

from __future__ import annotations

import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from dataclasses import dataclass, field


@dataclass
class DialogNode:
    """A single dialog node in the editor."""

    text: str = ""
    responses: list[str] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        return {
            "text": self.text,
            "responses": list(self.responses),
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> "DialogNode":
        responses = data.get("responses", [])
        if not isinstance(responses, list):
            responses = []

        return cls(
            text=str(data.get("text", "")),
            responses=[str(item) for item in responses],
        )


class NpcDialogTool(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.geometry("900x600")

        self.name_var = tk.StringVar()
        self.object_var = tk.StringVar()
        self.first_line_var = tk.StringVar()

        self.nodes: list[DialogNode] = []
        self.project_path: Path | None = None
        self._dirty = False
        self._updating_ui = False

        self._build_ui()
        self._bind_events()
        self.protocol("WM_DELETE_WINDOW", self.on_close)

        self.new_project(prompt=False)

    def _build_ui(self) -> None:
        menubar = tk.Menu(self)
        file_menu = tk.Menu(menubar, tearoff=False)
        file_menu.add_command(label="New Project", command=self.new_project)
        file_menu.add_command(label="Open Project...", command=self.open_project)
        file_menu.add_command(label="Save Project", command=self.save_project)
        file_menu.add_command(label="Save Project As...", command=self.save_project_as)
        file_menu.add_separator()
        file_menu.add_command(label="Export .uc...", command=self.export_uc)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.on_close)
        menubar.add_cascade(label="File", menu=file_menu)
        self.config(menu=menubar)

        top = tk.Frame(self)
        top.pack(fill=tk.X, padx=8, pady=8)

        project_buttons = tk.Frame(top)
        project_buttons.grid(row=0, column=0, columnspan=6, sticky="w", pady=(0, 8))
        tk.Button(project_buttons, text="New Project", command=self.new_project).pack(side=tk.LEFT)
        tk.Button(project_buttons, text="Open Project...", command=self.open_project).pack(
            side=tk.LEFT, padx=(6, 0)
        )
        tk.Button(project_buttons, text="Save Project", command=self.save_project).pack(
            side=tk.LEFT, padx=(6, 0)
        )
        tk.Button(project_buttons, text="Save Project As...", command=self.save_project_as).pack(
            side=tk.LEFT, padx=(6, 0)
        )
        tk.Button(project_buttons, text="Export .uc...", command=self.export_uc).pack(
            side=tk.LEFT, padx=(16, 0)
        )

        tk.Label(top, text="Name").grid(row=1, column=0, sticky="w")
        tk.Entry(top, textvariable=self.name_var).grid(row=1, column=1, sticky="ew", padx=(6, 10))
        tk.Label(top, text="Object").grid(row=1, column=2, sticky="w")
        tk.Entry(top, textvariable=self.object_var).grid(row=1, column=3, sticky="ew", padx=(6, 10))
        tk.Label(top, text="First line").grid(row=1, column=4, sticky="w")
        tk.Entry(top, textvariable=self.first_line_var).grid(
            row=1, column=5, sticky="ew", padx=(6, 0)
        )

        top.grid_columnconfigure(1, weight=1)
        top.grid_columnconfigure(3, weight=1)
        top.grid_columnconfigure(5, weight=2)

        body = tk.Frame(self)
        body.pack(fill=tk.BOTH, expand=True, padx=8, pady=(0, 8))

        self.node_list = tk.Listbox(body)
        self.node_list.pack(side=tk.LEFT, fill=tk.Y)

        buttons = tk.Frame(body)
        buttons.pack(side=tk.LEFT, fill=tk.Y, padx=8)
        tk.Button(buttons, text="Add Node", command=self.add_node).pack(fill=tk.X, pady=(0, 4))
        tk.Button(buttons, text="Remove Node", command=self.remove_selected_node).pack(fill=tk.X)

        editor = tk.Frame(body)
        editor.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        tk.Label(editor, text="Node Text").pack(anchor="w")
        self.node_text = tk.Text(editor, height=10)
        self.node_text.pack(fill=tk.BOTH, expand=True)

        tk.Label(editor, text="Responses (one per line)").pack(anchor="w", pady=(8, 0))
        self.responses_text = tk.Text(editor, height=8)
        self.responses_text.pack(fill=tk.BOTH, expand=True)

    def _bind_events(self) -> None:
        self.node_list.bind("<<ListboxSelect>>", self._on_select_node)
        self.node_text.bind("<KeyRelease>", lambda _event: self._on_node_editor_changed())
        self.responses_text.bind("<KeyRelease>", lambda _event: self._on_node_editor_changed())

        for var in (self.name_var, self.object_var, self.first_line_var):
            var.trace_add("write", lambda *_args: self._mark_dirty())

    def _set_dirty(self, value: bool) -> None:
        self._dirty = value
        self._update_title()

    def _mark_dirty(self) -> None:
        if self._updating_ui:
            return
        self._set_dirty(True)

    def _update_title(self) -> None:
        suffix = self.project_path.name if self.project_path else "Untitled"
        dirty = " *" if self._dirty else ""
        self.title(f"NPC Dialog Tool - {suffix}{dirty}")

    def _current_selection(self) -> int | None:
        selected = self.node_list.curselection()
        if not selected:
            return None
        return int(selected[0])

    def _refresh_node_list(self) -> None:
        self.node_list.delete(0, tk.END)
        for index, node in enumerate(self.nodes):
            title = node.text.strip().splitlines()[0] if node.text.strip() else "(empty)"
            self.node_list.insert(tk.END, f"{index + 1}. {title}")

    def _on_select_node(self, _event: tk.Event | None = None) -> None:
        index = self._current_selection()
        self._updating_ui = True
        try:
            self.node_text.delete("1.0", tk.END)
            self.responses_text.delete("1.0", tk.END)
            if index is None:
                return

            node = self.nodes[index]
            self.node_text.insert("1.0", node.text)
            self.responses_text.insert("1.0", "\n".join(node.responses))
        finally:
            self._updating_ui = False

    def _on_node_editor_changed(self) -> None:
        if self._updating_ui:
            return

        index = self._current_selection()
        if index is None:
            return

        node = self.nodes[index]
        node.text = self.node_text.get("1.0", tk.END).rstrip("\n")
        node.responses = [
            line.strip()
            for line in self.responses_text.get("1.0", tk.END).splitlines()
            if line.strip()
        ]
        self._refresh_node_list()
        self.node_list.selection_set(index)
        self._mark_dirty()

    def add_node(self) -> None:
        self.nodes.append(DialogNode(text="New node"))
        self._refresh_node_list()
        new_index = len(self.nodes) - 1
        self.node_list.selection_clear(0, tk.END)
        self.node_list.selection_set(new_index)
        self.node_list.see(new_index)
        self._on_select_node()
        self._mark_dirty()

    def remove_selected_node(self) -> None:
        index = self._current_selection()
        if index is None:
            return

        del self.nodes[index]
        self._refresh_node_list()
        if self.nodes:
            next_index = min(index, len(self.nodes) - 1)
            self.node_list.selection_set(next_index)
        self._on_select_node()
        self._mark_dirty()

    def to_dict(self) -> dict[str, Any]:
        return {
            "name_var": self.name_var.get(),
            "object_var": self.object_var.get(),
            "first_line_var": self.first_line_var.get(),
            "nodes": [node.to_dict() for node in self.nodes],
        }

    def load_dict(self, data: dict[str, Any]) -> None:
        nodes = data.get("nodes", [])
        if not isinstance(nodes, list):
            nodes = []

        # keep backwards compatibility with earlier key names
        name = data.get("name_var", data.get("name", ""))
        obj = data.get("object_var", data.get("object", ""))
        first = data.get("first_line_var", data.get("first_line", ""))

        self._updating_ui = True
        try:
            self.name_var.set(str(name))
            self.object_var.set(str(obj))
            self.first_line_var.set(str(first))
            self.nodes = [DialogNode.from_dict(item) for item in nodes if isinstance(item, dict)]
            self._refresh_node_list()
            self.node_list.selection_clear(0, tk.END)
            if self.nodes:
                self.node_list.selection_set(0)
            self._on_select_node()
        finally:
            self._updating_ui = False

    def _confirm_discard_changes(self) -> bool:
        if not self._dirty:
            return True

        result = messagebox.askyesnocancel(
            "Unsaved Changes",
            "You have unsaved changes. Save before continuing?",
            icon=messagebox.WARNING,
        )
        if result is None:
            return False
        if result:
            return self.save_project()
        return True

    def new_project(self, prompt: bool = True) -> None:
        if prompt and not self._confirm_discard_changes():
            return

        self.project_path = None
        self.load_dict({"name_var": "", "object_var": "", "first_line_var": "", "nodes": []})
        self._set_dirty(False)

    def open_project(self) -> None:
        if not self._confirm_discard_changes():
            return

        path = filedialog.askopenfilename(
            title="Open Project",
            filetypes=PROJECT_FILE_TYPES,
            defaultextension=PROJECT_EXTENSION,
        )
        if not path:
            return

        try:
            with open(path, "r", encoding="utf-8") as handle:
                data = json.load(handle)
            if not isinstance(data, dict):
                raise ValueError("Project file root must be a JSON object.")
        except (OSError, json.JSONDecodeError, ValueError) as exc:
            messagebox.showerror("Open Failed", f"Could not open project:\n{exc}")
            return

        self.project_path = Path(path)
        self.load_dict(data)
        self._set_dirty(False)

    def save_project(self) -> bool:
        if self.project_path is None:
            return self.save_project_as()

        try:
            with open(self.project_path, "w", encoding="utf-8") as handle:
                json.dump(self.to_dict(), handle, indent=2)
                handle.write("\n")
        except OSError as exc:
            messagebox.showerror("Save Failed", f"Could not save project:\n{exc}")
            return False

        self._set_dirty(False)
        return True

    def save_project_as(self) -> bool:
        path = filedialog.asksaveasfilename(
            title="Save Project As",
            filetypes=PROJECT_FILE_TYPES,
            defaultextension=PROJECT_EXTENSION,
        )
        if not path:
            return False

        save_path = Path(path)
        if save_path.suffix.lower() != PROJECT_EXTENSION:
            save_path = save_path.with_suffix(PROJECT_EXTENSION)

        if save_path.exists() and not messagebox.askyesno(
            "Overwrite File",
            f"{save_path.name} already exists. Overwrite it?",
            icon=messagebox.WARNING,
        ):
            return False

        self.project_path = save_path
        return self.save_project()

    def export_uc(self) -> None:
        path = filedialog.asksaveasfilename(
            title="Export Usecode",
            filetypes=UC_FILE_TYPES,
            defaultextension=".uc",
        )
        if not path:
            return

        export_path = Path(path)
        if export_path.suffix.lower() != ".uc":
            export_path = export_path.with_suffix(".uc")

        lines = [
            f"// NPC: {self.name_var.get()}",
            f"// Object: {self.object_var.get()}",
            f"// First line: {self.first_line_var.get()}",
            "",
        ]

        for i, node in enumerate(self.nodes):
            lines.append(f"// Node {i + 1}")
            lines.append(f"say(\"{node.text.replace('\"', '\\\"')}\");")
            for response in node.responses:
                lines.append(f"answer(\"{response.replace('\"', '\\\"')}\");")
            lines.append("")

        try:
            export_path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
        except OSError as exc:
            messagebox.showerror("Export Failed", f"Could not export .uc file:\n{exc}")
            return

        messagebox.showinfo("Export Complete", f"Exported to:\n{export_path}")

    def on_close(self) -> None:
        if not self._confirm_discard_changes():
            return
        self.destroy()


def main() -> None:
    app = NpcDialogTool()
    topic: str
    lines: list[str] = field(default_factory=list)
    opens_topics: list[str] = field(default_factory=list)
    remove_after_select: bool = True
    is_bye: bool = False


class UsecodeDialogBuilder(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Ultima 7 NPC Dialog Builder")
        self.geometry("1200x760")

        self.nodes: list[DialogNode] = []
        self._build_style()
        self._build_layout()

    def _build_style(self) -> None:
        style = ttk.Style(self)
        try:
            style.theme_use("clam")
        except tk.TclError:
            pass

        style.configure("Title.TLabel", font=("Segoe UI", 15, "bold"))
        style.configure("Hint.TLabel", foreground="#5b6b82")
        style.configure("Treeview", rowheight=26)

    def _build_layout(self) -> None:
        self.columnconfigure(0, weight=1)
        self.rowconfigure(1, weight=1)

        header = ttk.Frame(self, padding=(14, 12))
        header.grid(row=0, column=0, sticky="ew")
        header.columnconfigure(0, weight=1)

        ttk.Label(header, text="NPC Usecode Dialog Builder", style="Title.TLabel").grid(
            row=0, column=0, sticky="w"
        )
        ttk.Label(
            header,
            text="Build conversation topics with a mouse-driven editor and export working usecode.",
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
        self.lines_text = tk.Text(editor, height=6, wrap="word")
        self.lines_text.grid(row=1, column=1, sticky="ew", pady=3)

        ttk.Label(editor, text="Opens topics (comma-separated):").grid(row=2, column=0, sticky="w", padx=(0, 8), pady=3)
        self.opens_var = tk.StringVar()
        ttk.Entry(editor, textvariable=self.opens_var).grid(row=2, column=1, sticky="ew", pady=3)

        self.remove_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(editor, text="Remove topic after selecting", variable=self.remove_var).grid(
            row=3, column=1, sticky="w", pady=2
        )

        self.bye_var = tk.BooleanVar(value=False)
        ttk.Checkbutton(editor, text="This topic is the goodbye branch", variable=self.bye_var).grid(
            row=4, column=1, sticky="w", pady=2
        )

        btns = ttk.Frame(editor)
        btns.grid(row=5, column=1, sticky="e", pady=(8, 0))
        ttk.Button(btns, text="Add Topic", command=self.add_topic).grid(row=0, column=0, padx=4)
        ttk.Button(btns, text="Update Selected", command=self.update_topic).grid(row=0, column=1, padx=4)
        ttk.Button(btns, text="Delete Selected", command=self.delete_topic).grid(row=0, column=2, padx=4)

        tree_box = ttk.LabelFrame(parent, text="Dialog Tree", padding=8)
        tree_box.grid(row=2, column=0, sticky="nsew")
        tree_box.rowconfigure(0, weight=1)
        tree_box.columnconfigure(0, weight=1)

        self.tree = ttk.Treeview(
            tree_box,
            columns=("topic", "opens", "bye"),
            show="headings",
            selectmode="browse",
        )
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
        parent.rowconfigure(1, weight=1)
        parent.columnconfigure(0, weight=1)

        controls = ttk.Frame(parent)
        controls.grid(row=0, column=0, sticky="ew", pady=(0, 8))
        controls.columnconfigure(0, weight=1)

        ttk.Button(controls, text="Generate Usecode", command=self.generate_preview).grid(row=0, column=1, padx=4)
        ttk.Button(controls, text="Copy", command=self.copy_output).grid(row=0, column=2, padx=4)
        ttk.Button(controls, text="Save .uc", command=self.save_output).grid(row=0, column=3, padx=4)

        preview_box = ttk.LabelFrame(parent, text="Generated Usecode", padding=8)
        preview_box.grid(row=1, column=0, sticky="nsew")
        preview_box.rowconfigure(0, weight=1)
        preview_box.columnconfigure(0, weight=1)

        self.output = tk.Text(preview_box, wrap="none")
        self.output.grid(row=0, column=0, sticky="nsew")

        ys = ttk.Scrollbar(preview_box, orient="vertical", command=self.output.yview)
        xs = ttk.Scrollbar(preview_box, orient="horizontal", command=self.output.xview)
        self.output.configure(yscroll=ys.set, xscroll=xs.set)
        ys.grid(row=0, column=1, sticky="ns")
        xs.grid(row=1, column=0, sticky="ew")

    def _project_data(self) -> dict:
        return {
            "name": self.name_var.get().strip(),
            "object_id": self.object_var.get().strip(),
            "first_line": self.first_line_var.get().strip(),
            "already_met_line": self.already_met_var.get().strip(),
            "features": {
                "include_met": self.include_met_var.get(),
                "include_already_met": self.include_already_met_var.get(),
                "include_schedule": self.include_schedule_var.get(),
                "include_gender": self.include_gender_var.get(),
                "include_party_greeting": self.include_party_greeting_var.get(),
                "include_flag": self.include_flag_var.get(),
                "flag_name": self.flag_name_var.get().strip(),
                "export_comments": self.export_comments_var.get(),
            },
            "nodes": [n.to_dict() for n in self.nodes],
        }

    def _load_project_data(self, data: dict) -> None:
        self.name_var.set(data.get("name", "Template"))
        self.object_var.set(data.get("object_id", "0x000"))
        self.first_line_var.set(data.get("first_line", "Usually a description of the npc."))
        self.already_met_var.set(data.get("already_met_line", "@already met dialogue@"))
        features = data.get("features", {})
        self.include_met_var.set(bool(features.get("include_met", True)))
        self.include_already_met_var.set(bool(features.get("include_already_met", True)))
        self.include_schedule_var.set(bool(features.get("include_schedule", False)))
        self.include_gender_var.set(bool(features.get("include_gender", False)))
        self.include_party_greeting_var.set(bool(features.get("include_party_greeting", True)))
        self.include_flag_var.set(bool(features.get("include_flag", False)))
        self.flag_name_var.set(str(features.get("flag_name", "SI_ZOMBIE")))
        self.export_comments_var.set(bool(features.get("export_comments", False)))
        self.nodes = [DialogNode.from_dict(n) for n in data.get("nodes", [])]
        self._refresh_tree()
        self._clear_editor()
        self.generate_preview()

    def confirm_discard_if_dirty(self) -> bool:
        if not self.dirty:
            return True
        return messagebox.askyesno("Unsaved Changes", "You have unsaved changes. Continue and discard them?")

    def new_project(self) -> None:
        if not self.confirm_discard_if_dirty():
            return
        self.current_project_path = None
        self._load_project_data({})
        self._set_dirty(False)

    def open_project(self) -> None:
        if not self.confirm_discard_if_dirty():
            return
        path = filedialog.askopenfilename(filetypes=[("NPC Dialog Project", "*.npcdlg"), ("JSON", "*.json"), ("All", "*.*")])
        if not path:
            return
        with open(path, "r", encoding="utf-8") as fp:
            data = json.load(fp)
        self._load_project_data(data)
        self.current_project_path = path
        self._set_dirty(False)

    def save_project(self) -> None:
        if not self.current_project_path:
            self.save_project_as()
            return
        with open(self.current_project_path, "w", encoding="utf-8") as fp:
            json.dump(self._project_data(), fp, indent=2)
        self._set_dirty(False)

    def save_project_as(self) -> None:
        path = filedialog.asksaveasfilename(
            defaultextension=".npcdlg",
            filetypes=[("NPC Dialog Project", "*.npcdlg"), ("JSON", "*.json"), ("All", "*.*")],
        )
        if not path:
            return
        self.current_project_path = path
        self.save_project()

    def import_uc(self) -> None:
        if not self.confirm_discard_if_dirty():
            return
        path = filedialog.askopenfilename(filetypes=[("Usecode", "*.uc"), ("Text", "*.txt"), ("All", "*.*")])
        if not path:
            return
        text = Path(path).read_text(encoding="utf-8")

        header = re.search(r"void\s+(\w+)\s+object#\s*\((0x[0-9A-Fa-f]+)\)", text)
        if header:
            self.name_var.set(header.group(1))
            self.object_var.set(header.group(2))

        self.nodes = []
        report = []

        options_match = re.search(r"var\s+options\s*=\s*\[(.*?)\];", text, re.S)
        options = []
        if options_match:
            options = [o.strip().strip('"') for o in options_match.group(1).split(",") if o.strip()]

        case_pattern = re.compile(r'case\s+"([^"]+)"(\(remove\))?:\s*(.*?)(?=\n\s*case\s+"|\n\s*\}\s*\n\s*\}|\Z)', re.S)
        for m in case_pattern.finditer(text):
            topic, remove_tag, body = m.group(1), bool(m.group(2)), m.group(3)
            lines = [self._unquote(s) for s in re.findall(r'say\("((?:\\.|[^"\\])*)"\);', body)]
            add_match = re.search(r"add\(\[(.*?)\]\);", body, re.S)
            opens = []
            if add_match:
                opens = [v.strip().strip('"') for v in add_match.group(1).split(",") if v.strip()]
            cond_match = re.search(r"if\s*\((.*?)\)\s*\{", body, re.S)
            condition = cond_match.group(1).strip() if cond_match else ""
            is_bye = topic == "bye"
            self.nodes.append(
                DialogNode(
                    topic=topic,
                    lines=lines or (["@Goodbye!@"] if is_bye else ["@blank@"]),
                    opens_topics=opens,
                    remove_after_select=remove_tag,
                    is_bye=is_bye,
                    condition_expr=condition,
                    fail_lines=[],
                )
            )

        if options and not self.nodes:
            report.append("Found options but no parseable case blocks.")
        if not self.nodes:
            report.append("No conversation cases imported. The source may use advanced patterns.")

        self._refresh_tree()
        self.generate_preview()
        self._set_dirty(True)
        msg = "Imported .uc into editable topics."
        if report:
            msg += "\n\nNotes:\n- " + "\n- ".join(report)
        messagebox.showinfo("Import complete", msg)

    @staticmethod
    def _unquote(text: str) -> str:
        return text.replace('\\"', '"').replace("\\\\", "\\")

    def add_topic(self) -> None:
        node = self._node_from_editor()
        if node is None:
            return
        self.nodes.append(node)
        self._refresh_tree(select_idx=len(self.nodes) - 1)
        self._set_dirty(True)
        self._refresh_tree()
        self._clear_editor()

    def update_topic(self) -> None:
        sel = self.tree.selection()
        if not sel:
            messagebox.showinfo("No selection", "Select a topic to update.")
            return
        node = self._node_from_editor()
        if node is None:
            return
        idx = int(sel[0])
        self.nodes[idx] = node
        self._refresh_tree(select_idx=idx)
        self._set_dirty(True)
        idx = int(sel[0])
        node = self._node_from_editor()
        if node is None:
            return
        self.nodes[idx] = node
        self._refresh_tree(select_idx=idx)

    def delete_topic(self) -> None:
        sel = self.tree.selection()
        if not sel:
            return
        idx = int(sel[0])
        del self.nodes[idx]
        self._refresh_tree()
        self._clear_editor()
        self._set_dirty(True)

    def duplicate_topic(self) -> None:
        sel = self.tree.selection()
        if not sel:
            messagebox.showinfo("No selection", "Select a topic to duplicate.")
            return
        idx = int(sel[0])
        node = self.nodes[idx]
        copy_node = DialogNode.from_dict(node.to_dict())
        copy_node.topic = f"{copy_node.topic}_copy"
        self.nodes.insert(idx + 1, copy_node)
        self._refresh_tree(select_idx=idx + 1)
        self._set_dirty(True)

    def move_topic(self, direction: int) -> None:
        sel = self.tree.selection()
        if not sel:
            return
        idx = int(sel[0])
        new_idx = idx + direction
        if new_idx < 0 or new_idx >= len(self.nodes):
            return
        self.nodes[idx], self.nodes[new_idx] = self.nodes[new_idx], self.nodes[idx]
        self._refresh_tree(select_idx=new_idx)
        self._set_dirty(True)

    def apply_quick_template(self) -> None:
        choice = self.quick_template_var.get().strip()
        if choice == "Basic info topic":
            self.topic_var.set("name")
            self.lines_text.delete("1.0", tk.END)
            self.lines_text.insert("1.0", "@I am a humble citizen of Britannia.@")
            self.opens_var.set("")
            self.condition_var.set("")
            self.fail_lines_text.delete("1.0", tk.END)
            self.bye_var.set(False)
            self.remove_var.set(True)
        elif choice == "Rumor opener topic":
            self.topic_var.set("rumor")
            self.lines_text.delete("1.0", tk.END)
            self.lines_text.insert("1.0", "@I heard something strange near the old crypt.@")
            self.opens_var.set("crypt")
            self.condition_var.set("")
            self.fail_lines_text.delete("1.0", tk.END)
            self.bye_var.set(False)
            self.remove_var.set(True)
        elif choice == "Gated quest topic":
            self.topic_var.set("quest")
            self.lines_text.delete("1.0", tk.END)
            self.lines_text.insert("1.0", "@You have proven yourself. I trust you now.@")
            self.opens_var.set("reward")
            self.condition_var.set("UI_get_item_flag(item, MET)")
            self.fail_lines_text.delete("1.0", tk.END)
            self.fail_lines_text.insert("1.0", "@Not yet. Return when we know each other better.@")
            self.bye_var.set(False)
            self.remove_var.set(False)
        elif choice == "Goodbye topic":
            self.topic_var.set("bye")
            self.lines_text.delete("1.0", tk.END)
            self.lines_text.insert("1.0", "@Goodbye!@")
            self.opens_var.set("")
            self.condition_var.set("")
            self.fail_lines_text.delete("1.0", tk.END)
            self.bye_var.set(True)
            self.remove_var.set(False)

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
        self.update_explanation(node)

    def update_explanation(self, node: DialogNode | None) -> None:
        self.explain.delete("1.0", tk.END)
        topics = len(self.nodes)
        summary = [
            f"This NPC has {topics} topic(s).",
            "Generated code includes a converse(options) block with one case per topic.",
        ]
        if self.include_met_var.get():
            summary.append("The first-time MET branch is enabled.")
        if self.include_already_met_var.get():
            summary.append("The already-met branch is enabled.")
        if self.include_schedule_var.get():
            summary.append("Schedule variable scaffold is included for schedule-based lines.")
        if self.include_gender_var.get():
            summary.append("Player gender branch scaffold is included.")
        if node:
            summary.append(f"Selected topic: '{node.topic}'.")
            if node.condition_expr:
                summary.append(f"This topic is gated by condition: {node.condition_expr}")
            if node.opens_topics:
                summary.append("This topic unlocks: " + ", ".join(node.opens_topics))
        self.explain.insert("1.0", "\n".join(summary))

    def generate_preview(self) -> None:
        code = self._build_usecode()
        self.output.delete("1.0", tk.END)
        self.output.insert("1.0", code)

    def copy_output(self) -> None:
        code = self.output.get("1.0", tk.END).strip()
        if not code:
            self.generate_preview()
            code = self.output.get("1.0", tk.END).strip()
        self.clipboard_clear()
        self.clipboard_append(code)
        messagebox.showinfo("Copied", "Generated usecode copied to clipboard.")

    def save_output(self) -> None:
        code = self.output.get("1.0", tk.END).strip()
        if not code:
            self.generate_preview()
            code = self.output.get("1.0", tk.END).strip()
        if not code:
            return
        path = filedialog.asksaveasfilename(
            defaultextension=".uc",
            filetypes=[("Usecode", "*.uc"), ("Text", "*.txt"), ("All", "*.*")],
        )
        if not path:
            return
        with open(path, "w", encoding="utf-8") as fp:
            fp.write(code + "\n")
        messagebox.showinfo("Saved", f"Wrote usecode to:\n{path}")

    def _node_from_editor(self) -> DialogNode | None:
        topic = self.topic_var.get().strip()
        if not topic:
            messagebox.showerror("Missing topic", "Topic is required.")
            return None
        lines = [ln.strip() for ln in self.lines_text.get("1.0", tk.END).splitlines() if ln.strip()]
        if not lines and not self.bye_var.get():
            lines = ["@blank@"]
        opens = [v.strip() for v in self.opens_var.get().split(",") if v.strip()]
        fail_lines = [ln.strip() for ln in self.fail_lines_text.get("1.0", tk.END).splitlines() if ln.strip()]
        return DialogNode(
            topic=topic,
            lines=lines,
            opens_topics=opens,
            remove_after_select=self.remove_var.get(),
            is_bye=self.bye_var.get(),
            condition_expr=self.condition_var.get().strip(),
            fail_lines=fail_lines,
        )

    def _refresh_tree(self, select_idx: int | None = None) -> None:
        for iid in self.tree.get_children():
            self.tree.delete(iid)
        for idx, node in enumerate(self.nodes):
            self.tree.insert(
                "",
                "end",
                iid=str(idx),
                values=(node.topic, ", ".join(node.opens_topics), node.condition_expr, "Yes" if node.is_bye else "No"),
                values=(node.topic, ", ".join(node.opens_topics), "Yes" if node.is_bye else "No"),
            )
        if select_idx is not None and 0 <= select_idx < len(self.nodes):
            self.tree.selection_set(str(select_idx))
            self.tree.focus(str(select_idx))
            self.load_selected_topic()
        self.draw_graph()

    def draw_graph(self) -> None:
        self.graph_canvas.delete("all")
        self.graph_item_to_index.clear()
        width = max(self.graph_canvas.winfo_width(), 600)
        start_x = 70
        end_x = width - 120
        y_gap = 65
        positions: dict[str, tuple[int, int]] = {}

        for idx, node in enumerate(self.nodes):
            x = start_x if idx % 2 == 0 else end_x
            y = 40 + idx * y_gap
            positions[node.topic] = (x, y)

        for node in self.nodes:
            if node.topic not in positions:
                continue
            x1, y1 = positions[node.topic]
            for target in node.opens_topics:
                if target in positions:
                    x2, y2 = positions[target]
                    self.graph_canvas.create_line(x1 + 70, y1 + 16, x2 + 70, y2 + 16, fill="#7c8798", arrow=tk.LAST)
                else:
                    self.graph_canvas.create_text(x1 + 170, y1 - 8, text=f"missing: {target}", fill="#b42318", anchor="w")

        for idx, node in enumerate(self.nodes):
            x, y = positions[node.topic]
            fill = "#dbeafe" if not node.is_bye else "#fee2e2"
            rect = self.graph_canvas.create_rectangle(x, y, x + 145, y + 32, fill=fill, outline="#1f2937")
            text = self.graph_canvas.create_text(x + 72, y + 16, text=node.topic)
            self.graph_item_to_index[rect] = idx
            self.graph_item_to_index[text] = idx

    def on_graph_click(self, event: tk.Event) -> None:
        item = self.graph_canvas.find_closest(event.x, event.y)
        if not item:
            return
        idx = self.graph_item_to_index.get(item[0])
        if idx is None:
            return
        self.tree.selection_set(str(idx))
        self.tree.focus(str(idx))
        self.load_selected_topic()

    def _clear_editor(self) -> None:
        self.topic_var.set("")
        self.lines_text.delete("1.0", tk.END)
        self.opens_var.set("")
        self.remove_var.set(True)
        self.bye_var.set(False)
        self.condition_var.set("")
        self.fail_lines_text.delete("1.0", tk.END)

    def validate_project(self) -> list[tuple[str, str]]:
        issues: list[tuple[str, str]] = []
        if not re.fullmatch(r"[A-Za-z_]\w*", self.name_var.get().strip() or ""):
            issues.append(("ERROR", "Function name must be a valid identifier (letters/numbers/_)."))
        if not re.fullmatch(r"0x[0-9A-Fa-f]+", self.object_var.get().strip() or ""):
            issues.append(("ERROR", "Object id should be hex like 0x123."))

        names = [n.topic for n in self.nodes]
        duplicates = sorted({n for n in names if names.count(n) > 1})
        if duplicates:
            issues.append(("ERROR", "Duplicate topic names: " + ", ".join(duplicates)))

        bye_count = sum(1 for n in self.nodes if n.is_bye)
        if bye_count > 1:
            issues.append(("ERROR", "Only one goodbye topic should be marked as bye."))
        if bye_count == 0 and "bye" not in names:
            issues.append(("WARN", "No custom goodbye topic; a default bye case will be generated."))

        name_set = set(names)
        for node in self.nodes:
            for target in node.opens_topics:
                if target not in name_set:
                    issues.append(("WARN", f"Topic '{node.topic}' opens missing topic '{target}'."))
            if node.condition_expr and "(" in node.condition_expr and ")" not in node.condition_expr:
                issues.append(("WARN", f"Topic '{node.topic}' condition may be malformed."))
            if node.is_bye and node.remove_after_select:
                issues.append(("WARN", f"Topic '{node.topic}' is bye and remove-after-select is unnecessary."))

        if not issues:
            issues.append(("OK", "No validation issues detected."))
        return issues

    def refresh_validation(self) -> None:
        issues = self.validate_project()
        self.validation_list.delete(0, tk.END)
        for level, text in issues:
            self.validation_list.insert(tk.END, f"[{level}] {text}")

    def generate_preview(self) -> None:
        issues = self.validate_project()
        errors = [msg for lvl, msg in issues if lvl == "ERROR"]
        if errors:
            self.refresh_validation()
            messagebox.showerror("Validation failed", "Cannot generate due to errors:\n\n- " + "\n- ".join(errors))
            return
        warnings = [msg for lvl, msg in issues if lvl == "WARN"]
        if warnings:
            if not messagebox.askyesno("Warnings", "Project has warnings. Generate anyway?\n\n- " + "\n- ".join(warnings)):
                return

        code = self._build_usecode(with_comments=self.export_comments_var.get())
        self.output.delete("1.0", tk.END)
        self.output.insert("1.0", code)
        selected = None
        sel = self.tree.selection()
        if sel:
            selected = self.nodes[int(sel[0])]
        self.update_explanation(selected)

    def copy_output(self) -> None:
        code = self.output.get("1.0", tk.END).strip()
        if not code:
            self.generate_preview()
            code = self.output.get("1.0", tk.END).strip()
        if not code:
            return
        self.clipboard_clear()
        self.clipboard_append(code)
        messagebox.showinfo("Copied", "Generated usecode copied to clipboard.")

    def save_output(self) -> None:
        code = self.output.get("1.0", tk.END).strip()
        if not code:
            self.generate_preview()
            code = self.output.get("1.0", tk.END).strip()
        if not code:
            return
        path = filedialog.asksaveasfilename(
            defaultextension=".uc",
            filetypes=[("Usecode", "*.uc"), ("Text", "*.txt"), ("All", "*.*")],
        )
        if not path:
            return
        with open(path, "w", encoding="utf-8") as fp:
            fp.write(code + "\n")
        messagebox.showinfo("Saved", f"Wrote usecode to:\n{path}")

    def _render_case(self, node: DialogNode) -> str:
        remove = "(remove)" if node.remove_after_select else ""
        if node.is_bye:
            return self._render_bye_case(node)

        lines = "\n".join(f'\t\t\t\tsay("{self._esc(ln)}");' for ln in node.lines)
        add_line = ""
        if node.opens_topics:
            opens = ", ".join(f'"{self._esc(t)}"' for t in node.opens_topics)
            add_line = f"\n\t\t\t\tadd([{opens}]);"

        if node.condition_expr:
            fail_lines = node.fail_lines or ["@Not now.@"]
            fail_render = "\n".join(f'\t\t\t\t\tsay("{self._esc(ln)}");' for ln in fail_lines)
            body = (
                f"\t\t\t\tif ({node.condition_expr})\n"
                "\t\t\t\t{\n"
                f"{lines}{add_line}\n"
                "\t\t\t\t}\n"
                "\t\t\t\telse\n"
                "\t\t\t\t{\n"
                f"{fail_render}\n"
                "\t\t\t\t}\n"
            )
        else:
            body = f"{lines}{add_line}\n"

        return f'\t\t\tcase "{self._esc(node.topic)}"{remove}:\n{body}'

    def _build_usecode(self, with_comments: bool = False) -> str:
        name = self.name_var.get().strip() or "Template"
        obj = self.object_var.get().strip() or "0x000"
        first_line = self.first_line_var.get().strip() or "Usually a description of the npc."
        already_met = self.already_met_var.get().strip() or "@already met dialogue@"

        options = [n.topic for n in self.nodes if not n.is_bye]
        if not any(n.is_bye for n in self.nodes):
            options.append("bye")
        options_literal = ", ".join(f'"{self._esc(t)}"' for t in options)

        case_blocks = [self._render_case(node) for node in self.nodes]
        if not any(n.is_bye for n in self.nodes):
            case_blocks.append(self._render_bye_case(None))
        cases = "\n".join(case_blocks).rstrip()

        comments = {
            "vars": "\t// Core dialog variables\n" if with_comments else "",
            "gender": "\t// Optional branch for player gender-based dialog\n" if with_comments else "",
            "party": "\t// Optional plural/singular greeting helper\n" if with_comments else "",
            "met": "\t\t// First-time meeting branch\n" if with_comments else "",
            "main": "\t\t// Main conversation switch\n" if with_comments else "",
        }

        extra = []
        if self.include_schedule_var.get():
            extra.extend([
                "\tvar schedule = UI_get_schedule_type(item);",
                "\tvar current_schedule = schedule;",
            ])
        if self.include_flag_var.get():
            flag_name = self.flag_name_var.get().strip() or "SI_ZOMBIE"
            extra.append(f"\tvar example = UI_get_item_flag(item, {flag_name});")

        greeting_block = ""
        if self.include_party_greeting_var.get():
            greeting_block = (
                f"{comments['party']}"
                "\tif (partynum > 1)\n"
                '\t\tgreeting = "friends";\n'
                "\telse\n"
                '\t\tgreeting = "friend";\n'
            )

        gender_block = ""
        if self.include_gender_var.get():
            gender_block = (
                f"{comments['gender']}"
                "\tif (player_is_female)\n"
                "\t{\n"
                "\t\t// female-specific setup\n"
                "\t}\n"
                "\telse\n"
                "\t{\n"
                "\t\t// male-specific setup\n"
                "\t}\n"
            )

        met_block = ""
        if self.include_met_var.get():
            already_met_stmt = (
                f'\t\telse\n\t\t\titem.say("{self._esc(already_met)}");\n'
                if self.include_already_met_var.get()
                else ""
            )
            met_block = (
                f"{comments['met']}"
                "\t\tif (!UI_get_item_flag(item, MET))\n"
                "\t\t{\n"
                f'\t\t\titem.say("{self._esc(first_line)}");\n'
                '\t\t\titem.say("@Initial conversation greetings, add more as necessary.@");\n'
                "\t\t\tUI_set_item_flag(item, MET);\n"
                "\t\t}\n"
                f"{already_met_stmt}"
            )
        elif self.include_already_met_var.get():
            met_block = f'\t\titem.say("{self._esc(already_met)}");\n'

    def _build_usecode(self) -> str:
        name = self.name_var.get().strip() or "Template"
        obj = self.object_var.get().strip() or "0x000"
        first_line = self.first_line_var.get().strip() or "Usually a description of the npc."

        options = [node.topic for node in self.nodes if not node.is_bye]
        if not any(n.is_bye for n in self.nodes):
            options.append("bye")

        options_literal = ", ".join(f'"{self._esc(t)}"' for t in options)

        case_blocks: list[str] = []
        for node in self.nodes:
            if node.is_bye:
                case_blocks.append(self._render_bye_case(node))
                continue
            remove = "(remove)" if node.remove_after_select else ""
            lines = "\n".join(f'\t\t\t\tsay("{self._esc(ln)}");' for ln in node.lines)
            add_line = ""
            if node.opens_topics:
                opens = ", ".join(f'"{self._esc(t)}"' for t in node.opens_topics)
                add_line = f"\n\t\t\t\tadd([{opens}]);"
            case_blocks.append(
                f'\t\t\tcase "{self._esc(node.topic)}"{remove}:\n{lines}{add_line}\n'
            )

        if not any(n.is_bye for n in self.nodes):
            case_blocks.append(self._render_bye_case(None))

        cases = "\n".join(case_blocks).rstrip()

        return f'''// Generated by npc_dialog_tool.py

void {name} object# ({obj}) ()
{{
{comments['vars']}\tvar party = UI_get_party_list();
\tvar party = UI_get_party_list();
\tvar player_name = getAvatarName();
\tvar polite_title = getPoliteTitle();
\tvar hour = UI_game_hour();
\tvar partynum = UI_get_array_size(party);
\tvar bark;
\tvar player_is_female = UI_is_pc_female();
\tvar greeting;
\tvar avatar_bark;
\tvar npc_bark;
\tvar time_of_day = timeFunction(hour);
{chr(10).join(extra) + chr(10) if extra else ''}\tvar av_1st_greet;
\tvar schedule = UI_get_schedule_type(item);
\tvar current_schedule = schedule;

\tvar av_1st_greet;
\tvar npc_1st_greet;
\tvar av_2nd_greet;
\tvar npc_2nd_greet;
\tvar avatar_goodbye;
\tvar npc_goodbye;
\tvar started_talking = UI_get_item_flag(item, READ);

{gender_block}{greeting_block}\tif (event == DOUBLECLICK)

\tvar started_talking = UI_get_item_flag(item, READ);

\tif (partynum > 1)
\t\tgreeting = "friends";
\telse
\t\tgreeting = "friend";

\tif (event == DOUBLECLICK)
\t{{
\t\tav_1st_greet = "@Avatar Opening bark.@";
\t\tnpc_1st_greet = "@NPC opening bark@";
\t\tav_2nd_greet = "@Avatar 2nd greeting bark@";
\t\tnpc_2nd_greet = "@NPC 2nd greeting bark@";
\t\tstartConvo(item, av_1st_greet, npc_1st_greet, av_2nd_greet, npc_2nd_greet);
\t}}

\tif (started_talking)
\t{{
\t\tUI_run_schedule(item);
{met_block}
\t\tvar options = [{options_literal}];

{comments['main']}\t\tconverse(options)

\t\tif (!UI_get_item_flag(item, MET))
\t\t{{
\t\t\titem.say("{self._esc(first_line)}");
\t\t\titem.say("@Initial conversation greetings, add more as necessary.@");
\t\t\tUI_set_item_flag(item, MET);
\t\t}}
\t\telse
\t\t\titem.say("@already met dialogue@");

\t\tvar options = [{options_literal}];

\t\tconverse(options)
\t\t{{
{cases}
\t\t}}
\t}}
}}
'''

    def _render_bye_case(self, node: DialogNode | None) -> str:
        lines = []
        if node and node.lines:
            lines.extend(f'\t\t\t\tsay("{self._esc(ln)}");' for ln in node.lines)
            lines.extend([f'\t\t\t\tsay("{self._esc(ln)}");' for ln in node.lines])
        else:
            lines.append('\t\t\t\tsay("@Goodbye!@");')
        lines.extend(
            [
                '\t\t\t\tavatar_goodbye = "@avatar goodbye bark@";',
                '\t\t\t\tnpc_goodbye = "@npc goodbye bark@";',
                "\t\t\t\tsayGoodbye(item, npc_goodbye, avatar_goodbye);",
                "\t\t\t\tbreak;",
            ]
        )
        return '\t\t\tcase "bye":\n' + "\n".join(lines) + "\n"

    @staticmethod
    def _esc(text: str) -> str:
        return text.replace("\\", "\\\\").replace('"', '\\"')

    def on_close(self) -> None:
        if not self.confirm_discard_if_dirty():
            return
        self.destroy()


def main() -> None:
    app = UsecodeDialogBuilder()
    app.mainloop()


if __name__ == "__main__":
    main()

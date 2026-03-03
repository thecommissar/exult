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
    app.mainloop()


if __name__ == "__main__":
    main()

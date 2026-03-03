#!/usr/bin/env python3
"""GUI tool for generating Ultima 7 NPC usecode dialog scaffolding."""

from __future__ import annotations

import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from dataclasses import dataclass, field


@dataclass
class DialogNode:
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

    def add_topic(self) -> None:
        node = self._node_from_editor()
        if node is None:
            return
        self.nodes.append(node)
        self._refresh_tree()
        self._clear_editor()

    def update_topic(self) -> None:
        sel = self.tree.selection()
        if not sel:
            messagebox.showinfo("No selection", "Select a topic to update.")
            return
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
        return DialogNode(
            topic=topic,
            lines=lines,
            opens_topics=opens,
            remove_after_select=self.remove_var.get(),
            is_bye=self.bye_var.get(),
        )

    def _refresh_tree(self, select_idx: int | None = None) -> None:
        for iid in self.tree.get_children():
            self.tree.delete(iid)
        for idx, node in enumerate(self.nodes):
            self.tree.insert(
                "",
                "end",
                iid=str(idx),
                values=(node.topic, ", ".join(node.opens_topics), "Yes" if node.is_bye else "No"),
            )
        if select_idx is not None and 0 <= select_idx < len(self.nodes):
            self.tree.selection_set(str(select_idx))
            self.tree.focus(str(select_idx))

    def _clear_editor(self) -> None:
        self.topic_var.set("")
        self.lines_text.delete("1.0", tk.END)
        self.opens_var.set("")
        self.remove_var.set(True)
        self.bye_var.set(False)

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
\tvar schedule = UI_get_schedule_type(item);
\tvar current_schedule = schedule;

\tvar av_1st_greet;
\tvar npc_1st_greet;
\tvar av_2nd_greet;
\tvar npc_2nd_greet;
\tvar avatar_goodbye;
\tvar npc_goodbye;

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


def main() -> None:
    app = UsecodeDialogBuilder()
    app.mainloop()


if __name__ == "__main__":
    main()

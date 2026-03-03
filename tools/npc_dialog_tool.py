"""NPC dialog authoring helper for Ultima VII usecode snippets.

This utility provides a topic tree, generated usecode preview, and a structure
explanation panel that describes generated blocks in plain language.
"""

from __future__ import annotations

import tkinter as tk
from tkinter import filedialog, messagebox, ttk


class ToolTip:
    """Small hover tooltip helper for Tk widgets."""

    def __init__(self, widget: tk.Widget, text: str) -> None:
        self.widget = widget
        self.text = text
        self.tip_window: tk.Toplevel | None = None
        widget.bind("<Enter>", self._show, add="+")
        widget.bind("<Leave>", self._hide, add="+")

    def _show(self, _event: tk.Event) -> None:
        if self.tip_window:
            return
        x = self.widget.winfo_rootx() + 18
        y = self.widget.winfo_rooty() + 20
        self.tip_window = tk.Toplevel(self.widget)
        self.tip_window.wm_overrideredirect(True)
        self.tip_window.geometry(f"+{x}+{y}")
        label = tk.Label(
            self.tip_window,
            text=self.text,
            justify="left",
            background="#fff8dc",
            relief="solid",
            borderwidth=1,
            wraplength=340,
            padx=7,
            pady=5,
        )
        label.pack()

    def _hide(self, _event: tk.Event) -> None:
        if not self.tip_window:
            return
        self.tip_window.destroy()
        self.tip_window = None


class NpcDialogTool(ttk.Frame):
    def __init__(self, master: tk.Tk) -> None:
        super().__init__(master, padding=12)
        self.pack(fill="both", expand=True)

        self.topic_vars: dict[str, tk.StringVar] = {}
        self.export_with_comments = tk.BooleanVar(value=True)

        self.generated_ranges: dict[str, tuple[int, int]] = {}
        self.snippet_ranges: dict[str, tuple[str, str]] = {}

        self._build_ui()
        self._seed_topics()
        self._regenerate_preview()

    def _build_ui(self) -> None:
        self.columnconfigure(0, weight=1)
        self.columnconfigure(1, weight=2)
        self.columnconfigure(2, weight=2)
        self.rowconfigure(1, weight=1)

        controls = ttk.Frame(self)
        controls.grid(row=0, column=0, columnspan=3, sticky="ew", pady=(0, 8))

        ttk.Label(controls, text="NPC function name:").grid(row=0, column=0, sticky="w")
        self.func_name_var = tk.StringVar(value="npc_dialog")
        ttk.Entry(controls, width=20, textvariable=self.func_name_var).grid(
            row=0, column=1, sticky="w", padx=(6, 12)
        )

        ttk.Checkbutton(
            controls,
            text="Export with comments",
            variable=self.export_with_comments,
            command=self._regenerate_preview,
        ).grid(row=0, column=2, sticky="w")
        icon = ttk.Label(controls, text="ⓘ", foreground="#004f9f")
        icon.grid(row=0, column=3, sticky="w", padx=(4, 14))
        ToolTip(
            icon,
            "When enabled, .uc output includes comment hints for each block.\n"
            "Ultima VII example: add context like why a branch checks item flag 0x95\n"
            "before allowing a Fellowship-specific response.",
        )

        regen_btn = ttk.Button(controls, text="Regenerate", command=self._regenerate_preview)
        regen_btn.grid(row=0, column=4, sticky="w")

        export_btn = ttk.Button(controls, text="Export .uc", command=self._export_uc)
        export_btn.grid(row=0, column=5, sticky="w", padx=(8, 0))

        tree_box = ttk.Labelframe(self, text="Topic tree")
        tree_box.grid(row=1, column=0, sticky="nsew", padx=(0, 8))
        tree_box.columnconfigure(0, weight=1)
        tree_box.rowconfigure(0, weight=1)

        self.tree = ttk.Treeview(tree_box, show="tree", selectmode="browse")
        self.tree.grid(row=0, column=0, sticky="nsew")
        self.tree.bind("<<TreeviewSelect>>", self._on_tree_select)

        hint = ttk.Label(tree_box, text="ⓘ", foreground="#004f9f")
        hint.grid(row=1, column=0, sticky="w", pady=(6, 0))
        ToolTip(
            hint,
            "Ultima VII tip: keep root topics short (e.g., NAME, JOB, BYE) so they map\n"
            "to classic keyword buttons in the conversation bar.",
        )

        preview_box = ttk.Labelframe(self, text="Generated .uc")
        preview_box.grid(row=1, column=1, sticky="nsew", padx=(0, 8))
        preview_box.columnconfigure(0, weight=1)
        preview_box.rowconfigure(0, weight=1)

        self.preview = tk.Text(preview_box, wrap="none")
        self.preview.grid(row=0, column=0, sticky="nsew")
        self.preview.tag_configure("highlight", background="#fff3af")

        side_panel = ttk.Labelframe(self, text="Generated structure guide")
        side_panel.grid(row=1, column=2, sticky="nsew")
        side_panel.columnconfigure(0, weight=1)
        side_panel.rowconfigure(0, weight=3)
        side_panel.rowconfigure(1, weight=2)

        self.structure_text = tk.Text(side_panel, wrap="word", height=16)
        self.structure_text.grid(row=0, column=0, sticky="nsew")
        self.structure_text.tag_configure("selected", background="#d7ebff")

        self.snippet_text = tk.Text(side_panel, wrap="word", height=8)
        self.snippet_text.grid(row=1, column=0, sticky="nsew", pady=(8, 0))
        self.snippet_text.tag_configure("selected", background="#d7ebff")

        self.structure_help = ttk.Label(side_panel, text="ⓘ", foreground="#004f9f")
        self.structure_help.grid(row=2, column=0, sticky="w", pady=(6, 0))
        ToolTip(
            self.structure_help,
            "Sections explain how generated code maps to conversation flow:\n"
            "Greeting setup, First-time meeting block, Topic cases, and Goodbye behavior.\n"
            "Example: a first-time block often mirrors NPCs like Iolo introducing\n"
            "themselves only on first encounter.",
        )

    def _seed_topics(self) -> None:
        self.tree.delete(*self.tree.get_children())
        root = self.tree.insert("", "end", iid="topics", text="Topics")
        for topic in ["name", "job", "rumors", "bye"]:
            self.tree.insert(root, "end", iid=topic, text=topic.upper())

    def _generate_uc(self) -> str:
        func_name = self.func_name_var.get().strip() or "npc_dialog"
        comments = self.export_with_comments.get()

        lines: list[str] = []
        self.generated_ranges.clear()

        def add(line: str) -> None:
            lines.append(line)

        if comments:
            add("// Greeting setup: initialize conversation context and open choices.")
        start = len(lines) + 1
        add(f"void {func_name}()")
        add("{")
        add('    say("Greetings, Avatar.");')
        add('    add_answer("name", "job", "rumors", "bye");')
        self.generated_ranges["Greeting setup"] = (start, len(lines))

        if comments:
            add("")
            add("    // First-time meeting block: one-off intro then set met flag.")
        start = len(lines) + 1
        add("    if (!get_item_flag(0x01))")
        add("    {")
        add('        say("We have not met before.");')
        add("        set_item_flag(0x01, true);")
        add("    }")
        self.generated_ranges["First-time meeting block"] = (start, len(lines))

        if comments:
            add("")
            add("    // Topic cases: loop through topic choices until player says bye.")
        start = len(lines) + 1
        add("    while (true)")
        add("    {")
        add("        switch (ask_answer())")
        add("        {")
        self.generated_ranges["Topic cases"] = (start, len(lines))

        self.generated_ranges.pop("bye", None)
        for topic in ["name", "job", "rumors", "bye"]:
            if comments:
                add(f"            // Case for topic '{topic}'.")
            case_start = len(lines) + 1
            add(f'            case "{topic}":')
            if topic == "bye":
                add('                say("Farewell.");')
                add("                return;")
            else:
                add(f'                say("{topic.capitalize()} response placeholder.");')
                add("                break;")
            self.generated_ranges[topic] = (case_start, len(lines))

        if comments:
            add("            // Goodbye behavior: default fallback exits cleanly.")
        start = len(lines) + 1
        add("            default:")
        add('                say("Until next time.");')
        add("                return;")
        add("        }")
        add("    }")
        add("}")
        self.generated_ranges["Goodbye behavior"] = (start, len(lines))

        return "\n".join(lines)

    def _render_structure_summary(self) -> None:
        self.structure_text.config(state="normal")
        self.structure_text.delete("1.0", "end")
        self.snippet_text.config(state="normal")
        self.snippet_text.delete("1.0", "end")
        self.snippet_ranges.clear()

        sections = [
            (
                "Greeting setup",
                "Opens dialog and seeds core answers; this mirrors classic keyword entry in Ultima 7.",
            ),
            (
                "First-time meeting block",
                "Runs only once and sets a met flag so repeat visits skip long introductions.",
            ),
            (
                "Topic cases",
                "Maps each keyword button to a case in the switch and keeps looping until goodbye.",
            ),
            (
                "Goodbye behavior",
                "Handles explicit BYE and unknown choices by ending cleanly.",
            ),
        ]
        for title, desc in sections:
            start = self.structure_text.index("end-1c")
            self.structure_text.insert("end", f"{title}\n", ("section_title",))
            self.structure_text.insert("end", f"  {desc}\n\n")
            end = self.structure_text.index("end-1c")
            self.snippet_ranges[title] = (start, end)

        topic = self._selected_topic()
        if topic:
            snippet_start = self.snippet_text.index("end-1c")
            self.snippet_text.insert("end", f"Topic '{topic.upper()}'\n")
            self.snippet_text.insert(
                "end",
                f"This selection points at the generated case \"{topic}\" in the switch block.\n"
                "Use it to add NPC-specific lines (e.g., lore, location hints, quest checks).\n",
            )
            snippet_end = self.snippet_text.index("end-1c")
            self.snippet_ranges[topic] = (snippet_start, snippet_end)

        self.structure_text.tag_configure("section_title", font=("TkDefaultFont", 10, "bold"))
        self.structure_text.config(state="disabled")
        self.snippet_text.config(state="disabled")

    def _selected_topic(self) -> str | None:
        selected = self.tree.selection()
        if not selected:
            return None
        key = selected[0]
        if key in {"name", "job", "rumors", "bye"}:
            return key
        return None

    def _highlight_for_selection(self) -> None:
        self.preview.tag_remove("highlight", "1.0", "end")
        self.structure_text.config(state="normal")
        self.snippet_text.config(state="normal")
        self.structure_text.tag_remove("selected", "1.0", "end")
        self.snippet_text.tag_remove("selected", "1.0", "end")

        topic = self._selected_topic()
        if topic and topic in self.generated_ranges:
            line_start, line_end = self.generated_ranges[topic]
            self.preview.tag_add("highlight", f"{line_start}.0", f"{line_end}.end")
            snippet_range = self.snippet_ranges.get(topic)
            if snippet_range:
                self.snippet_text.tag_add("selected", snippet_range[0], snippet_range[1])
            topic_case_range = self.snippet_ranges.get("Topic cases")
            if topic_case_range:
                self.structure_text.tag_add("selected", topic_case_range[0], topic_case_range[1])
        else:
            for title in [
                "Greeting setup",
                "First-time meeting block",
                "Topic cases",
                "Goodbye behavior",
            ]:
                if title not in self.generated_ranges:
                    continue
                line_start, line_end = self.generated_ranges[title]
                self.preview.tag_add("highlight", f"{line_start}.0", f"{line_end}.end")
                rng = self.snippet_ranges.get(title)
                if rng:
                    self.structure_text.tag_add("selected", rng[0], rng[1])
                break

        self.structure_text.config(state="disabled")
        self.snippet_text.config(state="disabled")

    def _regenerate_preview(self) -> None:
        generated = self._generate_uc()
        self.preview.delete("1.0", "end")
        self.preview.insert("1.0", generated)
        self._render_structure_summary()
        self._highlight_for_selection()

    def _on_tree_select(self, _event: tk.Event) -> None:
        self._render_structure_summary()
        self._highlight_for_selection()

    def _export_uc(self) -> None:
        path = filedialog.asksaveasfilename(
            title="Export usecode",
            defaultextension=".uc",
            filetypes=[("Usecode", "*.uc"), ("All files", "*.*")],
        )
        if not path:
            return
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(self._generate_uc())
            handle.write("\n")
        messagebox.showinfo("Export complete", f"Saved: {path}")


def main() -> None:
    root = tk.Tk()
    root.title("NPC Dialog Tool")
    root.geometry("1500x860")
    NpcDialogTool(root)
    root.mainloop()


if __name__ == "__main__":
    main()

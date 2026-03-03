#!/usr/bin/env python3
"""NPC dialog template generator.

Small UI tool used to generate usecode conversation skeletons with optional
feature blocks.
"""

from __future__ import annotations

from dataclasses import dataclass
import tkinter as tk
from tkinter import ttk


PRESET_PROFILES = {
    "Minimal": {
        "include_met_first_time": False,
        "include_already_met_text": False,
        "include_schedule_snippets": False,
        "include_gender_variation": False,
        "include_party_size_greeting": False,
        "custom_flag": "",
    },
    "SI-style": {
        "include_met_first_time": True,
        "include_already_met_text": True,
        "include_schedule_snippets": True,
        "include_gender_variation": False,
        "include_party_size_greeting": False,
        "custom_flag": "",
    },
    "Template-complete": {
        "include_met_first_time": True,
        "include_already_met_text": True,
        "include_schedule_snippets": True,
        "include_gender_variation": True,
        "include_party_size_greeting": True,
        "custom_flag": "SI_ZOMBIE",
    },
}


@dataclass
class DialogTemplateModel:
    function_name: str
    npc_label: str
    first_time_text: str
    already_met_text: str
    include_met_first_time: bool
    include_already_met_text: bool
    include_schedule_snippets: bool
    include_gender_variation: bool
    include_party_size_greeting: bool
    custom_flag: str


class NpcDialogTool:
    def __init__(self, root: tk.Tk) -> None:
        self.root = root
        self.root.title("NPC Dialog Tool")

        self.function_name_var = tk.StringVar(value="sample_npc")
        self.npc_label_var = tk.StringVar(value="NPC")
        self.first_time_text_var = tk.StringVar(value="Hello, stranger.")
        self.already_met_text_var = tk.StringVar(value="Back again, Avatar?")
        self.include_met_first_time_var = tk.BooleanVar(value=True)
        self.include_already_met_text_var = tk.BooleanVar(value=True)
        self.include_schedule_snippets_var = tk.BooleanVar(value=False)
        self.include_gender_variation_var = tk.BooleanVar(value=False)
        self.include_party_size_greeting_var = tk.BooleanVar(value=False)
        self.custom_flag_var = tk.StringVar(value="")
        self.preset_var = tk.StringVar(value="Minimal")

        self._build_ui()
        self._apply_preset("Minimal")
        self._refresh_output()

    def _build_ui(self) -> None:
        frm = ttk.Frame(self.root, padding=10)
        frm.grid(row=0, column=0, sticky="nsew")
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)

        row = 0
        ttk.Label(frm, text="Preset").grid(row=row, column=0, sticky="w")
        preset = ttk.Combobox(
            frm,
            textvariable=self.preset_var,
            state="readonly",
            values=list(PRESET_PROFILES.keys()),
            width=20,
        )
        preset.grid(row=row, column=1, sticky="ew")
        preset.bind("<<ComboboxSelected>>", self._on_preset_changed)

        row += 1
        ttk.Label(frm, text="Function name").grid(row=row, column=0, sticky="w")
        ttk.Entry(frm, textvariable=self.function_name_var).grid(row=row, column=1, sticky="ew")

        row += 1
        ttk.Label(frm, text="NPC label").grid(row=row, column=0, sticky="w")
        ttk.Entry(frm, textvariable=self.npc_label_var).grid(row=row, column=1, sticky="ew")

        row += 1
        ttk.Label(frm, text="First-time text").grid(row=row, column=0, sticky="w")
        ttk.Entry(frm, textvariable=self.first_time_text_var).grid(row=row, column=1, sticky="ew")

        row += 1
        ttk.Label(frm, text="Already-met text").grid(row=row, column=0, sticky="w")
        ttk.Entry(frm, textvariable=self.already_met_text_var).grid(row=row, column=1, sticky="ew")

        row += 1
        ttk.Checkbutton(
            frm,
            text="Include MET first-time branch",
            variable=self.include_met_first_time_var,
            command=self._refresh_output,
        ).grid(row=row, column=0, columnspan=2, sticky="w")

        row += 1
        ttk.Checkbutton(
            frm,
            text="Include already-met branch text",
            variable=self.include_already_met_text_var,
            command=self._refresh_output,
        ).grid(row=row, column=0, columnspan=2, sticky="w")

        row += 1
        ttk.Checkbutton(
            frm,
            text="Include schedule-based branch snippets (UI_get_schedule_type(item))",
            variable=self.include_schedule_snippets_var,
            command=self._refresh_output,
        ).grid(row=row, column=0, columnspan=2, sticky="w")

        row += 1
        ttk.Checkbutton(
            frm,
            text="Include player gender variation branch",
            variable=self.include_gender_variation_var,
            command=self._refresh_output,
        ).grid(row=row, column=0, columnspan=2, sticky="w")

        row += 1
        ttk.Checkbutton(
            frm,
            text="Include party-size greeting branch",
            variable=self.include_party_size_greeting_var,
            command=self._refresh_output,
        ).grid(row=row, column=0, columnspan=2, sticky="w")

        row += 1
        ttk.Label(frm, text="Custom flag (optional)").grid(row=row, column=0, sticky="w")
        ttk.Entry(frm, textvariable=self.custom_flag_var).grid(row=row, column=1, sticky="ew")

        row += 1
        ttk.Button(frm, text="Generate", command=self._refresh_output).grid(row=row, column=0, columnspan=2, pady=(8, 8))

        row += 1
        self.output = tk.Text(frm, width=96, height=26, wrap="none")
        self.output.grid(row=row, column=0, columnspan=2, sticky="nsew")

        frm.columnconfigure(1, weight=1)
        frm.rowconfigure(row, weight=1)

        for var in (
            self.function_name_var,
            self.npc_label_var,
            self.first_time_text_var,
            self.already_met_text_var,
            self.custom_flag_var,
        ):
            var.trace_add("write", lambda *_: self._refresh_output())

    def _on_preset_changed(self, _event: object) -> None:
        self._apply_preset(self.preset_var.get())
        self._refresh_output()

    def _apply_preset(self, name: str) -> None:
        preset = PRESET_PROFILES.get(name)
        if not preset:
            return
        self.include_met_first_time_var.set(preset["include_met_first_time"])
        self.include_already_met_text_var.set(preset["include_already_met_text"])
        self.include_schedule_snippets_var.set(preset["include_schedule_snippets"])
        self.include_gender_variation_var.set(preset["include_gender_variation"])
        self.include_party_size_greeting_var.set(preset["include_party_size_greeting"])
        self.custom_flag_var.set(preset["custom_flag"])

    def _collect_model(self) -> DialogTemplateModel:
        return DialogTemplateModel(
            function_name=(self.function_name_var.get().strip() or "sample_npc"),
            npc_label=(self.npc_label_var.get().strip() or "NPC"),
            first_time_text=(self.first_time_text_var.get().strip() or "Hello."),
            already_met_text=(self.already_met_text_var.get().strip() or "Hello again."),
            include_met_first_time=self.include_met_first_time_var.get(),
            include_already_met_text=self.include_already_met_text_var.get(),
            include_schedule_snippets=self.include_schedule_snippets_var.get(),
            include_gender_variation=self.include_gender_variation_var.get(),
            include_party_size_greeting=self.include_party_size_greeting_var.get(),
            custom_flag=self.custom_flag_var.get().strip(),
        )

    def _refresh_output(self) -> None:
        model = self._collect_model()
        code = self._build_usecode(model)
        self.output.delete("1.0", "end")
        self.output.insert("1.0", code)

    def _build_usecode(self, model: DialogTemplateModel) -> str:
        parts: list[str] = [f"void {model.function_name} object#({model.npc_label})()", "{"]

        declarations = self._render_declarations(model)
        if declarations:
            parts.extend(declarations)
            parts.append("")

        parts.extend(self._render_met_branch(model))
        parts.extend(self._render_schedule_branch(model))
        parts.extend(self._render_gender_branch(model))
        parts.extend(self._render_party_branch(model))
        parts.extend(self._render_custom_flag_branch(model))

        parts.append('    add("name");')
        parts.append('    add("bye");')
        parts.append("    converse (0)")
        parts.append("    {")
        parts.append('        case "name":')
        parts.append(f'            say("{model.npc_label}.");')
        parts.append("            break;")
        parts.append('        case "bye":')
        parts.append('            say("Farewell.");')
        parts.append("            break;")
        parts.append("    }")
        parts.append("}")
        return "\n".join(parts) + "\n"

    def _render_declarations(self, model: DialogTemplateModel) -> list[str]:
        decl: list[str] = []
        if model.include_schedule_snippets:
            decl.append("    var schedule_type = UI_get_schedule_type(item);")
        if model.include_party_size_greeting:
            decl.append("    var party_size = UI_get_party_list().count;")
        return decl

    def _render_met_branch(self, model: DialogTemplateModel) -> list[str]:
        if not model.include_met_first_time:
            return []
        lines = ["    if (!item->get_item_flag(MET))", "    {"]
        lines.append(f'        say("{model.first_time_text}");')
        lines.append("        item->set_item_flag(MET);")
        if model.include_already_met_text:
            lines.extend([
                "    }",
                "    else",
                "    {",
                f'        say("{model.already_met_text}");',
            ])
        lines.append("    }")
        return lines

    def _render_schedule_branch(self, model: DialogTemplateModel) -> list[str]:
        if not model.include_schedule_snippets:
            return []
        return [
            "    if (schedule_type == SLEEP)",
            "    {",
            '        say("You woke me from my rest.");',
            "    }",
            "    else if (schedule_type == EAT)",
            "    {",
            '        say("I was just eating.");',
            "    }",
        ]

    def _render_gender_branch(self, model: DialogTemplateModel) -> list[str]:
        if not model.include_gender_variation:
            return []
        return [
            "    if (UI_is_pc_female())",
            "    {",
            '        say("Milady Avatar.");',
            "    }",
            "    else",
            "    {",
            '        say("My lord Avatar.");',
            "    }",
        ]

    def _render_party_branch(self, model: DialogTemplateModel) -> list[str]:
        if not model.include_party_size_greeting:
            return []
        return [
            "    if (party_size > 1)",
            "    {",
            '        say("You travel with many companions.");',
            "    }",
        ]

    def _render_custom_flag_branch(self, model: DialogTemplateModel) -> list[str]:
        if not model.custom_flag:
            return []
        flag = model.custom_flag
        return [
            f"    if (gflags[{flag}])",
            "    {",
            f'        say("({flag} already set.)");',
            "    }",
            "    else",
            "    {",
            f"        gflags[{flag}] = true;",
            "    }",
        ]


if __name__ == "__main__":
    root = tk.Tk()
    app = NpcDialogTool(root)
    root.minsize(900, 700)
    root.mainloop()

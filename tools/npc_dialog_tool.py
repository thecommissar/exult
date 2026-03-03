#!/usr/bin/env python3
"""NPC dialog tool with condition-aware dialog node generation.

This module provides:
1. A ``DialogNode`` model with optional conditions.
2. A simple Tkinter-based editor section for managing conditions.
3. Generator helpers that emit guarded ``if (...) { ... } else { ... }`` logic per case.
4. Validation for contradictory conditions.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Iterable, List, Optional
import argparse
import tkinter as tk
from tkinter import messagebox, ttk

KNOWN_FLAGS = [
    "MET_AVATAR",
    "JOINED_PARTY",
    "QUEST_STARTED",
    "QUEST_COMPLETED",
    "HAS_PAYMENT",
]

SCHEDULE_CONSTANTS = [
    "SCHED_WANDER",
    "SCHED_SLEEP",
    "SCHED_WORK",
    "SCHED_EAT",
    "SCHED_TALK",
]


@dataclass
class NodeConditions:
    requires_flags: List[str] = field(default_factory=list)
    forbidden_flags: List[str] = field(default_factory=list)
    schedule_in: Optional[str] = None

    def guard_expression(self) -> Optional[str]:
        checks: List[str] = []
        checks.extend(f'has_flag("{flag}")' for flag in self.requires_flags)
        checks.extend(f'!has_flag("{flag}")' for flag in self.forbidden_flags)
        if self.schedule_in:
            checks.append(f"npc_schedule == {self.schedule_in}")
        return " && ".join(checks) if checks else None


@dataclass
class DialogNode:
    case_label: str
    say_lines: List[str]
    fallback_say_lines: List[str] = field(default_factory=lambda: ["I can't talk about that right now."])
    conditions: Optional[NodeConditions] = None


def validate_conditions(conditions: NodeConditions) -> List[str]:
    errors: List[str] = []
    overlap = set(conditions.requires_flags).intersection(conditions.forbidden_flags)
    if overlap:
        errors.append(
            "Contradictory flags found in both requires_flags and forbidden_flags: "
            + ", ".join(sorted(overlap))
        )
    if conditions.schedule_in and conditions.schedule_in not in SCHEDULE_CONSTANTS:
        errors.append(f"Unknown schedule constant: {conditions.schedule_in}")
    unknown_required = sorted(set(conditions.requires_flags) - set(KNOWN_FLAGS))
    if unknown_required:
        errors.append("Unknown required flags: " + ", ".join(unknown_required))
    unknown_forbidden = sorted(set(conditions.forbidden_flags) - set(KNOWN_FLAGS))
    if unknown_forbidden:
        errors.append("Unknown forbidden flags: " + ", ".join(unknown_forbidden))
    return errors


def _emit_say_lines(lines: Iterable[str], indent: str) -> List[str]:
    return [f'{indent}say("{line}");' for line in lines]


def emit_case(node: DialogNode) -> str:
    output: List[str] = [f'case "{node.case_label}":']

    if node.conditions:
        errors = validate_conditions(node.conditions)
        if errors:
            raise ValueError("; ".join(errors))

    guard = node.conditions.guard_expression() if node.conditions else None
    if guard:
        output.append(f"    if ({guard}) {{")
        output.extend(_emit_say_lines(node.say_lines, "        "))
        output.append("    } else {")
        output.extend(_emit_say_lines(node.fallback_say_lines, "        "))
        output.append("    }")
    else:
        output.extend(_emit_say_lines(node.say_lines, "    "))

    output.append("    break;")
    return "\n".join(output)


class ConditionsEditor(ttk.LabelFrame):
    def __init__(self, parent: tk.Misc):
        super().__init__(parent, text="Conditions")

        self.requires_var = tk.StringVar(value=KNOWN_FLAGS[0])
        self.forbidden_var = tk.StringVar(value=KNOWN_FLAGS[0])
        self.schedule_var = tk.StringVar(value="")
        self.fallback_var = tk.StringVar(value="I can't talk about that right now.")

        ttk.Label(self, text="Require flag").grid(row=0, column=0, sticky="w")
        ttk.Combobox(self, textvariable=self.requires_var, values=KNOWN_FLAGS, state="readonly").grid(
            row=0, column=1, sticky="ew", padx=4
        )
        ttk.Button(self, text="Add", command=self._add_required).grid(row=0, column=2)

        ttk.Label(self, text="Forbidden flag").grid(row=1, column=0, sticky="w")
        ttk.Combobox(self, textvariable=self.forbidden_var, values=KNOWN_FLAGS, state="readonly").grid(
            row=1, column=1, sticky="ew", padx=4
        )
        ttk.Button(self, text="Add", command=self._add_forbidden).grid(row=1, column=2)

        ttk.Label(self, text="Schedule in").grid(row=2, column=0, sticky="w")
        ttk.Combobox(self, textvariable=self.schedule_var, values=[""] + SCHEDULE_CONSTANTS, state="readonly").grid(
            row=2, column=1, sticky="ew", padx=4
        )

        self.requires_list = tk.Listbox(self, height=4)
        self.requires_list.grid(row=3, column=0, columnspan=2, sticky="nsew", pady=(6, 0))
        ttk.Button(self, text="Remove selected required", command=lambda: self._remove_selected(self.requires_list)).grid(
            row=3, column=2, sticky="n"
        )

        self.forbidden_list = tk.Listbox(self, height=4)
        self.forbidden_list.grid(row=4, column=0, columnspan=2, sticky="nsew", pady=(6, 0))
        ttk.Button(
            self,
            text="Remove selected forbidden",
            command=lambda: self._remove_selected(self.forbidden_list),
        ).grid(row=4, column=2, sticky="n")

        ttk.Label(self, text="Fallback say (condition fails)").grid(row=5, column=0, sticky="w", pady=(8, 0))
        ttk.Entry(self, textvariable=self.fallback_var).grid(row=5, column=1, columnspan=2, sticky="ew", pady=(8, 0))

        self.columnconfigure(1, weight=1)

    def _add_required(self) -> None:
        value = self.requires_var.get()
        if value and value not in self.requires_list.get(0, tk.END):
            self.requires_list.insert(tk.END, value)

    def _add_forbidden(self) -> None:
        value = self.forbidden_var.get()
        if value and value not in self.forbidden_list.get(0, tk.END):
            self.forbidden_list.insert(tk.END, value)

    @staticmethod
    def _remove_selected(listbox: tk.Listbox) -> None:
        for index in reversed(listbox.curselection()):
            listbox.delete(index)

    def build_conditions(self) -> NodeConditions:
        return NodeConditions(
            requires_flags=list(self.requires_list.get(0, tk.END)),
            forbidden_flags=list(self.forbidden_list.get(0, tk.END)),
            schedule_in=self.schedule_var.get() or None,
        )

    def fallback_lines(self) -> List[str]:
        return [self.fallback_var.get().strip() or "I can't talk about that right now."]


class DialogEditor(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("NPC Dialog Tool")

        self.case_var = tk.StringVar(value="default")
        self.say_var = tk.StringVar(value="Hello there.")

        ttk.Label(self, text="Case label").grid(row=0, column=0, sticky="w")
        ttk.Entry(self, textvariable=self.case_var).grid(row=0, column=1, sticky="ew", padx=4)

        ttk.Label(self, text="Say text").grid(row=1, column=0, sticky="w")
        ttk.Entry(self, textvariable=self.say_var).grid(row=1, column=1, sticky="ew", padx=4)

        self.conditions_editor = ConditionsEditor(self)
        self.conditions_editor.grid(row=2, column=0, columnspan=2, sticky="nsew", pady=8)

        ttk.Button(self, text="Generate case", command=self._generate).grid(row=3, column=0, columnspan=2)

        self.output = tk.Text(self, height=12, width=80)
        self.output.grid(row=4, column=0, columnspan=2, sticky="nsew", pady=(8, 0))

        self.columnconfigure(1, weight=1)

    def _generate(self) -> None:
        conditions = self.conditions_editor.build_conditions()
        errors = validate_conditions(conditions)
        if errors:
            messagebox.showerror("Condition validation failed", "\n".join(errors))
            return

        node = DialogNode(
            case_label=self.case_var.get().strip() or "default",
            say_lines=[self.say_var.get().strip() or "..."],
            fallback_say_lines=self.conditions_editor.fallback_lines(),
            conditions=conditions,
        )

        generated = emit_case(node)
        self.output.delete("1.0", tk.END)
        self.output.insert(tk.END, generated)


def main() -> None:
    parser = argparse.ArgumentParser(description="Condition-aware NPC dialog case generator")
    parser.add_argument("--gui", action="store_true", help="Run the Tkinter editor")
    args = parser.parse_args()

    if args.gui:
        app = DialogEditor()
        app.mainloop()
        return

    demo = DialogNode(
        case_label="job",
        say_lines=["I am busy right now."],
        fallback_say_lines=["Come back later."],
        conditions=NodeConditions(
            requires_flags=["MET_AVATAR"],
            forbidden_flags=["QUEST_COMPLETED"],
            schedule_in="SCHED_WORK",
        ),
    )
    print(emit_case(demo))


if __name__ == "__main__":
    main()

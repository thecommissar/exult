#!/usr/bin/env python3
"""NPC dialog editing utility with project validation support.

This module provides a reusable ``validate_project`` function and a small Tk UI
that demonstrates how validation can be surfaced in a dedicated pane.
"""

from __future__ import annotations

import json
import re
import tkinter as tk
from dataclasses import asdict, dataclass
from pathlib import Path
from tkinter import filedialog, messagebox, ttk
from typing import Any

OBJECT_ID_PATTERN = re.compile(r"^0x[0-9A-Fa-f]+$")
FUNCTION_IDENTIFIER_PATTERN = re.compile(r"^void\s+[A-Za-z_][A-Za-z0-9_]*\s+object#$")


@dataclass(frozen=True)
class ValidationIssue:
    """A single warning/error produced during validation."""

    severity: str
    code: str
    message: str
    path: str


@dataclass(frozen=True)
class ValidationReport:
    """Structured set of validation issues."""

    warnings: list[ValidationIssue]
    errors: list[ValidationIssue]

    def as_dict(self) -> dict[str, Any]:
        return {
            "warnings": [asdict(issue) for issue in self.warnings],
            "errors": [asdict(issue) for issue in self.errors],
        }

    @property
    def has_errors(self) -> bool:
        return bool(self.errors)

    @property
    def has_warnings(self) -> bool:
        return bool(self.warnings)


# ------------------------------ Validation API ------------------------------ #

def validate_project(project: dict[str, Any]) -> ValidationReport:
    """Validate an NPC dialog project and return structured warnings/errors.

    Expected project shape (minimum):
      {
        "object_id": "0x123",
        "function_identifier": "void some_name object#",
        "topics": [
          {"name": "hello", "opens_topics": ["bye"], "is_bye": false},
          ...
        ]
      }
    """

    warnings: list[ValidationIssue] = []
    errors: list[ValidationIssue] = []

    topics = project.get("topics")
    if not isinstance(topics, list):
        errors.append(
            ValidationIssue(
                severity="error",
                code="INVALID_TOPICS",
                message="'topics' must be a list.",
                path="topics",
            )
        )
        return ValidationReport(warnings=warnings, errors=errors)

    # object id format
    object_id = str(project.get("object_id", "")).strip()
    if object_id and not OBJECT_ID_PATTERN.fullmatch(object_id):
        errors.append(
            ValidationIssue(
                severity="error",
                code="INVALID_OBJECT_ID",
                message="Object ID must use hexadecimal format, e.g. 0x1234.",
                path="object_id",
            )
        )

    # function identifier format: "void <name> object#"
    function_identifier = str(project.get("function_identifier", "")).strip()
    if function_identifier and not FUNCTION_IDENTIFIER_PATTERN.fullmatch(function_identifier):
        errors.append(
            ValidationIssue(
                severity="error",
                code="INVALID_FUNCTION_IDENTIFIER",
                message="Function identifier must match 'void <name> object#'.",
                path="function_identifier",
            )
        )

    names: list[str] = []
    byes: list[int] = []

    for index, topic in enumerate(topics):
        if not isinstance(topic, dict):
            errors.append(
                ValidationIssue(
                    severity="error",
                    code="INVALID_TOPIC",
                    message="Each topic entry must be an object.",
                    path=f"topics[{index}]",
                )
            )
            continue

        name = str(topic.get("name", "")).strip()
        if not name:
            warnings.append(
                ValidationIssue(
                    severity="warning",
                    code="EMPTY_TOPIC_NAME",
                    message="Topic has an empty name.",
                    path=f"topics[{index}].name",
                )
            )
        names.append(name)

        if topic.get("is_bye"):
            byes.append(index)

    # duplicate topic names
    seen: set[str] = set()
    duplicates: set[str] = set()
    for name in names:
        if not name:
            continue
        if name in seen:
            duplicates.add(name)
        seen.add(name)

    for name in sorted(duplicates):
        errors.append(
            ValidationIssue(
                severity="error",
                code="DUPLICATE_TOPIC",
                message=f"Duplicate topic name: '{name}'.",
                path="topics",
            )
        )

    # opens_topics references
    existing_names = {name for name in names if name}
    for index, topic in enumerate(topics):
        if not isinstance(topic, dict):
            continue
        opens_topics = topic.get("opens_topics", [])
        if opens_topics is None:
            opens_topics = []
        if not isinstance(opens_topics, list):
            errors.append(
                ValidationIssue(
                    severity="error",
                    code="INVALID_OPENS_TOPICS",
                    message="'opens_topics' must be a list when provided.",
                    path=f"topics[{index}].opens_topics",
                )
            )
            continue

        for ref_idx, ref in enumerate(opens_topics):
            ref_name = str(ref).strip()
            if ref_name and ref_name not in existing_names:
                errors.append(
                    ValidationIssue(
                        severity="error",
                        code="MISSING_OPEN_TOPIC_REFERENCE",
                        message=f"Referenced topic '{ref_name}' does not exist.",
                        path=f"topics[{index}].opens_topics[{ref_idx}]",
                    )
                )

    # multiple bye topics
    if len(byes) > 1:
        errors.append(
            ValidationIssue(
                severity="error",
                code="MULTIPLE_BYE_TOPICS",
                message="Only one topic can be marked as is_bye.",
                path="topics",
            )
        )

    return ValidationReport(warnings=warnings, errors=errors)


# ----------------------------------- UI ----------------------------------- #

class NpcDialogTool(tk.Tk):
    """Small editor that surfaces validation in a dedicated pane."""

    def __init__(self) -> None:
        super().__init__()
        self.title("NPC Dialog Tool")
        self.geometry("1100x700")

        self.editor = tk.Text(self, wrap="none")
        self.editor.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.editor.insert(
            "1.0",
            json.dumps(
                {
                    "object_id": "0x1234",
                    "function_identifier": "void npc_talk object#",
                    "topics": [
                        {
                            "name": "hello",
                            "opens_topics": ["bye"],
                            "is_bye": False,
                        },
                        {"name": "bye", "opens_topics": [], "is_bye": True},
                    ],
                },
                indent=2,
            ),
        )

        right = ttk.Frame(self)
        right.pack(side=tk.RIGHT, fill=tk.Y)

        controls = ttk.Frame(right)
        controls.pack(fill=tk.X, padx=8, pady=8)
        ttk.Button(controls, text="Validate", command=self.run_validation).pack(
            fill=tk.X, pady=(0, 6)
        )
        ttk.Button(controls, text="Export", command=self.export_project).pack(fill=tk.X)

        validation_frame = ttk.LabelFrame(right, text="Validation")
        validation_frame.pack(fill=tk.BOTH, expand=True, padx=8, pady=(0, 8))

        self.validation_list = tk.Text(validation_frame, width=48, wrap="word", state="disabled")
        self.validation_list.pack(fill=tk.BOTH, expand=True, padx=8, pady=8)
        self.validation_list.tag_configure("error_badge", foreground="white", background="#b91c1c")
        self.validation_list.tag_configure("warning_badge", foreground="black", background="#facc15")

        self._last_report = ValidationReport(warnings=[], errors=[])

        # Auto-run validation on edits.
        self.editor.bind("<<Modified>>", self._on_editor_modified)
        self.run_validation()

    def _on_editor_modified(self, _event: tk.Event) -> None:
        if self.editor.edit_modified():
            self.editor.edit_modified(False)
            self.run_validation()

    def _read_project(self) -> dict[str, Any] | None:
        raw = self.editor.get("1.0", tk.END).strip()
        if not raw:
            return {}
        try:
            return json.loads(raw)
        except json.JSONDecodeError as exc:
            self._last_report = ValidationReport(
                warnings=[],
                errors=[
                    ValidationIssue(
                        severity="error",
                        code="INVALID_JSON",
                        message=f"Invalid JSON: {exc.msg} (line {exc.lineno})",
                        path="$",
                    )
                ],
            )
            self.render_validation(self._last_report)
            return None

    def run_validation(self) -> ValidationReport:
        project = self._read_project()
        if project is None:
            return self._last_report

        report = validate_project(project)
        self._last_report = report
        self.render_validation(report)
        return report

    def render_validation(self, report: ValidationReport) -> None:
        self.validation_list.configure(state="normal")
        self.validation_list.delete("1.0", tk.END)

        if not report.errors and not report.warnings:
            self.validation_list.insert(tk.END, "No validation issues found.\n")
        else:
            for issue in report.errors + report.warnings:
                badge = " ERROR " if issue.severity == "error" else " WARNING "
                tag = "error_badge" if issue.severity == "error" else "warning_badge"
                self.validation_list.insert(tk.END, badge, (tag,))
                self.validation_list.insert(
                    tk.END, f" {issue.message}\n    [{issue.code}] at {issue.path}\n\n"
                )

        self.validation_list.configure(state="disabled")

    def export_project(self) -> None:
        report = self.run_validation()
        if report.has_errors:
            messagebox.showerror(
                "Export blocked", "Export is blocked until all validation errors are fixed."
            )
            return

        if report.has_warnings:
            proceed = messagebox.askyesno(
                "Validation warnings",
                "Validation produced warnings. Export anyway?",
            )
            if not proceed:
                return

        project = self._read_project()
        if project is None:
            return

        output_path = filedialog.asksaveasfilename(
            title="Export NPC dialog",
            defaultextension=".json",
            filetypes=[("JSON", "*.json"), ("All Files", "*.*")],
        )
        if not output_path:
            return

        Path(output_path).write_text(json.dumps(project, indent=2) + "\n", encoding="utf-8")
        messagebox.showinfo("Export complete", f"Exported project to {output_path}")


if __name__ == "__main__":
    app = NpcDialogTool()
    app.mainloop()

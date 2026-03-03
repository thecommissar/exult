#!/usr/bin/env python3
"""NPC dialog authoring helper.

This utility provides a small GUI for managing dialog nodes and importing
legacy `.uc` dialog code into a partial node representation for manual cleanup.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from tkinter import BOTH, END, LEFT, RIGHT, TOP, Button, Frame, Menu, Tk, filedialog, messagebox, ttk
from typing import Dict, Iterable, List, Sequence, Tuple


@dataclass
class DialogNode:
    """Represents a single dialog topic node extracted from usecode."""

    topic: str
    says: List[str] = field(default_factory=list)
    add_targets: List[str] = field(default_factory=list)
    metadata: Dict[str, str] = field(default_factory=dict)


@dataclass
class ImportReport:
    """Summary of what the importer could and could not parse."""

    source: str
    node_count: int
    metadata: Dict[str, str] = field(default_factory=dict)
    unparsed: List[str] = field(default_factory=list)


class UCDialogImporter:
    """Partial parser for common Ultima 7 conversation patterns."""

    OPTIONS_RE = re.compile(r"var\s+(?P<name>\w+)\s*=\s*\[(?P<body>.*?)\]\s*;", re.S)
    HEADER_RE = re.compile(
        r"void\s+(?P<name>\w+)\s+object#\s*\(\s*(?P<id>[^)]+?)\s*\)\s*\(\s*\)",
        re.S,
    )
    CONVERSE_RE = re.compile(r"converse\s*\(\s*(?P<expr>[^)]+?)\s*\)\s*\{", re.S)
    CASE_RE = re.compile(r"case\s+(?P<label>\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\w+)\s*:")
    SAY_RE = re.compile(r"say\s*\((?P<args>.*?)\)\s*;", re.S)
    ADD_RE = re.compile(r"add\s*\(\s*\[(?P<body>.*?)\]\s*\)\s*;", re.S)

    def parse(self, text: str, source: str = "<memory>") -> Tuple[List[DialogNode], ImportReport]:
        metadata = self._extract_metadata(text)
        options = self._extract_options(text)

        nodes: List[DialogNode] = []
        unparsed: List[str] = []

        for block in self._extract_converse_blocks(text):
            expr = block["expr"]
            cases = self._split_cases(block["body"])
            if not cases:
                unparsed.append(f"converse({expr}) has no parseable case labels")
                continue

            for case in cases:
                node = self._parse_case(case["label"], case["body"], metadata)
                if node is None:
                    unparsed.append(f"case {case['label']} could not be parsed")
                    continue
                nodes.append(node)

        referenced_topics = self._topics_from_expression_sequence(
            block["expr"] for block in self._extract_converse_blocks(text)
        )
        for topic in referenced_topics:
            if topic not in {node.topic for node in nodes} and topic not in options:
                unparsed.append(f"topic reference {topic!r} was not declared in options/case")

        report = ImportReport(
            source=source,
            node_count=len(nodes),
            metadata=metadata,
            unparsed=unparsed,
        )
        return nodes, report

    def _extract_metadata(self, text: str) -> Dict[str, str]:
        match = self.HEADER_RE.search(text)
        if not match:
            return {}
        return {"function": match.group("name"), "npc_id": match.group("id").strip()}

    def _extract_options(self, text: str) -> Dict[str, List[str]]:
        options: Dict[str, List[str]] = {}
        for match in self.OPTIONS_RE.finditer(text):
            options[match.group("name")] = self._extract_string_literals(match.group("body"))
        return options

    def _extract_converse_blocks(self, text: str) -> List[Dict[str, str]]:
        blocks: List[Dict[str, str]] = []
        index = 0
        while True:
            match = self.CONVERSE_RE.search(text, index)
            if not match:
                return blocks
            start = match.end()
            end = self._find_matching_brace(text, start - 1)
            if end < 0:
                return blocks
            blocks.append({"expr": match.group("expr").strip(), "body": text[start:end]})
            index = end + 1

    def _find_matching_brace(self, text: str, open_brace_at: int) -> int:
        depth = 0
        for pos in range(open_brace_at, len(text)):
            ch = text[pos]
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    return pos
        return -1

    def _split_cases(self, body: str) -> List[Dict[str, str]]:
        matches = list(self.CASE_RE.finditer(body))
        cases: List[Dict[str, str]] = []
        for i, match in enumerate(matches):
            begin = match.end()
            end = matches[i + 1].start() if i + 1 < len(matches) else len(body)
            cases.append({"label": self._strip_quotes(match.group("label")), "body": body[begin:end]})
        return cases

    def _parse_case(self, label: str, body: str, metadata: Dict[str, str]) -> DialogNode | None:
        normalized_topic = self._remove_modifier_prefix(label)
        if not normalized_topic:
            return None

        says: List[str] = []
        for say_match in self.SAY_RE.finditer(body):
            says.extend(self._extract_string_literals(say_match.group("args")))

        add_targets: List[str] = []
        for add_match in self.ADD_RE.finditer(body):
            add_targets.extend(self._extract_string_literals(add_match.group("body")))

        return DialogNode(topic=normalized_topic, says=says, add_targets=add_targets, metadata=dict(metadata))

    def _extract_string_literals(self, value: str) -> List[str]:
        results = []
        for quoted in re.finditer(r'"((?:\\.|[^"\\])*)"|\'((?:\\.|[^\'\\])*)\'', value):
            literal = quoted.group(1) if quoted.group(1) is not None else quoted.group(2)
            results.append(bytes(literal, "utf-8").decode("unicode_escape"))
        return results

    def _strip_quotes(self, token: str) -> str:
        token = token.strip()
        if len(token) >= 2 and token[0] == token[-1] and token[0] in {'"', "'"}:
            return token[1:-1]
        return token

    def _remove_modifier_prefix(self, topic: str) -> str:
        topic = topic.strip()
        topic = re.sub(r"^\s*[+\-!?#]+\s*", "", topic)
        return topic.strip()

    def _topics_from_expression_sequence(self, expressions: Iterable[str]) -> List[str]:
        topics: List[str] = []
        for expr in expressions:
            topics.extend(self._extract_string_literals(expr))
        return topics


class NPCDialogTool:
    """Simple dialog list UI with partial `.uc` import support."""

    def __init__(self, root: Tk) -> None:
        self.root = root
        self.root.title("NPC Dialog Tool")
        self.importer = UCDialogImporter()
        self.nodes: List[DialogNode] = []
        self._build_ui()

    def _build_ui(self) -> None:
        menubar = Menu(self.root)
        file_menu = Menu(menubar, tearoff=False)
        file_menu.add_command(label="Import .uc...", command=self.import_uc)
        menubar.add_cascade(label="File", menu=file_menu)
        self.root.config(menu=menubar)

        frame = Frame(self.root)
        frame.pack(side=TOP, fill=BOTH, expand=True)

        self.tree = ttk.Treeview(frame, columns=("topic", "says", "adds"), show="headings")
        self.tree.heading("topic", text="Topic")
        self.tree.heading("says", text="say(...) lines")
        self.tree.heading("adds", text="add([...]) targets")
        self.tree.column("topic", width=180)
        self.tree.column("says", width=320)
        self.tree.column("adds", width=240)
        self.tree.pack(side=LEFT, fill=BOTH, expand=True)

        controls = Frame(frame)
        controls.pack(side=RIGHT, fill="y")
        Button(controls, text="Import .uc...", command=self.import_uc).pack(padx=8, pady=8)

    def import_uc(self) -> None:
        path = filedialog.askopenfilename(
            title="Import Usecode dialog",
            filetypes=(("Usecode", "*.uc"), ("All files", "*.*")),
        )
        if not path:
            return

        raw = Path(path).read_text(encoding="utf-8")
        self.nodes, report = self.importer.parse(raw, source=path)
        self._refresh_nodes()
        self._show_import_report(report)

    def _refresh_nodes(self) -> None:
        for item in self.tree.get_children():
            self.tree.delete(item)
        for node in self.nodes:
            self.tree.insert("", END, values=(node.topic, " | ".join(node.says), ", ".join(node.add_targets)))

    def _show_import_report(self, report: ImportReport) -> None:
        info_lines = [
            f"Source: {report.source}",
            f"Imported nodes: {report.node_count}",
        ]
        if report.metadata:
            info_lines.append("Metadata: " + ", ".join(f"{k}={v}" for k, v in report.metadata.items()))

        if report.unparsed:
            info_lines.append("\nUnparsed constructs (manual review required):")
            info_lines.extend(f" - {entry}" for entry in report.unparsed)
        else:
            info_lines.append("\nNo unparsed constructs detected.")

        messagebox.showinfo("Import Report", "\n".join(info_lines))


def main() -> None:
    root = Tk()
    NPCDialogTool(root)
    root.geometry("980x480")
    root.mainloop()


if __name__ == "__main__":
    main()

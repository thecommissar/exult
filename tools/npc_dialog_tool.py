"""NPC dialog editor with table and graph views for topic navigation."""

from __future__ import annotations

import math
import tkinter as tk
from tkinter import ttk


class NPCDialogTool(tk.Tk):
    NODE_W = 170
    NODE_H = 64
    GRID_X = 260
    GRID_Y = 120

    def __init__(self, topics: dict[str, dict] | None = None):
        super().__init__()
        self.title("NPC Dialog Tool")
        self.geometry("1200x760")

        self.topics: dict[str, dict] = topics or {}
        self.current_topic: str | None = None
        self.node_positions: dict[str, tuple[float, float]] = {}
        self.node_bounds: dict[str, tuple[float, float, float, float]] = {}
        self.node_ids: dict[int, str] = {}
        self.scale = 1.0
        self.pan_x = 0.0
        self.pan_y = 0.0
        self._pan_anchor: tuple[int, int] | None = None

        self._build_ui()
        self.refresh_topics()

    def _build_ui(self) -> None:
        root = ttk.Panedwindow(self, orient=tk.HORIZONTAL)
        root.pack(fill=tk.BOTH, expand=True)

        left_panel = ttk.Frame(root)
        right_panel = ttk.Frame(root)
        root.add(left_panel, weight=1)
        root.add(right_panel, weight=3)

        self.left_notebook = ttk.Notebook(left_panel)
        self.left_notebook.pack(fill=tk.BOTH, expand=True)

        table_tab = ttk.Frame(self.left_notebook)
        self.graph_tab = ttk.Frame(self.left_notebook)
        self.left_notebook.add(table_tab, text="Table")
        self.left_notebook.add(self.graph_tab, text="Graph")

        self.topic_list = tk.Listbox(table_tab, exportselection=False)
        self.topic_list.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        topic_scroll = ttk.Scrollbar(table_tab, orient=tk.VERTICAL, command=self.topic_list.yview)
        topic_scroll.pack(side=tk.RIGHT, fill=tk.Y)
        self.topic_list.configure(yscrollcommand=topic_scroll.set)
        self.topic_list.bind("<<ListboxSelect>>", self._on_table_select)

        graph_controls = ttk.Frame(self.graph_tab)
        graph_controls.pack(fill=tk.X, padx=6, pady=6)
        ttk.Button(graph_controls, text="+", width=3, command=lambda: self.zoom_by(1.2)).pack(side=tk.LEFT)
        ttk.Button(graph_controls, text="-", width=3, command=lambda: self.zoom_by(1 / 1.2)).pack(side=tk.LEFT, padx=(4, 0))
        ttk.Button(graph_controls, text="Reset", command=self.reset_view).pack(side=tk.LEFT, padx=(8, 0))

        self.graph_canvas = tk.Canvas(self.graph_tab, bg="#1f1f1f", highlightthickness=0)
        self.graph_canvas.pack(fill=tk.BOTH, expand=True)
        self.graph_canvas.bind("<ButtonPress-1>", self._on_canvas_press)
        self.graph_canvas.bind("<B1-Motion>", self._on_canvas_drag)
        self.graph_canvas.bind("<ButtonRelease-1>", self._on_canvas_release)
        self.graph_canvas.bind("<MouseWheel>", self._on_mousewheel)
        self.graph_canvas.bind("<Button-4>", lambda e: self.zoom_by(1.1, e.x, e.y))
        self.graph_canvas.bind("<Button-5>", lambda e: self.zoom_by(1 / 1.1, e.x, e.y))

        ttk.Label(right_panel, text="Topic").pack(anchor=tk.W, padx=8, pady=(8, 2))
        self.topic_name = tk.StringVar()
        ttk.Entry(right_panel, textvariable=self.topic_name).pack(fill=tk.X, padx=8)
        ttk.Label(right_panel, text="Text").pack(anchor=tk.W, padx=8, pady=(8, 2))
        self.topic_text = tk.Text(right_panel, height=10)
        self.topic_text.pack(fill=tk.BOTH, expand=True, padx=8, pady=(0, 8))

    def refresh_topics(self) -> None:
        self.topic_list.delete(0, tk.END)
        for topic in sorted(self.topics):
            self.topic_list.insert(tk.END, topic)
        self._layout_graph_nodes()
        self.redraw_graph()

    def _layout_graph_nodes(self) -> None:
        if not self.topics:
            self.node_positions = {}
            return
        ordered = sorted(self.topics)
        cols = max(1, int(math.sqrt(len(ordered))))
        self.node_positions = {}
        for idx, topic in enumerate(ordered):
            row = idx // cols
            col = idx % cols
            self.node_positions[topic] = (80 + col * self.GRID_X, 80 + row * self.GRID_Y)

    def redraw_graph(self) -> None:
        c = self.graph_canvas
        c.delete("all")
        self.node_bounds.clear()
        self.node_ids.clear()

        known = set(self.topics)

        for topic, data in self.topics.items():
            sx, sy = self._to_screen(*self.node_positions.get(topic, (0, 0)))
            for dst in data.get("opens_topics", []):
                if dst in self.node_positions:
                    ex, ey = self._to_screen(*self.node_positions[dst])
                    self._draw_arrow(sx, sy, ex, ey, color="#7da6d9")
                else:
                    ux, uy = sx + 120 * self.scale, sy
                    self._draw_arrow(sx, sy, ux, uy, color="#e6a23c")
                    c.create_text(
                        ux + 12,
                        uy,
                        text=f"missing: {dst}",
                        fill="#e6a23c",
                        anchor=tk.W,
                        font=("TkDefaultFont", max(8, int(9 * self.scale))),
                    )

        for topic, (x, y) in self.node_positions.items():
            sx, sy = self._to_screen(x, y)
            w = self.NODE_W * self.scale
            h = self.NODE_H * self.scale
            x1, y1, x2, y2 = sx - w / 2, sy - h / 2, sx + w / 2, sy + h / 2
            unresolved = any(dst not in known for dst in self.topics.get(topic, {}).get("opens_topics", []))
            fill = "#4f88f7" if topic == self.current_topic else ("#6e4f2b" if unresolved else "#2e3b4f")
            outline = "#f39c12" if unresolved else "#9eaec7"
            rect_id = c.create_rectangle(x1, y1, x2, y2, fill=fill, outline=outline, width=2)
            c.create_text(sx, sy, text=topic, fill="white", width=w - 16)
            self.node_bounds[topic] = (x1, y1, x2, y2)
            self.node_ids[rect_id] = topic

        c.configure(scrollregion=c.bbox("all") or (0, 0, 1, 1))

    def _draw_arrow(self, sx: float, sy: float, ex: float, ey: float, color: str) -> None:
        angle = math.atan2(ey - sy, ex - sx)
        start_x = sx + (self.NODE_W * self.scale / 2) * math.cos(angle)
        start_y = sy + (self.NODE_H * self.scale / 2) * math.sin(angle)
        end_x = ex - (self.NODE_W * self.scale / 2) * math.cos(angle)
        end_y = ey - (self.NODE_H * self.scale / 2) * math.sin(angle)
        self.graph_canvas.create_line(start_x, start_y, end_x, end_y, fill=color, width=max(1, int(2 * self.scale)), arrow=tk.LAST)

    def _to_screen(self, x: float, y: float) -> tuple[float, float]:
        return (x * self.scale + self.pan_x, y * self.scale + self.pan_y)

    def _to_world(self, x: float, y: float) -> tuple[float, float]:
        return ((x - self.pan_x) / self.scale, (y - self.pan_y) / self.scale)

    def zoom_by(self, factor: float, cx: int | None = None, cy: int | None = None) -> None:
        cx = cx if cx is not None else self.graph_canvas.winfo_width() // 2
        cy = cy if cy is not None else self.graph_canvas.winfo_height() // 2
        wx, wy = self._to_world(cx, cy)
        self.scale = max(0.35, min(2.8, self.scale * factor))
        self.pan_x = cx - wx * self.scale
        self.pan_y = cy - wy * self.scale
        self.redraw_graph()

    def reset_view(self) -> None:
        self.scale = 1.0
        self.pan_x = 0.0
        self.pan_y = 0.0
        self.redraw_graph()

    def _on_canvas_press(self, event: tk.Event) -> None:
        self._pan_anchor = (event.x, event.y)

    def _on_canvas_drag(self, event: tk.Event) -> None:
        if not self._pan_anchor:
            return
        ax, ay = self._pan_anchor
        self.pan_x += event.x - ax
        self.pan_y += event.y - ay
        self._pan_anchor = (event.x, event.y)
        self.redraw_graph()

    def _on_canvas_release(self, event: tk.Event) -> None:
        self._pan_anchor = None
        clicked = self._topic_at_point(event.x, event.y)
        if clicked:
            self._select_topic(clicked)

    def _on_mousewheel(self, event: tk.Event) -> None:
        factor = 1.1 if event.delta > 0 else 1 / 1.1
        self.zoom_by(factor, event.x, event.y)

    def _topic_at_point(self, x: int, y: int) -> str | None:
        for topic, (x1, y1, x2, y2) in self.node_bounds.items():
            if x1 <= x <= x2 and y1 <= y <= y2:
                return topic
        return None

    def _on_table_select(self, _event: tk.Event | None = None) -> None:
        selected = self.topic_list.curselection()
        if not selected:
            return
        self._select_topic(self.topic_list.get(selected[0]))

    def _select_topic(self, topic_name: str) -> None:
        self.current_topic = topic_name
        self.load_selected_topic(topic_name)
        self.redraw_graph()

    def load_selected_topic(self, topic_name: str) -> None:
        """Shared loading path used by table and graph click handlers."""
        data = self.topics.get(topic_name, {})
        self.topic_name.set(topic_name)
        self.topic_text.delete("1.0", tk.END)
        self.topic_text.insert("1.0", data.get("text", ""))


if __name__ == "__main__":
    demo_topics = {
        "greeting": {"text": "Hello, traveler.", "opens_topics": ["quest", "rumors"]},
        "quest": {"text": "Could you help me?", "opens_topics": ["accept", "decline"]},
        "rumors": {"text": "They say a dragon woke.", "opens_topics": ["missing_topic"]},
        "accept": {"text": "Thank you!", "opens_topics": []},
        "decline": {"text": "That's unfortunate.", "opens_topics": []},
    }
    NPCDialogTool(demo_topics).mainloop()

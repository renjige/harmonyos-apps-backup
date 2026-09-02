#!/usr/bin/env python3
"""Rasterize 球星风采 symbol → PNG masters (PIL, no cairosvg required)."""
from __future__ import annotations

import math
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    raise SystemExit("Install: pip install pillow")

ROOT = Path(__file__).resolve().parent
MASTER = 1024
AGC = 216
BG = (22, 17, 13)  # #16110D
MARK = (244, 230, 195)  # #F4E6C3


def star_points(cx: float, cy: float, outer: float, inner: float) -> list[tuple[float, float]]:
    pts: list[tuple[float, float]] = []
    for i in range(8):
        ang = math.radians(-90 + i * 45)
        r = outer if i % 2 == 0 else inner
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    return pts


def paint_mark(draw: ImageDraw.ImageDraw, size: int, color: tuple[int, int, int]) -> None:
    s = size / 1024.0
    cx = cy = size / 2.0
    pts = star_points(cx, cy, 268 * s, 98 * s)
    draw.polygon(pts, fill=color)
    r = int(320 * s)
    box = (int(cx - r), int(cy - r), int(cx + r), int(cy + r))
    width = max(8, int(36 * s))
    draw.arc(box, start=300, end=70, fill=color, width=width)


def render_preview(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), BG)
    paint_mark(ImageDraw.Draw(img), size, MARK)
    return img


def render_foreground(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    paint_mark(ImageDraw.Draw(img), size, MARK + (255,))
    return img


def main() -> None:
    preview = render_preview(MASTER)
    preview.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), BG).save(ROOT / "background.png")
    render_foreground(MASTER).save(ROOT / "foreground.png")
    preview.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    preview.resize((32, 32), Image.Resampling.LANCZOS).save(ROOT / "favicon-32.png")
    print("OK rendered 球星风采 PNG masters")


if __name__ == "__main__":
    main()

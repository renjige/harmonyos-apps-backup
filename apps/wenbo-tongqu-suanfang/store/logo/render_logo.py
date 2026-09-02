#!/usr/bin/env python3
"""Rasterize 童趣算坊 mark to PNG masters (Pillow, no cairosvg)."""
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
BG = (30, 58, 95)
FG = (255, 255, 255)


def star_points(cx: float, cy: float, r_out: float, r_in: float, n: int = 5):
    pts = []
    start = -math.pi / 2
    for i in range(n * 2):
        ang = start + i * math.pi / n
        r = r_out if i % 2 == 0 else r_in
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    return pts


def draw_mark(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), BG)
    d = ImageDraw.Draw(img)
    s = size / 1024.0

    def xy(x: float, y: float):
        return (x * s, y * s)

    # Rounded numeral 7 as a thick polygon
    seven = [
        xy(300, 250),
        xy(720, 250),
        xy(768, 298),
        xy(768, 330),
        xy(720, 378),
        xy(560, 378),
        xy(430, 760),
        xy(300, 760),
        xy(460, 378),
        xy(300, 378),
        xy(252, 330),
        xy(252, 298),
    ]
    d.polygon(seven, fill=FG)

    # Abacus bead
    cx, cy, r = 368 * s, 742 * s, 92 * s
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=FG)
    # Star cutout in bead (same as background)
    d.polygon(star_points(cx, cy, 42 * s, 18 * s), fill=BG)
    return img


def main() -> None:
    preview = draw_mark(MASTER)
    preview.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), BG).save(ROOT / "background.png")
    fg = Image.new("RGBA", (MASTER, MASTER), (0, 0, 0, 0))
    fg.paste(preview)
    fg.save(ROOT / "foreground.png")
    preview.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    print("OK rendered PNG masters from Pillow mark")


if __name__ == "__main__":
    main()

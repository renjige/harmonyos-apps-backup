#!/usr/bin/env python3
"""Rasterize 亲子智谜 planet-puzzle mark with Pillow (no cairosvg)."""
from __future__ import annotations

from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    raise SystemExit("Install: pip install pillow")

ROOT = Path(__file__).resolve().parent
MASTER = 1024
AGC = 216
NAVY = (30, 58, 110)
WHITE = (255, 255, 255)


def draw_mark(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), NAVY)
    d = ImageDraw.Draw(img)
    s = size / 1024.0

    def xy(x: float, y: float) -> tuple[float, float]:
        return x * s, y * s

    def r(v: float) -> float:
        return v * s

    # orbit arc
    bbox = [250 * s, 250 * s, 774 * s, 530 * s]
    d.arc(bbox, start=200, end=340, fill=WHITE, width=max(2, int(28 * s)))
    # two dots (parent + child)
    d.ellipse([242 * s, 366 * s, 294 * s, 418 * s], fill=WHITE)
    d.ellipse([736 * s, 372 * s, 776 * s, 412 * s], fill=WHITE)
    # planet
    d.ellipse([276 * s, 324 * s, 748 * s, 796 * s], fill=WHITE)
    # puzzle box
    box = [428 * s, 488 * s, 596 * s, 656 * s]
    d.rounded_rectangle(box, radius=max(4, int(32 * s)), fill=NAVY)
    # lid line
    y = 544 * s
    d.line([(428 * s, y), (596 * s, y)], fill=WHITE, width=max(2, int(18 * s)))
    # box knob / wonder dot
    d.ellipse([490 * s, 582 * s, 534 * s, 626 * s], fill=WHITE)
    return img


def main() -> None:
    preview = draw_mark(MASTER)
    preview.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), NAVY).save(ROOT / "background.png")
    # foreground: white mark on transparent
    fg = Image.new("RGBA", (MASTER, MASTER), (0, 0, 0, 0))
    mask = draw_mark(MASTER)
    px = mask.load()
    out = fg.load()
    for y in range(MASTER):
        for x in range(MASTER):
            r, g, b = px[x, y]
            if r > 200:
                out[x, y] = (255, 255, 255, 255)
    fg.save(ROOT / "foreground.png")
    preview.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    print("OK rendered PNG masters from planet-puzzle mark")


if __name__ == "__main__":
    main()

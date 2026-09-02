#!/usr/bin/env python3
"""Rasterize 少儿画苑 brush+seedling mark with Pillow (no cairosvg)."""
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
DEEP = (74, 42, 28)
CREAM = (255, 245, 238)


def draw_mark(size: int, bg: tuple[int, int, int], fg: tuple[int, int, int]) -> Image.Image:
    img = Image.new("RGB", (size, size), bg)
    d = ImageDraw.Draw(img)
    s = size / 1024.0

    def r(v: float) -> float:
        return v * s

    # handle
    d.rounded_rectangle([r(470), r(548), r(554), r(824)], radius=max(4, int(42 * s)), fill=fg)
    # ferrule
    d.rounded_rectangle([r(462), r(500), r(562), r(556)], radius=max(3, int(10 * s)), fill=fg)
    # brush head triangle
    d.polygon([(r(512), r(236)), (r(628), r(508)), (r(396), r(508))], fill=fg)

    def ellipse_rot(cx: float, cy: float, rx: float, ry: float, deg: float) -> None:
        overlay = Image.new("L", (size, size), 0)
        od = ImageDraw.Draw(overlay)
        bbox = [cx - rx, cy - ry, cx + rx, cy + ry]
        od.ellipse(bbox, fill=255)
        rot = overlay.rotate(-deg, center=(cx, cy), resample=Image.Resampling.BICUBIC)
        color_layer = Image.new("RGB", (size, size), fg)
        img.paste(color_layer, (0, 0), rot)

    ellipse_rot(r(404), r(300), r(78), r(34), -32)
    ellipse_rot(r(620), r(292), r(78), r(34), 32)
    # stem notch in bg color (growth slit)
    d.rounded_rectangle([r(500), r(268), r(524), r(340)], radius=max(2, int(12 * s)), fill=bg)
    return img


def main() -> None:
    preview = draw_mark(MASTER, DEEP, CREAM)
    preview.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), DEEP).save(ROOT / "background.png")
    fg_img = Image.new("RGBA", (MASTER, MASTER), (0, 0, 0, 0))
    mask = draw_mark(MASTER, (0, 0, 0), (255, 255, 255))
    px = mask.load()
    out = fg_img.load()
    for y in range(MASTER):
        for x in range(MASTER):
            r, g, b = px[x, y]
            if r > 200:
                out[x, y] = (255, 245, 238, 255)
    fg_img.save(ROOT / "foreground.png")
    preview.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    print("OK rendered PNG masters from brush-seedling mark")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Rasterize 筑科材料验收 symbol → PNG masters (PIL, no cairosvg required)."""
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
BG = (26, 31, 38)
WHITE = (255, 255, 255)
CHECK = (122, 158, 128)


def draw_round_line(draw: ImageDraw.ImageDraw, a, b, color, width: int) -> None:
    draw.line([a, b], fill=color, width=width)
    r = width // 2
    draw.ellipse((a[0] - r, a[1] - r, a[0] + r, a[1] + r), fill=color)
    draw.ellipse((b[0] - r, b[1] - r, b[0] + r, b[1] + r), fill=color)


def render_symbol(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), BG)
    draw = ImageDraw.Draw(img)
    s = size / 1024.0
    pad = int(168 * s)
    frame_w = int(36 * s)
    radius = int(96 * s)
    draw.rounded_rectangle(
        (pad, pad, size - pad, size - pad),
        radius=radius,
        outline=WHITE,
        width=max(3, frame_w),
    )
    w = max(8, int(56 * s))
    draw_round_line(draw, (int(300 * s), int(320 * s)), (int(700 * s), int(320 * s)), WHITE, w)
    draw_round_line(draw, (int(700 * s), int(320 * s)), (int(340 * s), int(704 * s)), WHITE, w)
    draw_round_line(draw, (int(340 * s), int(704 * s)), (int(560 * s), int(704 * s)), WHITE, w)
    cw = max(8, int(52 * s))
    draw_round_line(draw, (int(520 * s), int(560 * s)), (int(620 * s), int(700 * s)), CHECK, cw)
    draw_round_line(draw, (int(620 * s), int(700 * s)), (int(820 * s), int(420 * s)), CHECK, cw)
    return img


def main() -> None:
    preview = render_symbol(MASTER)
    preview.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), BG).save(ROOT / "background.png")
    fg = Image.new("RGBA", (MASTER, MASTER), (0, 0, 0, 0))
    fg.paste(preview.convert("RGBA"))
    fg.save(ROOT / "foreground.png")
    preview.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    print("OK rendered PNG masters from geometric ZK+check")


if __name__ == "__main__":
    main()

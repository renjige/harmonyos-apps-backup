#!/usr/bin/env python3
"""Rasterize 灵感笺 mark with Pillow (no cairosvg required)."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent
MASTER = 1024
AGC = 216
INK = (24, 35, 58, 255)
GOLD = (229, 184, 107, 255)
CREAM = (247, 243, 234, 255)


def rounded_rect_mask(size: int, radius: int) -> Image.Image:
    img = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return img


def star_points(cx: float, cy: float, r_out: float, r_in: float) -> list[tuple[float, float]]:
    pts: list[tuple[float, float]] = []
    import math

    for i in range(8):
        ang = -math.pi / 2 + i * math.pi / 4
        r = r_out if i % 2 == 0 else r_in
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    return pts


def render_mark(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    k = size / 1024.0
    r = int(228 * k)
    tile = Image.new("RGBA", (size, size), INK)
    tile.putalpha(rounded_rect_mask(size, r))
    img.alpha_composite(tile)

    paper = [
        (268 * k, 236 * k),
        (660 * k, 236 * k),
        (808 * k, 384 * k),
        (808 * k, 780 * k),
        (728 * k, 860 * k),
        (348 * k, 860 * k),
        (268 * k, 780 * k),
        (268 * k, 316 * k),
    ]
    draw.polygon(paper, fill=GOLD)
    fold = [
        (660 * k, 236 * k),
        (808 * k, 384 * k),
        (708 * k, 384 * k),
        (660 * k, 336 * k),
    ]
    draw.polygon(fold, fill=INK)
    star = star_points(512 * k, 620 * k, 118 * k, 48 * k)
    draw.polygon(star, fill=CREAM)
    return img


def main() -> None:
    mark = render_mark(MASTER)
    rgb = Image.new("RGB", (MASTER, MASTER), (24, 35, 58))
    rgb.paste(mark, mask=mark.split()[-1])
    rgb.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), (247, 243, 234)).save(ROOT / "background.png")
    mark.save(ROOT / "foreground.png")
    rgb.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")

    board = Image.new("RGB", (1280, 360), (247, 243, 234))
    icon = render_mark(288)
    board.paste(icon, (40, 36), icon)
    draw = ImageDraw.Draw(board)
    try:
        from PIL import ImageFont

        font = ImageFont.truetype("msyh.ttc", 84)
        sub = ImageFont.truetype("msyh.ttc", 28)
    except OSError:
        font = ImageFont.load_default()
        sub = font
    draw.text((360, 88), "灵感笺", font=font, fill=(24, 35, 58))
    draw.text((360, 210), "Linggan Jian  ·  记录灵感，收藏小心思", font=sub, fill=(133, 139, 153))
    board.save(ROOT / "logo-horizontal.png")
    print("OK rendered PNG masters for 灵感笺")


if __name__ == "__main__":
    main()

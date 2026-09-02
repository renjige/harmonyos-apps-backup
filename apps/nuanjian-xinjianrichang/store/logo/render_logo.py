#!/usr/bin/env python3
"""Rasterize 心笺日常 mark with Pillow (no cairosvg required)."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent
MASTER = 1024
AGC = 216
APRICOT = (233, 141, 131, 255)
CREAM = (255, 249, 246, 255)
INK = (39, 35, 33, 255)


def rounded_rect_mask(size: int, radius: int) -> Image.Image:
    img = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return img


def heart_points(cx: float, cy: float, s: float) -> list[tuple[float, float]]:
    pts: list[tuple[float, float]] = []
    for i in range(72):
        t = (i / 72.0) * math.tau
        x = s * 16 * math.sin(t) ** 3
        y = -s * (
            13 * math.cos(t)
            - 5 * math.cos(2 * t)
            - 2 * math.cos(3 * t)
            - math.cos(4 * t)
        )
        pts.append((cx + x, cy + y * 0.92))
    return pts


def render_mark(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    k = size / 1024.0
    r = int(228 * k)
    tile = Image.new("RGBA", (size, size), APRICOT)
    tile.putalpha(rounded_rect_mask(size, r))
    img.alpha_composite(tile)

    paper = [
        (236 * k, 252 * k),
        (666 * k, 252 * k),
        (818 * k, 404 * k),
        (818 * k, 776 * k),
        (742 * k, 852 * k),
        (312 * k, 852 * k),
        (236 * k, 776 * k),
        (236 * k, 328 * k),
    ]
    draw.polygon(paper, fill=CREAM)

    heart = heart_points(512 * k, 620 * k, 9.2 * k)
    draw.polygon(heart, fill=APRICOT)

    cx, cy = 768 * k, 328 * k
    draw.ellipse((cx - 46 * k, cy - 46 * k, cx + 46 * k, cy + 46 * k), fill=CREAM)
    draw.ellipse((cx - 18 * k, cy - 18 * k, cx + 18 * k, cy + 18 * k), fill=APRICOT)
    return img


def main() -> None:
    mark = render_mark(MASTER)
    rgb = Image.new("RGB", (MASTER, MASTER), (233, 141, 131))
    rgb.paste(mark, mask=mark.split()[-1])
    rgb.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), (255, 249, 246)).save(ROOT / "background.png")
    mark.save(ROOT / "foreground.png")
    rgb.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")

    # horizontal wordmark board
    board = Image.new("RGB", (1280, 360), (255, 249, 246))
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
    draw.text((360, 88), "心笺日常", font=font, fill=INK)
    draw.text((360, 210), "HeartNote  ·  记录日常，收藏心情", font=sub, fill=(142, 136, 132))
    board.save(ROOT / "logo-horizontal.png")
    print("OK rendered PNG masters for 心笺日常")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Rasterize 梦隅札 mark — corner window + crescent."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent
MASTER = 1024
AGC = 216
DEEP = (26, 26, 46, 255)
GOLD = (201, 168, 124, 255)
CREAM = (245, 240, 232, 255)


def rounded_rect_mask(size: int, radius: int) -> Image.Image:
    img = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return img


def render_mark(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    k = size / 1024.0
    r = int(228 * k)
    tile = Image.new("RGBA", (size, size), DEEP)
    tile.putalpha(rounded_rect_mask(size, r))
    img.alpha_composite(tile)

    paper = [
        (268 * k, 780 * k),
        (268 * k, 320 * k),
        (512 * k, 236 * k),
        (756 * k, 320 * k),
        (756 * k, 780 * k),
        (512 * k, 860 * k),
    ]
    draw.polygon(paper, fill=GOLD)
    fold = [
        (512 * k, 236 * k),
        (756 * k, 320 * k),
        (656 * k, 320 * k),
        (512 * k, 276 * k),
    ]
    draw.polygon(fold, fill=DEEP)

    cx, cy = 512 * k, 460 * k
    draw.ellipse((cx - 108 * k, cy - 108 * k, cx + 108 * k, cy + 108 * k), fill=CREAM)
    draw.ellipse((cx - 40 * k, cy - 120 * k, cx + 160 * k, cy + 120 * k), fill=DEEP)
    return img


def main() -> None:
    mark = render_mark(MASTER)
    rgb = Image.new("RGB", (MASTER, MASTER), (26, 26, 46))
    rgb.paste(mark, mask=mark.split()[-1])
    rgb.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), (26, 26, 46)).save(ROOT / "background.png")
    mark.save(ROOT / "foreground.png")
    rgb.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")

    board = Image.new("RGB", (1280, 360), (245, 240, 232))
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
    draw.text((360, 88), "梦隅札", font=font, fill=(26, 26, 46))
    draw.text((360, 210), "Mengyu Zha  ·  记录梦境 · 洞察自我", font=sub, fill=(120, 115, 105))
    board.save(ROOT / "logo-horizontal.png")
    print("OK rendered PNG masters for 梦隅札")


if __name__ == "__main__":
    main()

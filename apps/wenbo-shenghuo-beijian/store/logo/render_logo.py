#!/usr/bin/env python3
"""Rasterize 生活备笺 mark with Pillow (no cairosvg required)."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
MASTER = 1024
AGC = 216
TEAL = (61, 130, 119, 255)
CREAM = (247, 245, 239, 255)
INK = (37, 49, 47, 255)
MUTED = (123, 133, 130, 255)


def rounded_rect_mask(size: int, radius: int) -> Image.Image:
    img = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return img


def render_mark(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    k = size / 1024.0
    r = int(220 * k)
    tile = Image.new("RGBA", (size, size), TEAL)
    tile.putalpha(rounded_rect_mask(size, r))
    img.alpha_composite(tile)

    paper = [
        (268 * k, 248 * k),
        (660 * k, 248 * k),
        (796 * k, 384 * k),
        (796 * k, 776 * k),
        (716 * k, 856 * k),
        (348 * k, 856 * k),
        (268 * k, 776 * k),
        (268 * k, 328 * k),
    ]
    draw.polygon(paper, fill=CREAM)
    fold = [
        (660 * k, 248 * k),
        (796 * k, 384 * k),
        (708 * k, 384 * k),
        (660 * k, 336 * k),
    ]
    draw.polygon(fold, fill=TEAL)
    x0, y0, x1, y1 = 348 * k, 488 * k, 596 * k, 516 * k
    draw.rounded_rectangle((x0, y0, x1, y1), radius=14 * k, fill=TEAL)
    cx, cy, rr = 732 * k, 332 * k, 42 * k
    draw.ellipse((cx - rr, cy - rr, cx + rr, cy + rr), fill=CREAM)
    return img


def main() -> None:
    mark = render_mark(MASTER)
    rgb = Image.new("RGB", (MASTER, MASTER), (61, 130, 119))
    rgb.paste(mark, mask=mark.split()[-1])
    rgb.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), (247, 245, 239)).save(ROOT / "background.png")
    mark.save(ROOT / "foreground.png")
    rgb.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")

    board = Image.new("RGB", (1280, 360), (247, 245, 239))
    icon = mark.resize((288, 288), Image.Resampling.LANCZOS)
    board.paste(icon, (48, 36), icon)
    draw = ImageDraw.Draw(board)
    try:
        font_title = ImageFont.truetype("msyh.ttc", 72)
        font_sub = ImageFont.truetype("georgia.ttf", 28)
    except OSError:
        font_title = ImageFont.load_default()
        font_sub = font_title
    draw.text((372, 108), "生活备笺", font=font_title, fill=INK)
    draw.text((372, 210), "Life Slip", font=font_sub, fill=MUTED)
    board.save(ROOT / "logo-horizontal.png")
    print("logo rendered")


if __name__ == "__main__":
    main()

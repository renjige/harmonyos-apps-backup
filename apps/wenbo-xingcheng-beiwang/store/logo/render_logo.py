#!/usr/bin/env python3
"""Rasterize 行程备忘 mark with Pillow (no cairosvg required)."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
MASTER = 1024
AGC = 216
NAVY = (27, 39, 68, 255)
CREAM = (246, 245, 242, 255)
BLUE = (76, 126, 212, 255)
MUTED = (138, 147, 163, 255)
INK = (27, 39, 68, 255)


def rounded_rect_mask(size: int, radius: int) -> Image.Image:
    img = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return img


def render_mark(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    k = size / 1024.0
    tile = Image.new("RGBA", (size, size), NAVY)
    tile.putalpha(rounded_rect_mask(size, int(220 * k)))
    img.alpha_composite(tile)

    x0, y0 = 392 * k, 236 * k
    x1, y1 = 428 * k, 788 * k
    draw.rounded_rectangle((x0, y0, x1, y1), radius=18 * k, fill=CREAM)
    draw.ellipse((410 * k - 34 * k, 332 * k - 34 * k, 410 * k + 34 * k, 332 * k + 34 * k), fill=CREAM)
    draw.ellipse((410 * k - 28 * k, 532 * k - 28 * k, 410 * k + 28 * k, 532 * k + 28 * k), fill=BLUE)
    draw.ellipse((410 * k - 16 * k, 532 * k - 16 * k, 410 * k + 16 * k, 532 * k + 16 * k), fill=CREAM)
    draw.ellipse((410 * k - 34 * k, 724 * k - 34 * k, 410 * k + 34 * k, 724 * k + 34 * k), fill=CREAM)
    draw.rounded_rectangle((500 * k, 430 * k, 768 * k, 626 * k), radius=36 * k, fill=CREAM)
    draw.rounded_rectangle((536 * k, 486 * k, 684 * k, 504 * k), radius=9 * k, fill=NAVY)
    draw.rounded_rectangle((536 * k, 532 * k, 632 * k, 546 * k), radius=7 * k, fill=MUTED)
    return img


def main() -> None:
    mark = render_mark(MASTER)
    rgb = Image.new("RGB", (MASTER, MASTER), (27, 39, 68))
    rgb.paste(mark, mask=mark.split()[-1])
    rgb.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), (246, 245, 242)).save(ROOT / "background.png")
    mark.save(ROOT / "foreground.png")
    rgb.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")

    board = Image.new("RGB", (1280, 360), (246, 245, 242))
    icon = mark.resize((288, 288), Image.Resampling.LANCZOS)
    board.paste(icon, (48, 36), icon)
    draw = ImageDraw.Draw(board)
    try:
        font_title = ImageFont.truetype("msyh.ttc", 72)
        font_sub = ImageFont.truetype("georgia.ttf", 28)
    except OSError:
        font_title = ImageFont.load_default()
        font_sub = font_title
    draw.text((372, 108), "行程备忘", font=font_title, fill=INK)
    draw.text((372, 210), "Itinerary Memo", font=font_sub, fill=MUTED)
    board.save(ROOT / "logo-horizontal.png")
    print("logo rendered")


if __name__ == "__main__":
    main()

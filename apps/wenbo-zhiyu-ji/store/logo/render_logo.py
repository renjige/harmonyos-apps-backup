#!/usr/bin/env python3
"""Rasterize 知语集 mark with Pillow."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent
MASTER = 1024
AGC = 216
INK = (26, 42, 58, 255)
GOLD = (201, 169, 110, 255)
CREAM = (247, 245, 240, 255)


def render_mark(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    k = size / 1024.0

    draw.rectangle((0, 0, size - 1, size - 1), fill=INK)
    draw.rectangle(
        (int(220 * k), int(260 * k), int(804 * k), int(764 * k)),
        fill=(247, 245, 240, int(255 * 0.08)),
    )
    draw.line((int(512 * k), int(260 * k), int(512 * k), int(764 * k)), fill=GOLD, width=max(1, int(6 * k)))

    draw.rounded_rectangle(
        (int(340 * k), int(300 * k), int(684 * k), int(356 * k)),
        radius=int(8 * k),
        fill=GOLD,
    )
    for x in (380, 460, 540, 620):
        draw.rounded_rectangle(
            (int(x * k), int(380 * k), int((x + 48) * k), int(600 * k)),
            radius=int(6 * k),
            fill=CREAM,
        )
    draw.rounded_rectangle(
        (int(420 * k), int(460 * k), int(604 * k), int(500 * k)),
        radius=int(6 * k),
        fill=(*GOLD[:3], int(255 * 0.85)),
    )
    draw.rounded_rectangle(
        (int(420 * k), int(540 * k), int(604 * k), int(580 * k)),
        radius=int(6 * k),
        fill=(*GOLD[:3], int(255 * 0.65)),
    )
    draw.ellipse((int(280 * k), int(580 * k), int(360 * k), int(640 * k)), fill=(*GOLD[:3], int(255 * 0.5)))
    draw.ellipse((int(664 * k), int(580 * k), int(744 * k), int(640 * k)), fill=(*GOLD[:3], int(255 * 0.5)))
    return img


def main() -> None:
    mark = render_mark(MASTER)
    rgb = Image.new("RGB", (MASTER, MASTER), INK[:3])
    rgb.paste(mark, mask=mark.split()[-1])
    rgb.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), CREAM[:3]).save(ROOT / "background.png")
    mark.save(ROOT / "foreground.png")
    rgb.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    print("rendered 知语集 logo pngs")


if __name__ == "__main__":
    main()

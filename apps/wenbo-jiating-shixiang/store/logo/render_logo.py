#!/usr/bin/env python3
"""Rasterize store/logo/symbol.svg → PNG masters. Pillow fallback if cairosvg missing."""
from __future__ import annotations

import io
import math
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Install: pip install pillow", file=sys.stderr)
    sys.exit(1)

ROOT = Path(__file__).resolve().parent
SYMBOL = ROOT / "symbol.svg"
MASTER = 1024
AGC = 216
BG = (36, 68, 58)
FG = (246, 241, 232)


def render_with_cairo() -> Image.Image | None:
    try:
        import cairosvg
    except ImportError:
        return None
    if not SYMBOL.exists():
        return None
    svg = SYMBOL.read_text(encoding="utf-8")
    png_bytes = cairosvg.svg2png(bytestring=svg.encode("utf-8"), output_width=MASTER, output_height=MASTER)
    return Image.open(io.BytesIO(png_bytes)).convert("RGBA")


def draw_mark() -> Image.Image:
    img = Image.new("RGBA", (MASTER, MASTER), BG + (255,))
    d = ImageDraw.Draw(img)

    def line(points: list[tuple[float, float]], width: int) -> None:
        d.line(points, fill=FG, width=width, joint="curve")
        r = width // 2
        for x, y in points:
            d.ellipse((x - r, y - r, x + r, y + r), fill=FG)

    line([(250, 530), (512, 268), (774, 530)], 58)
    line([(388, 572), (478, 670), (678, 430)], 54)
    return img


def main() -> None:
    rgba = render_with_cairo()
    if rgba is None:
        rgba = draw_mark()
    preview = Image.new("RGB", (MASTER, MASTER), BG)
    preview.paste(rgba, mask=rgba.split()[-1] if rgba.mode == "RGBA" else None)
    preview.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), BG).save(ROOT / "background.png")
    rgba.save(ROOT / "foreground.png")
    preview.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    print("OK rendered PNG masters")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Rasterize store/logo/symbol.svg → PNG masters. Pillow fallback if cairosvg missing."""
from __future__ import annotations

import io
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
BG = (22, 50, 79)
FG = (244, 247, 250)
ACCENT = (242, 140, 40)


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


def rounded_rect(d: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int, fill: tuple[int, int, int]) -> None:
    d.rounded_rectangle(box, radius=radius, fill=fill)


def draw_mark() -> Image.Image:
    img = Image.new("RGBA", (MASTER, MASTER), BG + (255,))
    d = ImageDraw.Draw(img)
    rounded_rect(d, (268, 248, 756, 340), 20, FG)
    rounded_rect(d, (268, 372, 756, 464), 20, FG)
    rounded_rect(d, (268, 496, 756, 588), 20, FG)
    rounded_rect(d, (300, 608, 388, 776), 18, FG)
    rounded_rect(d, (636, 608, 724, 776), 18, FG)
    d.line([(430, 700), (520, 800), (760, 500)], fill=ACCENT, width=92, joint="curve")
    r = 46
    for x, y in ((430, 700), (520, 800), (760, 500)):
        d.ellipse((x - r, y - r, x + r, y + r), fill=ACCENT)
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

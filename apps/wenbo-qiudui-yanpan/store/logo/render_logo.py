#!/usr/bin/env python3
"""Rasterize store/logo/symbol.svg → PNG masters."""
from __future__ import annotations

import io
import sys
from pathlib import Path

try:
    import cairosvg
except ImportError:
    print("Install: pip install cairosvg pillow", file=sys.stderr)
    sys.exit(1)

try:
    from PIL import Image
except ImportError:
    print("Install: pip install pillow", file=sys.stderr)
    sys.exit(1)

ROOT = Path(__file__).resolve().parent
SYMBOL = ROOT / "symbol.svg"
MASTER = 1024
AGC = 216
BG = (15, 23, 42)


def main() -> None:
    if not SYMBOL.exists():
        print(f"missing {SYMBOL}", file=sys.stderr)
        sys.exit(1)
    svg = SYMBOL.read_text(encoding="utf-8")
    png_bytes = cairosvg.svg2png(bytestring=svg.encode("utf-8"), output_width=MASTER, output_height=MASTER)
    preview = Image.open(io.BytesIO(png_bytes)).convert("RGB")
    preview.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), BG).save(ROOT / "background.png")
    Image.open(io.BytesIO(png_bytes)).convert("RGBA").save(ROOT / "foreground.png")
    preview.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    print("OK rendered PNG masters from symbol.svg")


if __name__ == "__main__":
    main()

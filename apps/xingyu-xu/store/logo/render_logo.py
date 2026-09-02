#!/usr/bin/env python3
"""Rasterize store/logo/symbol.svg → PNG masters (cairosvg + Pillow), with PNG fallback."""
from __future__ import annotations

import io
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SYMBOL = ROOT / "symbol.svg"
MASTER = 1024
AGC = 216
BG = (18, 24, 43)

ASSETS = Path(r"C:\Users\Administrator\.cursor\projects\e-huawei001-master\assets")
FALLBACK = ASSETS / "xingyu-logo-preview.png"


def from_svg() -> bool:
    try:
        import cairosvg
        from PIL import Image
    except ImportError:
        return False
    if not SYMBOL.exists():
        return False
    svg = SYMBOL.read_text(encoding="utf-8")
    png_bytes = cairosvg.svg2png(bytestring=svg.encode("utf-8"), output_width=MASTER, output_height=MASTER)
    preview = Image.open(io.BytesIO(png_bytes)).convert("RGB")
    preview.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), BG).save(ROOT / "background.png")
    Image.open(io.BytesIO(png_bytes)).convert("RGBA").save(ROOT / "foreground.png")
    preview.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    print("OK rendered PNG masters from symbol.svg")
    return True


def from_fallback() -> None:
    from PIL import Image

    src = FALLBACK if FALLBACK.exists() else ROOT / "preview-1024.png"
    if not src.exists():
        print("missing logo source png", file=sys.stderr)
        sys.exit(1)
    im = Image.open(src).convert("RGB").resize((MASTER, MASTER), Image.Resampling.LANCZOS)
    im.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), BG).save(ROOT / "background.png")
    im.convert("RGBA").save(ROOT / "foreground.png")
    im.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    print("OK rendered PNG masters from fallback png")


def main() -> None:
    if not from_svg():
        from_fallback()


if __name__ == "__main__":
    main()

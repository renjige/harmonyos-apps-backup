#!/usr/bin/env python3
"""Rasterize 诗词寻宝 seal mark. Deep ink ground + gold 诗 seal. No rounded icon mask."""
from __future__ import annotations

from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    raise SystemExit("Install: pip install pillow")

ROOT = Path(__file__).resolve().parent
MASTER = 1024
AGC = 216
INK = (26, 26, 46)
GOLD = (201, 168, 76)


def load_font(size: int) -> ImageFont.ImageFont:
    candidates = [
        r"C:\Windows\Fonts\simsun.ttc",
        r"C:\Windows\Fonts\simhei.ttf",
        r"C:\Windows\Fonts\msyh.ttc",
        "/usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc",
    ]
    for p in candidates:
        try:
            return ImageFont.truetype(p, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


def draw_mark(size: int, transparent: bool) -> Image.Image:
    mode = "RGBA" if transparent else "RGB"
    bg = (0, 0, 0, 0) if transparent else INK
    img = Image.new(mode, (size, size), bg)
    d = ImageDraw.Draw(img)
    s = size / 1024.0
    gold = GOLD + ((255,) if transparent else ())
    pad = int(196 * s)
    d.rectangle([pad, pad, size - pad, size - pad], outline=gold, width=max(4, int(28 * s)))
    inner = int(236 * s)
    d.rectangle([inner, inner, size - inner, size - inner], outline=gold, width=max(2, int(8 * s)))
    font = load_font(int(360 * s))
    ch = "诗"
    bbox = d.textbbox((0, 0), ch, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text(((size - tw) / 2 - bbox[0], (size - th) / 2 - bbox[1] - int(12 * s)), ch, font=font, fill=gold)
    # compass nub at seal corner
    cx, cy = int(760 * s), int(268 * s)
    d.polygon([(cx, cy), (cx + int(36 * s), cy - int(36 * s)), (cx + int(16 * s), cy + int(12 * s))], fill=gold)
    return img


def main() -> None:
    preview = draw_mark(MASTER, False)
    preview.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), INK).save(ROOT / "background.png")
    draw_mark(MASTER, True).save(ROOT / "foreground.png")
    preview.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    print("OK rendered 诗词寻宝 seal")


if __name__ == "__main__":
    main()

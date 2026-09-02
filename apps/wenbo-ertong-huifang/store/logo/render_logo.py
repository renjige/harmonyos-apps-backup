#!/usr/bin/env python3
"""儿童绘坊 — 暖橙底画笔微笑图标"""
from __future__ import annotations

from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    raise SystemExit("Install: pip install pillow")

ROOT = Path(__file__).resolve().parent
MASTER = 1024
AGC = 216
BG = (230, 74, 25)  # #E64A19
FG = (255, 255, 255)
ACCENT = (79, 195, 247)  # #4FC3F7
LIGHT = (255, 224, 178)


def draw_mark(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), BG)
    d = ImageDraw.Draw(img)
    s = size / 1024.0

    def xy(x: float, y: float):
        return (x * s, y * s)

    brush_left = [
        xy(320, 680), xy(420, 280), xy(520, 300), xy(480, 720),
    ]
    d.polygon(brush_left, fill=FG)
    brush_right = [
        xy(480, 300), xy(620, 340), xy(560, 760), xy(480, 720),
    ]
    d.polygon(brush_right, fill=LIGHT)
    d.arc([xy(400, 520), xy(560, 620)], start=20, end=160, fill=ACCENT, width=int(28 * s))
    r = 48 * s
    cx, cy = 640 * s, 360 * s
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=ACCENT)
    return img


def main() -> None:
    preview = draw_mark(MASTER)
    preview.save(ROOT / "preview-1024.png")
    Image.new("RGB", (MASTER, MASTER), BG).save(ROOT / "background.png")
    fg = Image.new("RGBA", (MASTER, MASTER), (0, 0, 0, 0))
    fg.paste(preview)
    fg.save(ROOT / "foreground.png")
    preview.resize((AGC, AGC), Image.Resampling.LANCZOS).save(ROOT / "agc-216.png")
    app_root = ROOT.parent.parent / "app"
    for rel in [
        "AppScope/resources/base/media/app_icon.png",
        "entry/src/main/resources/base/media/icon.png",
        "entry/src/main/resources/base/media/startIcon.png",
        "entry/src/main/resources/base/media/app_icon.png",
    ]:
        target = app_root / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        preview.save(target)
    print("OK 儿童绘坊 logo rendered")


if __name__ == "__main__":
    main()

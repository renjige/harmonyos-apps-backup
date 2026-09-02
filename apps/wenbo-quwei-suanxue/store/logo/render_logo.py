#!/usr/bin/env python3
"""趣味算学 — 智慧蓝底 + 数字与加号融合图形"""
from __future__ import annotations

from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    raise SystemExit("Install: pip install pillow")

ROOT = Path(__file__).resolve().parent
MASTER = 1024
AGC = 216
BG = (74, 144, 217)  # #4A90D9
FG = (255, 255, 255)
ACCENT = (245, 166, 35)  # #F5A623


def draw_mark(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), BG)
    d = ImageDraw.Draw(img)
    s = size / 1024.0

    def xy(x: float, y: float):
        return (x * s, y * s)

    # Stylized "1"
    one = [
        xy(340, 220), xy(420, 220), xy(420, 760), xy(340, 760), xy(340, 220),
    ]
    d.polygon(one, fill=FG)

    # Plus arm (horizontal)
    d.rounded_rectangle(
        [xy(480, 470), xy(720, 530)], radius=int(30 * s), fill=ACCENT
    )
    # Plus arm (vertical)
    d.rounded_rectangle(
        [xy(570, 380), xy(630, 620)], radius=int(30 * s), fill=ACCENT
    )

    # Smile arc
    d.arc([xy(360, 560), xy(560, 720)], start=20, end=160, fill=ACCENT, width=int(18 * s))

    # Star sparkle
    cx, cy, r = 760 * s, 300 * s, 36 * s
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
    app_icon = ROOT.parent.parent / "app" / "AppScope" / "resources" / "base" / "media" / "app_icon.png"
    app_icon.parent.mkdir(parents=True, exist_ok=True)
    preview.save(app_icon)
    entry_icon = ROOT.parent.parent / "app" / "entry" / "src" / "main" / "resources" / "base" / "media" / "icon.png"
    entry_icon.parent.mkdir(parents=True, exist_ok=True)
    preview.save(entry_icon)
    start = ROOT.parent.parent / "app" / "entry" / "src" / "main" / "resources" / "base" / "media" / "startIcon.png"
    preview.save(start)
    print("OK 趣味算学 logo rendered")


if __name__ == "__main__":
    main()

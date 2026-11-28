#!/usr/bin/env python3
"""Uygulama ikonunu uretir.

Ikon tasarimi oyunun estetigini tasiyor: koyu slate zemin, neon yesil
terminal istemi ve yukari giden bir cizgi (degerleme). Harici bir tasarim
dosyasina bagimli olmamak icin kod ile ciziliyor; boylece renk degisirse
tek komutla yeniden uretilebiliyor.

Kullanim:
    python3 tool/make_icon.py
"""

from __future__ import annotations

import pathlib
import subprocess
import sys

from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "icon"

BG = (11, 15, 20)
BG_INNER = (21, 27, 35)
GREEN = (63, 224, 143)
AMBER = (245, 185, 66)
BORDER = (42, 51, 64)

# Android mipmap yogunluklari ve kenar uzunluklari.
ANDROID = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

# iOS AppIcon setindeki boyutlar: (dosya adi, kenar uzunlugu).
IOS = [
    ("Icon-App-20x20@1x.png", 20), ("Icon-App-20x20@2x.png", 40),
    ("Icon-App-20x20@3x.png", 60), ("Icon-App-29x29@1x.png", 29),
    ("Icon-App-29x29@2x.png", 58), ("Icon-App-29x29@3x.png", 87),
    ("Icon-App-40x40@1x.png", 40), ("Icon-App-40x40@2x.png", 80),
    ("Icon-App-40x40@3x.png", 120), ("Icon-App-60x60@2x.png", 120),
    ("Icon-App-60x60@3x.png", 180), ("Icon-App-76x76@1x.png", 76),
    ("Icon-App-76x76@2x.png", 152), ("Icon-App-83.5x83.5@2x.png", 167),
    ("Icon-App-1024x1024@1x.png", 1024),
]


def draw_icon(size: int, *, rounded: bool) -> Image.Image:
    """Verilen kenar uzunlugunda ikonu cizer."""
    # 4x buyuk cizip kucultuyoruz: kenarlar yumusak ciksin.
    scale = 4
    s = size * scale
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    radius = int(s * 0.22)
    if rounded:
        d.rounded_rectangle([0, 0, s - 1, s - 1], radius=radius, fill=BG)
    else:
        # iOS kendi maskesini uyguluyor; tam kare ve opak olmali.
        d.rectangle([0, 0, s - 1, s - 1], fill=BG)

    # Ic panel: terminal penceresi.
    m = int(s * 0.17)
    d.rounded_rectangle(
        [m, m, s - m, s - m],
        radius=int(s * 0.07),
        fill=BG_INNER,
        outline=BORDER,
        width=max(1, int(s * 0.012)),
    )

    # Terminal istemi: ">" isareti.
    w = max(2, int(s * 0.035))
    x0, y0 = int(s * 0.30), int(s * 0.37)
    arm = int(s * 0.10)
    d.line([(x0, y0), (x0 + arm, y0 + arm)], fill=GREEN, width=w,
           joint="curve")
    d.line([(x0 + arm, y0 + arm), (x0, y0 + 2 * arm)], fill=GREEN, width=w,
           joint="curve")

    # Alt cizgi: imlec.
    d.line(
        [(int(s * 0.47), int(s * 0.57)), (int(s * 0.63), int(s * 0.57))],
        fill=GREEN, width=w,
    )

    # Yukari giden deger cizgisi: degerleme grafigi.
    pts = [
        (int(s * 0.30), int(s * 0.72)),
        (int(s * 0.44), int(s * 0.66)),
        (int(s * 0.56), int(s * 0.71)),
        (int(s * 0.70), int(s * 0.60)),
    ]
    d.line(pts, fill=AMBER, width=max(2, int(s * 0.028)), joint="curve")

    return img.resize((size, size), Image.LANCZOS)


def write(img: Image.Image, path: pathlib.Path, *, opaque: bool) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if opaque:
        # App Store saydam kanal kabul etmiyor.
        flat = Image.new("RGB", img.size, BG)
        flat.paste(img, mask=img.split()[3])
        flat.save(path)
    else:
        img.save(path)


def main() -> int:
    # Magaza listelemesi ve README icin ana gorsel.
    write(draw_icon(512, rounded=True), OUT / "icon-512.png", opaque=False)
    write(draw_icon(1024, rounded=True), OUT / "icon-1024.png", opaque=False)

    android = ROOT / "android" / "app" / "src" / "main" / "res"
    for folder, size in ANDROID.items():
        icon = draw_icon(size, rounded=True)
        write(icon, android / folder / "ic_launcher.png", opaque=False)

    ios = (ROOT / "ios" / "Runner" / "Assets.xcassets" /
           "AppIcon.appiconset")
    if ios.exists():
        for name, size in IOS:
            write(draw_icon(size, rounded=False), ios / name, opaque=True)

    print("Ikonlar uretildi.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

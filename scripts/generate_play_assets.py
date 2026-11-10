#!/usr/bin/env python3
"""Generates the Google Play icon (512x512) and feature graphic (1024x500)
from assets/images into android/app/src/main/play/listings/en-US/graphics.

Requires Pillow. Run from anywhere: python3 scripts/generate_play_assets.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
IMAGES = ROOT / "assets" / "images"
OUT = ROOT / "android/app/src/main/play/listings/en-US/graphics"


def icon() -> None:
    im = Image.open(IMAGES / "icon.png").convert("RGBA")
    side = min(im.size)
    left = (im.width - side) // 2
    top = (im.height - side) // 2
    im = im.crop((left, top, left + side, top + side)).resize((512, 512), Image.LANCZOS)
    (OUT / "icon").mkdir(parents=True, exist_ok=True)
    im.save(OUT / "icon" / "icon.png", optimize=True)


def feature_graphic() -> None:
    # banner-appstore.png is 1536x1024; keep the title and vehicles in a 1024:500 band.
    im = Image.open(IMAGES / "banner-appstore.png").convert("RGB")
    band = round(im.width * 500 / 1024)
    top = 120
    im = im.crop((0, top, im.width, top + band)).resize((1024, 500), Image.LANCZOS)
    (OUT / "feature-graphic").mkdir(parents=True, exist_ok=True)
    im.save(OUT / "feature-graphic" / "feature.png", optimize=True)


if __name__ == "__main__":
    icon()
    feature_graphic()
    print("Generated assets in", OUT)

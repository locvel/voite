#!/usr/bin/env python3
"""Generate platform icons from Voite's supplied glassy orange V logo."""

import json
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
SOURCE_LOGO = ROOT / "assets/logo/voite-logo-glassy-v.webp"
IOS_ICONS = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
IOS_LAUNCH_IMAGES = ROOT / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
ANDROID_RES = ROOT / "android/app/src/main/res"
MASTER_SIZE = 1024


def load_master() -> Image.Image:
    source = Image.open(SOURCE_LOGO).convert("RGB")
    return source.resize(
        (MASTER_SIZE, MASTER_SIZE),
        Image.Resampling.LANCZOS,
    )


def make_adaptive_foreground(master: Image.Image) -> Image.Image:
    """Extract the orange waveform and fit it inside Android's safe icon area."""
    red, green, blue = master.split()
    mask = ImageChops.lighter(red, ImageChops.lighter(green, blue))
    mask = mask.point(lambda value: 255 if value > 0 else 0)
    bounds = mask.getbbox()
    if bounds is None:
        raise ValueError("The supplied Voite logo contains no foreground art")

    artwork = master.crop(bounds)
    artwork_mask = mask.crop(bounds)
    safe_extent = round(MASTER_SIZE * 0.66)
    scale = min(safe_extent / artwork.width, safe_extent / artwork.height)
    target_size = (round(artwork.width * scale), round(artwork.height * scale))
    artwork = artwork.resize(target_size, Image.Resampling.LANCZOS)
    artwork_mask = artwork_mask.resize(target_size, Image.Resampling.LANCZOS)

    layer = Image.new("RGBA", target_size, (0, 0, 0, 0))
    layer.paste(artwork, (0, 0))
    layer.putalpha(artwork_mask)
    result = Image.new("RGBA", (MASTER_SIZE, MASTER_SIZE), (0, 0, 0, 0))
    position = (
        (MASTER_SIZE - target_size[0]) // 2,
        (MASTER_SIZE - target_size[1]) // 2,
    )
    result.alpha_composite(layer, position)
    return result


def main() -> None:
    master = load_master()

    ios_contents = json.loads((IOS_ICONS / "Contents.json").read_text())
    for entry in ios_contents["images"]:
        filename = entry.get("filename")
        if not filename:
            continue
        base_size = float(entry["size"].split("x")[0])
        scale = int(entry["scale"].replace("x", ""))
        size = round(base_size * scale)
        master.resize((size, size), Image.Resampling.LANCZOS).save(
            IOS_ICONS / filename,
            format="PNG",
            optimize=True,
        )

    for scale, suffix in ((1, ""), (2, "@2x"), (3, "@3x")):
        canvas = Image.new("RGB", (168 * scale, 185 * scale), (0, 0, 0))
        mark = master.resize((120 * scale, 120 * scale), Image.Resampling.LANCZOS)
        canvas.paste(mark, (24 * scale, 32 * scale))
        canvas.save(
            IOS_LAUNCH_IMAGES / f"LaunchImage{suffix}.png",
            format="PNG",
            optimize=True,
        )

    for density, size in {
        "mdpi": 48,
        "hdpi": 72,
        "xhdpi": 96,
        "xxhdpi": 144,
        "xxxhdpi": 192,
    }.items():
        target = ANDROID_RES / f"mipmap-{density}/ic_launcher.png"
        master.resize((size, size), Image.Resampling.LANCZOS).save(
            target,
            format="PNG",
            optimize=True,
        )

    adaptive_dir = ANDROID_RES / "drawable-nodpi"
    adaptive_dir.mkdir(parents=True, exist_ok=True)
    make_adaptive_foreground(master).save(
        adaptive_dir / "ic_launcher_foreground.png",
        format="PNG",
        optimize=True,
    )
    master.resize((420, 420), Image.Resampling.LANCZOS).save(
        adaptive_dir / "launch_logo.png",
        format="PNG",
        optimize=True,
    )

    master.save(ROOT / "assets/voite_logo_glassy.png", format="PNG", optimize=True)
    master.save(ROOT / "assets/voite_app_icon.png", format="PNG", optimize=True)
    # Keep the old filename as an output alias for existing store-art scripts.
    master.save(ROOT / "assets/voice_recorder_app_icon.png", format="PNG", optimize=True)


if __name__ == "__main__":
    main()

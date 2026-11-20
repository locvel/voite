#!/usr/bin/env python3
"""Create draft Google Play art from the app icon and a real Android capture."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = ROOT / "docs/play-store/assets"
ICON = ROOT / "assets/voice_recorder_app_icon.png"
SCREENSHOT = ASSET_DIR / "record-screen-android.png"
SORA = ROOT / "assets/fonts/Sora-Variable.ttf"
INTER = ROOT / "assets/fonts/Inter-Variable.ttf"


def load_font(path: Path, size: int, weight: int) -> ImageFont.FreeTypeFont:
    font = ImageFont.truetype(str(path), size=size)
    axes = font.get_variation_axes()
    if len(axes) == 1:
        font.set_variation_by_axes([weight])
    else:
        font.set_variation_by_axes([14, weight])
    return font


def rounded_image(source: Image.Image, size: tuple[int, int], radius: int) -> Image.Image:
    source = source.convert("RGB")
    source.thumbnail(size, Image.Resampling.LANCZOS)
    frame = Image.new("RGB", size, "#ffffff")
    x = (size[0] - source.width) // 2
    y = (size[1] - source.height) // 2
    frame.paste(source, (x, y))
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255
    )
    frame.putalpha(mask)
    return frame


def main() -> None:
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    icon = Image.open(ICON).convert("RGBA")
    if icon.size != (512, 512):
        icon = icon.resize((512, 512), Image.Resampling.LANCZOS)
    icon.save(ASSET_DIR / "google-play-icon-draft.png", optimize=True)

    screen = Image.open(SCREENSHOT).convert("RGB")
    if screen.width < 1080 or screen.height < 2160:
        raise SystemExit("Use an Android capture at least 1080 x 2160 pixels.")

    # Preserve the full real screen and add background gutters to meet the
    # recommended 9:16 portrait ratio without stretching or cropping controls.
    screenshot = Image.new("RGB", (1350, 2400), screen.getpixel((0, 100)))
    screenshot.paste(screen, (135, 0))
    screenshot.save(ASSET_DIR / "phone-record-9x16-draft.png", optimize=True)

    graphic = Image.new("RGB", (1024, 500))
    pixels = graphic.load()
    start = (246, 251, 250)
    end = (219, 245, 241)
    for x in range(graphic.width):
        t = x / (graphic.width - 1)
        color = tuple(round(start[i] * (1 - t) + end[i] * t) for i in range(3))
        for y in range(graphic.height):
            pixels[x, y] = color

    draw = ImageDraw.Draw(graphic)
    draw.rounded_rectangle((55, 56, 257, 98), radius=21, fill="#D2F2EF")
    draw.text((72, 65), "VOICE RECORDER", font=load_font(INTER, 17, 700), fill="#006B69")
    draw.text(
        (55, 124),
        "PRIVATE AUDIO · OFFLINE NOTES",
        font=load_font(INTER, 16, 700),
        fill="#006B69",
    )
    draw.text((55, 168), "Make room to", font=load_font(SORA, 45, 700), fill="#142021")
    draw.text((55, 222), "listen.", font=load_font(SORA, 45, 700), fill="#142021")
    draw.text(
        (58, 302),
        "Capture a lecture. Find the details later.",
        font=load_font(INTER, 19, 400),
        fill="#465556",
    )
    draw.text(
        (58, 333),
        "Share only when you choose.",
        font=load_font(INTER, 19, 400),
        fill="#465556",
    )
    draw.rounded_rectangle((57, 404, 378, 450), radius=23, fill="#FFFFFF")
    draw.ellipse((73, 418, 90, 435), fill="#D92F24")
    draw.text(
        (102, 416),
        "RECORD · REPLAY · SHARE",
        font=load_font(INTER, 14, 700),
        fill="#263434",
    )

    # This inset is cropped from the latest Android capture, so it shows the
    # selected label and complete recording card rather than a mock screen.
    record_card = screen.crop((45, 865, 1035, 1370))
    record_card = rounded_image(record_card, (470, 250), 22)
    graphic_rgba = graphic.convert("RGBA")
    shadow = Image.new("RGBA", (510, 290), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (20, 20, 490, 270), 22, fill=(13, 50, 49, 88)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(18))
    graphic_rgba.alpha_composite(shadow, (480, 107))
    graphic_rgba.alpha_composite(record_card, (500, 87))
    graphic_rgba.convert("RGB").save(
        ASSET_DIR / "feature-graphic-draft.png", optimize=True
    )


if __name__ == "__main__":
    main()

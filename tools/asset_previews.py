#!/usr/bin/env python3
"""Build a preview.png contact sheet for each pack in assets/third_party/.

Each sheet shows up to 16 images from the pack, picked round-robin across its
folders and skipping animation frames of the same sprite, so a pack can be
browsed without opening hundreds of files. Pixel art is enlarged by an integer
factor with nearest-neighbour scaling; larger images are scaled down.

Usage:
    python3 tools/asset_previews.py                 # every pack
    python3 tools/asset_previews.py <folder> ...    # only these packs

Requires Pillow (pip install pillow).
"""
import argparse
import os
import re
import sys

from PIL import Image, ImageDraw, ImageFont

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_ROOT = os.path.join(REPO, 'assets', 'third_party')
EXT = ('.png', '.gif', '.bmp')
OUT_NAME = 'preview.png'
CELL, COLS, MAX_IMAGES, PAD, LABEL, HEADER = 240, 4, 16, 8, 14, 22
BG, CELL_BG, FG = (24, 22, 28), (44, 40, 52), (220, 214, 230)
FRAME_SUFFIX = re.compile(r'([ _-]?(idle|run|walk|hit|hurt|attack|jump|anim|sheet|f\d+|\(?\d+\)?))+$')


def list_images(pack_dir):
    images = []
    for root, _, files in os.walk(pack_dir):
        for name in files:
            if not name.lower().endswith(EXT) or name == OUT_NAME:
                continue
            path = os.path.join(root, name)
            try:
                with Image.open(path) as im:
                    w, h = im.size
            except OSError:
                continue
            images.append((path, w * h))
    return images


def pick(images):
    """Pick up to MAX_IMAGES paths, preferring large images and variety."""
    if len(images) <= MAX_IMAGES:
        return sorted(p for p, _ in images)
    best = {}  # one image per (folder, sprite name without frame suffix)
    for path, area in images:
        stem = FRAME_SUFFIX.sub('', os.path.splitext(os.path.basename(path))[0].lower())
        key = (os.path.dirname(path), stem)
        if key not in best or area > best[key][0]:
            best[key] = (area, path)
    by_dir = {}
    for area, path in best.values():
        by_dir.setdefault(os.path.dirname(path), []).append((area, path))
    for entries in by_dir.values():
        entries.sort(reverse=True)
    order = []
    for rnd in range(MAX_IMAGES):  # round-robin over folders, largest first
        layer = sorted((v[rnd] for v in by_dir.values() if len(v) > rnd), reverse=True)
        if not layer:
            break
        order += layer
    return sorted(p for _, p in order[:MAX_IMAGES])


def fit(im):
    w, h = im.size
    scale = min(CELL / w, CELL / h)
    if scale >= 1:
        scale = int(scale)
        return im.resize((w * scale, h * scale), Image.NEAREST)
    return im.resize((max(1, int(w * scale)), max(1, int(h * scale))), Image.LANCZOS)


def build(pack_dir):
    images = list_images(pack_dir)
    if not images:
        return None
    picked = pick(images)
    n = len(picked)
    cols = min(COLS, n)
    rows = (n + cols - 1) // cols
    size = (cols * (CELL + PAD) + PAD, HEADER + rows * (CELL + LABEL + PAD) + PAD)
    sheet = Image.new('RGBA', size, BG + (255,))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    title = f'{os.path.basename(pack_dir)}  ({len(images)} images, {n} shown)'
    draw.text((PAD, 6), title, fill=FG, font=font)
    for i, path in enumerate(picked):
        with Image.open(path) as src:
            src.seek(0)  # first frame of animated GIFs
            im = fit(src.convert('RGBA'))
        x0 = PAD + (i % cols) * (CELL + PAD)
        y0 = HEADER + PAD + (i // cols) * (CELL + LABEL + PAD)
        draw.rectangle([x0, y0, x0 + CELL - 1, y0 + CELL - 1], fill=CELL_BG + (255,))
        sheet.alpha_composite(im, (x0 + (CELL - im.size[0]) // 2, y0 + (CELL - im.size[1]) // 2))
        label = os.path.relpath(path, pack_dir).replace(os.sep, '/')
        if len(label) > 38:
            label = '...' + label[-35:]
        draw.text((x0, y0 + CELL + 1), label, fill=FG, font=font)
    out = sheet.convert('RGB')
    if out.getcolors(256) is None:  # more than 256 colours: palette it to keep the file small
        out = out.quantize(256, dither=Image.Dither.NONE)
    out_path = os.path.join(pack_dir, OUT_NAME)
    out.save(out_path, optimize=True)
    return out_path, n, len(images)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('packs', nargs='*', help='pack folder names (default: all)')
    parser.add_argument('--root', default=DEFAULT_ROOT, help='folder that holds the packs')
    args = parser.parse_args(argv)
    names = args.packs or sorted(os.listdir(args.root))
    for name in names:
        pack_dir = os.path.join(args.root, name)
        if not os.path.isdir(pack_dir):
            if args.packs:
                print(f'not a pack folder: {pack_dir}', file=sys.stderr)
                return 1
            continue
        result = build(pack_dir)
        if result:
            out_path, shown, total = result
            print(f'{os.path.relpath(out_path, REPO)}: {shown}/{total} images')
    return 0


if __name__ == '__main__':
    sys.exit(main())

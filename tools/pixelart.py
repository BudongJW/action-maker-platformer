#!/usr/bin/env python3
"""Render text pixel-art sources (.pix sprites/tilesets, .scene mock-ups) to PNG.

The art itself lives as plain-text data under assets/original/art/src/ (all
rights reserved, see assets/original/LICENSE.md). This GPL tool only knows the
format, the same split the project uses for dialogue text and code.

Formats (how the art uses them: assets/original/art/README.md)

  palette (.pal)   KEY HEX [name]           one character per colour; HEX is
                                            RRGGBB, or RRGGBBAA for translucency
  sprite (.pix)    @palette PATH            palette file, relative to the source
                   @size W H                frame size in pixels
                   @output PATH             PNG sheet to write
                   @columns N               frames per sheet row (default: all)
                   @preview PATH SCALE      optional enlarged copy
                   @split DIR               also write each sheet frame as
                                            DIR/<frame>.png (e.g. portraits)
                   @frame NAME [base=OTHER] then H rows of W characters;
                                            '.' transparent, '~' keep OTHER's
                                            pixel, a row of just '~' keeps the
                                            whole row
                   @frame NAME mirror=OTHER horizontally flipped copy, no rows
                   @frame NAME shift=OTHER,DX,DY  moved copy, no rows
                   @frame NAME copy=FILE.pix:OTHER  frame from another
                                            source of the same size, no rows
                   @frame NAME fade=OTHER,LEVEL  OTHER with LEVEL/4 of its
                                            pixels removed in an ordered
                                            dither (1..3), for dissolves
                   @blank NAME              empty frame
                   frames whose name starts with "_" are helpers: usable as
                   base/mirror/shift sources but not placed in the sheet
  scene (.scene)   @palette / @size / @output / @preview as above
                   @fill KEY                background colour
                   @tiles ALIAS PATH        a .pix tileset
                   @legend C ALIAS:FRAME    map character C to a tile
                   @layer [over]            then rows of legend characters; an
                                            "over" layer is drawn above the
                                            darkness (UI in mock-ups)
                   @sprite PATH FRAME X Y [flip] [over]
                   @darkness KEY ALPHA      night overlay (0..1)
                   @light X Y RADIUS        hole in the darkness
                   @cone X Y ANGLE SPREAD LENGTH   flashlight beam
                   sprites marked "over" are drawn above the darkness

Usage:
  python3 tools/pixelart.py            render every source under the art folder
  python3 tools/pixelart.py --check    fail if any PNG is missing or out of date
  python3 tools/pixelart.py FILE ...   render only these sources
"""
import argparse
import math
import os
import struct
import sys
import zlib

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART_SRC = os.path.join(REPO, 'assets', 'original', 'art', 'src')
TRANSPARENT = '.'
INHERIT = '~'
DARK_STEPS = 4  # darkness is quantised into this many levels for a pixel-art look
BAYER2 = ((0, 2), (3, 1))  # ordered-dither thresholds for fade=


class ArtError(Exception):
    pass


# ---------------------------------------------------------------- PNG output

def encode_png(width, height, pixels):
    """pixels: list of rows, each a list of (r, g, b, a). Deterministic output."""
    raw = bytearray()
    for row in pixels:
        raw.append(0)
        for r, g, b, a in row:
            raw += bytes((r, g, b, a))

    def chunk(tag, data):
        body = tag + data
        return struct.pack('>I', len(data)) + body + struct.pack('>I', zlib.crc32(body) & 0xffffffff)

    header = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', header)
            + chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b''))


def scale_pixels(pixels, factor):
    out = []
    for row in pixels:
        wide = [px for px in row for _ in range(factor)]
        out.extend(list(wide) for _ in range(factor))
    return out


# ---------------------------------------------------------------- parsing

def _lines(path):
    with open(path, encoding='utf-8') as f:
        for number, line in enumerate(f, 1):
            line = line.rstrip('\n').rstrip('\r')
            stripped = line.strip()
            if not stripped or stripped.startswith('#'):
                continue
            yield number, line.rstrip()


def load_palette(path):
    colours = {TRANSPARENT: (0, 0, 0, 0)}
    names = {}
    for number, line in _lines(path):
        parts = line.split()
        key, value = parts[0], parts[1] if len(parts) > 1 else ''
        if len(key) != 1 or key in (TRANSPARENT, INHERIT, '#', '@'):
            raise ArtError(f'{path}:{number}: palette key must be one character other than . ~ # @')
        if key in colours:
            raise ArtError(f'{path}:{number}: duplicate palette key {key!r}')
        value = value.lstrip('#')
        if len(value) not in (6, 8):
            raise ArtError(f'{path}:{number}: colour must be RRGGBB or RRGGBBAA')
        try:
            rgba = tuple(int(value[i:i + 2], 16) for i in range(0, len(value), 2))
        except ValueError:
            raise ArtError(f'{path}:{number}: colour must be RRGGBB or RRGGBBAA') from None
        colours[key] = rgba if len(rgba) == 4 else rgba + (255,)
        names[key] = ' '.join(parts[2:])
    return colours, names


class Sprite:
    """A parsed .pix file: named frames of palette characters."""

    def __init__(self, path):
        self.path = path
        self.palette_path = None
        self.width = self.height = None
        self.output = None
        self.preview = None
        self.columns = None
        self.split = None
        self.frames = {}  # name -> list of row strings
        self.order = []
        self._parse()

    def _rel(self, value):
        return os.path.normpath(os.path.join(os.path.dirname(self.path), value))

    def _parse(self):
        lines = list(_lines(self.path))
        i = 0
        while i < len(lines):
            number, line = lines[i]
            i += 1
            if not line.startswith('@'):
                raise ArtError(f'{self.path}:{number}: expected a directive, got {line!r}')
            parts = line.split()
            name = parts[0]
            if name == '@palette':
                self.palette_path = self._rel(parts[1])
            elif name == '@size':
                self.width, self.height = int(parts[1]), int(parts[2])
            elif name == '@output':
                self.output = self._rel(parts[1])
            elif name == '@preview':
                self.preview = (self._rel(parts[1]), int(parts[2]))
            elif name == '@columns':
                self.columns = int(parts[1])
            elif name == '@split':
                self.split = self._rel(parts[1])
            elif name == '@blank':
                self._add(number, parts[1], ['.' * self.width] * self.height)
            elif name == '@frame':
                i = self._frame(parts, number, lines, i)
            else:
                raise ArtError(f'{self.path}:{number}: unknown directive {name}')
        if self.palette_path is None or self.width is None:
            raise ArtError(f'{self.path}: @palette and @size are required')
        if not self.sheet_frames():
            raise ArtError(f'{self.path}: no frames')
        self.colours, _ = load_palette(self.palette_path)
        colours = self.colours
        for frame in self.order:
            for y, row in enumerate(self.frames[frame]):
                for ch in row:
                    if ch not in colours:
                        raise ArtError(f'{self.path}: frame {frame} row {y}: {ch!r} is not in the palette')

    def _add(self, number, name, rows):
        if self.width is None:
            raise ArtError(f'{self.path}:{number}: @size must come before frames')
        if name in self.frames:
            raise ArtError(f'{self.path}:{number}: duplicate frame {name!r}')
        self.frames[name] = rows
        self.order.append(name)

    def _source(self, number, name):
        if name not in self.frames:
            raise ArtError(f'{self.path}:{number}: unknown frame {name!r} (frames must be defined before use)')
        return self.frames[name]

    def _frame(self, parts, number, lines, i):
        if len(parts) < 2:
            raise ArtError(f'{self.path}:{number}: @frame needs a name')
        name, options = parts[1], dict(p.split('=', 1) for p in parts[2:])
        if 'copy' in options:
            other_path, other_frame = options['copy'].rsplit(':', 1)
            other = Sprite(self._rel(other_path))
            if (other.width, other.height) != (self.width, self.height):
                raise ArtError(f'{self.path}:{number}: {other_path} frames are not {self.width}x{self.height}')
            if other_frame not in other.frames:
                raise ArtError(f'{self.path}:{number}: no frame {other_frame!r} in {other_path}')
            self._add(number, name, list(other.frames[other_frame]))
            return i
        if 'mirror' in options:
            self._add(number, name, [row[::-1] for row in self._source(number, options['mirror'])])
            return i
        if 'fade' in options:
            other, level = options['fade'].split(',')
            src, level = self._source(number, other), int(level)
            if not 1 <= level <= 3:
                raise ArtError(f'{self.path}:{number}: fade level must be 1, 2 or 3')
            self._add(number, name, [''.join(
                TRANSPARENT if BAYER2[y % 2][x % 2] < level else ch for x, ch in enumerate(row))
                for y, row in enumerate(src)])
            return i
        if 'shift' in options:
            other, dx, dy = options['shift'].split(',')
            src, dx, dy = self._source(number, other), int(dx), int(dy)
            rows = []
            for y in range(self.height):
                sy = y - dy
                rows.append(''.join(
                    src[sy][x - dx] if 0 <= sy < self.height and 0 <= x - dx < self.width else TRANSPARENT
                    for x in range(self.width)))
            self._add(number, name, rows)
            return i
        base = self._source(number, options['base']) if 'base' in options else None
        rows = []
        for y in range(self.height):
            if i >= len(lines):
                raise ArtError(f'{self.path}:{number}: frame {name!r} has {y} rows, expected {self.height}')
            row_number, row = lines[i]
            i += 1
            row = row.strip()
            if row == INHERIT:
                if base is None:
                    raise ArtError(f'{self.path}:{row_number}: "~" needs base=FRAME')
                rows.append(base[y])
                continue
            if len(row) != self.width:
                raise ArtError(f'{self.path}:{row_number}: row is {len(row)} wide, expected {self.width}')
            if INHERIT in row:
                if base is None:
                    raise ArtError(f'{self.path}:{row_number}: "~" needs base=FRAME')
                row = ''.join(b if c == INHERIT else c for c, b in zip(row, base[y]))
            rows.append(row)
        self._add(number, name, rows)
        return i

    def frame_pixels(self, name, flip=False):
        out = [[self.colours[ch] for ch in row] for row in self.frames[name]]
        return [row[::-1] for row in out] if flip else out

    def sheet_frames(self):
        return [name for name in self.order if not name.startswith('_')]

    def render(self):
        frames = self.sheet_frames()
        cols = self.columns or len(frames)
        rows = math.ceil(len(frames) / cols)
        sheet = [[(0, 0, 0, 0)] * (cols * self.width) for _ in range(rows * self.height)]
        for index, name in enumerate(frames):
            ox, oy = (index % cols) * self.width, (index // cols) * self.height
            for y, row in enumerate(self.frame_pixels(name)):
                sheet[oy + y][ox:ox + self.width] = row
        return sheet


class Scene:
    """A parsed .scene file: tile layers, sprites and lighting."""

    def __init__(self, path, sprite_cache):
        self.path = path
        self.cache = sprite_cache
        self.steps = []  # drawing operations in order
        self.palette_path = self.output = self.preview = None
        self.width = self.height = None
        self.fill = None
        self.tiles, self.legend = {}, {}
        self.darkness = None
        self.lights = []
        self._parse()

    def _rel(self, value):
        return os.path.normpath(os.path.join(os.path.dirname(self.path), value))

    def sprite(self, path):
        if path not in self.cache:
            self.cache[path] = Sprite(path)
        return self.cache[path]

    def _parse(self):
        lines = list(_lines(self.path))
        i = 0
        while i < len(lines):
            number, line = lines[i]
            i += 1
            parts = line.split()
            name = parts[0]
            if name == '@palette':
                self.palette_path = self._rel(parts[1])
            elif name == '@size':
                self.width, self.height = int(parts[1]), int(parts[2])
            elif name == '@output':
                self.output = self._rel(parts[1])
            elif name == '@preview':
                self.preview = (self._rel(parts[1]), int(parts[2]))
            elif name == '@fill':
                self.fill = parts[1]
            elif name == '@tiles':
                self.tiles[parts[1]] = self.sprite(self._rel(parts[2]))
            elif name == '@legend':
                alias, frame = parts[2].split(':')
                if alias not in self.tiles or frame not in self.tiles[alias].frames:
                    raise ArtError(f'{self.path}:{number}: unknown tile {parts[2]}')
                self.legend[parts[1]] = (alias, frame)
            elif name == '@layer':
                is_over = 'over' in parts[1:]
                rows = []
                while i < len(lines) and not lines[i][1].lstrip().startswith('@'):
                    rows.append(lines[i][1].strip())
                    i += 1
                for row in rows:
                    for ch in row:
                        if ch != TRANSPARENT and ch not in self.legend:
                            raise ArtError(f'{self.path}: layer near line {number}: {ch!r} has no @legend')
                self.steps.append(('layer', rows, is_over))
            elif name == '@sprite':
                sprite = self.sprite(self._rel(parts[1]))
                if parts[2] not in sprite.frames:
                    raise ArtError(f'{self.path}:{number}: no frame {parts[2]!r} in {parts[1]}')
                flags = set(parts[5:])
                self.steps.append(('sprite', sprite, parts[2], int(parts[3]), int(parts[4]),
                                   'flip' in flags, 'over' in flags))
            elif name == '@darkness':
                self.darkness = (parts[1], float(parts[2]))
            elif name == '@light':
                self.lights.append(('circle', int(parts[1]), int(parts[2]), int(parts[3])))
            elif name == '@cone':
                self.lights.append(('cone',) + tuple(int(p) for p in parts[1:6]))
            else:
                raise ArtError(f'{self.path}:{number}: unknown directive {name}')
        if self.palette_path is None or self.width is None:
            raise ArtError(f'{self.path}: @palette and @size are required')

    def _light_level(self, x, y):
        """0 = fully lit, 1 = full darkness."""
        level = 1.0
        for light in self.lights:
            if light[0] == 'circle':
                _, lx, ly, radius = light
                d = math.hypot(x - lx, y - ly) / radius
            else:
                _, lx, ly, angle, spread, length = light
                dx, dy = x - lx, y - ly
                dist = math.hypot(dx, dy)
                if dist == 0:
                    d = 0.0
                else:
                    off = abs((math.degrees(math.atan2(dy, dx)) - angle + 180) % 360 - 180)
                    d = max(dist / length, off / (spread / 2)) if off <= spread / 2 else 1.0
            level = min(level, d)
        level = max(0.0, min(1.0, level))
        return math.floor(level * DARK_STEPS) / DARK_STEPS

    def render(self):
        colours, _ = load_palette(self.palette_path)
        bg = colours[self.fill] if self.fill else (0, 0, 0, 0)
        canvas = [[bg] * self.width for _ in range(self.height)]

        def blit(pixels, ox, oy):
            for y, row in enumerate(pixels):
                cy = oy + y
                if not 0 <= cy < self.height:
                    continue
                for x, px in enumerate(row):
                    cx = ox + x
                    if px[3] and 0 <= cx < self.width:
                        canvas[cy][cx] = px

        def draw(step):
            if step[0] == 'layer':
                for ty, row in enumerate(step[1]):
                    for tx, ch in enumerate(row):
                        if ch == TRANSPARENT:
                            continue
                        alias, frame = self.legend[ch]
                        tiles = self.tiles[alias]
                        blit(tiles.frame_pixels(frame), tx * tiles.width, ty * tiles.height)
            else:
                _, sprite, frame, x, y, flip, _ = step
                blit(sprite.frame_pixels(frame, flip), x, y)

        over = [step for step in self.steps if step[-1]]
        for step in self.steps:
            if not step[-1]:
                draw(step)
        if self.darkness:
            key, alpha = self.darkness
            dr, dg, db, _ = colours[key]
            for y in range(self.height):
                for x in range(self.width):
                    t = alpha * self._light_level(x + 0.5, y + 0.5)
                    if t:
                        r, g, b, a = canvas[y][x]
                        canvas[y][x] = (round(r + (dr - r) * t), round(g + (dg - g) * t),
                                        round(b + (db - b) * t), a if a else round(255 * t))
        for step in over:
            draw(step)
        return canvas


# ---------------------------------------------------------------- driver

def outputs_for(path, cache):
    """Return {output_path: png_bytes} for one source file."""
    if path.endswith('.scene'):
        art = Scene(path, cache)
    else:
        art = cache.get(path) or Sprite(path)
        cache[path] = art
    if not art.output:
        raise ArtError(f'{path}: @output is required')
    pixels = art.render()
    height, width = len(pixels), len(pixels[0])
    result = {art.output: encode_png(width, height, pixels)}
    if art.preview:
        preview_path, factor = art.preview
        result[preview_path] = encode_png(width * factor, height * factor, scale_pixels(pixels, factor))
    if getattr(art, 'split', None):
        for name in art.sheet_frames():
            result[os.path.join(art.split, name + '.png')] = encode_png(art.width, art.height, art.frame_pixels(name))
    return result


def find_sources(root):
    found = []
    for dirpath, _, files in os.walk(root):
        for name in files:
            if name.endswith(('.pix', '.scene')):
                found.append(os.path.join(dirpath, name))
    return sorted(found)


def main(argv=None):
    parser = argparse.ArgumentParser(description='Render text pixel-art sources to PNG.')
    parser.add_argument('sources', nargs='*', help='.pix or .scene files (default: every source under --root)')
    parser.add_argument('--root', default=ART_SRC, help='folder searched when no sources are given')
    parser.add_argument('--check', action='store_true', help='only verify that outputs are up to date')
    args = parser.parse_args(argv)
    sources = [os.path.abspath(s) for s in args.sources] or find_sources(args.root)
    if not sources:
        print(f'pixelart: no sources under {os.path.relpath(args.root, REPO)}; nothing to do.')
        return 0
    cache, stale, written = {}, [], 0
    try:
        for source in sources:
            for out_path, data in outputs_for(source, cache).items():
                current = None
                if os.path.exists(out_path):
                    with open(out_path, 'rb') as f:
                        current = f.read()
                if current == data:
                    continue
                if args.check:
                    stale.append(out_path)
                else:
                    os.makedirs(os.path.dirname(out_path), exist_ok=True)
                    with open(out_path, 'wb') as f:
                        f.write(data)
                    written += 1
    except ArtError as e:
        print(f'pixelart: {e}', file=sys.stderr)
        return 1
    if args.check:
        if stale:
            for path in stale:
                print(f'pixelart: out of date: {os.path.relpath(path, REPO)}', file=sys.stderr)
            print('pixelart: run "python3 tools/pixelart.py" and commit the PNGs.', file=sys.stderr)
            return 1
        print(f'pixelart: OK, {len(sources)} source(s) up to date.')
        return 0
    print(f'pixelart: {len(sources)} source(s), {written} file(s) written.')
    return 0


if __name__ == '__main__':
    sys.exit(main())

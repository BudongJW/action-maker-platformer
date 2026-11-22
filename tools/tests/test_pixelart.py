import contextlib
import io
import os
import struct
import sys
import tempfile
import unittest
import zlib
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import pixelart  # noqa: E402

PALETTE = """# test palette
K 000000 black
W ffffff white
R ff0000 red
"""


def decode_png(data):
    """Minimal decoder for the RGBA, filter-0 PNGs that pixelart writes."""
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    pos, idat, width = 8, b"", None
    while pos < len(data):
        length, tag = struct.unpack(">I4s", data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + length]
        if tag == b"IHDR":
            width, height = struct.unpack(">II", body[:8])
        elif tag == b"IDAT":
            idat += body
        pos += 12 + length
    raw = zlib.decompress(idat)
    stride = width * 4 + 1
    rows = []
    for y in range(height):
        line = raw[y * stride:(y + 1) * stride]
        assert line[0] == 0
        rows.append([tuple(line[1 + x * 4:5 + x * 4]) for x in range(width)])
    return rows


class PixelArtTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self.tmp.name)
        (self.dir / "p.pal").write_text(PALETTE, encoding="utf-8")

    def tearDown(self):
        self.tmp.cleanup()

    def write(self, name, text):
        path = self.dir / name
        path.write_text(text, encoding="utf-8")
        return str(path)

    def render(self, path):
        outputs = pixelart.outputs_for(path, {})
        return {os.path.basename(k): decode_png(v) for k, v in outputs.items()}

    def run_main(self, *args):
        err = io.StringIO()
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(err):
            code = pixelart.main(list(args))
        return code, err.getvalue()

    def test_sheet_layout_and_colours(self):
        src = self.write("a.pix", "@palette p.pal\n@size 2 2\n@output a.png\n@columns 2\n"
                         "@frame one\nKW\n.R\n@frame two\nRR\nKK\n@frame three\nWW\nWW\n")
        sheet = self.render(src)["a.png"]
        self.assertEqual((len(sheet[0]), len(sheet)), (4, 4))  # 2 columns x 2 rows of 2x2 frames
        self.assertEqual(sheet[0][0], (0, 0, 0, 255))
        self.assertEqual(sheet[0][1], (255, 255, 255, 255))
        self.assertEqual(sheet[1][0], (0, 0, 0, 0))  # '.' is transparent
        self.assertEqual(sheet[0][2], (255, 0, 0, 255))  # second frame to the right
        self.assertEqual(sheet[2][0], (255, 255, 255, 255))  # third frame wraps to the next row
        self.assertEqual(sheet[3][3], (0, 0, 0, 0))  # unused cell stays empty

    def test_base_inherit_mirror_shift_and_helpers(self):
        src = self.write("b.pix", "@palette p.pal\n@size 3 2\n@output b.png\n"
                         "@frame _base\nKWR\nRRR\n"
                         "@frame edited base=_base\n~K~\n~\n"
                         "@frame flipped mirror=_base\n"
                         "@frame moved shift=_base,1,0\n")
        sprite = pixelart.Sprite(src)
        self.assertEqual(sprite.frames["edited"], ["KKR", "RRR"])
        self.assertEqual(sprite.frames["flipped"], ["RWK", "RRR"])
        self.assertEqual(sprite.frames["moved"], [".KW", ".RR"])
        self.assertEqual(sprite.sheet_frames(), ["edited", "flipped", "moved"])  # helper hidden

    def test_fade_and_rgba_palette(self):
        (self.dir / "a.pal").write_text("L ffffff80 half white\n", encoding="utf-8")
        src = self.write("f.pix", "@palette a.pal\n@size 2 2\n@output f.png\n"
                         "@frame full\nLL\nLL\n@frame half fade=full,2\n@frame gone fade=full,3\n")
        sprite = pixelart.Sprite(src)
        self.assertEqual(sprite.frames["half"], [".L", "L."])
        self.assertEqual(sum(row.count("L") for row in sprite.frames["gone"]), 1)
        self.assertEqual(self.render(src)["f.png"][0][0], (255, 255, 255, 128))

    def test_copy_from_other_file(self):
        self.write("src.pix", "@palette p.pal\n@size 1 1\n@output s.png\n@frame dot\nR\n")
        dst = self.write("dst.pix", "@palette p.pal\n@size 1 1\n@output d.png\n@frame x copy=src.pix:dot\n")
        self.assertEqual(pixelart.Sprite(dst).frames["x"], ["R"])

    def test_errors_are_reported(self):
        cases = {
            "wide.pix": "@palette p.pal\n@size 2 1\n@output o.png\n@frame a\nKKK\n",
            "colour.pix": "@palette p.pal\n@size 1 1\n@output o.png\n@frame a\nZ\n",
            "inherit.pix": "@palette p.pal\n@size 1 1\n@output o.png\n@frame a\n~\n",
            "dupe.pix": "@palette p.pal\n@size 1 1\n@output o.png\n@frame a\nK\n@frame a\nK\n",
            "short.pix": "@palette p.pal\n@size 1 2\n@output o.png\n@frame a\nK\n",
        }
        for name, text in cases.items():
            with self.subTest(name):
                with self.assertRaises(pixelart.ArtError):
                    pixelart.Sprite(self.write(name, text))

    def test_bad_palette_key(self):
        self.write("bad.pal", "# K 000000\n. 000000\n")
        with self.assertRaises(pixelart.ArtError):
            pixelart.load_palette(str(self.dir / "bad.pal"))

    def test_scene_layers_sprites_and_light(self):
        self.write("t.pix", "@palette p.pal\n@size 2 2\n@output t.png\n@frame wall\nWW\nWW\n")
        self.write("s.pix", "@palette p.pal\n@size 1 1\n@output s.png\n@frame dot\nR\n")
        scene = self.write("x.scene", "@palette p.pal\n@size 12 2\n@output x.png\n@fill K\n"
                           "@tiles t t.pix\n@legend w t:wall\n@layer\nww\n"
                           "@sprite s.pix dot 11 1\n@darkness K 1.0\n@light 0 0 8\n"
                           "@sprite s.pix dot 11 0 over\n")
        pixels = self.render(scene)["x.png"]
        self.assertEqual(pixels[0][0], (255, 255, 255, 255))  # light core: untouched
        self.assertEqual(pixels[0][3], (191, 191, 191, 255))  # one darkness step further out
        self.assertEqual(pixels[1][11], (0, 0, 0, 255))  # sprite under full darkness
        self.assertEqual(pixels[0][11], (255, 0, 0, 255))  # "over" sprite drawn after darkness

    def test_over_layer_is_drawn_above_darkness(self):
        self.write("t.pix", "@palette p.pal\n@size 1 1\n@output t.png\n@frame r\nR\n")
        scene = self.write("o.scene", "@palette p.pal\n@size 2 1\n@output o.png\n@fill W\n"
                           "@tiles t t.pix\n@legend r t:r\n@layer over\n.r\n@darkness K 1.0\n")
        pixels = self.render(scene)["o.png"]
        self.assertEqual(pixels[0][0], (0, 0, 0, 255))  # background darkened
        self.assertEqual(pixels[0][1], (255, 0, 0, 255))  # over layer untouched

    def test_swap_palette_and_keep(self):
        (self.dir / "q.pal").write_text("K 010101\nW 020202\nR 030303\n", encoding="utf-8")
        self.write("t.pix", "@palette p.pal\n@size 1 1\n@output t.png\n@frame w\nW\n@frame r\nR\n")
        scene = self.write("w.scene", "@palette p.pal\n@size 3 1\n@output w.png\n@swap q.pal\n@fill K\n"
                           "@tiles t t.pix\n@legend w t:w\n@layer\nw..\n"
                           "@sprite t.pix r 1 0\n@sprite t.pix r 2 0 keep\n")
        pixels = self.render(scene)["w.png"][0]
        self.assertEqual(pixels[0], (2, 2, 2, 255))  # tile drawn with the swap palette
        self.assertEqual(pixels[1], (3, 3, 3, 255))  # sprite swapped too
        self.assertEqual(pixels[2], (255, 0, 0, 255))  # "keep" uses its own palette
        (self.dir / "o.pal").write_text("4 00000080\n", encoding="utf-8")
        self.write("o.pix", "@palette o.pal\n@size 1 1\n@output o.png\n@frame dim\n4\n")
        other = self.write("x2.scene", "@palette p.pal\n@size 1 1\n@output x2.png\n@swap q.pal\n@fill W\n"
                           "@sprite o.pix dim 0 0\n")
        self.assertEqual(self.render(other)["x2.png"][0][0], (1, 1, 1, 255))  # own palette, blended over swapped fill
        (self.dir / "bad.pal").write_text("K 010101\n", encoding="utf-8")
        bad = self.write("b.scene", "@palette p.pal\n@size 1 1\n@output b.png\n@swap bad.pal\n@fill K\n")
        with self.assertRaises(pixelart.ArtError):
            self.render(bad)

    def test_translucent_sprites_blend(self):
        (self.dir / "a.pal").write_text("K 000000\nH 00000080\nW ffffff\n", encoding="utf-8")
        self.write("h.pix", "@palette a.pal\n@size 1 1\n@output h.png\n@frame half\nH\n")
        scene = self.write("bl.scene", "@palette a.pal\n@size 1 1\n@output bl.png\n@fill W\n"
                           "@sprite h.pix half 0 0\n")
        self.assertEqual(self.render(scene)["bl.png"][0][0], (127, 127, 127, 255))

    def test_preview_is_scaled(self):
        src = self.write("p.pix", "@palette p.pal\n@size 1 1\n@output o.png\n@preview big.png 3\n@frame a\nR\n")
        outputs = self.render(src)
        self.assertEqual(len(outputs["big.png"]), 3)
        self.assertEqual(outputs["big.png"][2][2], (255, 0, 0, 255))

    def test_split_writes_one_png_per_frame(self):
        src = self.write("s.pix", "@palette p.pal\n@size 1 1\n@output s.png\n@split parts\n"
                         "@frame _hidden\nK\n@frame a\nR\n@frame b\nW\n")
        outputs = pixelart.outputs_for(src, {})
        names = sorted(os.path.relpath(k, self.dir) for k in outputs)
        self.assertEqual(names, [os.path.join("parts", "a.png"), os.path.join("parts", "b.png"), "s.png"])
        self.assertEqual(decode_png(outputs[str(self.dir / "parts" / "b.png")])[0][0], (255, 255, 255, 255))

    def test_output_is_deterministic(self):
        src = self.write("d.pix", "@palette p.pal\n@size 2 1\n@output d.png\n@frame a\nKR\n")
        self.assertEqual(pixelart.outputs_for(src, {}), pixelart.outputs_for(src, {}))

    def test_check_mode(self):
        src = self.write("c.pix", "@palette p.pal\n@size 1 1\n@output c.png\n@frame a\nR\n")
        code, err = self.run_main("--check", src)
        self.assertEqual(code, 1)
        self.assertIn("out of date", err)
        self.assertEqual(self.run_main(src)[0], 0)
        self.assertEqual(self.run_main("--check", src)[0], 0)
        Path(src).write_text(Path(src).read_text().replace("\nR\n", "\nK\n"))
        self.assertEqual(self.run_main("--check", src)[0], 1)

    def test_check_ignores_how_zlib_compressed(self):
        # Another zlib build (zlib-ng in CPython 3.14 on Windows) writes other bytes for the same
        # pixels; that is not out of date, and the file is left alone.
        src = self.write("z.pix", "@palette p.pal\n@size 4 2\n@output z.png\n@frame a\nKWRK\nRRWW\n")
        self.assertEqual(self.run_main(src)[0], 0)
        out = self.dir / "z.png"
        data = out.read_bytes()
        recompressed = bytearray(data)
        pos = 8
        while pos < len(recompressed):
            length, tag = struct.unpack(">I4s", recompressed[pos:pos + 8])
            if tag == b"IDAT":
                body = zlib.compress(zlib.decompress(recompressed[pos + 8:pos + 8 + length]), 0)
                recompressed[pos:pos + 12 + length] = (struct.pack(">I", len(body)) + b"IDAT" + body
                                                       + struct.pack(">I", zlib.crc32(b"IDAT" + body)))
                break
            pos += 12 + length
        recompressed = bytes(recompressed)
        self.assertNotEqual(recompressed, data)
        out.write_bytes(recompressed)
        self.assertTrue(pixelart.same_png(recompressed, data))
        self.assertEqual(self.run_main("--check", src)[0], 0)
        self.assertEqual(self.run_main(src)[0], 0)
        self.assertEqual(out.read_bytes(), recompressed)
        self.assertFalse(pixelart.same_png(recompressed, data.replace(b"IHDR\x00\x00\x00\x04", b"IHDR\x00\x00\x00\x02")))

    def test_empty_root_is_ok(self):
        empty = self.dir / "empty"
        empty.mkdir()
        self.assertEqual(self.run_main("--check", "--root", str(empty))[0], 0)


if __name__ == "__main__":
    unittest.main()

import contextlib
import io
import os
import struct
import sys
import tempfile
import unittest
import wave
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import sfxsynth  # noqa: E402


def read_wav(data):
    with wave.open(io.BytesIO(data)) as w:
        n = w.getnframes()
        return w.getframerate(), list(struct.unpack("<%dh" % n, w.readframes(n)))


class SfxSynthTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def recipe(self, name, text):
        path = self.dir / name
        path.write_text(text, encoding="utf-8")
        return str(path)

    def render(self, text, name="r.sfx"):
        recipe = sfxsynth.Recipe(self.recipe(name, text))
        return read_wav(sfxsynth.encode_wav(recipe.render(), recipe.rate))

    def run_main(self, *args):
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            return sfxsynth.main(list(args))

    def test_length_rate_and_peak(self):
        rate, x = self.render("@output o.wav\n@length 0.1\n@rate 8000\n@peak -6\nlayer sine freq=440 amp=0.2\n")
        self.assertEqual(rate, 8000)
        self.assertEqual(len(x), 800)
        self.assertAlmostEqual(max(abs(v) for v in x) / 32767, 10 ** (-6 / 20), places=2)

    def test_layer_timing_and_repeat(self):
        _, x = self.render("@output o.wav\n@length 1.0\n@rate 1000\n"
                           "layer sine freq=100 at=0.2 dur=0.05 repeat=3 every=0.3\n")
        loud = [i for i, v in enumerate(x) if abs(v) > 1000]
        self.assertGreaterEqual(min(loud), 200)
        for start in (200, 500, 800):  # three hits, 0.3 s apart
            self.assertTrue(any(start <= i < start + 50 for i in loud))
        self.assertFalse(any(260 <= i < 490 for i in loud))  # silence between hits

    def test_noise_is_seeded(self):
        text = "@output o.wav\n@length 0.05\n@seed 4\nlayer noise\n"
        self.assertEqual(self.render(text, "a.sfx"), self.render(text, "b.sfx"))
        other = self.render(text.replace("@seed 4", "@seed 5"), "c.sfx")
        self.assertNotEqual(self.render(text, "a.sfx"), other)

    def test_loop_is_seamless(self):
        _, x = self.render("@output o.wav\n@length 0.5\n@rate 8000\n@loop 0.05\n"
                           "layer brown amp=0.8 lp=300\nlayer sine freq=97 amp=0.3\n")
        steps = [abs(x[i + 1] - x[i]) for i in range(len(x) - 1)]
        self.assertLessEqual(abs(x[0] - x[-1]), 3 * max(1, sorted(steps)[len(steps) // 2]) + 50)

    def test_errors(self):
        cases = {
            "type": "@output o.wav\n@length 1\nlayer wobble freq=1\n",
            "freq": "@output o.wav\n@length 1\nlayer sine\n",
            "option": "@output o.wav\n@length 1\nlayer noise colour=pink\n",
            "required": "@length 1\nlayer noise\n",
            "empty": "@output o.wav\n@length 1\n",
        }
        for name, text in cases.items():
            with self.subTest(name):
                with self.assertRaises(sfxsynth.SfxError):
                    sfxsynth.Recipe(self.recipe(name + ".sfx", text))

    def test_check_mode(self):
        path = self.recipe("k.sfx", "@output k.wav\n@length 0.02\nlayer sine freq=300\n")
        self.assertEqual(self.run_main("--check", path), 1)
        self.assertEqual(self.run_main(path), 0)
        self.assertEqual(self.run_main("--check", path), 0)


if __name__ == "__main__":
    unittest.main()

"""Tests for tools/get_godot.py and tools/check_all.py (no network, no Godot needed)."""

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import check_all  # noqa: E402
import get_godot  # noqa: E402
import pack_private  # noqa: E402


class AssetNameTests(unittest.TestCase):
    def test_each_platform_gets_its_release_zip(self):
        v = "4.7-stable"
        self.assertEqual(get_godot.asset_name(v, "Windows", "AMD64"), "Godot_v4.7-stable_win64.exe.zip")
        self.assertEqual(get_godot.asset_name(v, "Windows", "ARM64"), "Godot_v4.7-stable_windows_arm64.exe.zip")
        self.assertEqual(get_godot.asset_name(v, "Darwin", "arm64"), "Godot_v4.7-stable_macos.universal.zip")
        self.assertEqual(get_godot.asset_name(v, "Linux", "x86_64"), "Godot_v4.7-stable_linux.x86_64.zip")
        self.assertEqual(get_godot.asset_name(v, "Linux", "aarch64"), "Godot_v4.7-stable_linux.arm64.zip")

    def test_unknown_platform_stops(self):
        with self.assertRaises(SystemExit):
            get_godot.asset_name("4.7-stable", "Linux", "riscv64")
        with self.assertRaises(SystemExit):
            get_godot.asset_name("4.7-stable", "Plan9", "x86_64")


class SumsTests(unittest.TestCase):
    def test_reads_name_and_hash_pairs(self):
        good = "a" * 128
        text = f"{good}  Godot_v4.7-stable_win64.exe.zip\nnot a line\n{'b' * 64}  short.zip\n"
        self.assertEqual(get_godot.parse_sums(text), {"Godot_v4.7-stable_win64.exe.zip": good})


class ExecutableTests(unittest.TestCase):
    def test_windows_prefers_the_console_wrapper(self):
        with tempfile.TemporaryDirectory() as tmp:
            folder = Path(tmp)
            (folder / "Godot_v4.7-stable_win64.exe").write_bytes(b"")
            (folder / "Godot_v4.7-stable_win64_console.exe").write_bytes(b"")
            self.assertEqual(get_godot.executable_in(folder, "Windows").name, "Godot_v4.7-stable_win64_console.exe")

    def test_linux_and_macos_layouts(self):
        with tempfile.TemporaryDirectory() as tmp:
            folder = Path(tmp)
            self.assertIsNone(get_godot.executable_in(folder, "Linux"))
            (folder / "Godot_v4.7-stable_linux.x86_64").write_bytes(b"")
            self.assertEqual(get_godot.executable_in(folder, "Linux").name, "Godot_v4.7-stable_linux.x86_64")
            app = folder / "Godot.app" / "Contents" / "MacOS"
            app.mkdir(parents=True)
            (app / "Godot").write_bytes(b"")
            self.assertEqual(get_godot.executable_in(folder, "Darwin"), app / "Godot")

    def test_missing_folder(self):
        self.assertIsNone(get_godot.executable_in(Path("/nonexistent/godot"), "Linux"))


class CheckAllTests(unittest.TestCase):
    def test_public_steps_mirror_ci(self):
        names = [name for name, _, _ in check_all.steps(private=False)]
        self.assertEqual(len(names), 11)
        self.assertIn("Private story files are not tracked", names)
        self.assertTrue(all(cmd[0] == sys.executable or cmd[0] == "git" for _, cmd, _ in check_all.steps(False)))

    def test_private_adds_the_pack_checks(self):
        extra = check_all.steps(private=True)[len(check_all.steps(private=False)):]
        self.assertEqual([name for name, _, _ in extra],
                         ["Private story compiles", "Private scare settings", "Private bot playthrough"])
        self.assertTrue(extra[-1][2])  # the playthrough needs Godot


class PackTests(unittest.TestCase):
    def test_korean_names_carry_the_utf8_flag_and_clutter_stays_out(self):
        import zipfile
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "private"
            (root / "자문").mkdir(parents=True)
            (root / "자문" / "질문지.md").write_text("x", encoding="utf-8")
            (root / ".DS_Store").write_text("x", encoding="utf-8")
            (root / "l10n").mkdir()
            (root / "l10n" / ".gdignore").write_text("", encoding="utf-8")
            (root / "src" / "__pycache__").mkdir(parents=True)
            (root / "src" / "__pycache__" / "a.pyc").write_bytes(b"")
            (root / "src" / "a.py").write_text("x", encoding="utf-8")
            out = Path(tmp) / "pack.zip"
            self.assertEqual(pack_private.write_pack(root, out), 3)
            with zipfile.ZipFile(out) as z:
                names = {i.filename: i.flag_bits for i in z.infolist()}
            self.assertEqual(set(names), {"자문/질문지.md", "src/a.py", "l10n/.gdignore"})
            self.assertTrue(names["자문/질문지.md"] & 0x800)


if __name__ == "__main__":
    unittest.main()

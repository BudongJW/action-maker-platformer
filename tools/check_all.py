#!/usr/bin/env python3
"""Runs the checks CI runs (.github/workflows/content-license-checks.yml) in one go.

    python3 tools/check_all.py [--private] [--godot PATH] [--keep-going]

Run it from anywhere; it works from the repository root. Godot 4.7 is found via --godot,
$GODOT_BIN, tools/godot/ (python3 tools/get_godot.py) or `godot` on PATH.

--private also checks the private story pack in private/ (CI cannot see it): the compile, the
scare settings and a full bot playthrough of the private story. Stops at the first failure
unless --keep-going. Exit code 0 only when every step passed.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO / "tools"))

import get_godot  # noqa: E402


def steps(private: bool) -> list[tuple[str, list[str], bool]]:
    """(name, command, needs Godot) for each check, in CI order."""
    py = sys.executable
    out = [
        ("Tool tests", [py, "-m", "unittest", "discover", "-s", "tools/tests"], False),
        ("No dialogue text in GDScript", [py, "tools/check_dialogue_in_code.py"], False),
        ("Private story files are not tracked", ["git", "ls-files", "private"], False),
        ("Story scripts compile (public)", [py, "tools/storyc.py", "--check"], False),
        ("Pixel art: assets/original/art/src", [py, "tools/pixelart.py", "--check"], False),
        ("Pixel art: mibangsong", [py, "tools/pixelart.py", "--check", "--root", "assets/original/mibangsong/art/src"], False),
        ("Sound: assets/original/audio/src", [py, "tools/sfxsynth.py", "--check"], False),
        ("Sound: mibangsong", [py, "tools/sfxsynth.py", "--check", "--root", "assets/original/mibangsong/audio/src"], False),
        ("Godot runtime tests", [py, "tools/run_godot_tests.py", "--require-godot"], True),
        ("Demo bot playthrough", [py, "tools/build_prototype.py", "--story", "demo", "--smoke", "--require-godot"], True),
        ("Demo reel", [py, "tools/build_prototype.py", "--story", "demo", "--reel", "prototype/demo/reel.json", "--require-godot"], True),
    ]
    if private:
        out += [
            ("Private story compiles", [py, "tools/storyc.py", "--root", "private"], False),
            ("Private scare settings", [py, "tools/scare_lint.py", "private/assets/original/story/scares.json"], False),
            ("Private bot playthrough", [py, "tools/build_prototype.py", "--story", "private", "--smoke", "--require-godot"], True),
        ]
    return out


def find_godot(explicit: str | None) -> str | None:
    for candidate in (explicit, os.environ.get("GODOT_BIN"), get_godot.local_godot(), shutil.which("godot")):
        if candidate and Path(candidate).exists():
            return str(candidate)
    return None


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--private", action="store_true", help="also check the private story pack in private/")
    parser.add_argument("--godot", help="path to a Godot 4.7 executable")
    parser.add_argument("--keep-going", action="store_true", help="run every step even after a failure")
    args = parser.parse_args(argv)

    if args.private and not (REPO / "private/assets/original/story/project.json").exists():
        print("check_all: no private story pack in private/ (unzip it there first)", file=sys.stderr)
        return 1
    godot = find_godot(args.godot)
    env = dict(os.environ)
    env["PYTHONIOENCODING"] = "utf-8"  # Windows consoles default to another code page
    if godot:
        env["GODOT_BIN"] = godot

    results: list[tuple[str, str, float]] = []
    for name, cmd, needs_godot in steps(args.private):
        if needs_godot and godot is None:
            results.append((name, "NO GODOT", 0.0))
            print(f"--- {name}: skipped, Godot not found (run: python3 tools/get_godot.py)")
            if not args.keep_going:
                break
            continue
        print(f"--- {name}", flush=True)
        start = time.monotonic()
        proc = subprocess.run(cmd, cwd=REPO, env=env, capture_output=True, text=True, encoding="utf-8", errors="replace")
        secs = time.monotonic() - start
        ok = proc.returncode == 0
        if cmd[:2] == ["git", "ls-files"] and proc.stdout.strip():
            ok = False  # anything tracked under private/ is a failure
        tail = (proc.stdout + proc.stderr).strip().splitlines()
        for line in (tail if not ok else tail[-1:]):
            print("    " + line)
        results.append((name, "ok" if ok else "FAILED", secs))
        if not ok and not args.keep_going:
            break

    print("\ncheck_all summary")
    for name, status, secs in results:
        print(f"  {status:9} {name} ({secs:.0f} s)")
    passed = len(results) == len(steps(args.private)) and all(s == "ok" for _, s, _ in results)
    print("check_all: all checks passed" if passed else "check_all: some checks did not pass")
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())

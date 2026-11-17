#!/usr/bin/env python3
"""Run the GDScript story runtime tests in headless Godot.

Builds a throwaway Godot project that contains scripts/ (story runtime, scare director,
track mixer), tests/godot/ and a story compiled by tools/storyc.py from the examples in
docs/script-format.md plus tests/godot/fixtures/*.dlg, then runs every script in
TEST_SCRIPTS.

Usage:
    python3 tools/run_godot_tests.py [--godot PATH] [--require-godot] [--keep]

Godot is found via --godot, $GODOT_BIN, or `godot` on PATH. If it is not found the tests
are skipped (exit 0) unless --require-godot is given.
"""

from __future__ import annotations

import argparse
import contextlib
import csv
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO / "tools"))

import storyc  # noqa: E402

SPEC = REPO / "docs" / "script-format.md"
TEST_SCRIPTS = [
    ("res://tests/godot/test_story_runtime.gd", "story runtime"),
    ("res://tests/godot/test_scare_director.gd", "scare director"),
    ("res://tests/godot/test_track_mixer.gd", "track mixer"),
]
SCRIPT_DIRS = ("story", "scare", "tracks")

# Characters used by the spec example besides hongryeon (whose registry is in the spec).
EXTRA_CHARACTERS = {
    "hero": ["neutral", "uneasy"],
    "ibang": ["neutral", "bow", "fear", "surprised"],
    "watchman": ["neutral", "fear"],
}
# Translations filled into strings.csv so locale switching can be tested.
TRANSLATIONS = {
    "en": {
        "ch01_pg_002": "You came again. Do you remember which night this is?",
        "name.hongryeon": "Hongryeon",
    },
}


def spec_block(heading: str, lang: str = "") -> str:
    text = SPEC.read_text(encoding="utf-8")
    start = text.index(heading)
    return re.compile(r"```" + lang + r"\n(.*?)```", re.S).search(text, start).group(1)


def _write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def _compile(root: Path) -> None:
    out = io.StringIO()
    with contextlib.redirect_stdout(out), contextlib.redirect_stderr(out):
        code = storyc.main(["--root", str(root)])
    if code != 0:
        raise RuntimeError("storyc failed:\n" + out.getvalue())


def _add_translations(root: Path) -> None:
    path = root / "assets/original/story/l10n/strings.csv"
    rows = list(csv.reader(io.StringIO(path.read_text(encoding="utf-8"))))
    header = rows[0]
    for row in rows[1:]:
        for locale, table in TRANSLATIONS.items():
            if row[0] in table:
                row[header.index(locale)] = table[row[0]]
                row[header.index(f"{locale}_src_hash")] = row[header.index("source_hash")]
    out = io.StringIO()
    csv.writer(out, lineterminator="\n").writerows(rows)
    path.write_text(out.getvalue(), encoding="utf-8")


def build_project(root: Path) -> None:
    _write(root / "project.godot",
           'config_version=5\n\n[application]\n\nconfig/name="story-runtime-tests"\n')
    for name in SCRIPT_DIRS:
        shutil.copytree(REPO / "scripts" / name, root / "scripts" / name)
    shutil.copytree(REPO / "tests" / "godot", root / "tests" / "godot")

    story = root / "assets/original/story"
    _write(story / "project.json", spec_block("## 8. 프로젝트 설정", "json"))
    _write(root / "assets/original/characters/hongryeon/character.json", spec_block("## 3. 캐릭터 레지스트리", "json"))
    for cid, expressions in EXTRA_CHARACTERS.items():
        data = {"id": cid, "name": cid, "expressions": expressions, "default_expression": expressions[0]}
        _write(root / f"assets/original/characters/{cid}/character.json", json.dumps(data))
    _write(story / "src/ch01.dlg", spec_block("## 13. 전체 예시"))
    for fixture in sorted((REPO / "tests/godot/fixtures").glob("*.dlg")):
        shutil.copy(fixture, story / "src" / fixture.name)

    _compile(root)
    _add_translations(root)
    _compile(root)


def find_godot(explicit: str | None) -> str | None:
    for candidate in (explicit, os.environ.get("GODOT_BIN"), shutil.which("godot")):
        if candidate and Path(candidate).is_file():
            return candidate
    return None


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--godot", help="path to a Godot 4 executable")
    parser.add_argument("--require-godot", action="store_true", help="fail instead of skipping without Godot")
    parser.add_argument("--keep", action="store_true", help="keep the temporary project and print its path")
    args = parser.parse_args(argv)

    godot = find_godot(args.godot)
    if godot is None:
        print("run_godot_tests: Godot not found (use --godot or $GODOT_BIN); skipping.")
        return 1 if args.require_godot else 0

    tmp = Path(tempfile.mkdtemp(prefix="story-runtime-"))
    try:
        build_project(tmp)
        total = 0
        failed = False
        for script, label in TEST_SCRIPTS:
            proc = subprocess.run(
                [godot, "--headless", "--path", str(tmp), "-s", script],
                capture_output=True, text=True, timeout=300,
            )
            output = proc.stdout + proc.stderr
            print(output)
            summary = re.search(re.escape(label) + r": (\d+) checks, (\d+) failure\(s\)", output)
            script_errors = "SCRIPT ERROR" in output or "Parse Error" in output
            if proc.returncode != 0 or summary is None or summary.group(2) != "0" or script_errors:
                print(f"run_godot_tests: {label} FAILED (exit {proc.returncode}"
                      f"{', script errors' if script_errors else ''}"
                      f"{', no summary' if summary is None else ''})", file=sys.stderr)
                failed = True
                continue
            total += int(summary.group(1))
            print(f"run_godot_tests: {label} OK ({summary.group(1)} checks)")
        if failed:
            return 1
        print(f"run_godot_tests: OK ({total} checks in {len(TEST_SCRIPTS)} scripts)")
        return 0
    finally:
        if args.keep:
            print(f"run_godot_tests: project kept at {tmp}")
        else:
            shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())

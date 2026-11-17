#!/usr/bin/env python3
"""Build (and optionally run) the vertical-slice prototype as a standalone Godot project.

The prototype wires the story runtime, scare director and track mixer to a graybox level.
Content comes from the private story pack in private/ (git-ignored; same layout as the
repository: private/assets/original/story/ and private/assets/original/characters/) when it is
present (it must contain proto_level.json and scares.json), otherwise from the generic demo in
prototype/demo/.

Usage:
    python3 tools/build_prototype.py                     # build into build/prototype/
    python3 tools/build_prototype.py --run               # build, then open the game window
    python3 tools/build_prototype.py --story demo --smoke  # headless bot playthrough (CI)

Godot is found via --godot, $GODOT_BIN, or `godot` on PATH. Without Godot, --run and --smoke
are skipped (exit 0) unless --require-godot is given.
"""

from __future__ import annotations

import argparse
import contextlib
import io
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO / "tools"))

import storyc  # noqa: E402

SCRIPT_DIRS = ("story", "scare", "tracks", "proto")
PRIVATE_STORY = REPO / "private/assets/original/story"
PRIVATE_CHARS = REPO / "private/assets/original/characters"
DEMO = REPO / "prototype/demo"
SUMMARY_RE = re.compile(r"prototype: (\d+) frames, (\d+) loops, (\d+) dialogues, (\d+) lines, (\d+) scares")

PROJECT_GODOT = """config_version=5

[application]

config/name="Story prototype"
run/main_scene="res://main.tscn"

[display]

window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"

[rendering]

renderer/rendering_method="gl_compatibility"
"""

MAIN_TSCN = """[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/proto/proto_game.gd" id="1"]

[node name="Main" type="Node2D"]
script = ExtResource("1")
"""


def choose_source(mode: str) -> tuple[str, Path, Path]:
    private_ok = (PRIVATE_STORY / "project.json").is_file()
    if mode == "private" or (mode == "auto" and private_ok):
        if not private_ok:
            raise SystemExit("build_prototype: no private story pack in private/assets/original/story/")
        for name in ("proto_level.json", "scares.json"):
            if not (PRIVATE_STORY / name).is_file():
                raise SystemExit(f"build_prototype: private/assets/original/story/{name} is missing")
        return "private", PRIVATE_STORY, PRIVATE_CHARS
    return "demo", DEMO / "story", DEMO / "characters"


def build(out: Path, mode: str) -> str:
    source, story_dir, chars_dir = choose_source(mode)
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    (out / "project.godot").write_text(PROJECT_GODOT, encoding="utf-8")
    (out / "main.tscn").write_text(MAIN_TSCN, encoding="utf-8")
    for name in SCRIPT_DIRS:
        shutil.copytree(REPO / "scripts" / name, out / "scripts" / name)
    ignore = shutil.ignore_patterns("compiled", "l10n")
    shutil.copytree(story_dir, out / "assets/original/story", ignore=ignore)
    shutil.copytree(chars_dir, out / "assets/original/characters")
    log = io.StringIO()
    with contextlib.redirect_stdout(log), contextlib.redirect_stderr(log):
        code = storyc.main(["--root", str(out)])
    if code != 0:
        print(log.getvalue(), file=sys.stderr)
        raise SystemExit("build_prototype: story failed to compile")
    print(f"build_prototype: built {out} from the {source} story")
    return source


def find_godot(explicit: str | None) -> str | None:
    for candidate in (explicit, os.environ.get("GODOT_BIN"), shutil.which("godot")):
        if candidate and Path(candidate).is_file():
            return candidate
    return None


def smoke(godot: str, out: Path) -> int:
    subprocess.run([godot, "--headless", "--path", str(out), "--import"], capture_output=True, text=True, timeout=300)
    proc = subprocess.run([godot, "--headless", "--fixed-fps", "60", "--path", str(out), "--", "--bot"],
                          capture_output=True, text=True, timeout=600)
    output = proc.stdout + proc.stderr
    summary = SUMMARY_RE.search(output)
    errors = [line for line in output.splitlines()
              if "SCRIPT ERROR" in line or "Parse Error" in line or line.startswith("ERROR:")]
    if proc.returncode != 0 or summary is None or errors or int(summary.group(3)) == 0:
        print(output)
        print(f"build_prototype: smoke FAILED (exit {proc.returncode}, {len(errors)} error line(s)"
              f"{', no summary' if summary is None else ''})", file=sys.stderr)
        return 1
    line = next(l for l in output.splitlines() if l.startswith("prototype:"))
    print(line)
    print("build_prototype: smoke OK")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--story", choices=("auto", "demo", "private"), default="auto")
    parser.add_argument("--out", type=Path, default=REPO / "build/prototype")
    parser.add_argument("--run", action="store_true", help="open the game window after building")
    parser.add_argument("--smoke", action="store_true", help="run a headless bot playthrough")
    parser.add_argument("--godot", help="path to a Godot 4.7 executable")
    parser.add_argument("--require-godot", action="store_true")
    args = parser.parse_args(argv)
    out = args.out.resolve()
    build(out, args.story)
    if not (args.run or args.smoke):
        return 0
    godot = find_godot(args.godot)
    if godot is None:
        print("build_prototype: Godot not found (use --godot or $GODOT_BIN); skipping.")
        return 1 if args.require_godot else 0
    if args.smoke:
        return smoke(godot, out)
    subprocess.run([godot, "--path", str(out), "--import"], capture_output=True, text=True, timeout=300)
    return subprocess.call([godot, "--path", str(out)])


if __name__ == "__main__":
    sys.exit(main())

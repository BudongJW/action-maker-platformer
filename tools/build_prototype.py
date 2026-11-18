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
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO / "tools"))

import pixelart  # noqa: E402
import storyc  # noqa: E402

SCRIPT_DIRS = ("story", "scare", "tracks", "proto")
# Pixel-art sources whose @output PNGs a level's "art" block may use (frame layouts for the atlas).
ART_SOURCE_ROOTS = ("assets/original/art/src", "assets/original/mibangsong/art/src")
ART_SUFFIXES = (".png", ".pal", ".wav", ".ogg")
PRIVATE_STORY = REPO / "private/assets/original/story"
PRIVATE_CHARS = REPO / "private/assets/original/characters"
DEMO = REPO / "prototype/demo"
QUIT_AFTER_FRAMES = 150000
SMOKE_TIMEOUT_S = 1800
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
textures/canvas_textures/default_texture_filter=0
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
    ui_strings = REPO / "assets/original/ui/strings.csv"
    if ui_strings.is_file():
        # UI labels (settings screen); the prototype reads the CSV itself, so keep Godot from importing it.
        (out / "assets/original/ui").mkdir(parents=True, exist_ok=True)
        shutil.copy2(ui_strings, out / "assets/original/ui/strings.csv")
        (out / "assets/original/ui/.gdignore").write_text("", encoding="utf-8")
    log = io.StringIO()
    with contextlib.redirect_stdout(log), contextlib.redirect_stderr(log):
        code = storyc.main(["--root", str(out)])
    if code != 0:
        print(log.getvalue(), file=sys.stderr)
        raise SystemExit("build_prototype: story failed to compile")
    art = copy_art(out)
    print(f"build_prototype: built {out} from the {source} story" + (f" with {art} art and sound file(s)" if art else ""))
    return source


def _art_paths(value: object) -> list[str]:
    if isinstance(value, str):
        return [value] if value.endswith(ART_SUFFIXES) else []
    if isinstance(value, dict):
        return [p for v in value.values() for p in _art_paths(v)]
    if isinstance(value, list):
        return [p for v in value for p in _art_paths(v)]
    return []


def _sources_by_output() -> dict[str, Path]:
    found: dict[str, Path] = {}
    for root in ART_SOURCE_ROOTS:
        for src in sorted((REPO / root).glob("*.pix")):
            for line in src.read_text(encoding="utf-8").splitlines():
                if line.startswith("@output "):
                    out = (src.parent / line.split(None, 1)[1].strip()).resolve()
                    found[out.relative_to(REPO).as_posix()] = src
                    break
    return found


def copy_art(out: Path) -> int:
    """Copies the files named in the level's "art", "audio" and "board" blocks, the palette-swap
    shader, and writes assets/art_atlas.json with each sprite sheet's frame size, columns and frame
    names."""
    level = json.loads((out / "assets/original/story/proto_level.json").read_text(encoding="utf-8"))
    paths = sorted(set(_art_paths([level.get(block, {}) for block in ("art", "audio", "board")])))
    if not paths:
        return 0
    missing = [p for p in paths if not (REPO / p).is_file()]
    if missing:
        raise SystemExit("build_prototype: art file(s) not found: " + ", ".join(missing))
    shutil.copytree(REPO / "shaders", out / "shaders")
    sources = _sources_by_output()
    atlas: dict[str, dict] = {}
    for rel in paths:
        (out / rel).parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(REPO / rel, out / rel)
        if rel in sources:
            sprite = pixelart.Sprite(str(sources[rel]))
            frames = sprite.sheet_frames()
            atlas[rel] = {"size": [sprite.width, sprite.height],
                          "columns": sprite.columns or len(frames), "frames": frames}
    (out / "assets/art_atlas.json").write_text(json.dumps(atlas, indent=1), encoding="utf-8")
    return len(paths)


def find_godot(explicit: str | None) -> str | None:
    for candidate in (explicit, os.environ.get("GODOT_BIN"), shutil.which("godot")):
        if candidate and Path(candidate).is_file():
            return candidate
    return None


def smoke(godot: str, out: Path) -> int:
    subprocess.run([godot, "--headless", "--path", str(out), "--import"], capture_output=True, text=True, timeout=300)
    # --quit-after caps the frames: if the main script fails to load (a parse error), Godot would
    # otherwise run an empty scene forever and the error would never be reported.
    try:
        proc = subprocess.run([godot, "--headless", "--fixed-fps", "60", "--quit-after", str(QUIT_AFTER_FRAMES),
                               "--path", str(out), "--", "--bot"],
                              capture_output=True, text=True, timeout=SMOKE_TIMEOUT_S)
    except subprocess.TimeoutExpired as exc:
        print((exc.stdout or b"").decode("utf-8", "replace") if isinstance(exc.stdout, bytes) else (exc.stdout or ""))
        print(f"build_prototype: smoke FAILED (no result after {SMOKE_TIMEOUT_S} s)", file=sys.stderr)
        return 1
    output = proc.stdout + proc.stderr
    summary = SUMMARY_RE.search(output)
    errors = [line for line in output.splitlines()
              if "SCRIPT ERROR" in line or "Parse Error" in line or line.startswith("ERROR:")
              or "ProtoArt:" in line or "ProtoAudio:" in line or "leaked at exit" in line]
    # A level with a board must let the bot open it once (", board 2/3 unopened" otherwise).
    unopened = re.search(r"^prototype: .*, board \d+/\d+( knots \d+/\d+)? unopened", output, re.M) is not None
    if proc.returncode != 0 or summary is None or errors or int(summary.group(3)) == 0 or unopened:
        print(output)
        print(f"build_prototype: smoke FAILED (exit {proc.returncode}, {len(errors)} error line(s)"
              f"{', no summary' if summary is None else ''}{', board never opened' if unopened else ''})",
              file=sys.stderr)
        return 1
    line = next(l for l in output.splitlines() if l.startswith("prototype:"))
    print(line)
    print("build_prototype: smoke OK")
    return 0


def reel(godot: str, out: Path, reel_file: Path, movie: Path | None, fps: int = 30) -> int:
    """Plays a reel (`-- --reel`). Without `movie` it runs headless and checks for errors; with it,
    Godot's movie writer records the reel (needs a display: on a server without one, xvfb-run is
    used when present). A .mp4 movie is recorded as .avi and converted with ffmpeg."""
    subprocess.run([godot, "--headless", "--path", str(out), "--import"], capture_output=True, text=True, timeout=300)
    user_args = ["--", "--reel", str(reel_file.resolve())]
    if movie is None:
        cmd = [godot, "--headless", "--fixed-fps", str(fps), "--quit-after", str(QUIT_AFTER_FRAMES), "--path", str(out)]
    else:
        movie = movie.resolve()
        raw = movie.with_suffix(".avi") if movie.suffix.lower() == ".mp4" else movie
        cmd = [godot, "--path", str(out), "--resolution", "1280x720", "--write-movie", str(raw),
               "--fixed-fps", str(fps), "--disable-vsync", "--quit-after", str(QUIT_AFTER_FRAMES)]
        if not os.environ.get("DISPLAY") and shutil.which("xvfb-run"):
            cmd = ["xvfb-run", "-a", "-s", "-screen 0 1280x720x24"] + cmd + ["--rendering-driver", "opengl3"]
    try:
        proc = subprocess.run(cmd + user_args, capture_output=True, text=True, timeout=SMOKE_TIMEOUT_S)
    except subprocess.TimeoutExpired:
        print(f"build_prototype: reel FAILED (no result after {SMOKE_TIMEOUT_S} s)", file=sys.stderr)
        return 1
    output = proc.stdout + proc.stderr
    errors = [line for line in output.splitlines()
              if "SCRIPT ERROR" in line or "Parse Error" in line or line.startswith("ERROR:")
              or "ProtoArt:" in line or "ProtoAudio:" in line or "ProtoReel:" in line]
    done = re.search(r"^reel: (\d+) frames", output, re.M)
    if proc.returncode != 0 or errors or done is None:
        print(output)
        print(f"build_prototype: reel FAILED (exit {proc.returncode}, {len(errors)} error line(s))", file=sys.stderr)
        return 1
    print(f"build_prototype: reel OK, {int(done.group(1)) / fps:.0f} s at {fps} fps")
    if movie is not None and raw != movie:
        if shutil.which("ffmpeg") is None:
            print(f"build_prototype: ffmpeg not found; the recording is {raw}")
            return 0
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(raw), "-c:v", "libx264", "-preset", "slow",
                        "-crf", "24", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "160k", "-movflags", "+faststart",
                        str(movie)], check=True)
        raw.unlink()
        print(f"build_prototype: wrote {movie}")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--story", choices=("auto", "demo", "private"), default="auto")
    parser.add_argument("--out", type=Path, default=REPO / "build/prototype")
    parser.add_argument("--run", action="store_true", help="open the game window after building")
    parser.add_argument("--smoke", action="store_true", help="run a headless bot playthrough")
    parser.add_argument("--reel", type=Path, help="play a reel file (headless check, or record with --movie)")
    parser.add_argument("--movie", type=Path, help="with --reel: record the reel (.avi, or .mp4 through ffmpeg)")
    parser.add_argument("--godot", help="path to a Godot 4.7 executable")
    parser.add_argument("--require-godot", action="store_true")
    args = parser.parse_args(argv)
    out = args.out.resolve()
    build(out, args.story)
    if not (args.run or args.smoke or args.reel):
        return 0
    godot = find_godot(args.godot)
    if godot is None:
        print("build_prototype: Godot not found (use --godot or $GODOT_BIN); skipping.")
        return 1 if args.require_godot else 0
    if args.smoke:
        return smoke(godot, out)
    if args.reel:
        return reel(godot, out, args.reel, args.movie)
    subprocess.run([godot, "--path", str(out), "--import"], capture_output=True, text=True, timeout=300)
    return subprocess.call([godot, "--path", str(out)])


if __name__ == "__main__":
    sys.exit(main())

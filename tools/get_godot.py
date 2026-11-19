#!/usr/bin/env python3
"""Downloads Godot 4.7-stable, the engine ACTION GAME MAKER G is built on, for this computer.

    python3 tools/get_godot.py [--version 4.7-stable] [--force]

The zip comes from the official GitHub release, is checked against the release's SHA-512 list
and is unpacked into tools/godot/<version>/ (git-ignored). build_prototype.py, run_godot_tests.py
and check_all.py look there when neither --godot nor $GODOT_BIN is given, so nothing else needs
to be set. Windows (x64, arm64), macOS (universal) and Linux (x86_64, arm64) are supported.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import platform
import stat
import sys
import urllib.request
import zipfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
VERSION = "4.7-stable"
BASE_URL = "https://github.com/godotengine/godot/releases/download/{version}/"
DEST = REPO / "tools" / "godot"


def asset_name(version: str, system: str, machine: str) -> str:
    """The release zip for an OS (platform.system()) and CPU (platform.machine())."""
    m = machine.lower()
    if system == "Windows":
        return f"Godot_v{version}_windows_arm64.exe.zip" if m in ("arm64", "aarch64") else f"Godot_v{version}_win64.exe.zip"
    if system == "Darwin":
        return f"Godot_v{version}_macos.universal.zip"
    if system == "Linux":
        arch = {"x86_64": "x86_64", "amd64": "x86_64", "aarch64": "arm64", "arm64": "arm64"}.get(m)
        if arch is None:
            raise SystemExit(f"get_godot: no Godot build for Linux on {machine}")
        return f"Godot_v{version}_linux.{arch}.zip"
    raise SystemExit(f"get_godot: no Godot build for {system}")


def parse_sums(text: str) -> dict[str, str]:
    """Reads a SHA512-SUMS.txt ("<hex>  <file name>" per line) into {file name: hex}."""
    sums: dict[str, str] = {}
    for line in text.splitlines():
        parts = line.split()
        if len(parts) == 2 and len(parts[0]) == 128:
            sums[parts[1]] = parts[0].lower()
    return sums


def executable_in(folder: Path, system: str) -> Path | None:
    """The Godot executable inside an unpacked release folder. On Windows the _console.exe
    wrapper is preferred, so output reaches the terminal and the tools that capture it."""
    if not folder.is_dir():
        return None
    if system == "Darwin":
        app = folder / "Godot.app" / "Contents" / "MacOS" / "Godot"
        return app if app.is_file() else None
    files = sorted(p for p in folder.iterdir() if p.is_file() and p.name.startswith("Godot_v") and not p.name.endswith(".zip"))
    if system == "Windows":
        console = [p for p in files if p.name.endswith("_console.exe")]
        if console:
            return console[0]
        exes = [p for p in files if p.name.endswith(".exe")]
        return exes[0] if exes else None
    return files[0] if files else None


def local_godot(version: str = VERSION) -> str | None:
    """Path of a Godot unpacked by this script for this computer, or None."""
    exe = executable_in(DEST / version, platform.system())
    return str(exe) if exe is not None else None


def _download(url: str) -> bytes:
    with urllib.request.urlopen(url, timeout=300) as response:  # noqa: S310 - fixed https URL
        return response.read()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--version", default=VERSION, help=f"Godot release tag (default {VERSION})")
    parser.add_argument("--force", action="store_true", help="download again even if it is already there")
    args = parser.parse_args(argv)

    system, machine = platform.system(), platform.machine()
    folder = DEST / args.version
    existing = executable_in(folder, system)
    if existing is not None and not args.force:
        print(f"get_godot: already there: {existing}")
        return 0

    name = asset_name(args.version, system, machine)
    base = BASE_URL.format(version=args.version)
    print(f"get_godot: downloading {name}")
    sums = parse_sums(_download(base + "SHA512-SUMS.txt").decode("utf-8", "replace"))
    if name not in sums:
        print(f"get_godot: {name} is not in the release's SHA512-SUMS.txt", file=sys.stderr)
        return 1
    data = _download(base + name)
    digest = hashlib.sha512(data).hexdigest()
    if digest != sums[name]:
        print(f"get_godot: checksum mismatch for {name}; nothing was unpacked", file=sys.stderr)
        return 1
    print("get_godot: SHA-512 verified")

    folder.mkdir(parents=True, exist_ok=True)
    archive = folder / name
    archive.write_bytes(data)
    with zipfile.ZipFile(archive) as z:
        z.extractall(folder)
    archive.unlink()
    exe = executable_in(folder, system)
    if exe is None:
        print(f"get_godot: no Godot executable found in {folder}", file=sys.stderr)
        return 1
    if system != "Windows":
        # zipfile does not keep the executable bit.
        exe.chmod(exe.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    print(f"get_godot: ready: {exe}")
    print("get_godot: the tools find it on their own; to use it elsewhere, set GODOT_BIN to that path")
    return 0


if __name__ == "__main__":
    sys.exit(main())

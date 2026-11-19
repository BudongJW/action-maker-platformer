#!/usr/bin/env python3
"""Packs the private story folder (private/) into one zip for backup or handing over.

    python3 tools/pack_private.py [--out build/private_pack.zip]

File names are stored as UTF-8 with the zip's UTF-8 flag set, so Korean names unpack correctly
with Windows Explorer, PowerShell Expand-Archive, macOS and `unzip` alike (zips made by some
other tools leave the flag off, and Windows then shows the names garbled). OS clutter
(.DS_Store, Thumbs.db, desktop.ini), .git and Python caches are left out. The default output
is under build/, which git ignores; keep the zip out of the repository.

Unpack it into private/ of a checkout (see docs/handoff.md 2.2).
"""

from __future__ import annotations

import argparse
import sys
import zipfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
PRIVATE = REPO / "private"
SKIP_NAMES = {".DS_Store", "Thumbs.db", "desktop.ini", "__pycache__", ".git"}


def pack_files(root: Path) -> list[Path]:
    """Files under `root` to pack, in a stable order, without OS clutter and caches."""
    out = []
    for path in sorted(root.rglob("*")):
        rel = path.relative_to(root)
        if path.is_file() and not any(part in SKIP_NAMES for part in rel.parts) and path.suffix != ".pyc":
            out.append(path)
    return out


def write_pack(root: Path, out: Path) -> int:
    out.parent.mkdir(parents=True, exist_ok=True)
    files = pack_files(root)
    with zipfile.ZipFile(out, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for path in files:
            # zipfile sets the UTF-8 flag (bit 11) itself for names outside ASCII.
            z.write(path, path.relative_to(root).as_posix())
    return len(files)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--out", type=Path, default=REPO / "build" / "private_pack.zip", help="zip to write")
    args = parser.parse_args(argv)
    if not (PRIVATE / "assets/original/story/project.json").exists():
        print("pack_private: no private story pack in private/", file=sys.stderr)
        return 1
    out = args.out if args.out.is_absolute() else Path.cwd() / args.out
    try:
        out.resolve().relative_to(PRIVATE.resolve())
        print("pack_private: write the zip outside private/", file=sys.stderr)
        return 1
    except ValueError:
        pass
    count = write_pack(PRIVATE, out)
    print(f"pack_private: {count} file(s) -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

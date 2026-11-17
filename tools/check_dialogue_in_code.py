#!/usr/bin/env python3
"""Fail if GDScript files contain Korean text inside string literals.

Dialogue and scenario text belongs in data files under ``assets/original/``
(All Rights Reserved). GPL-licensed code must only reference that text by a
line or translation ID. Text written directly into code is distributed under
the code's license, which is how dialogue ended up GPL-licensed in projects
such as Doom and VVVVVV.

Comments (``#`` and ``##``) may contain Korean. To allow a specific literal,
add ``# dialogue-lint: allow`` as a comment on the line where it starts.

Usage:
    python3 tools/check_dialogue_in_code.py [PATH ...]

Exit status is 1 if any violation is found, 0 otherwise.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass
from typing import Iterable, Iterator, List, Sequence

HANGUL = re.compile(r"[ᄀ-ᇿ㄰-㆏ꥠ-꥿가-퟿]")
ALLOW_MARKER = "dialogue-lint: allow"
DEFAULT_EXTENSIONS = (".gd",)
# Third-party add-ons, tests, Godot cache and git-ignored private assets.
DEFAULT_EXCLUDES = ("addons", "test", "tests", ".godot", ".git", "assets_private")


@dataclass(frozen=True)
class Literal:
    line: int
    column: int
    text: str


@dataclass(frozen=True)
class Violation:
    path: str
    line: int
    column: int
    text: str


def scan_gdscript(source: str) -> tuple[List[Literal], dict[int, str]]:
    """Split GDScript source into string literals and comments.

    Returns the literals (with 1-based start line/column) and a mapping of
    line number to the comment text on that line.
    """
    literals: List[Literal] = []
    comments: dict[int, str] = {}
    i = 0
    line = 1
    col = 1
    n = len(source)

    def advance(count: int) -> None:
        nonlocal i, line, col
        for _ in range(count):
            if i >= n:
                return
            if source[i] == "\n":
                line += 1
                col = 1
            else:
                col += 1
            i += 1

    while i < n:
        ch = source[i]
        if ch == "#":
            end = source.find("\n", i)
            if end == -1:
                end = n
            comments[line] = comments.get(line, "") + source[i:end]
            advance(end - i)
            continue
        if ch in ("'", '"'):
            start_line, start_col = line, col
            quote = source[i : i + 3] if source[i : i + 3] in ('"""', "'''") else ch
            advance(len(quote))
            content_start = i
            while i < n:
                if source[i] == "\\":
                    advance(2)
                    continue
                if source.startswith(quote, i):
                    break
                if len(quote) == 1 and source[i] == "\n":
                    break  # Unterminated single-line string; stop at line end.
                advance(1)
            literals.append(Literal(start_line, start_col, source[content_start:i]))
            if source.startswith(quote, i):
                advance(len(quote))
            continue
        advance(1)
    return literals, comments


def check_source(source: str, path: str = "<string>") -> List[Violation]:
    literals, comments = scan_gdscript(source)
    violations = []
    for lit in literals:
        if not HANGUL.search(lit.text):
            continue
        if ALLOW_MARKER in comments.get(lit.line, ""):
            continue
        violations.append(Violation(path, lit.line, lit.column, lit.text))
    return violations


def iter_files(
    paths: Sequence[str], extensions: Iterable[str], excludes: Iterable[str]
) -> Iterator[str]:
    extensions = tuple(extensions)
    excluded = set(excludes)
    for root_path in paths:
        if os.path.isfile(root_path):
            if root_path.endswith(extensions):
                yield root_path
            continue
        for dirpath, dirnames, filenames in os.walk(root_path):
            dirnames[:] = sorted(d for d in dirnames if d not in excluded)
            for name in sorted(filenames):
                if name.endswith(extensions):
                    yield os.path.join(dirpath, name)


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("paths", nargs="*", default=["."], help="files or directories to scan")
    parser.add_argument(
        "--exclude",
        action="append",
        default=None,
        help="directory name to skip (repeatable; replaces the defaults: %s)"
        % ", ".join(DEFAULT_EXCLUDES),
    )
    args = parser.parse_args(argv)
    excludes = args.exclude if args.exclude is not None else DEFAULT_EXCLUDES

    violations: List[Violation] = []
    scanned = 0
    for path in iter_files(args.paths, DEFAULT_EXTENSIONS, excludes):
        scanned += 1
        with open(path, encoding="utf-8") as f:
            violations.extend(check_source(f.read(), path))

    for v in violations:
        snippet = v.text.replace("\n", "\\n")
        if len(snippet) > 60:
            snippet = snippet[:57] + "..."
        print(f'{v.path}:{v.line}:{v.column}: Korean text in string literal: "{snippet}"')

    if violations:
        print(
            f"\n{len(violations)} violation(s) in {scanned} file(s). Move dialogue and scenario "
            "text to data files under assets/original/ and reference it by ID "
            f"(or add '# {ALLOW_MARKER}' if the literal is not content).",
            file=sys.stderr,
        )
        return 1
    print(f"OK: no Korean string literals in {scanned} GDScript file(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""storyc: lint and compile .dlg character scripts.

Implements format v1 of docs/script-format.md. Reads, under the project root:

    assets/original/story/project.json
    assets/original/characters/<id>/character.json
    assets/original/story/src/**/*.dlg
    assets/original/story/l10n/strings.csv   (translations, optional)

and writes:

    assets/original/story/compiled/story.json
    assets/original/story/compiled/strings.<locale>.json
    assets/original/story/l10n/strings.csv   (compiler-managed columns)

Usage:
    python3 tools/storyc.py            # lint, then write outputs if there are no errors
    python3 tools/storyc.py --fix      # first assign missing #line: IDs in the .dlg files
    python3 tools/storyc.py --check    # lint and verify outputs are up to date; write nothing
    python3 tools/storyc.py --strict   # also fail on warnings

Exit status: 0 on success, 1 on errors (or warnings with --strict). If the story
project does not exist yet, prints a notice and exits 0.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, Iterator, List, Optional, Tuple

FORMAT_VERSION = 1
STORY_DIR = Path("assets/original/story")
CHAR_DIR = Path("assets/original/characters")

IDENT = r"[a-z][a-z0-9_]*"
IDENT_RE = re.compile(rf"^{IDENT}$")
LINE_ID_RE = re.compile(r"^[a-z0-9_]+$")
FLAG_RE = re.compile(rf"^{IDENT}(?:\.[a-z0-9_]+)+$")

RESERVED_SPEAKERS = ("narrator", "system")
DOC_SPEAKERS = ("title", "p")
KEYWORDS = ("if", "elif", "else", "set", "do")
STYLES = ("window", "bubble", "caption")
TARGETS = STYLES + ("os_dialog", "window_title", "desktop_file")
TIERS = ("loop", "save", "meta")
SYS_FLAGS = ("loop_count", "playthrough", "meta_os", "locale")
TOKENS = ("player_name", "loop_count", "os_user")
KNOWN_TAGS = ("line", "ctx")

COMMANDS: Dict[str, Tuple[Any, ...]] = {
    "wait": ("number",),
    "sfx": ("ident",),
    "music": ("ident",),
    "shake": ("number", "number"),
    "fade": (("in", "out"), "number"),
    "emit": ("ident",),
    "loop_reset": (),
    "window_shake": ("number", "number"),
}

LINE_ATTRS = ("name", "to", "emote", "voice", "side")
KIND_ATTRS = {
    "dialogue": LINE_ATTRS,
    "bark": LINE_ATTRS + ("w",),
    "cue": LINE_ATTRS + ("at", "dur"),
    "doc": (),
}
BLOCK_ATTRS = {
    "dialogue": ("requires", "forbids", "once", "priority", "style"),
    "bark": ("requires", "forbids", "cooldown"),
    "doc": ("category",),
    "cue": (),
}
ALL_BLOCK_ATTRS = {a for attrs in BLOCK_ATTRS.values() for a in attrs}
LIST_ATTRS = ("requires", "forbids")

RESERVED_DEFAULTS = {
    "narrator": {"name": None, "style": "caption", "expressions": [], "default_expression": None,
                 "portraits": {}, "aliases": {}},
    "system": {"name": None, "style": "os_dialog", "expressions": [], "default_expression": None,
               "portraits": {}, "aliases": {}},
}

NUMBER_RE = re.compile(r"^\d+(?:\.\d+)?$")
ARG_IDENT_RE = re.compile(r"^[a-z0-9_]+$")
INTERP_RE = re.compile(r"(?<!\\)\{([^}]*)\}")
BBCODE_RE = re.compile(r"\[/?([a-z_]+)(?:=[^\]]*)?\]")


# ---------------------------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------------------------


@dataclass
class Diag:
    level: str  # "error" | "warning"
    code: str
    path: str
    line: int
    msg: str

    def __str__(self) -> str:
        loc = f"{self.path}:{self.line}" if self.line else self.path
        return f"{loc}: {self.code} {self.msg}"


class Reporter:
    def __init__(self) -> None:
        self.diags: List[Diag] = []
        self.notes: List[str] = []

    def error(self, code: str, path: str, line: int, msg: str) -> None:
        self.diags.append(Diag("error", code, path, line, msg))

    def warn(self, code: str, path: str, line: int, msg: str) -> None:
        self.diags.append(Diag("warning", code, path, line, msg))

    @property
    def errors(self) -> List[Diag]:
        return [d for d in self.diags if d.level == "error"]

    @property
    def warnings(self) -> List[Diag]:
        return [d for d in self.diags if d.level == "warning"]


@dataclass(frozen=True)
class Src:
    path: str
    line: int


# ---------------------------------------------------------------------------
# Expressions
# ---------------------------------------------------------------------------


class ExprError(Exception):
    pass


_TOKEN_RE = re.compile(
    r'\s*(?:(?P<num>-?\d+(?:\.\d+)?)(?![a-z0-9_.])'
    r'|(?P<str>"[a-z0-9_]*")'
    r'|(?P<op>==|!=|<=|>=|<|>|\(|\))'
    rf"|(?P<name>{IDENT}(?:\.[a-z0-9_]+)*))"
)


def _tokenize(text: str) -> List[Tuple[str, str]]:
    text = text.strip()
    pos, toks = 0, []
    while pos < len(text):
        m = _TOKEN_RE.match(text, pos)
        if not m:
            raise ExprError(f"unexpected '{text[pos:].strip()[:20]}'")
        kind = m.lastgroup or ""
        toks.append((kind, m.group(kind)))
        pos = m.end()
        while pos < len(text) and text[pos].isspace():
            pos += 1
    return toks


class _ExprParser:
    CMP = ("==", "!=", "<", "<=", ">", ">=")

    def __init__(self, toks: List[Tuple[str, str]]) -> None:
        self.toks = toks
        self.i = 0

    def peek(self) -> Tuple[Optional[str], Optional[str]]:
        return self.toks[self.i] if self.i < len(self.toks) else (None, None)

    def take(self) -> Tuple[Optional[str], Optional[str]]:
        tok = self.peek()
        self.i += 1
        return tok

    def parse(self) -> Any:
        if not self.toks:
            raise ExprError("empty expression")
        node = self.or_()
        if self.i != len(self.toks):
            raise ExprError(f"unexpected '{self.peek()[1]}'")
        return node

    def or_(self) -> Any:
        items = [self.and_()]
        while self.peek() == ("name", "or"):
            self.take()
            items.append(self.and_())
        return items[0] if len(items) == 1 else {"or": items}

    def and_(self) -> Any:
        items = [self.not_()]
        while self.peek() == ("name", "and"):
            self.take()
            items.append(self.not_())
        return items[0] if len(items) == 1 else {"and": items}

    def not_(self) -> Any:
        if self.peek() == ("name", "not"):
            self.take()
            return {"not": self.not_()}
        return self.cmp()

    def cmp(self) -> Any:
        a = self.term()
        kind, val = self.peek()
        if kind == "op" and val in self.CMP:
            self.take()
            return {"cmp": val, "a": a, "b": self.term()}
        return a

    def term(self) -> Any:
        kind, val = self.take()
        if kind is None:
            raise ExprError("unexpected end of expression")
        if kind == "num":
            return float(val) if "." in val else int(val)
        if kind == "str":
            return val[1:-1]
        if kind == "op" and val == "(":
            node = self.or_()
            if self.take() != ("op", ")"):
                raise ExprError("missing ')'")
            return node
        if kind == "name":
            if val == "true":
                return True
            if val == "false":
                return False
            if val in ("and", "or", "not"):
                raise ExprError(f"unexpected '{val}'")
            return {"var": val}
        raise ExprError(f"unexpected '{val}'")


def parse_expr(text: str) -> Any:
    return _ExprParser(_tokenize(text)).parse()


def parse_literal(text: str) -> Any:
    toks = _tokenize(text)
    if len(toks) != 1 or toks[0][0] not in ("num", "str", "name"):
        raise ExprError(f"expected a literal value, got '{text.strip()}'")
    value = _ExprParser(toks).term()
    if isinstance(value, dict):
        raise ExprError(f"expected a literal value, got '{text.strip()}'")
    return value


def expr_vars(node: Any) -> Iterator[str]:
    if isinstance(node, dict):
        if "var" in node:
            yield node["var"]
        for key in ("a", "b", "not"):
            if key in node:
                yield from expr_vars(node[key])
        for key in ("and", "or"):
            for item in node.get(key, []):
                yield from expr_vars(item)


# ---------------------------------------------------------------------------
# Statements
# ---------------------------------------------------------------------------


@dataclass
class TextInfo:
    """Displayable text of a line or choice, with its tags."""

    text: str
    raw_text: str
    line_id: Optional[str]
    ctx: Optional[str]
    tags: List[Tuple[str, str]]
    file: Path
    raw_index: int
    tag_col: Optional[int]  # absolute column of the first tag, for --fix


@dataclass
class LineStmt:
    src: Src
    speaker: str
    expression: Optional[str]
    attrs: Dict[str, str]
    t: TextInfo


@dataclass
class ChoiceStmt:
    src: Src
    cond_if: Any
    cond_enable: Any
    once: bool
    target: Optional[str]
    body: List[Any]
    t: TextInfo


@dataclass
class IfStmt:
    src: Src
    branches: List[Tuple[Any, List[Any], Src]]  # (cond or None for else, body, src)


@dataclass
class SetStmt:
    src: Src
    var: str
    mode: str
    value: Any


@dataclass
class DoStmt:
    src: Src
    cmd: str
    args: List[str]


@dataclass
class JumpStmt:
    src: Src
    target: str


@dataclass
class LabelStmt:
    src: Src
    name: str


@dataclass
class Block:
    kind: str
    id: str
    src: Src
    attrs: Dict[str, List[Tuple[Any, Src]]] = field(default_factory=dict)
    body: List[Any] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Parser
# ---------------------------------------------------------------------------

HEADER_RE = re.compile(rf"^~(?:(bark|doc|cue)\s+|\s+)({IDENT})\s*$")
ATTR_RE = re.compile(r"^@([a-z_]+)(?:\s+(.*))?$")
LINE_HEAD_RE = re.compile(
    r"^(?P<speaker>[a-z][a-z0-9_]*)"
    r"(?:\s*\((?P<expr>[^)]*)\))?"
    r"(?P<attrs>(?:\s*\[[^\]]*\])*)"
    r"\s*:(?=\s|$)\s?"
)
ATTR_ITEM_RE = re.compile(r"^([a-z_]+)=(\S+)$")
TAG_START_RE = re.compile(r"(?:^|(?<!\\)\s)(#[a-z_]+:)")
TAG_RE = re.compile(r"#([a-z_]+):")
CHOICE_PREFIX_RE = re.compile(r"\[(if|enable_if)\s+([^\]]+)\]\s*|\[once\]\s*")
CHOICE_JUMP_RE = re.compile(r"(?:^|(?<!\\)\s)=>\s*(\S+)\s*$")


def unescape(s: str) -> str:
    out, i = [], 0
    while i < len(s):
        c = s[i]
        if c == "\\" and i + 1 < len(s):
            nx = s[i + 1]
            if nx == "n":
                out.append("\n")
                i += 2
                continue
            if nx == "#":
                out.append("#")
                i += 2
                continue
            if nx == "=" and s[i + 2 : i + 3] == ">":
                out.append("=>")
                i += 3
                continue
            if nx in "{\\":
                out.append(c + nx)  # left for the runtime's interpolation parser
                i += 2
                continue
        out.append(c)
        i += 1
    return "".join(out)


@dataclass
class _Entry:
    level: int
    line: int
    content: str
    raw_index: int
    lead: int


class FileParser:
    def __init__(self, file: Path, display: str, rep: Reporter) -> None:
        self.file = file
        self.display = display
        self.rep = rep
        self.raw_lines = file.read_text(encoding="utf-8-sig").splitlines()

    def src(self, line: int) -> Src:
        return Src(self.display, line)

    def err(self, code: str, line: int, msg: str) -> None:
        self.rep.error(code, self.display, line, msg)

    def _entries(self) -> List[_Entry]:
        entries, style = [], None
        for idx, raw in enumerate(self.raw_lines):
            raw = raw.rstrip("\r")
            stripped = raw.strip()
            if not stripped or stripped.startswith("//"):
                continue
            lead_ws = raw[: len(raw) - len(raw.lstrip())]
            level = 0
            if lead_ws:
                kinds = set(lead_ws)
                if kinds - {" ", "\t"} or len(kinds) > 1:
                    self.err("E001", idx + 1, "mixed tabs and spaces in indentation")
                    continue
                this_style = "tab" if "\t" in kinds else "space"
                if style is None:
                    style = this_style
                elif style != this_style:
                    self.err("E001", idx + 1, "indentation style differs from the rest of the file")
                    continue
                if this_style == "space":
                    if len(lead_ws) % 4:
                        self.err("E001", idx + 1, "indentation must be a multiple of 4 spaces")
                        continue
                    level = len(lead_ws) // 4
                else:
                    level = len(lead_ws)
            entries.append(_Entry(level, idx + 1, stripped, idx, len(lead_ws)))
        return entries

    def parse(self) -> List[Block]:
        entries = self._entries()
        blocks: List[Block] = []
        i = 0
        while i < len(entries) and not entries[i].content.startswith("~"):
            self.err("E001", entries[i].line, "statement outside of a block (expected a '~' header)")
            i += 1
        while i < len(entries):
            head = entries[i]
            m = HEADER_RE.match(head.content) if head.level == 0 else None
            j = i + 1
            while j < len(entries) and not (entries[j].level == 0 and entries[j].content.startswith("~")):
                j += 1
            if not m:
                self.err("E001", head.line, f"invalid block header '{head.content}'")
                i = j
                continue
            block = Block(m.group(1) or "dialogue", m.group(2), self.src(head.line))
            body = entries[i + 1 : j]
            k = 0
            while k < len(body) and body[k].level == 0 and body[k].content.startswith("@"):
                self._parse_attr(block, body[k])
                k += 1
            block.body, _ = self._parse_seq(body, k, 0, block)
            blocks.append(block)
            i = j
        return blocks

    def _parse_attr(self, block: Block, e: _Entry) -> None:
        m = ATTR_RE.match(e.content)
        if not m:
            self.err("E001", e.line, f"invalid attribute '{e.content}'")
            return
        name, value = m.group(1), (m.group(2) or "").strip()
        if name not in ALL_BLOCK_ATTRS:
            self.err("E001", e.line, f"unknown block attribute '@{name}'")
            return
        if name not in BLOCK_ATTRS[block.kind]:
            self.err("E008", e.line, f"'@{name}' is not allowed in a {block.kind} block")
            return
        if name not in LIST_ATTRS and name in block.attrs:
            self.err("E001", e.line, f"duplicate attribute '@{name}'")
            return
        parsed: Any = None
        try:
            if name in LIST_ATTRS:
                parsed = parse_expr(value)
            elif name == "once":
                parsed = value or "save"
                if parsed not in TIERS:
                    raise ExprError(f"@once takes one of {', '.join(TIERS)}")
            elif name == "priority":
                if not re.match(r"^-?\d+$", value):
                    raise ExprError("@priority takes an integer")
                parsed = int(value)
            elif name == "style":
                if value not in STYLES:
                    raise ExprError(f"@style takes one of {', '.join(STYLES)}")
                parsed = value
            elif name == "cooldown":
                if not NUMBER_RE.match(value):
                    raise ExprError("@cooldown takes a non-negative number")
                parsed = float(value)
            elif name == "category":
                if not IDENT_RE.match(value):
                    raise ExprError("@category takes an identifier")
                parsed = value
        except ExprError as exc:
            self.err("E001", e.line, f"@{name}: {exc}")
            return
        block.attrs.setdefault(name, []).append((parsed, self.src(e.line)))

    def _parse_seq(self, entries: List[_Entry], pos: int, level: int, block: Block) -> Tuple[List[Any], int]:
        stmts: List[Any] = []
        while pos < len(entries):
            e = entries[pos]
            if e.level < level:
                break
            if e.level > level:
                self.err("E001", e.line, "unexpected indentation")
                pos += 1
                while pos < len(entries) and entries[pos].level > level:
                    pos += 1
                continue
            c = e.content
            if c.startswith("@"):
                self.err("E001", e.line, "block attributes must come right after the block header")
                pos += 1
            elif c.startswith("::"):
                name = c[2:].strip()
                if level != 0:
                    self.err("E001", e.line, "labels are only allowed at the top level of a block")
                elif not IDENT_RE.match(name):
                    self.err("E001", e.line, f"invalid label name '{name}'")
                else:
                    stmts.append(LabelStmt(self.src(e.line), name))
                pos += 1
            elif c.startswith("=>"):
                target = c[2:].strip()
                if self._valid_target(target, e.line):
                    stmts.append(JumpStmt(self.src(e.line), target))
                pos += 1
            elif c == "-" or c.startswith("- "):
                choice = self._parse_choice(e)
                pos += 1
                body: List[Any] = []
                if pos < len(entries) and entries[pos].level > level:
                    body, pos = self._parse_seq(entries, pos, level + 1, block)
                if choice is not None:
                    if choice.target is not None and body:
                        self.err("E001", e.line, "a choice cannot have both '=>' and an indented body")
                    choice.body = body
                    stmts.append(choice)
            elif re.match(r"^if\s", c):
                pos = self._parse_if(entries, pos, level, block, stmts)
            elif re.match(r"^elif\s", c) or c == "else":
                self.err("E001", e.line, f"'{c.split()[0]}' without a preceding 'if'")
                pos += 1
                if pos < len(entries) and entries[pos].level > level:
                    _, pos = self._parse_seq(entries, pos, level + 1, block)
            elif c.startswith("set "):
                stmt = self._parse_set(e)
                if stmt:
                    stmts.append(stmt)
                pos += 1
            elif c == "do" or c.startswith("do "):
                parts = c.split()
                if len(parts) < 2:
                    self.err("E007", e.line, "'do' needs a command")
                else:
                    stmts.append(DoStmt(self.src(e.line), parts[1], parts[2:]))
                pos += 1
            else:
                stmt = self._parse_line(e)
                if stmt:
                    stmts.append(stmt)
                pos += 1
        return stmts, pos

    def _valid_target(self, target: str, line: int) -> bool:
        if target == "END" or IDENT_RE.match(target) or (target.startswith("~") and IDENT_RE.match(target[1:])):
            return True
        self.err("E001", line, f"invalid jump target '{target}'")
        return False

    def _parse_if(self, entries: List[_Entry], pos: int, level: int, block: Block, stmts: List[Any]) -> int:
        first = entries[pos]
        branches: List[Tuple[Any, List[Any], Src]] = []
        ok = True
        while pos < len(entries) and entries[pos].level == level:
            e = entries[pos]
            c = e.content
            if branches and not (re.match(r"^elif\s", c) or c == "else"):
                break
            if not branches and not re.match(r"^if\s", c):
                break
            cond: Any = None
            if c != "else":
                try:
                    cond = parse_expr(c.split(None, 1)[1])
                except ExprError as exc:
                    self.err("E001", e.line, f"condition: {exc}")
                    ok = False
            if branches and branches[-1][0] is None:
                self.err("E001", e.line, f"'{c.split()[0]}' after 'else'")
                ok = False
            pos += 1
            body: List[Any] = []
            if pos < len(entries) and entries[pos].level > level:
                body, pos = self._parse_seq(entries, pos, level + 1, block)
            else:
                self.err("E001", e.line, f"'{c.split()[0]}' needs an indented body")
                ok = False
            branches.append((cond, body, self.src(e.line)))
            if c == "else":
                break
        if ok and branches:
            stmts.append(IfStmt(self.src(first.line), branches))
        return pos

    def _parse_set(self, e: _Entry) -> Optional[SetStmt]:
        m = re.match(r"^set\s+(\S+)\s*(\+=|-=|=)\s*(.+)$", e.content)
        if not m:
            self.err("E001", e.line, "expected 'set <flag> = <value>' (or += / -=)")
            return None
        var, mode, value_text = m.groups()
        try:
            value = parse_literal(value_text)
        except ExprError as exc:
            self.err("E001", e.line, str(exc))
            return None
        if mode != "=" and (isinstance(value, bool) or not isinstance(value, int)):
            self.err("E001", e.line, f"'{mode}' takes an integer")
            return None
        return SetStmt(self.src(e.line), var, mode, value)

    def _text_info(self, e: _Entry, rest: str, rest_offset: int) -> Optional[TextInfo]:
        m = TAG_START_RE.search(rest)
        if m:
            pre, tag_str, tag_pos = rest[: m.start(1)], rest[m.start(1) :], m.start(1)
        else:
            pre, tag_str, tag_pos = rest, "", None
        tags: List[Tuple[str, str]] = []
        line_id = ctx = None
        p = 0
        while p < len(tag_str):
            while p < len(tag_str) and tag_str[p].isspace():
                p += 1
            if p >= len(tag_str):
                break
            tm = TAG_RE.match(tag_str, p)
            if not tm:
                self.err("E001", e.line, f"unexpected text after tags: '{tag_str[p:].strip()[:30]}'")
                return None
            key = tm.group(1)
            p = tm.end()
            if key == "ctx":
                value, p = tag_str[p:].strip(), len(tag_str)
            else:
                vm = re.compile(r"\S*").match(tag_str, p)
                value, p = vm.group(0), vm.end()
            tags.append((key, value))
            if key == "line":
                if line_id is not None:
                    self.err("E004", e.line, "more than one #line: tag")
                elif not LINE_ID_RE.match(value):
                    self.err("E001", e.line, f"invalid line ID '{value}' (use [a-z0-9_]+)")
                line_id = value
            elif key == "ctx":
                ctx = value
        raw_text = pre.strip()
        tag_col = e.lead + rest_offset + tag_pos if tag_pos is not None else None
        return TextInfo(unescape(raw_text), raw_text, line_id, ctx, tags, self.file, e.raw_index, tag_col)

    def _parse_line(self, e: _Entry) -> Optional[LineStmt]:
        m = LINE_HEAD_RE.match(e.content)
        if not m:
            self.err("E001", e.line, f"cannot parse line: '{e.content[:40]}'")
            return None
        expr = m.group("expr")
        if expr is not None:
            expr = expr.strip()
            if not IDENT_RE.match(expr):
                self.err("E001", e.line, f"invalid expression name '({expr})'")
                return None
        attrs: Dict[str, str] = {}
        for item in re.findall(r"\[([^\]]*)\]", m.group("attrs")):
            am = ATTR_ITEM_RE.match(item.strip())
            if not am:
                self.err("E001", e.line, f"invalid line attribute '[{item}]' (expected [key=value])")
                return None
            if am.group(1) in attrs:
                self.err("E001", e.line, f"duplicate attribute '{am.group(1)}'")
                return None
            attrs[am.group(1)] = am.group(2)
        info = self._text_info(e, e.content[m.end() :], m.end())
        if info is None:
            return None
        if not info.text:
            self.err("E001", e.line, "empty line text")
            return None
        return LineStmt(self.src(e.line), m.group("speaker"), expr, attrs, info)

    def _parse_choice(self, e: _Entry) -> Optional[ChoiceStmt]:
        s = e.content[1:]
        offset = 1
        lead = len(s) - len(s.lstrip())
        s, offset = s[lead:], offset + lead
        cond_if = cond_enable = None
        once = False
        seen_prefix = set()
        while True:
            m = CHOICE_PREFIX_RE.match(s)
            if not m:
                break
            kind = m.group(1) or "once"
            if kind in seen_prefix:
                self.err("E001", e.line, f"duplicate [{kind}] on a choice")
                return None
            seen_prefix.add(kind)
            if kind == "once":
                once = True
            else:
                try:
                    node = parse_expr(m.group(2))
                except ExprError as exc:
                    self.err("E001", e.line, f"[{kind}]: {exc}")
                    return None
                if kind == "if":
                    cond_if = node
                else:
                    cond_enable = node
            s, offset = s[m.end() :], offset + m.end()
        info = self._text_info(e, s, offset)
        if info is None:
            return None
        target = None
        jm = CHOICE_JUMP_RE.search(info.raw_text)
        if jm:
            target = jm.group(1)
            if not self._valid_target(target, e.line):
                return None
            info.raw_text = info.raw_text[: jm.start()].strip()
            info.text = unescape(info.raw_text)
        if not info.text:
            self.err("E001", e.line, "empty choice text")
            return None
        return ChoiceStmt(self.src(e.line), cond_if, cond_enable, once, target, [], info)


# ---------------------------------------------------------------------------
# Project and characters
# ---------------------------------------------------------------------------


def _rel(root: Path, path: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return path.as_posix()


def _load_json(path: Path, display: str, rep: Reporter) -> Optional[Any]:
    try:
        return json.loads(path.read_text(encoding="utf-8-sig"))
    except (OSError, ValueError) as exc:
        rep.error("E009", display, 0, f"cannot read JSON: {exc}")
        return None


def load_project(root: Path, rep: Reporter) -> Optional[Dict[str, Any]]:
    path = root / STORY_DIR / "project.json"
    display = _rel(root, path)
    data = _load_json(path, display, rep)
    if not isinstance(data, dict):
        if data is not None:
            rep.error("E009", display, 0, "project.json must be an object")
        return None
    ok = True
    if data.get("format") != FORMAT_VERSION:
        rep.error("E009", display, 0, f"'format' must be {FORMAT_VERSION}")
        ok = False
    src_locale = data.get("source_locale")
    locales = data.get("locales")
    if not isinstance(src_locale, str) or not src_locale:
        rep.error("E009", display, 0, "'source_locale' is required")
        ok = False
    if not isinstance(locales, list) or not all(isinstance(x, str) for x in locales) or src_locale not in locales:
        rep.error("E009", display, 0, "'locales' must be a list of strings that includes source_locale")
        ok = False
    emotes = data.get("emotes", [])
    max_chars = data.get("max_chars", {})
    external = data.get("external_flags", [])
    if not isinstance(emotes, list) or not all(isinstance(x, str) for x in emotes):
        rep.error("E009", display, 0, "'emotes' must be a list of strings")
        ok = False
    if not isinstance(max_chars, dict) or not all(isinstance(v, int) for v in max_chars.values()):
        rep.error("E009", display, 0, "'max_chars' must map styles to integers")
        ok = False
    if not isinstance(external, list) or not all(isinstance(x, str) for x in external):
        rep.error("E009", display, 0, "'external_flags' must be a list of strings")
        ok = False
    if not ok:
        return None
    return {"source_locale": src_locale, "locales": locales, "emotes": emotes,
            "max_chars": max_chars, "external_flags": external}


def load_characters(root: Path, rep: Reporter) -> Dict[str, Dict[str, Any]]:
    chars: Dict[str, Dict[str, Any]] = {}
    base = root / CHAR_DIR
    if not base.is_dir():
        return chars
    for folder in sorted(p for p in base.iterdir() if p.is_dir()):
        path = folder / "character.json"
        display = _rel(root, path)
        if not path.exists():
            rep.error("E009", _rel(root, folder), 0, "missing character.json")
            continue
        data = _load_json(path, display, rep)
        if data is None:
            continue
        char = _validate_character(root, folder, data, display, rep)
        if char is not None:
            chars[char["id"]] = char
    return chars


def _validate_character(root: Path, folder: Path, data: Any, display: str, rep: Reporter) -> Optional[Dict[str, Any]]:
    def bad(msg: str) -> None:
        rep.error("E009", display, 0, msg)

    if not isinstance(data, dict):
        bad("character.json must be an object")
        return None
    cid = data.get("id")
    if cid != folder.name or not isinstance(cid, str) or not IDENT_RE.match(cid):
        bad(f"'id' must match the folder name '{folder.name}' and be [a-z][a-z0-9_]*")
        return None
    if cid in DOC_SPEAKERS or cid in KEYWORDS:
        bad(f"'{cid}' is reserved and cannot be a character ID")
        return None
    reserved = cid in RESERVED_SPEAKERS
    base = dict(RESERVED_DEFAULTS[cid]) if reserved else {}
    ok = True
    name = data.get("name", base.get("name"))
    if not reserved and (not isinstance(name, str) or not name):
        bad("'name' is required")
        ok = False
    expressions = data.get("expressions", base.get("expressions"))
    if not isinstance(expressions, list) or not all(isinstance(x, str) and IDENT_RE.match(x) for x in expressions) \
            or len(set(expressions)) != len(expressions) or (not reserved and not expressions):
        bad("'expressions' must be a non-empty list of unique identifiers")
        ok = False
        expressions = []
    default = data.get("default_expression", base.get("default_expression"))
    if expressions and default not in expressions:
        bad("'default_expression' must be one of 'expressions'")
        ok = False
    aliases = data.get("aliases", {})
    if not isinstance(aliases, dict) or not all(IDENT_RE.match(k) and isinstance(v, str) and v for k, v in aliases.items()):
        bad("'aliases' must map identifiers to non-empty names")
        ok = False
    color = data.get("color")
    if color is not None and not (isinstance(color, str) and re.match(r"^#[0-9a-fA-F]{6}$", color)):
        bad("'color' must look like #rrggbb")
        ok = False
    style = data.get("style", base.get("style", "window"))
    allowed_styles = TARGETS if reserved else STYLES
    if style not in allowed_styles:
        bad(f"'style' must be one of {', '.join(allowed_styles)}")
        ok = False
    portraits = data.get("portraits", {})
    if not isinstance(portraits, dict) or not all(isinstance(v, str) for v in portraits.values()):
        bad("'portraits' must map expressions to file paths")
        ok = False
        portraits = {}
    for expr, rel in portraits.items():
        if expr not in expressions:
            bad(f"portrait for unknown expression '{expr}'")
            ok = False
        elif not (folder / rel).is_file():
            rep.warn("W106", display, 0, f"portrait file not found: {rel}")
    blip = data.get("blip")
    if blip is not None and not isinstance(blip, str):
        bad("'blip' must be a string")
        ok = False
    if not ok:
        return None
    return {
        "id": cid, "name": name, "aliases": aliases, "color": color, "style": style,
        "expressions": expressions, "default_expression": default,
        "portraits": {k: "res://" + _rel(root, folder / v) for k, v in portraits.items()},
        "blip": blip,
    }


# ---------------------------------------------------------------------------
# Compiler
# ---------------------------------------------------------------------------


@dataclass
class StringEntry:
    id: str
    kind: str
    speaker: str
    expression: str
    context: str
    text: str
    src: Src


@dataclass
class MissingId:
    file: Path
    raw_index: int
    tag_col: Optional[int]
    block_id: str


class Compiler:
    def __init__(self, root: Path, project: Dict[str, Any], speakers: Dict[str, Dict[str, Any]],
                 blocks: List[Block], rep: Reporter) -> None:
        self.root = root
        self.project = project
        self.speakers = speakers
        self.blocks = blocks
        self.rep = rep
        self.block_kinds: Dict[str, str] = {}
        self.strings: List[StringEntry] = []
        self.missing: List[MissingId] = []
        self.flags_read: Dict[str, Src] = {}
        self.flags_written: set = set()
        self.seen_refs: List[Tuple[str, Src]] = []
        self.switch_refs: List[Tuple[str, Src]] = []
        self.line_ids: Dict[str, Src] = {}

    # -- helpers -----------------------------------------------------------

    def err(self, code: str, src: Src, msg: str) -> None:
        self.rep.error(code, src.path, src.line, msg)

    def warn(self, code: str, src: Src, msg: str) -> None:
        self.rep.warn(code, src.path, src.line, msg)

    def check_flag(self, name: str, src: Src, write: bool) -> None:
        if not FLAG_RE.match(name):
            self.err("E006", src, f"invalid flag name '{name}' (expected <tier>.<name>)")
            return
        parts = name.split(".")
        tier = parts[0]
        if tier in TIERS:
            if write:
                self.flags_written.add(name)
            else:
                self.flags_read.setdefault(name, src)
            return
        if write:
            self.err("E006", src, f"'{name}' is read-only and cannot be set")
            return
        if tier == "sys":
            if len(parts) != 2 or parts[1] not in SYS_FLAGS:
                self.err("E006", src, f"unknown runtime flag '{name}' (sys.* is {', '.join(SYS_FLAGS)})")
        elif tier == "seen":
            if len(parts) != 3 or parts[1] not in TIERS:
                self.err("E006", src, f"invalid seen flag '{name}' (expected seen.<loop|save|meta>.<block id>)")
            else:
                self.seen_refs.append((parts[2], src))
        else:
            self.err("E006", src, f"unknown flag tier '{tier}' in '{name}'")

    def check_expr(self, node: Any, src: Src) -> None:
        for var in expr_vars(node):
            self.check_flag(var, src, write=False)

    def check_text(self, t: TextInfo, src: Src) -> None:
        for key, _ in t.tags:
            if key not in KNOWN_TAGS:
                self.warn("W105", src, f"unknown tag '#{key}:'")
        for inner in INTERP_RE.findall(t.raw_text):
            inner = inner.strip()
            if inner.startswith("@"):
                if inner[1:] not in TOKENS:
                    self.err("E006", src, f"unknown runtime token '{{{inner}}}' (use {', '.join('@' + x for x in TOKENS)})")
            else:
                self.check_flag(inner, src, write=False)

    def register_text(self, t: TextInfo, src: Src, block: Block, kind: str, speaker: str,
                      expression: Optional[str], style: Optional[str]) -> Optional[str]:
        self.check_text(t, src)
        if t.line_id is None:
            self.err("E004", src, "missing #line: ID (run with --fix to assign one)")
            self.missing.append(MissingId(t.file, t.raw_index, t.tag_col, block.id))
            return None
        if t.line_id in self.line_ids:
            other = self.line_ids[t.line_id]
            self.err("E004", src, f"duplicate line ID '{t.line_id}' (also at {other.path}:{other.line})")
            return t.line_id
        self.line_ids[t.line_id] = src
        self.strings.append(StringEntry(t.line_id, kind, speaker, expression or "", t.ctx or "", t.text, src))
        if style:
            limit = self.project["max_chars"].get(style)
            visible = len(BBCODE_RE.sub("", t.text).replace("\\{", "{").replace("\\\\", "\\"))
            if isinstance(limit, int) and visible > limit:
                self.warn("W103", src, f"text is {visible} characters; the '{style}' limit is {limit}")
        return t.line_id

    def speaker_info(self, name: str) -> Optional[Dict[str, Any]]:
        return self.speakers.get(name)

    def check_line(self, s: LineStmt, block: Block) -> Optional[Dict[str, Any]]:
        """Validate a line statement; return its compiled fields (without 'op')."""
        kind = block.kind
        ok = True
        if kind == "doc":
            if s.speaker not in DOC_SPEAKERS:
                self.err("E008", s.src, f"document blocks only allow 'title:' and 'p:' lines, not '{s.speaker}'")
                return None
            if s.expression or s.attrs:
                self.err("E008", s.src, "'title:' and 'p:' lines take no expression or attributes")
                return None
        else:
            if s.speaker in DOC_SPEAKERS:
                self.err("E008", s.src, f"'{s.speaker}:' is only allowed in document blocks")
                return None
            info = self.speaker_info(s.speaker)
            if info is None:
                self.err("E002", s.src, f"unknown speaker '{s.speaker}'")
                return None
            if s.expression is not None and s.expression not in info["expressions"]:
                self.err("E003", s.src, f"'{s.speaker}' has no expression '{s.expression}'")
                ok = False
            allowed = KIND_ATTRS[kind]
            for key, value in s.attrs.items():
                if key not in allowed:
                    if key in ("w", "at", "dur"):
                        self.err("E008", s.src, f"[{key}=] is not allowed in a {kind} block")
                    else:
                        self.err("E001", s.src, f"unknown line attribute '{key}'")
                    ok = False
                    continue
                if key == "name" and value not in info["aliases"]:
                    self.err("E003", s.src, f"'{s.speaker}' has no alias '{value}'")
                    ok = False
                elif key == "to" and value not in TARGETS:
                    self.err("E001", s.src, f"[to=] must be one of {', '.join(TARGETS)}")
                    ok = False
                elif key == "emote" and value not in self.project["emotes"]:
                    self.err("E003", s.src, f"unknown emote '{value}' (see project.json 'emotes')")
                    ok = False
                elif key == "side" and value not in ("left", "right"):
                    self.err("E001", s.src, "[side=] must be left or right")
                    ok = False
                elif key == "voice" and not ARG_IDENT_RE.match(value):
                    self.err("E001", s.src, "[voice=] takes a clip identifier")
                    ok = False
                elif key == "w" and not re.match(r"^[1-9]\d*$", value):
                    self.err("E001", s.src, "[w=] takes a positive integer")
                    ok = False
                elif key in ("at", "dur") and not NUMBER_RE.match(value):
                    self.err("E001", s.src, f"[{key}=] takes a non-negative number")
                    ok = False
            if kind == "cue" and not ("at" in s.attrs and "dur" in s.attrs):
                self.err("E008", s.src, "cue lines need both [at=] and [dur=]")
                ok = False
        style = None
        if kind != "doc":
            info = self.speakers[s.speaker]
            default_style = {"bark": "bubble", "cue": "caption"}.get(kind)
            block_style = block.attrs.get("style", [(None, None)])[0][0]
            style = s.attrs.get("to") or default_style or block_style or info["style"] or "window"
        str_kind = {"dialogue": "line", "bark": "bark", "doc": "doc", "cue": "cue"}[kind]
        line_id = self.register_text(s.t, s.src, block, str_kind, s.speaker, s.expression, style)
        if not ok or line_id is None:
            return None
        out: Dict[str, Any] = {"id": line_id, "speaker": s.speaker}
        if s.expression:
            out["expression"] = s.expression
        for key in LINE_ATTRS:
            if key in s.attrs:
                out[key] = s.attrs[key]
        if kind == "bark":
            out["w"] = int(s.attrs.get("w", "1"))
        if kind == "cue" and "at" in s.attrs and "dur" in s.attrs:
            out["at"] = float(s.attrs["at"])
            out["dur"] = float(s.attrs["dur"])
        return out

    # -- blocks ------------------------------------------------------------

    def compile(self) -> Dict[str, Any]:
        for b in self.blocks:
            if b.id in self.block_kinds:
                self.err("E004", b.src, f"duplicate block ID '{b.id}'")
            else:
                self.block_kinds[b.id] = b.kind
        story: Dict[str, Any] = {
            "format": FORMAT_VERSION,
            "source_locale": self.project["source_locale"],
            "locales": self.project["locales"],
            "characters": self.compile_characters(),
            "dialogues": {}, "barks": {}, "docs": {}, "cues": {},
        }
        for b in self.blocks:
            if b.kind == "dialogue":
                story["dialogues"][b.id] = self.compile_dialogue(b)
            elif b.kind == "bark":
                story["barks"][b.id] = self.compile_bark(b)
            elif b.kind == "doc":
                story["docs"][b.id] = self.compile_doc(b)
            else:
                story["cues"][b.id] = self.compile_cue(b)
        for target, src in self.seen_refs:
            if target not in self.block_kinds:
                self.err("E006", src, f"seen flag refers to unknown block '{target}'")
        for target, src in self.switch_refs:
            if self.block_kinds.get(target) != "dialogue":
                self.err("E005", src, f"'=> ~{target}': no dialogue block with that ID")
        external = set(self.project["external_flags"])
        for name, src in self.flags_read.items():
            if name not in self.flags_written and name not in external:
                self.warn("W101", src, f"flag '{name}' is read but never set in any .dlg "
                                       "(add it to project.json 'external_flags' if the game sets it)")
        return story

    def compile_characters(self) -> Dict[str, Any]:
        out = {}
        for cid in sorted(self.speakers):
            c = self.speakers[cid]
            entry: Dict[str, Any] = {}
            if c.get("color"):
                entry["color"] = c["color"]
            entry["style"] = c["style"]
            entry["expressions"] = c["expressions"]
            entry["default_expression"] = c["default_expression"]
            entry["portraits"] = c["portraits"]
            entry["aliases"] = list(c["aliases"])
            if c.get("blip"):
                entry["blip"] = c["blip"]
            out[cid] = entry
        return out

    def _requires(self, b: Block) -> Any:
        conds = []
        for node, src in b.attrs.get("requires", []):
            self.check_expr(node, src)
            conds.append(node)
        for node, src in b.attrs.get("forbids", []):
            self.check_expr(node, src)
            conds.append({"not": node})
        if not conds:
            return None
        return conds[0] if len(conds) == 1 else {"and": conds}

    def _only_lines(self, b: Block) -> List[LineStmt]:
        lines = []
        for s in b.body:
            if isinstance(s, LineStmt):
                lines.append(s)
            else:
                self.err("E008", s.src, f"only lines are allowed in a {b.kind} block")
        if not b.body:
            self.err("E008", b.src, f"empty {b.kind} block")
        return lines

    def compile_bark(self, b: Block) -> Dict[str, Any]:
        cooldown = b.attrs.get("cooldown", [(None, None)])[0][0]
        lines = [x for x in (self.check_line(s, b) for s in self._only_lines(b)) if x]
        return {"requires": self._requires(b), "cooldown": cooldown, "lines": lines}

    def compile_doc(self, b: Block) -> Dict[str, Any]:
        title = None
        paragraphs = []
        for s in self._only_lines(b):
            compiled = self.check_line(s, b)
            if s.speaker == "title":
                if title is not None:
                    self.err("E008", s.src, "a document can have only one 'title:' line")
                elif compiled:
                    title = compiled["id"]
            elif compiled:
                paragraphs.append(compiled["id"])
        category = b.attrs.get("category", [(None, None)])[0][0]
        return {"category": category, "title": title, "paragraphs": paragraphs}

    def compile_cue(self, b: Block) -> Dict[str, Any]:
        lines = [x for x in (self.check_line(s, b) for s in self._only_lines(b)) if x]
        return {"lines": lines}

    def compile_dialogue(self, b: Block) -> Dict[str, Any]:
        dc = _DialogueCode(self, b)
        if not b.body:
            self.err("E008", b.src, "empty dialogue block")
        dc.compile()
        return {
            "requires": self._requires(b),
            "once": b.attrs.get("once", [(None, None)])[0][0],
            "priority": b.attrs.get("priority", [(0, None)])[0][0],
            "style": b.attrs.get("style", [(None, None)])[0][0],
            "code": dc.code,
        }


class _DialogueCode:
    TERMINAL = ("goto", "end", "switch")

    def __init__(self, c: Compiler, block: Block) -> None:
        self.c = c
        self.block = block
        self.code: List[Dict[str, Any]] = []
        self.op_src: List[Src] = []
        self.labels: Dict[str, int] = {}
        self.label_src: Dict[str, Src] = {}
        self.used_labels: set = set()
        self.fixups: List[Tuple[Dict[str, Any], str, str, Src]] = []

    def emit(self, op: Dict[str, Any], src: Src) -> int:
        self.code.append(op)
        self.op_src.append(src)
        return len(self.code) - 1

    def jump_op(self, s: JumpStmt) -> Dict[str, Any]:
        if s.target == "END":
            return {"op": "end"}
        if s.target.startswith("~"):
            self.c.switch_refs.append((s.target[1:], s.src))
            return {"op": "switch", "dialogue": s.target[1:]}
        op = {"op": "goto", "pc": None}
        self.fixups.append((op, "pc", s.target, s.src))
        return op

    def compile(self) -> None:
        falls = self.body(self.block.body)
        if falls or not self.code:
            self.emit({"op": "end"}, self.block.src)
        for holder, key, label, src in self.fixups:
            if label not in self.labels:
                self.c.err("E005", src, f"unknown label '{label}' in '{self.block.id}'")
                holder[key] = 0
            else:
                holder[key] = self.labels[label]
                self.used_labels.add(label)
        for name, src in self.label_src.items():
            if name not in self.used_labels:
                self.c.warn("W102", src, f"label '{name}' is never jumped to")
        self.check_reachability()

    def body(self, stmts: List[Any]) -> bool:
        falls = True
        i = 0
        while i < len(stmts):
            s = stmts[i]
            if isinstance(s, ChoiceStmt):
                group = [s]
                while i + len(group) < len(stmts) and isinstance(stmts[i + len(group)], ChoiceStmt):
                    group.append(stmts[i + len(group)])
                self.choice_group(group)
                i += len(group)
                falls = True
                continue
            if isinstance(s, LabelStmt):
                if s.name in self.labels:
                    self.c.err("E004", s.src, f"duplicate label '{s.name}'")
                else:
                    self.labels[s.name] = len(self.code)
                    self.label_src[s.name] = s.src
                falls = True
            elif isinstance(s, LineStmt):
                fields = self.c.check_line(s, self.block)
                self.emit(dict({"op": "line"}, **(fields or {"id": s.t.line_id, "speaker": s.speaker})), s.src)
                falls = True
            elif isinstance(s, SetStmt):
                self.c.check_flag(s.var, s.src, write=True)
                self.emit({"op": "set", "var": s.var, "mode": s.mode, "value": s.value}, s.src)
                falls = True
            elif isinstance(s, DoStmt):
                self.emit({"op": "do", "cmd": s.cmd, "args": self.do_args(s)}, s.src)
                falls = True
            elif isinstance(s, JumpStmt):
                self.emit(self.jump_op(s), s.src)
                falls = False
            elif isinstance(s, IfStmt):
                self.if_stmt(s)
                falls = True
            i += 1
        return falls

    def do_args(self, s: DoStmt) -> List[Any]:
        spec = COMMANDS.get(s.cmd)
        if spec is None:
            self.c.err("E007", s.src, f"unknown command '{s.cmd}' (allowed: {', '.join(COMMANDS)})")
            return list(s.args)
        if len(s.args) != len(spec):
            self.c.err("E007", s.src, f"'{s.cmd}' takes {len(spec)} argument(s), got {len(s.args)}")
            return list(s.args)
        out: List[Any] = []
        for arg, kind in zip(s.args, spec):
            if kind == "number":
                if not NUMBER_RE.match(arg):
                    self.c.err("E007", s.src, f"'{s.cmd}': '{arg}' is not a non-negative number")
                    out.append(arg)
                else:
                    out.append(float(arg) if "." in arg else int(arg))
            elif kind == "ident":
                if not ARG_IDENT_RE.match(arg):
                    self.c.err("E007", s.src, f"'{s.cmd}': '{arg}' is not an identifier")
                out.append(arg)
            else:
                if arg not in kind:
                    self.c.err("E007", s.src, f"'{s.cmd}': '{arg}' must be one of {', '.join(kind)}")
                out.append(arg)
        return out

    def choice_group(self, group: List[ChoiceStmt]) -> None:
        choice = {"op": "choice", "options": [], "skip_pc": None}
        self.emit(choice, group[0].src)
        end_gotos = []
        for ch in group:
            line_id = self.c.register_text(ch.t, ch.src, self.block, "choice", "", None, None)
            opt: Dict[str, Any] = {"id": line_id}
            if ch.cond_if is not None:
                self.c.check_expr(ch.cond_if, ch.src)
                opt["if"] = ch.cond_if
            if ch.cond_enable is not None:
                self.c.check_expr(ch.cond_enable, ch.src)
                opt["enable_if"] = ch.cond_enable
            if ch.once:
                opt["once"] = True
            if ch.target is not None:
                jump = JumpStmt(ch.src, ch.target)
                if ch.target == "END" or ch.target.startswith("~"):
                    opt["pc"] = self.emit(self.jump_op(jump), ch.src)
                else:
                    opt["pc"] = None
                    self.fixups.append((opt, "pc", ch.target, ch.src))
            else:
                opt["pc"] = len(self.code)
                if self.body(ch.body):
                    end_gotos.append(self.emit({"op": "goto", "pc": None}, ch.src))
            choice["options"].append(opt)
        after = len(self.code)
        choice["skip_pc"] = after
        for idx in end_gotos:
            self.code[idx]["pc"] = after

    def if_stmt(self, s: IfStmt) -> None:
        end_jumps = []
        for idx, (cond, body, src) in enumerate(s.branches):
            last = idx == len(s.branches) - 1
            if cond is not None:
                self.c.check_expr(cond, src)
                br = self.emit({"op": "branch", "if": cond, "else_pc": None}, src)
                falls = self.body(body)
                if falls and not last:
                    end_jumps.append(self.emit({"op": "goto", "pc": None}, src))
                self.code[br]["else_pc"] = len(self.code)
            else:
                self.body(body)
        end = len(self.code)
        for j in end_jumps:
            self.code[j]["pc"] = end

    def check_reachability(self) -> None:
        n = len(self.code)
        seen = [False] * n
        stack = [0] if n else []
        while stack:
            pc = stack.pop()
            if pc < 0 or pc >= n or seen[pc]:
                continue
            seen[pc] = True
            op = self.code[pc]
            kind = op["op"]
            if kind in ("line", "set", "do"):
                stack.append(pc + 1)
            elif kind == "choice":
                stack.extend(o["pc"] for o in op["options"] if isinstance(o.get("pc"), int))
                stack.append(op["skip_pc"])
            elif kind == "branch":
                stack.extend([pc + 1, op["else_pc"]])
            elif kind == "goto" and isinstance(op["pc"], int):
                stack.append(op["pc"])
        pc = 0
        while pc < n:
            if not seen[pc]:
                self.c.warn("W102", self.op_src[pc], f"unreachable statement in '{self.block.id}'")
                while pc < n and not seen[pc]:
                    pc += 1
            pc += 1


# ---------------------------------------------------------------------------
# Strings and translations
# ---------------------------------------------------------------------------


def source_hash(text: str) -> str:
    return hashlib.sha1(text.encode("utf-8")).hexdigest()[:8]


def _placeholders(text: str) -> List[str]:
    return sorted(INTERP_RE.findall(text)) + sorted(m.group(0).split("=")[0] for m in BBCODE_RE.finditer(text))


def name_strings(speakers: Dict[str, Dict[str, Any]]) -> List[StringEntry]:
    out = []
    for cid in sorted(speakers):
        c = speakers[cid]
        if c.get("name"):
            out.append(StringEntry(f"name.{cid}", "name", cid, "", "", c["name"], Src("", 0)))
        for alias, text in c.get("aliases", {}).items():
            out.append(StringEntry(f"name.{cid}.{alias}", "name", cid, "", "", text, Src("", 0)))
    return out


def build_translations(root: Path, project: Dict[str, Any], entries: List[StringEntry],
                       rep: Reporter) -> Tuple[str, Dict[str, Dict[str, str]]]:
    """Return the new CSV text and per-locale string tables."""
    src_loc = project["source_locale"]
    others = [loc for loc in project["locales"] if loc != src_loc]
    csv_path = root / STORY_DIR / "l10n" / "strings.csv"
    csv_display = _rel(root, csv_path)
    existing: Dict[str, Tuple[int, Dict[str, str]]] = {}
    if csv_path.exists():
        with csv_path.open(encoding="utf-8-sig", newline="") as f:
            for row_no, row in enumerate(csv.DictReader(f), start=2):
                if row.get("id"):
                    existing[row["id"]] = (row_no, row)
    header = ["id", "kind", "speaker", "expression", "context", "source_hash", src_loc]
    for loc in others:
        header += [loc, f"{loc}_src_hash"]
    out = io.StringIO()
    writer = csv.writer(out, lineterminator="\n")
    writer.writerow(header)
    tables: Dict[str, Dict[str, str]] = {loc: {} for loc in project["locales"]}
    missing = {loc: 0 for loc in others}
    stale = {loc: 0 for loc in others}
    for e in entries:
        h = source_hash(e.text)
        tables[src_loc][e.id] = e.text
        row = [e.id, e.kind, e.speaker, e.expression, e.context, h, e.text]
        old_no, old = existing.get(e.id, (0, {}))
        for loc in others:
            text = old.get(loc, "") or ""
            text_hash = old.get(f"{loc}_src_hash", "") or ""
            row += [text, text_hash]
            if not text:
                missing[loc] += 1
            elif text_hash != h:
                stale[loc] += 1
            else:
                tables[loc][e.id] = text
                if _placeholders(text) != _placeholders(e.text):
                    rep.warn("W104", csv_display, old_no,
                             f"'{e.id}' ({loc}): placeholders or BBCode tags differ from the source text")
        writer.writerow(row)
    for loc in others:
        if stale[loc]:
            rep.warn("W104", csv_display, 0,
                     f"{loc}: {stale[loc]} translation(s) are stale because the source text changed")
        if missing[loc]:
            rep.notes.append(f"{loc}: {missing[loc]} of {len(entries)} string(s) untranslated")
    return out.getvalue(), tables


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------


@dataclass
class Result:
    project_found: bool
    rep: Reporter
    outputs: Dict[Path, str] = field(default_factory=dict)
    stale_outputs: List[Path] = field(default_factory=list)
    missing_ids: List[MissingId] = field(default_factory=list)
    line_ids: List[str] = field(default_factory=list)


def _dump(obj: Any) -> str:
    return json.dumps(obj, ensure_ascii=False, indent=2) + "\n"


def analyze(root: Path) -> Result:
    rep = Reporter()
    story_dir = root / STORY_DIR
    if not (story_dir / "project.json").exists():
        return Result(False, rep)
    project = load_project(root, rep)
    chars = load_characters(root, rep)
    if project is None:
        return Result(True, rep)
    speakers = {k: dict(v, id=k) for k, v in RESERVED_DEFAULTS.items()}
    speakers.update(chars)
    blocks: List[Block] = []
    src_dir = story_dir / "src"
    files = sorted(src_dir.rglob("*.dlg")) if src_dir.is_dir() else []
    for f in files:
        blocks += FileParser(f, _rel(root, f), rep).parse()
    comp = Compiler(root, project, speakers, blocks, rep)
    story = comp.compile()
    result = Result(True, rep, missing_ids=comp.missing, line_ids=list(comp.line_ids))
    if rep.errors:
        return result
    csv_text, tables = build_translations(root, project, name_strings(speakers) + comp.strings, rep)
    compiled_dir = story_dir / "compiled"
    result.outputs[compiled_dir / "story.json"] = _dump(story)
    for loc, table in tables.items():
        result.outputs[compiled_dir / f"strings.{loc}.json"] = _dump(table)
    result.outputs[story_dir / "l10n" / "strings.csv"] = csv_text
    # Keep Godot (and ACTION GAME MAKER G) from importing strings.csv as a translation table;
    # the game reads compiled/strings.<locale>.json instead.
    result.outputs[story_dir / "l10n" / ".gdignore"] = ""
    if compiled_dir.is_dir():
        wanted = {compiled_dir / f"strings.{loc}.json" for loc in tables}
        result.stale_outputs = sorted(p for p in compiled_dir.glob("strings.*.json") if p not in wanted)
    return result


def apply_fix(root: Path, result: Result) -> int:
    used = set(result.line_ids)
    counters: Dict[str, int] = {}
    edits: Dict[Path, Dict[int, Tuple[Optional[int], str]]] = {}
    for m in result.missing_ids:
        n = counters.get(m.block_id, 0)
        while True:
            n += 1
            candidate = f"{m.block_id}_{n:03d}"
            if candidate not in used:
                break
        counters[m.block_id] = n
        used.add(candidate)
        edits.setdefault(m.file, {})[m.raw_index] = (m.tag_col, candidate)
    for path, changes in edits.items():
        text = path.read_text(encoding="utf-8-sig")
        newline = "\r\n" if "\r\n" in text else "\n"
        lines = text.splitlines()
        for idx, (col, line_id) in changes.items():
            raw = lines[idx].rstrip("\r")
            if col is None:
                lines[idx] = raw.rstrip() + f"  #line:{line_id}"
            else:
                lines[idx] = raw[:col] + f"#line:{line_id} " + raw[col:]
        path.write_text(newline.join(lines) + (newline if text.endswith(("\n", "\r\n")) else ""), encoding="utf-8")
    return sum(len(c) for c in edits.values())


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Lint and compile .dlg character scripts (docs/script-format.md).")
    parser.add_argument("--root", default=str(Path(__file__).resolve().parent.parent),
                        help="project root (default: the repository containing this script)")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="verify outputs are up to date; write nothing")
    mode.add_argument("--fix", action="store_true", help="assign missing #line: IDs before compiling")
    parser.add_argument("--strict", action="store_true", help="treat warnings as errors")
    args = parser.parse_args(argv)
    root = Path(args.root)

    result = analyze(root)
    if not result.project_found:
        print(f"storyc: no {STORY_DIR.as_posix()}/project.json; nothing to do.")
        return 0
    if args.fix and result.missing_ids:
        count = apply_fix(root, result)
        print(f"storyc: assigned {count} line ID(s).")
        result = analyze(root)

    rep = result.rep
    if args.check and not rep.errors:
        for path, content in result.outputs.items():
            current = path.read_text(encoding="utf-8") if path.exists() else None
            if current != content:
                rep.error("E010", _rel(root, path), 0, "out of date; run 'python3 tools/storyc.py'")
        for path in result.stale_outputs:
            rep.error("E010", _rel(root, path), 0, "not in project.json 'locales'; run 'python3 tools/storyc.py'")

    for d in rep.diags:
        print(d, file=sys.stderr if d.level == "error" else sys.stdout)
    if rep.errors:
        print(f"storyc: {len(rep.errors)} error(s), {len(rep.warnings)} warning(s).", file=sys.stderr)
        return 1

    if not args.check:
        for path, content in result.outputs.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            current = path.read_text(encoding="utf-8") if path.exists() else None
            if current != content:
                path.write_text(content, encoding="utf-8")
        for path in result.stale_outputs:
            path.unlink()
    for note in rep.notes:
        print(f"storyc: {note}")
    print(f"storyc: OK ({len(result.line_ids)} line(s), {len(rep.warnings)} warning(s)).")
    if args.strict and rep.warnings:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

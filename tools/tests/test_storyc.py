import contextlib
import csv
import io
import json
import os
import re
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import storyc  # noqa: E402

SPEC = Path(__file__).resolve().parents[2] / "docs" / "script-format.md"


def spec_block(heading: str, lang: str = "") -> str:
    """Return the first fenced code block (optionally of a language) after a heading in the spec."""
    text = SPEC.read_text(encoding="utf-8")
    start = text.index(heading)
    m = re.compile(r"```" + lang + r"\n(.*?)```", re.S).search(text, start)
    return m.group(1)


PROJECT = {
    "format": 1,
    "source_locale": "ko",
    "locales": ["ko", "en"],
    "emotes": ["exclaim", "sweat"],
    "max_chars": {"bubble": 40, "caption": 60, "window": 120},
    "external_flags": [],
}


def char(cid, expressions, **extra):
    data = {"id": cid, "name": cid.upper(), "expressions": expressions, "default_expression": expressions[0]}
    data.update(extra)
    return data


class StoryProject:
    """A throwaway project tree for one test."""

    def __init__(self, project=None, characters=(), scripts=None):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        self.story = self.root / "assets/original/story"
        self.write_json("assets/original/story/project.json", project or PROJECT)
        for data in characters:
            self.write_json(f"assets/original/characters/{data['id']}/character.json", data)
        for name, text in (scripts or {}).items():
            self.write(f"assets/original/story/src/{name}", text)

    def write(self, rel, text):
        path = self.root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        return path

    def write_json(self, rel, data):
        return self.write(rel, json.dumps(data, ensure_ascii=False))

    def read_json(self, rel):
        return json.loads((self.story / rel).read_text(encoding="utf-8"))

    def run(self, *args):
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            code = storyc.main(["--root", str(self.root), *args])
        return code, out.getvalue() + err.getvalue()

    def codes(self):
        return sorted({d.code for d in storyc.analyze(self.root).rep.diags})

    def close(self):
        self._tmp.cleanup()


class SpecExampleTest(unittest.TestCase):
    """Compile the examples in docs/script-format.md and compare with its compiled-output section."""

    def setUp(self):
        project = json.loads(spec_block("## 8. 프로젝트 설정", "json"))
        hongryeon = json.loads(spec_block("## 3. 캐릭터 레지스트리", "json"))
        others = [
            char("hero", ["neutral", "uneasy"]),
            char("ibang", ["neutral", "bow", "fear", "surprised"]),
            char("watchman", ["neutral", "fear"]),
        ]
        self.p = StoryProject(project, [hongryeon] + others, {"ch01.dlg": spec_block("## 13. 전체 예시")})
        for expr in ("neutral", "sad"):
            self.p.write(f"assets/original/characters/hongryeon/portraits/{expr}.png", "")
        self.expected = json.loads(spec_block("### 10.1", "json"))

    def tearDown(self):
        self.p.close()

    def test_example_compiles_without_diagnostics(self):
        code, output = self.p.run("--strict")
        self.assertEqual(code, 0, output)

    def test_compiled_output_matches_spec(self):
        self.p.run()
        story = self.p.read_json("compiled/story.json")
        self.assertEqual(story["dialogues"]["ch01_pond_ghost"], self.expected["dialogues"]["ch01_pond_ghost"])
        self.assertEqual(story["characters"]["hongryeon"], self.expected["characters"]["hongryeon"])
        for key in ("format", "source_locale", "locales"):
            self.assertEqual(story[key], self.expected[key])

    def test_strings_match_spec(self):
        self.p.run()
        expected = json.loads(spec_block("### 10.2", "json"))
        strings = self.p.read_json("compiled/strings.ko.json")
        for key, value in expected.items():
            self.assertEqual(strings[key], value)

    def test_csv_matches_spec_rows(self):
        self.p.run()
        rows = list(csv.reader(io.StringIO((self.p.story / "l10n/strings.csv").read_text(encoding="utf-8"))))
        spec_rows = list(csv.reader(io.StringIO(spec_block("## 9. 번역 표", "csv"))))
        self.assertEqual(rows[0], spec_rows[0])
        generated = {r[0]: r for r in rows[1:]}
        for spec_row in spec_rows[1:]:
            # Compiler-managed columns (id..source language) must match; translations are filled in by hand.
            self.assertEqual(generated[spec_row[0]][:7], spec_row[:7], spec_row[0])
            # The spec rows show up-to-date translations, so their src hashes equal the source hash.
            self.assertEqual(spec_row[8], spec_row[5], spec_row[0])

    def test_other_block_kinds(self):
        self.p.run()
        story = self.p.read_json("compiled/story.json")
        bark = story["barks"]["ch01_night_watch"]
        self.assertEqual(bark["cooldown"], 12.0)
        self.assertEqual([line["w"] for line in bark["lines"]], [3, 1, 1])
        self.assertEqual(story["docs"]["ch01_prev_diary"],
                         {"category": "journal", "title": "ch01_dc_001", "paragraphs": ["ch01_dc_002", "ch01_dc_003"]})
        self.assertEqual(story["cues"]["ch01_opening"]["lines"][1]["at"], 3.5)
        greeting = story["dialogues"]["ch01_ibang_greeting"]
        self.assertEqual(greeting["priority"], 10)
        self.assertEqual(greeting["code"][0], {"op": "branch", "if": {"var": "seen.meta.ch01_ibang_greeting"},
                                               "else_pc": 2})

    def test_check_mode(self):
        code, _ = self.p.run("--check")
        self.assertEqual(code, 1, "outputs do not exist yet")
        self.p.run()
        code, output = self.p.run("--check")
        self.assertEqual(code, 0, output)
        src = self.p.story / "src/ch01.dlg"
        src.write_text(src.read_text(encoding="utf-8").replace("또 오셨네요.", "다시 오셨네요."), encoding="utf-8")
        code, output = self.p.run("--check")
        self.assertEqual(code, 1)
        self.assertIn("E010", output)


def project_with(script, characters=None, **project_overrides):
    project = dict(PROJECT, **project_overrides)
    chars = characters if characters is not None else [
        char("hero", ["neutral", "sad"], aliases={"masked": "???"}),
        char("ghost", ["neutral"]),
    ]
    return StoryProject(project, chars, {"test.dlg": script})


class DiagnosticsTest(unittest.TestCase):
    def assertCodes(self, script, expected, **kwargs):
        p = project_with(script, **kwargs)
        try:
            codes = p.codes()
        finally:
            p.close()
        for code in expected:
            self.assertIn(code, codes)
        return codes

    def test_clean_script(self):
        codes = self.assertCodes("~ a\nhero: 안녕.  #line:a_001\n", [])
        self.assertEqual(codes, [])

    def test_syntax_errors(self):
        self.assertCodes("hero: 블록 밖  #line:x\n", ["E001"])
        self.assertCodes("~ a\n  hero: 들여쓰기  #line:a_001\n", ["E001"])
        self.assertCodes("~ a\nhero:  #line:a_001\n", ["E001"])
        self.assertCodes("~ a\nelse\n    hero: 없음  #line:a_001\n", ["E001"])
        self.assertCodes("~ a\nif (save.x\n    hero: 괄호  #line:a_001\n", ["E001"])

    def test_unknown_speaker_and_expression(self):
        self.assertCodes("~ a\nnobody: 누구?  #line:a_001\n", ["E002"])
        self.assertCodes("~ a\nhero (angry): 화남  #line:a_001\n", ["E003"])
        self.assertCodes("~ a\nhero [name=unknown]: 별칭  #line:a_001\n", ["E003"])
        self.assertCodes("~ a\nhero [emote=heart]: 이모트  #line:a_001\n", ["E003"])

    def test_ids(self):
        self.assertCodes("~ a\nhero: 하나  #line:dup\nhero: 둘  #line:dup\n", ["E004"])
        self.assertCodes("~ a\nhero: 하나  #line:a_001\n~ a\nhero: 둘  #line:a_002\n", ["E004"])
        self.assertCodes("~ a\nhero: ID 없음\n", ["E004"])

    def test_jumps(self):
        self.assertCodes("~ a\nhero: 하나  #line:a_001\n=> nowhere\n", ["E005"])
        self.assertCodes("~ a\nhero: 하나  #line:a_001\n=> ~missing\n", ["E005"])

    def test_flags(self):
        self.assertCodes("~ a\nhero: 하나  #line:a_001\nset sys.loop_count = 1\n", ["E006"])
        self.assertCodes("~ a\nif bogus.flag\n    hero: 하나  #line:a_001\n", ["E006"])
        self.assertCodes("~ a\nif seen.save.nope\n    hero: 하나  #line:a_001\n", ["E006"])
        self.assertCodes("~ a\nhero: {@nope}  #line:a_001\n", ["E006"])

    def test_commands(self):
        self.assertCodes("~ a\nhero: 하나  #line:a_001\ndo explode\n", ["E007"])
        self.assertCodes("~ a\nhero: 하나  #line:a_001\ndo shake 1\n", ["E007"])
        self.assertCodes("~ a\nhero: 하나  #line:a_001\ndo fade sideways 1\n", ["E007"])

    def test_block_kind_rules(self):
        self.assertCodes("~bark b\n- 선택  #line:b_001\n", ["E008"])
        self.assertCodes("~cue c\nhero: 시간 없음  #line:c_001\n", ["E008"])
        self.assertCodes("~doc d\nhero: 화자  #line:d_001\n", ["E008"])
        self.assertCodes("~ a\nhero [w=2]: 가중치  #line:a_001\n", ["E008"])
        self.assertCodes("~doc d\n@cooldown 3\np: 문단  #line:d_001\n", ["E008"])

    def test_registry_errors(self):
        bad = [{"id": "hero", "name": "H", "expressions": ["neutral"], "default_expression": "sad"}]
        self.assertCodes("~ a\nnarrator: 서술  #line:a_001\n", ["E009"], characters=bad)

    def test_warnings(self):
        self.assertCodes("~ a\nif save.never_set\n    hero: 하나  #line:a_001\n", ["W101"])
        self.assertCodes("~ a\nhero: 하나  #line:a_001\n=> END\nhero: 둘  #line:a_002\n", ["W102"])
        self.assertCodes("~ a\nhero: 하나  #line:a_001\n:: unused\nhero: 둘  #line:a_002\n", ["W102"])
        self.assertCodes("~ a\n@style bubble\nhero: " + "가" * 41 + "  #line:a_001\n", ["W103"])
        self.assertCodes("~ a\nhero: 하나  #line:a_001 #mood:x\n", ["W105"])

    def test_external_flags_silence_w101(self):
        codes = self.assertCodes("~ a\nif save.from_game\n    hero: 하나  #line:a_001\n", [],
                                 external_flags=["save.from_game"])
        self.assertNotIn("W101", codes)


class CompileDetailsTest(unittest.TestCase):
    def compile(self, script, **kwargs):
        p = project_with(script, **kwargs)
        self.addCleanup(p.close)
        code, output = p.run()
        self.assertEqual(code, 0, output)
        return p

    def test_escapes_and_interpolation(self):
        p = self.compile("~ a\nhero: 해시 \\#line:x 와 줄\\n바꿈, {save.n} \\{literal}  #line:a_001\nset save.n = 1\n")
        self.assertEqual(p.read_json("compiled/strings.ko.json")["a_001"],
                         "해시 #line:x 와 줄\n바꿈, {save.n} \\{literal}")

    def test_choice_flow(self):
        p = self.compile(
            "~ a\n"
            "- [once] 첫째  #line:a_001\n"
            "    set loop.x = true\n"
            "- [enable_if loop.x] 둘째  => END  #line:a_002\n"
            "hero: 합류  #line:a_003\n"
        )
        code = p.read_json("compiled/story.json")["dialogues"]["a"]["code"]
        self.assertEqual(code[0], {"op": "choice", "skip_pc": 4, "options": [
            {"id": "a_001", "once": True, "pc": 1},
            {"id": "a_002", "enable_if": {"var": "loop.x"}, "pc": 3},
        ]})
        self.assertEqual(code[2], {"op": "goto", "pc": 4})
        self.assertEqual(code[3], {"op": "end"})
        self.assertEqual(code[4]["id"], "a_003")
        self.assertEqual(code[-1], {"op": "end"})

    def test_if_elif_else(self):
        p = self.compile(
            "~ a\n"
            "if save.n >= 2 and not loop.y\n"
            "    hero: 하나  #line:a_001\n"
            "elif save.n == 1\n"
            "    hero: 둘  #line:a_002\n"
            "else\n"
            "    hero: 셋  #line:a_003\n"
            "set save.n += 1\n"
            "set loop.y = false\n"
        )
        code = p.read_json("compiled/story.json")["dialogues"]["a"]["code"]
        self.assertEqual(code[0]["op"], "branch")
        self.assertEqual(code[0]["if"], {"and": [{"cmp": ">=", "a": {"var": "save.n"}, "b": 2},
                                                 {"not": {"var": "loop.y"}}]})
        self.assertEqual(code[0]["else_pc"], 3)
        self.assertEqual(code[2], {"op": "goto", "pc": 7})
        self.assertEqual(code[5], {"op": "goto", "pc": 7})
        self.assertEqual(code[7], {"op": "set", "var": "save.n", "mode": "+=", "value": 1})

    def test_translations(self):
        p = project_with("~ a\nhero: 안녕.  #line:a_001\n")
        self.addCleanup(p.close)
        p.run()
        csv_path = p.story / "l10n/strings.csv"
        lines = csv_path.read_text(encoding="utf-8").splitlines()
        row = next(r for r in lines if r.startswith("a_001,"))
        source_hash = row.split(",")[5]
        csv_path.write_text("\n".join(lines).replace(row, row[:-1] + f"Hello.,{source_hash}") + "\n",
                            encoding="utf-8")
        p.run()
        self.assertEqual(p.read_json("compiled/strings.en.json")["a_001"], "Hello.")
        # Changing the source text makes the translation stale: it is kept in the CSV but not shipped.
        src = p.story / "src/test.dlg"
        src.write_text(src.read_text(encoding="utf-8").replace("안녕.", "안녕하세요."), encoding="utf-8")
        code, output = p.run()
        self.assertIn("W104", output)
        self.assertNotIn("a_001", p.read_json("compiled/strings.en.json"))
        self.assertIn("Hello.", csv_path.read_text(encoding="utf-8"))


class FixTest(unittest.TestCase):
    def test_fix_assigns_ids(self):
        script = (
            "~ a\n"
            "hero: 하나\n"
            "hero: 둘  #ctx:맥락 메모\n"
            "- 선택  => END\n"
            "hero: 셋  #line:a_001\n"
        )
        p = project_with(script)
        self.addCleanup(p.close)
        code, output = p.run("--fix")
        self.assertEqual(code, 0, output)
        fixed = (p.story / "src/test.dlg").read_text(encoding="utf-8").splitlines()
        self.assertEqual(fixed[1], "hero: 하나  #line:a_002")
        self.assertEqual(fixed[2], "hero: 둘  #line:a_003 #ctx:맥락 메모")
        self.assertEqual(fixed[3], "- 선택  => END  #line:a_004")
        code, output = p.run("--check")
        self.assertEqual(code, 0, output)


class NoProjectTest(unittest.TestCase):
    def test_missing_project_is_not_an_error(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = io.StringIO()
            with contextlib.redirect_stdout(out):
                self.assertEqual(storyc.main(["--root", tmp, "--check"]), 0)
            self.assertIn("nothing to do", out.getvalue())


if __name__ == "__main__":
    unittest.main()

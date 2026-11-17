import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import check_dialogue_in_code as checker  # noqa: E402


def lines(violations):
    return [v.line for v in violations]


class CheckSourceTest(unittest.TestCase):
    def test_korean_comments_are_allowed(self):
        src = '# 플레이어 이동 처리\n## 문서 주석\nvar speed = 200  # 픽셀/초\n'
        self.assertEqual(checker.check_source(src), [])

    def test_line_id_reference_is_allowed(self):
        src = 'func _ready():\n\tshow_line(tr("well_002"))\n'
        self.assertEqual(checker.check_source(src), [])

    def test_double_and_single_quoted_korean_fail(self):
        src = 'var a = "우물 아래에서 누가 불러요"\nvar b = \'안녕\'\n'
        self.assertEqual(lines(checker.check_source(src)), [1, 2])

    def test_triple_quoted_multiline_reports_start_line(self):
        src = 'var x = 1\nvar s = """\n첫 줄\n둘째 줄\n"""\n'
        self.assertEqual(lines(checker.check_source(src)), [2])

    def test_hash_inside_string_is_not_a_comment(self):
        src = 'var s = "# not a comment"  # 진짜 주석\n'
        self.assertEqual(checker.check_source(src), [])

    def test_escaped_quote_does_not_end_string(self):
        src = 'var s = "say \\"hi\\" 그리고 한글"\n'
        self.assertEqual(lines(checker.check_source(src)), [1])

    def test_prefixed_literals_fail(self):
        src = 'var a = &"이름"\nvar b = ^"노드"\nvar c = r"원문"\n'
        self.assertEqual(lines(checker.check_source(src)), [1, 2, 3])

    def test_allow_marker_on_same_line(self):
        src = 'print("디버그 출력")  # dialogue-lint: allow\nprint("대사")\n'
        self.assertEqual(lines(checker.check_source(src)), [2])

    def test_unterminated_string_does_not_swallow_file(self):
        src = 'var s = "unterminated\nvar t = "한글"\n'
        self.assertEqual(lines(checker.check_source(src)), [2])


class MainTest(unittest.TestCase):
    def _write(self, root, rel, content):
        path = os.path.join(root, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)

    def test_excluded_directories_and_exit_codes(self):
        with tempfile.TemporaryDirectory() as root:
            self._write(root, "scripts/ok.gd", 'var a = tr("intro_001")  # 인트로\n')
            self._write(root, "addons/thirdparty/x.gd", 'var a = "한글"\n')
            self._write(root, "tests/test_x.gd", 'var a = "한글"\n')
            self._write(root, "notes.txt", '"한글"\n')
            self.assertEqual(checker.main([root]), 0)

            self._write(root, "scripts/bad.gd", 'var a = "한글"\n')
            self.assertEqual(checker.main([root]), 1)


if __name__ == "__main__":
    unittest.main()

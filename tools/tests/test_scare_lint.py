"""Tests for tools/scare_lint.py."""

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import scare_lint  # noqa: E402


def codes(config):
    findings, _ = scare_lint.lint(config)
    return sorted(f.code for f in findings)


class ModelTests(unittest.TestCase):
    def test_blink_probability_matches_reference_points(self):
        self.assertAlmostEqual(scare_lint.blink_probability(80.0), 0.5, places=3)
        self.assertGreater(scare_lint.blink_probability(102.0), 0.93)

    def test_context_and_loudness_raise_the_estimate(self):
        base = {"level_lu": 12, "rise_ms": 2, "body_ms": 600}
        quiet = scare_lint.estimate(base, [])["J"]
        louder = scare_lint.estimate({**base, "level_lu": 18}, [])["J"]
        threat = scare_lint.estimate({**base, "design": {"threat": 1, "dark": 1}}, [])["J"]
        self.assertLess(quiet, louder)
        self.assertLess(quiet, threat)

    def test_slow_rise_and_short_body_lower_the_estimate(self):
        base = {"level_lu": 16, "rise_ms": 2, "body_ms": 600}
        self.assertLess(scare_lint.estimate({**base, "rise_ms": 60}, [])["J"], scare_lint.estimate(base, [])["J"])
        self.assertLess(scare_lint.estimate({**base, "body_ms": 200}, [])["J"], scare_lint.estimate(base, [])["J"])

    def test_same_family_habituates_more_than_a_different_one(self):
        s = {"level_lu": 16, "family": "a", "design": {"minute": 10}}
        same = scare_lint.estimate(s, [(5.0, "a")])["habituation"]
        other = scare_lint.estimate(s, [(5.0, "b")])["habituation"]
        self.assertLess(same, other)
        self.assertGreaterEqual(same, scare_lint.PARAMS["hab_floor"])


class RuleTests(unittest.TestCase):
    def test_clean_config(self):
        cfg = {"scares": {"x": {"kind": "real", "level_lu": 16, "rise_ms": 2, "body_ms": 600,
                                "delay": {"mean": 1.2, "min": 0.6, "max": 4.0}, "input": True,
                                "visual": {"flash": True, "area": 0.2}}}}
        self.assertEqual(codes(cfg), [])

    def test_errors(self):
        cfg = {"scares": {
            "loud": {"level_lu": 24},
            "slow": {"kind": "fail", "rise_ms": 30, "repeat_step_db": -4},
            "big": {"visual": {"area": 0.4}},
            "red": {"visual": {"red": True}},
            "strobe": {"visual": {"flashes": 5}},
            "odd": {"kind": "ghost"},
        }}
        self.assertEqual(codes(cfg), ["E201", "E202", "E203", "E204", "E205", "E206"])

    def test_warnings(self):
        cfg = {"scares": {
            "narrow": {"delay": {"mean": 2.0, "min": 0.5, "max": 3.0}},
            "click": {"input": True, "delay": {"mean": 1.0, "min": 0.2, "max": 4.0}},
            "caught": {"kind": "fail"},
            "wide": {"visual": {"area": 0.22}},
        }}
        self.assertEqual(codes(cfg), ["W211", "W212", "W213", "W216"])

    def test_spacing_and_pairs(self):
        cfg = {"scares": {
            "a": {"design": {"minute": 10}},
            "b": {"design": {"minute": 11}},
            "c": {"design": {"minute": 30}},
            "d": {"design": {"minute": 30.6, "pair_with": "c"}},
        }}
        found, _ = scare_lint.lint(cfg)
        self.assertEqual([(f.code, f.scare) for f in found], [("W214", "b")])

    def test_tier_target(self):
        cfg = {"scares": {"tiny": {"level_lu": 4, "design": {"tier": "large"}}}}
        self.assertEqual(codes(cfg), ["W215"])

    def test_cli_exit_codes(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "scares.json"
            path.write_text(json.dumps({"scares": {"w": {"visual": {"area": 0.22}}}}), encoding="utf-8")
            self.assertEqual(scare_lint.main([str(path)]), 0)
            self.assertEqual(scare_lint.main([str(path), "--strict"]), 1)
            path.write_text(json.dumps({"scares": {"e": {"level_lu": 30}}}), encoding="utf-8")
            self.assertEqual(scare_lint.main([str(path)]), 1)


if __name__ == "__main__":
    unittest.main()

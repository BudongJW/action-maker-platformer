#!/usr/bin/env python3
"""Check a jump-scare config against startle research and estimate each scare's strength.

The config is the JSON file read by ``scripts/scare/scare_director.gd`` (see
docs/scare-director.md). Optional ``design`` fields per scare feed the estimate:
``tier`` (large/medium/small), ``minute`` (planned play time), ``threat``, ``dark``,
``anticip``, ``quiet``, ``av`` (0/1) and ``pair_with`` (a false scare it may follow).

Rules (code, meaning):
    E201  stinger above dialogue + 20 LU (no headroom at -24 LUFS integrated, -1 dBTP)
    E202  real or fail scare rises slower than 10 ms to peak (weak startle)
    E203  visual area above 25% of the screen (photosensitivity guidance)
    E204  saturated red flash (R/(R+G+B) >= 0.8)
    E205  more than 3 flashes in one scare
    E206  unknown kind
    W211  delay window max < 3 x mean (expectation builds up near the end of the window)
    W212  input-triggered scare can start < 0.6 s after the input (input sound acts as a prepulse)
    W213  repeating fail scare without a negative repeat_step_db (habituation fatigue)
    W214  two real scares closer than 3 minutes (not a declared false->real pair)
    W215  estimated strength J outside the tier's target range
    W216  visual area above 20% (Xbox Accessibility Guideline threshold)

Usage:
    python3 tools/scare_lint.py CONFIG.json [--strict] [--table]
Exit status: 1 on errors (or on warnings with --strict), else 0.
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from dataclasses import dataclass
from pathlib import Path

# Startle model parameters. Shape from published numbers; scale to be calibrated by playtests.
PARAMS = {
    "L_ref": 70.0,       # assumed dialogue playback level, dB(A)
    "L50": 80.0,         # blink probability 50% (about 80 dB(A))
    "L_scale": 8.0,      # gives about 94% at 102 dB(A)
    "gain_per5": 0.15,   # +11-18% magnitude per 5 dB
    "rise_ok": 10.0,     # no penalty up to 10 ms rise
    "rise_tau": 30.0,
    "dur_short": 0.85,   # cardiac defense needs >= 500 ms
    "pot_threat": 0.40,  # threat of shock +65% (conservative)
    "pot_dark": 0.20,    # darkness +33% in a clinical sample (conservative)
    "pot_anticip": 0.15,
    "pot_quiet": 0.10,
    "pot_av": 0.10,
    "hab_floor": 0.71,   # about -29% over a session
    "hab_k": 0.6,
    "hab_tau": 15.0,     # minutes
    "hab_other": 0.25,
}
TARGET = {"large": (0.85, 1.20), "medium": (0.45, 0.85), "small": (0.15, 0.50)}
KINDS = ("real", "false", "fail")


@dataclass
class Finding:
    code: str
    scare: str
    message: str

    @property
    def is_error(self) -> bool:
        return self.code.startswith("E")


def blink_probability(level_db: float, p=PARAMS) -> float:
    return 1.0 / (1.0 + math.exp(-(level_db - p["L50"]) / p["L_scale"]))


def estimate(scare: dict, history: list[tuple[float, str]], p=PARAMS) -> dict:
    """Relative startle strength J for one scare. `history`: (minute, family) of earlier scares."""
    design = scare.get("design", {})
    level = p["L_ref"] + min(float(scare.get("level_lu", 12.0)), 20.0)
    blink = blink_probability(level, p)
    size = (1 + p["gain_per5"]) ** ((level - 95.0) / 5.0)
    rise = float(scare.get("rise_ms", 2.0))
    r = 1.0 if rise <= p["rise_ok"] else math.exp(-(rise - p["rise_ok"]) / p["rise_tau"])
    d = 1.0 if float(scare.get("body_ms", 500.0)) >= 500.0 else p["dur_short"]
    pot = 1.0 + sum(p["pot_" + k] * float(design.get(k, 0)) for k in ("threat", "dark", "anticip", "quiet", "av"))
    minute = design.get("minute")
    n = 0.0
    if minute is not None:
        for m, fam in history:
            if m < minute:
                w = 1.0 if fam == scare.get("family", "") else p["hab_other"]
                n += w * math.exp(-(minute - m) / p["hab_tau"])
    h = p["hab_floor"] + (1 - p["hab_floor"]) * math.exp(-p["hab_k"] * n)
    j = blink * size * r * d * pot * h
    return {"level_db": level, "blink": blink, "pot": pot, "habituation": h, "J": j}


def lint(config: dict) -> tuple[list[Finding], list[tuple[str, dict]]]:
    findings: list[Finding] = []
    scares: dict = config.get("scares", {})
    ordered = sorted(scares.items(), key=lambda kv: (kv[1].get("design", {}).get("minute") is None,
                                                      kv[1].get("design", {}).get("minute", 0)))
    history: list[tuple[float, str]] = []
    estimates: list[tuple[str, dict]] = []
    last_real: tuple[float, str] | None = None
    for sid, s in ordered:
        kind = s.get("kind", "real")
        design = s.get("design", {})
        visual = s.get("visual", {})
        if kind not in KINDS:
            findings.append(Finding("E206", sid, f"unknown kind {kind!r}"))
        if float(s.get("level_lu", 12.0)) > 20.0:
            findings.append(Finding("E201", sid, f"level_lu {s['level_lu']} > 20"))
        if kind in ("real", "fail") and float(s.get("rise_ms", 2.0)) > 10.0:
            findings.append(Finding("E202", sid, f"rise_ms {s['rise_ms']} > 10"))
        area = float(visual.get("area", 0.0))
        if area > 0.25:
            findings.append(Finding("E203", sid, f"visual area {area:.2f} > 0.25"))
        elif area > 0.20:
            findings.append(Finding("W216", sid, f"visual area {area:.2f} > 0.20"))
        if visual.get("red"):
            findings.append(Finding("E204", sid, "saturated red flash"))
        if int(visual.get("flashes", 1 if visual.get("flash") else 0)) > 3:
            findings.append(Finding("E205", sid, "more than 3 flashes"))
        delay = s.get("delay") or {}
        if not s.get("immediate") and delay:
            mean, lo = float(delay.get("mean", 1.5)), float(delay.get("min", 0.0))
            hi = float(delay.get("max", lo + 3 * mean))
            if hi > lo and hi < 3 * mean:
                findings.append(Finding("W211", sid, f"delay max {hi} < 3 x mean {mean}"))
            if s.get("input") and lo < 0.6:
                findings.append(Finding("W212", sid, f"input-triggered with delay min {lo} < 0.6 s"))
        if kind == "fail" and float(s.get("repeat_step_db", 0.0)) >= 0.0:
            findings.append(Finding("W213", sid, "fail scare repeats without attenuation"))
        minute = design.get("minute")
        if kind == "real" and minute is not None:
            if last_real is not None and minute - last_real[0] < 3.0 and design.get("pair_with") is None:
                findings.append(Finding("W214", sid, f"{minute - last_real[0]:.1f} min after {last_real[1]}"))
            last_real = (minute, sid)
        est = estimate(s, history)
        estimates.append((sid, est))
        tier = design.get("tier")
        if tier in TARGET:
            lo_t, hi_t = TARGET[tier]
            if not lo_t <= est["J"] <= hi_t:
                findings.append(Finding("W215", sid, f"J {est['J']:.2f} outside {tier} {lo_t}-{hi_t}"))
        if minute is not None:
            history.append((float(minute), s.get("family", "")))
    return findings, estimates


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("config", type=Path)
    parser.add_argument("--strict", action="store_true", help="treat warnings as errors")
    parser.add_argument("--table", action="store_true", help="print the estimate for every scare")
    args = parser.parse_args(argv)
    try:
        config = json.loads(args.config.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"scare_lint: cannot read {args.config}: {exc}", file=sys.stderr)
        return 1
    findings, estimates = lint(config)
    if args.table:
        print(f"{'scare':10} {'dB':>5} {'blink':>6} {'pot':>5} {'hab':>5} {'J':>5}")
        for sid, e in estimates:
            print(f"{sid:10} {e['level_db']:5.0f} {e['blink']:6.2f} {e['pot']:5.2f} {e['habituation']:5.2f} {e['J']:5.2f}")
    for f in findings:
        print(f"{args.config}: {f.code} {f.scare}: {f.message}")
    errors = sum(1 for f in findings if f.is_error)
    warnings = len(findings) - errors
    print(f"scare_lint: {len(estimates)} scare(s), {errors} error(s), {warnings} warning(s)")
    return 1 if errors or (args.strict and warnings) else 0


if __name__ == "__main__":
    sys.exit(main())

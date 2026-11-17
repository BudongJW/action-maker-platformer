#!/usr/bin/env python3
"""Render text sound recipes (.sfx) to 16-bit mono WAV.

The recipes are content and live under assets/original/audio/src/ (all rights
reserved). This GPL tool only knows the format, the same split as
tools/pixelart.py and the dialogue tools. Pure Python, no dependencies.

Recipe format (one directive or layer per line, '#' starts a comment line)

  @output PATH          WAV to write, relative to the recipe
  @length SECONDS       length of the sound (for loops: the loop length)
  @rate HZ              sample rate (default 44100)
  @seed N               random seed for noise and jitter (default 1)
  @peak DB              normalise the peak to this level (default -1)
  @echo DELAY FEEDBACK MIX   feedback delay over the whole mix (hallway)
  @loop [XFADE]         seamless loop: layers run XFADE seconds past @length
                        (default 0.25) and that overlap is crossfaded into the
                        start; anything later (echo tails) wraps around

  layer TYPE key=value ...
    TYPE      sine | triangle | square | saw | noise | brown
    freq      start frequency in Hz (oscillators)
    freq_end  end frequency, exponential glide over the layer
    amp       linear amplitude (default 0.5)
    at        start time in seconds (default 0)
    dur       duration in seconds (default: to the end)
    attack    linear attack time (default 0.002)
    decay     exponential decay time constant after the attack (0 = hold)
    fade      linear fade-out over the last N seconds of the layer
    lp, lp_end  one-pole low-pass cutoff (Hz) and its end value (sweep)
    hp        one-pole high-pass cutoff (Hz)
    trem, trem_depth   tremolo rate (Hz) and depth (0..1)
    repeat, every      play the layer N times, EVERY seconds apart
    jitter    per-repeat random variation of amplitude and timing (0..1)

Usage:
  python3 tools/sfxsynth.py            render every recipe under the audio folder
  python3 tools/sfxsynth.py --check    report WAVs that differ from their recipes
  python3 tools/sfxsynth.py FILE ...   render only these recipes
"""
import argparse
import math
import os
import random
import struct
import sys
import wave

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AUDIO_SRC = os.path.join(REPO, 'assets', 'original', 'audio', 'src')
TYPES = ('sine', 'triangle', 'square', 'saw', 'noise', 'brown')
NUMERIC = ('freq', 'freq_end', 'amp', 'at', 'dur', 'attack', 'decay', 'fade', 'lp', 'lp_end', 'hp',
           'trem', 'trem_depth', 'every', 'jitter')


class SfxError(Exception):
    pass


class Recipe:
    def __init__(self, path):
        self.path = path
        self.output = None
        self.length = None
        self.rate = 44100
        self.seed = 1
        self.peak_db = -1.0
        self.echo = None
        self.loop = False
        self.xfade = 0.0
        self.layers = []
        self._parse()

    def _parse(self):
        with open(self.path, encoding='utf-8') as f:
            for number, line in enumerate(f, 1):
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                parts = line.split()
                head = parts[0]
                try:
                    if head == '@output':
                        self.output = os.path.normpath(os.path.join(os.path.dirname(self.path), parts[1]))
                    elif head == '@length':
                        self.length = float(parts[1])
                    elif head == '@rate':
                        self.rate = int(parts[1])
                    elif head == '@seed':
                        self.seed = int(parts[1])
                    elif head == '@peak':
                        self.peak_db = float(parts[1])
                    elif head == '@echo':
                        self.echo = tuple(float(p) for p in parts[1:4])
                    elif head == '@loop':
                        self.loop = True
                        self.xfade = float(parts[1]) if len(parts) > 1 else 0.25
                    elif head == 'layer':
                        self.layers.append(self._layer(parts[1:], number))
                    else:
                        raise SfxError(f'unknown directive {head}')
                except (IndexError, ValueError) as e:
                    raise SfxError(f'{self.path}:{number}: {e}') from None
                except SfxError as e:
                    raise SfxError(f'{self.path}:{number}: {e}') from None
        if self.output is None or self.length is None:
            raise SfxError(f'{self.path}: @output and @length are required')
        if not self.layers:
            raise SfxError(f'{self.path}: no layers')

    def _layer(self, parts, number):
        if not parts or parts[0] not in TYPES:
            raise SfxError(f'layer type must be one of {", ".join(TYPES)}')
        layer = {'type': parts[0], 'amp': 0.5, 'at': 0.0, 'attack': 0.002, 'decay': 0.0, 'fade': 0.0,
                 'trem_depth': 0.0, 'repeat': 1, 'jitter': 0.0}
        for item in parts[1:]:
            key, _, value = item.partition('=')
            if key == 'repeat':
                layer[key] = int(value)
            elif key in NUMERIC:
                layer[key] = float(value)
            else:
                raise SfxError(f'unknown layer option {key!r}')
        if parts[0] not in ('noise', 'brown') and 'freq' not in layer:
            raise SfxError(f'{parts[0]} layer needs freq=')
        return layer

    # ------------------------------------------------------------ rendering
    def render(self):
        rnd = random.Random(self.seed)
        n_main = int(round(self.length * self.rate))
        tail = int(self.rate * (self.echo[0] * 8 if self.echo else 0)) + n_main
        mix = [0.0] * (n_main + tail)
        for layer in self.layers:
            for k in range(layer['repeat']):
                scale, shift = 1.0, 0.0
                if layer['jitter'] and k:
                    scale = 1 + layer['jitter'] * (rnd.random() * 2 - 1)
                    shift = layer['jitter'] * layer.get('every', 0) * 0.25 * (rnd.random() * 2 - 1)
                start = layer['at'] + k * layer.get('every', 0) + shift
                self._render_layer(layer, start, scale, mix, rnd)
        if self.echo:
            delay, feedback, wet = self.echo
            d = max(1, int(delay * self.rate))
            y = mix[:]
            for i in range(d, len(y)):
                y[i] += feedback * y[i - d]
            mix = [a * (1 - wet) + b * wet for a, b in zip(mix, y)]
        if self.loop:
            out = mix[:n_main]
            n_x = min(n_main, int(self.xfade * self.rate))
            for i in range(n_x):
                w = i / n_x
                out[i] = mix[i] * w + mix[n_main + i] * (1 - w)
            for i in range(n_main + n_x, len(mix)):
                out[(i - n_main) % n_main] += mix[i]
        else:
            out = mix[:n_main]
        peak = max((abs(v) for v in out), default=0.0)
        if peak > 0:
            gain = 10 ** (self.peak_db / 20) / peak
            out = [v * gain for v in out]
        return out

    def _render_layer(self, layer, start, scale, mix, rnd):
        sr = self.rate
        total = len(mix)
        dur = layer.get('dur', max(0.0, self.length + self.xfade - start))
        i0 = int(round(start * sr))
        n = int(round(dur * sr))
        if n <= 0:
            return
        kind = layer['type']
        f0 = layer.get('freq', 0.0)
        f1 = layer.get('freq_end', f0)
        lp0 = layer.get('lp')
        lp1 = layer.get('lp_end', lp0)
        hp = layer.get('hp')
        attack, decay, fade = layer['attack'], layer['decay'], layer['fade']
        trem, depth = layer.get('trem', 0.0), layer['trem_depth']
        amp = layer['amp'] * scale
        phase = 0.0
        lp_state = hp_state = brown = 0.0
        hp_a = 1 - math.exp(-2 * math.pi * hp / sr) if hp else 0.0
        for j in range(n):
            idx = i0 + j
            if idx >= total:
                break
            t = j / sr
            frac = j / n
            if kind == 'noise':
                s = rnd.random() * 2 - 1
            elif kind == 'brown':
                brown = brown * 0.995 + (rnd.random() * 2 - 1) * 0.1
                s = brown
            else:
                f = f0 * (f1 / f0) ** frac if f0 > 0 and f1 > 0 else f0
                phase = (phase + f / sr) % 1.0
                if kind == 'sine':
                    s = math.sin(2 * math.pi * phase)
                elif kind == 'triangle':
                    s = 4 * abs(phase - 0.5) - 1
                elif kind == 'square':
                    s = 1.0 if phase < 0.5 else -1.0
                else:
                    s = 2 * phase - 1
            if lp0:
                fc = lp0 * (lp1 / lp0) ** frac
                a = 1 - math.exp(-2 * math.pi * fc / sr)
                lp_state += a * (s - lp_state)
                s = lp_state
            if hp:
                hp_state += hp_a * (s - hp_state)
                s = s - hp_state
            env = t / attack if attack and t < attack else 1.0
            if decay:
                env *= math.exp(-max(0.0, t - attack) / decay)
            if fade and t > dur - fade:
                env *= max(0.0, (dur - t) / fade)
            if depth:
                env *= 1 - depth * (0.5 - 0.5 * math.cos(2 * math.pi * trem * t))
            if idx >= 0:
                mix[idx] += s * env * amp


def encode_wav(samples, rate):
    import io
    buf = io.BytesIO()
    with wave.open(buf, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(b''.join(struct.pack('<h', max(-32767, min(32767, int(round(v * 32767)))))
                               for v in samples))
    return buf.getvalue()


def find_recipes(root):
    found = []
    for dirpath, _, files in os.walk(root):
        found += [os.path.join(dirpath, f) for f in files if f.endswith('.sfx')]
    return sorted(found)


def main(argv=None):
    parser = argparse.ArgumentParser(description='Render .sfx sound recipes to WAV.')
    parser.add_argument('recipes', nargs='*', help='.sfx files (default: every recipe under --root)')
    parser.add_argument('--root', default=AUDIO_SRC, help='folder searched when no recipes are given')
    parser.add_argument('--check', action='store_true', help='only report WAVs that differ from their recipes')
    args = parser.parse_args(argv)
    recipes = [os.path.abspath(r) for r in args.recipes] or find_recipes(args.root)
    if not recipes:
        print('sfxsynth: no recipes; nothing to do.')
        return 0
    stale, written = [], 0
    try:
        for path in recipes:
            recipe = Recipe(path)
            data = encode_wav(recipe.render(), recipe.rate)
            current = None
            if os.path.exists(recipe.output):
                with open(recipe.output, 'rb') as f:
                    current = f.read()
            if current == data:
                continue
            if args.check:
                stale.append(recipe.output)
            else:
                os.makedirs(os.path.dirname(recipe.output), exist_ok=True)
                with open(recipe.output, 'wb') as f:
                    f.write(data)
                written += 1
    except SfxError as e:
        print(f'sfxsynth: {e}', file=sys.stderr)
        return 1
    if args.check:
        for path in stale:
            print(f'sfxsynth: differs: {os.path.relpath(path, REPO)}', file=sys.stderr)
        if stale:
            return 1
        print(f'sfxsynth: OK, {len(recipes)} recipe(s) match.')
        return 0
    print(f'sfxsynth: {len(recipes)} recipe(s), {written} file(s) written.')
    return 0


if __name__ == '__main__':
    sys.exit(main())

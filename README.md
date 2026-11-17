# action-maker-platformer

A story-driven 2D platformer built with ACTION GAME MAKER G (formerly ACTION GAME MAKER, by Gotcha Gotcha Games).
The project is in pre-production. Research on usable resources, story sources and open-source game scripts is in [`reports/`](reports/) and [`research_notes/`](research_notes/) (Korean).

## License overview

This repository **separates code and content licenses by path**. The root `LICENSE` (GPL-3.0) applies **to code only**. It does not cover art, audio or scenario text.

| Path | Contents | License |
|---|---|---|
| Everything not listed below | GDScript, scenes (`.tscn`), project settings, docs, tools | [GPL-3.0](LICENSE) + [additional permission for ACTION GAME MAKER G](LICENSE-EXCEPTION.md) |
| `assets/original/` | Art, audio and scenario/dialogue text made for this project | [All rights reserved](assets/original/LICENSE.md) (edit that file if this changes) |
| `assets/third_party/<source>/` | Third-party assets whose license allows redistribution (CC0, CC BY, CC BY-SA 4.0, GPL-compatible, etc.) | The `LICENSE` file in each folder |
| `addons/<name>/` | Third-party Godot add-ons (MIT, etc.) | The `LICENSE` file in each add-on folder |
| `assets_private/` | Assets that must not be redistributed (GGG RTP/DLC, Japanese free BGM/SFX, paid packs, etc.) | **Never committed** (`.gitignore`). Only where to get them is recorded in [`SOURCES.md`](SOURCES.md) |

### Why the split

- **Non-redistributable assets cannot go into a public repository.** The Gotcha Gotcha Games (GGG) product terms only allow passing materials "to other Users free of charge" and forbid distributing all or part of GGG products without written consent ([GGG Terms](https://rpgmakerofficial.com/en/support/rule/), revised 2026-06-22). Most Japanese free music sites likewise allow use inside games but forbid redistributing the original files.
- **The GPL does not by itself allow combining with a proprietary runtime.** An exported game combines this repository's code with GGG's proprietary runtime. [`LICENSE-EXCEPTION.md`](LICENSE-EXCEPTION.md) grants an additional permission under GPL-3.0 section 7 so that forks can build and distribute the game. Godot Engine itself is MIT-licensed and needs no exception.
- **Content needs a separate decision.** Original art and scenario text start as all rights reserved, the most conservative choice. Opening them later (for example under CC BY-SA 4.0) is easy; an open license cannot be taken back once granted.

## What you need to build

1. **A legitimately purchased copy of ACTION GAME MAKER G** (Steam). Under the GGG terms, a distributed game must be made by a legitimate purchaser.
2. The non-redistributable assets listed in [`SOURCES.md`](SOURCES.md), obtained yourself and placed at the listed paths under `assets_private/`.

If `assets_private/` is empty, scenes that reference those assets will show missing-resource warnings. This is expected.

## Repository layout

```
.
├── LICENSE                  # GPL-3.0 full text (code only)
├── LICENSE-EXCEPTION.md     # GPL-3.0 section 7 additional permission (ACTION GAME MAKER G runtime)
├── CREDITS.md               # Source for in-game credits (required notices + third-party assets/add-ons)
├── SOURCES.md               # Where to obtain assets that are not committed, and their terms
├── assets/
│   ├── README.md            # How to classify and add assets
│   ├── original/            # Original content (all rights reserved); art/ holds the first pixel-art concept
│   └── third_party/         # Redistributable third-party assets (one folder per source + LICENSE); 25 CC0 reference packs, indexed in its README
├── assets_private/          # Non-redistributable assets (git-ignored; only its README is tracked)
├── docs/
│   ├── script-format.md     # Character script format spec (.dlg), Korean
│   ├── design-references.md # Art references: RPG Maker graphic specs, horror visual references, palettes, Korean
│   ├── resource-needs.md    # What the game still needs (art, audio, text, engine), by priority, Korean
│   └── scare-director.md    # Scare director, track mixer and scare lint (Korean)
├── scripts/
│   ├── story/               # GDScript story runtime (GPL-3.0)
│   ├── scare/               # Jump-scare scheduling (GPL-3.0)
│   ├── tracks/              # HI-FI / LINEAR track mixer and tape clock (GPL-3.0)
│   └── proto/               # Vertical-slice prototype (GPL-3.0)
├── shaders/                 # Godot shaders (GPL-3.0), e.g. the palette swap
├── prototype/
│   └── demo/                # Generic demo content used when the private story pack is absent
├── private/                 # Private story pack, git-ignored (see "Story content stays out of this repository")
├── tests/
│   └── godot/               # GDScript runtime tests and fixtures
├── tools/                   # Compiler, pixel-art and sound renderers, repository checks, test runners (GPL-3.0)
├── reports/                 # Research reports (Korean)
└── research_notes/          # Research notes (Korean)
```

The ACTION GAME MAKER G project (`project.godot`) is expected at the repository root. Godot cannot read files outside the project folder (`res://`), so `assets/` and `assets_private/` must live inside the project.

## Checklist before the first project commit

It is not yet known which GGG proprietary files (runtime scripts, add-ons, built-in assets) ACTION GAME MAKER G adds to a new project. Before committing the project for the first time:

- [ ] Create an empty project and review the generated files (`git status --ignored`).
- [ ] Identify files and folders provided by GGG and add them to the GGG proprietary files section ("GGG 독점 파일") of `.gitignore`.
- [ ] If scenes use any of the 1,000+ built-in assets, make sure those files are not committed either.
- [ ] Record the AGM G version in use in this README (e.g. `2.0.x`, Godot 4.7.0).

## Adding assets and add-ons

Follow the classification in [`assets/README.md`](assets/README.md). In short:

1. Made by us → `assets/original/`
2. License **explicitly** allows redistributing the original files → `assets/third_party/<source>/` + `LICENSE` + `SOURCE.md` + an entry in `CREDITS.md`
3. Anything else → `assets_private/` + an entry in `SOURCES.md`

Third-party code is accepted **only under licenses that are GPL-3.0-compatible and do not prevent combining with a proprietary runtime**, such as MIT, BSD or CC0. Third-party GPL code is not accepted, because we cannot grant the additional permission on someone else's behalf (unless it already carries the same permission).

**Dialogue and scenario text from other games is never imported, even from open-source games.** Only their formats and structure are used as references. See "Dialogue and scenario text rules" in [`assets/README.md`](assets/README.md).

## Art references

First-pass original pixel art (protagonist, three folklore-horror enemies, a night-school corridor tileset, faces and a mock-up) is in [`assets/original/art/`](assets/original/art/README.md) (Korean). It was generated by AI and is recorded in [`assets/original/AI_CONTENT.md`](assets/original/AI_CONTENT.md) for Steam's AI disclosure. Its sources are plain-text pixel maps rendered by [`tools/pixelart.py`](tools/pixelart.py); CI fails if a PNG does not match its source:

```bash
python3 tools/pixelart.py            # render assets/original/art/src/ to PNG
python3 tools/pixelart.py --check    # what CI runs
```

First-pass sound effects, ambience loops and four music sketches are in [`assets/original/audio/`](assets/original/audio/README.md) (Korean), also AI-generated: plain-text synthesis recipes rendered by [`tools/sfxsynth.py`](tools/sfxsynth.py) (`python3 tools/sfxsynth.py`). Nobody has listened to them yet.

Collected CC0 art packs (characters, horror tilesets and backgrounds, map tilesets) are in [`assets/third_party/`](assets/third_party/README.md), each with a `preview.png` contact sheet. They are for reference and placeholder art; final art is meant to be original. [`docs/resource-needs.md`](docs/resource-needs.md) (Korean) lists what is still missing, with the decisions that block it and a checklist for the first playable build. [`docs/design-references.md`](docs/design-references.md) (Korean) covers RPG Maker sprite and tile formats, horror game visual references, tutorials, palettes and sources that cannot be committed.

To rebuild the contact sheets after adding or changing a pack (needs Pillow):

```bash
python3 tools/asset_previews.py
```

## Dialogue text and code separation

Dialogue text lives only in data files under `assets/original/` (all rights reserved). GDScript code (GPL) refers to it only by line ID or translation key, because text written into code is distributed under the code's license.

CI ([`.github/workflows/content-license-checks.yml`](.github/workflows/content-license-checks.yml)) enforces this on every pull request and push to `main`: it fails if a string literal in a `.gd` file contains Korean text. To run it locally:

```bash
python3 tools/check_dialogue_in_code.py
```

- Korean comments (`#`, `##`) are allowed.
- A string that is not content passes if the same line has a `# dialogue-lint: allow` comment.
- `addons/`, `test/`, `tests/`, `.godot/` and `assets_private/` are not scanned.
- **Known limitations:** scene and resource files (`.tscn`, `.tres`) are not scanned yet. Whether to add them depends on whether ACTION GAME MAKER G's visual scripts store text-display strings in scene files. Non-Korean dialogue (English, etc.) is not detected either, so reviewers should check for it.

## Writing dialogue

Dialogue, barks, documents and subtitles are written in `.dlg` files under `assets/original/story/src/`. The format is specified in [`docs/script-format.md`](docs/script-format.md) (Korean). [`tools/storyc.py`](tools/storyc.py) lints the scripts and compiles them into the JSON the game loads (`assets/original/story/compiled/`), and keeps the translation table (`assets/original/story/l10n/strings.csv`) in sync.

```bash
python3 tools/storyc.py            # lint, then update compiled/ and strings.csv
python3 tools/storyc.py --fix      # first add missing #line: IDs to the .dlg files
python3 tools/storyc.py --check    # lint and verify outputs are up to date (what CI runs)
```

Until `assets/original/story/project.json` exists, the compiler has nothing to do and exits successfully.

### Story content stays out of this repository

The game's story text (plot, dialogue, character notes, endings) and its level and scare configs are kept **out of this public repository**. Keep the private story pack in `private/` (git-ignored) on your machine and back it up separately; it has the same layout as the repository (`private/assets/original/story/`, `private/assets/original/characters/`). Compile it with:

```bash
python3 tools/storyc.py --root private
```

`assets/original/story/` and `assets/original/characters/` in the repository hold a public placeholder project; do not unpack the private pack there. CI fails if any file under `private/` is tracked.

The design pack in [`assets/original/mibangsong/`](assets/original/mibangsong/README.md) (sprites, tiles, palettes, storyboard cuts) is public by the project owner's decision and contains spoilers; the storyboard text, story bible and scripts are not in it.

## Story runtime

[`scripts/story/`](scripts/story/) loads the compiled story and runs it in the game: dialogues with choices and branches, barks, documents, subtitle cues, the loop/save/meta flag tiers, locale fallback, and in-game fallbacks for meta effects the player has not consented to. `StoryRunner` is meant to be an autoload; the game UI listens to its signals (`line_started`, `choices_presented`, `command`, ...) and calls `advance()` / `choose()`. The API is described in section 11 of [`docs/script-format.md`](docs/script-format.md).

The runtime is tested in headless Godot 4.7 (the engine version ACTION GAME MAKER G uses), but **not yet inside ACTION GAME MAKER G itself**. To run the tests locally:

```bash
GODOT_BIN=/path/to/Godot_v4.7-stable_linux.x86_64 python3 tools/run_godot_tests.py
```

The runner builds a temporary Godot project from `scripts/`, `tests/godot/` and the examples in the spec, compiles it with `storyc`, and runs the story runtime, scare director and track mixer tests. Without Godot it skips; CI downloads Godot, verifies its checksum and runs it.

## Scare director and track mixer

- [`scripts/scare/scare_director.gd`](scripts/scare/scare_director.gd) (`ScareDirector`) schedules jump scares with timing rules taken from startle research: delays drawn from a truncated exponential distribution (so waiting does not make a scare predictable), a 0.5 s quiet window before each onset (a sound 30-500 ms before a startle stimulus weakens it), ambience ducking, repeat attenuation, a relax period, and Soft / Off / photosafe settings. The story script triggers a scare with `do emit scare_<id>`.
- [`scripts/tracks/track_mixer.gd`](scripts/tracks/track_mixer.gd) (`TrackMixer`) switches between the HI-FI and LINEAR recordings of the same night (and MIX), crossfades their audio buses, shows or hides track-only nodes, runs the tape clock, and reports dubbed segments and timeline events.
- [`tools/scare_lint.py`](tools/scare_lint.py) checks a scare config against those rules (loudness headroom, rise time, flash area, spacing) and estimates each scare's relative strength.

Rules, numbers and sources are in [`docs/scare-director.md`](docs/scare-director.md) (Korean). `tools/run_godot_tests.py` runs their headless tests together with the story runtime tests.

## Prototype

A vertical slice wires the story runtime, scare director and track mixer to a playable level, so the loop, the two tracks and the scares can be played and playtested before the ACTION GAME MAKER G version exists. It is built in plain Godot 4.7. A level's optional `art` block draws it with the pixel art in `assets/original/` (sprites, tiles, backdrop, per-track palettes through `shaders/palette_swap.gdshader`, the camera viewfinder, scare frames), and an optional `audio` block plays the sounds there (per-track ambience crossfaded by the track mixer, timed loops, stingers, footsteps that fall silent before a scare); without them it is a graybox with generated noise. ACTION GAME MAKER G's own player and level tools are expected to replace the player and level code, while the runtime modules carry over.

```bash
python3 tools/build_prototype.py --run      # build into build/prototype/ and open the game window
python3 tools/build_prototype.py --smoke    # headless bot playthrough
```

It uses the private story pack when `private/assets/original/story/` contains `proto_level.json` and `scares.json`, and the generic demo in [`prototype/demo/`](prototype/demo/) otherwise. CI runs the bot on the demo. Keys and the level format are described in [`prototype/README.md`](prototype/README.md).

## Contributing

Code contributed to this repository is provided under GPL-3.0 with the additional permission in [`LICENSE-EXCEPTION.md`](LICENSE-EXCEPTION.md). Content contributed to `assets/original/` is subject to [`assets/original/LICENSE.md`](assets/original/LICENSE.md).

---

This license structure is a practical arrangement based on research, not legal advice. Before a commercial release, review the original terms and consider a professional legal review.

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
│   ├── original/            # Original content (all rights reserved)
│   └── third_party/         # Redistributable third-party assets (one folder per source + LICENSE)
├── assets_private/          # Non-redistributable assets (git-ignored; only its README is tracked)
├── docs/
│   └── script-format.md     # Character script format spec (.dlg), Korean
├── tools/                   # Repository checks (GPL-3.0)
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

## Dialogue text and code separation

Dialogue text lives only in data files under `assets/original/` (all rights reserved). GDScript code (GPL) refers to it only by line ID or translation key, because text written into code is distributed under the code's license. The script format is specified in [`docs/script-format.md`](docs/script-format.md) (Korean).

CI ([`.github/workflows/content-license-checks.yml`](.github/workflows/content-license-checks.yml)) enforces this on every pull request and push to `main`: it fails if a string literal in a `.gd` file contains Korean text. To run it locally:

```bash
python3 tools/check_dialogue_in_code.py
```

- Korean comments (`#`, `##`) are allowed.
- A string that is not content passes if the same line has a `# dialogue-lint: allow` comment.
- `addons/`, `test/`, `tests/`, `.godot/` and `assets_private/` are not scanned.
- **Known limitations:** scene and resource files (`.tscn`, `.tres`) are not scanned yet. Whether to add them depends on whether ACTION GAME MAKER G's visual scripts store text-display strings in scene files. Non-Korean dialogue (English, etc.) is not detected either, so reviewers should check for it.

## Contributing

Code contributed to this repository is provided under GPL-3.0 with the additional permission in [`LICENSE-EXCEPTION.md`](LICENSE-EXCEPTION.md). Content contributed to `assets/original/` is subject to [`assets/original/LICENSE.md`](assets/original/LICENSE.md).

---

This license structure is a practical arrangement based on research, not legal advice. Before a commercial release, review the original terms and consider a professional legal review.

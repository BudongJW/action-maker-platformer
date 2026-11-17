# assets: how to classify and add assets

Before adding an asset, decide where it goes using the steps below. **There is one criterion: does the license explicitly allow redistributing the original files?** Whether an asset may ship inside a game (usually yes) and whether it may be committed to a public repository (usually no) are different questions.

## Classification

```
Did we make it? ──yes──▶ assets/original/
      │
      no
      ▼
Do the terms explicitly allow redistributing the original files?
(CC0, CC BY, CC BY-SA 4.0, GPL-compatible, Pipoya free materials, etc.)
      │
   ┌──┴──┐
  yes    no / unclear
   ▼      ▼
assets/third_party/<source>/   assets_private/  (not committed)
 + LICENSE                     + entry in SOURCES.md
 + SOURCE.md                   + entry in CREDITS.md
 + entry in CREDITS.md
```

When in doubt, **always use `assets_private/`**. You can move a file later once redistribution is confirmed. A file pushed to a public repository, on the other hand, is hard to remove from the history completely.

## Dialogue and scenario text rules

Separately from asset classification, two rules always apply to text. The reasoning is in [`reports/오픈소스 게임 스토리 스크립트 분석.md`](../reports/오픈소스%20게임%20스토리%20스크립트%20분석.md) (Korean).

1. **Never import dialogue or scenario text from other games, whatever its license.** This includes open-source games. Use their formats and structure as references and write all dialogue ourselves.
   - GPL text would make that part GPL, so it could not stay all rights reserved under `original/`. We also cannot extend the AGM permission in [`LICENSE-EXCEPTION.md`](../LICENSE-EXCEPTION.md) to someone else's work.
   - CC BY-SA text carries ShareAlike terms, and version 3.0 is not compatible with GPL-3.0.
   - NonCommercial (NC), NoDerivatives (ND), freeware and author-guideline works cannot be used in a commercial game.
   - If a parser or dialogue-system test needs sample dialogue, write a short one ourselves.
2. **Dialogue text lives only in data files under `original/`.** GDScript code (GPL) refers to dialogue only by line ID or translation key, because text written into code is distributed under the code's license. This is how Doom's ending texts and VVVVVV's cutscene dialogue were released along with their code.
   - CI runs [`tools/check_dialogue_in_code.py`](../tools/check_dialogue_in_code.py) and fails if a `.gd` string literal contains Korean text. Korean comments are allowed.
   - A string that is not content (debug output, etc.) passes if the same line has a `# dialogue-lint: allow` comment.
   - The dialogue file format (`.dlg`) is specified in [`docs/script-format.md`](../docs/script-format.md) (Korean).

## 1. `original/`: our own content

- Art, audio and scenario/dialogue text, including source and work files (`.dlg`, `.aseprite`, `.kra`, `.psd`).
- License: [`original/LICENSE.md`](original/LICENSE.md)
- If AI-generated content is used, record the file paths and tools (needed for Steam's AI content disclosure).
- **Do not put modified GGG or third-party assets here.** A modified asset still follows the original license, so keep it with the original (`third_party/` or `assets_private/`).

## 2. `third_party/<source>/`: redistributable third-party assets

Create one folder per source (author or pack). Name it `author-pack-name` in lowercase with hyphens (e.g. `pixelfrog-pixel-adventure-1`). Every folder must contain these two files:

- `LICENSE`: the license file shipped with the original, or, if there is none, the full text of the terms page or license
- `SOURCE.md`: the template below

```markdown
# <pack name>

- Author:
- Source URL:
- License: (e.g. CC0 1.0 / CC BY 4.0 / GPL-3.0 (chosen side of the LPC dual license))
- Download date / version:
- Credit required: yes / no (required wording: )
- Modifications: (none / recolored, resized, etc.)
```

Then add a row to the external assets table ("외부 에셋") in [`CREDITS.md`](../CREDITS.md).

### Sources confirmed safe to commit (as of the 2026-11 research)

| Source | License | Notes |
|---|---|---|
| Kenney | CC0 | Both visuals and audio |
| Pixel Frog Pixel Adventure 1 & 2 | CC0 | Side-scrolling platformer |
| Ansimuz Sunny Land | CC0 | Side-scrolling. Check the author's other paid packs one by one |
| 0x72 DungeonTileset II, Ninja Adventure | CC0 | Top-down 16x16 |
| LPC (OpenGameArt) | GPL-3.0 / CC BY-SA 3.0 dual | **Record the GPL-3.0 side.** Per-asset CREDITS are required |
| Pipoya (ぴぽや倉庫) free materials | Own terms | Free redistribution only with the full terms included as `LICENSE`. Paid and supporter materials are not allowed. **The itch.io pages** (e.g. "PIPOYA FREE RPG Character Sprites 32x32", "Pipoya RPG Tileset 32x32") say "Not redistribute or resell this assets", so those downloads go in `assets_private/` (checked 2026-11-17) |
| OpenGameArt, per asset | Per asset | Use the page's "License(s)" field, and read the description and comments too: some CC0 uploads are edits of RPG Maker RTP or of other artists' work, or are re-uploads by someone other than the author. Those are not committed. Packs already committed are listed in [`third_party/README.md`](third_party/README.md) |
| Freesound individual files | CC0 / CC BY per file | Check each file's license. **CC BY-NC is not allowed** (no commercial use) |
| Incompetech (Kevin MacLeod) | CC BY 4.0 | The prescribed credit wording is required |
| SFX made by us with Bfxr or jfxr | Ours | May go in `original/` |

### Share-alike caveats

- **CC BY-SA 3.0 is not compatible with GPL-3.0.** Creative Commons has declared one-way compatibility with GPL-3.0 only for CC BY-SA 4.0.
- **CC 4.0 licenses prohibit DRM.** If CC BY or BY-SA assets ship in a Steam build, distribute that build DRM-free or pick only assets whose authors waive the DRM clause.
- **Do not use SCP Foundation content (CC BY-SA 3.0).** It is not GPL-3.0-compatible, and it is unclear whether ShareAlike would extend to the whole game.

## 3. `assets_private/`: non-redistributable assets (repository root, not committed)

These are typical sources that may ship inside the game but **whose original files cannot be committed to a public repository**:

- GGG RTP and DLC, ACTION GAME MAKER G built-in assets (GGG terms: free transfer between legitimate users only, no extraction)
- Japanese free BGM/SFX: 魔王魂 (Maou-damashii), 甘茶の音楽工房 (Amacha), OpenTracks (formerly DOVA-SYNDROME), 効果音ラボ, ポケットサウンド, On-Jin, ユーフルカ
- Paid or free commercial packs: CraftPix, Szadi Art, Time Fantasy, Pipoya paid/supporter materials, DOTOWN
- Pixabay audio, Sonniss GDC bundles

See [`../assets_private/README.md`](../assets_private/README.md) for placement and [`../SOURCES.md`](../SOURCES.md) for recording where they come from.

# AI-generated content record

Steam asks developers to disclose AI-generated content that players will see
([Steamworks content survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey)),
and [`assets/README.md`](../README.md) requires recording which files under
`assets/original/` were made with AI and how. Keep this file up to date; when a
file is redrawn by a person, move it to the "Replaced" table instead of deleting
the row.

## Current AI-generated files

| Files | Made with | Date | How |
|---|---|---|---|
| `art/palette/*.pal` (night-school, otherworld, dawn, light, dark) | Anthropic Claude (Claude Code) | 2026-11-17 | Colour values chosen by the AI |
| `art/src/*.pix`, `art/src/*.scene` | Anthropic Claude (Claude Code) | 2026-11-17 | The AI wrote the text pixel maps directly, and for the tileset and faces wrote small shape-drawing scripts that emitted the text (those scripts are not kept; the `.pix` text is the source) |
| `art/characters/*.png`, `art/tiles/*.png`, `art/portraits/*.png`, `art/mockups/*.png`, `art/lights/*.png`, `art/ui/*.png`, `art/backgrounds/*.png`, `art/fx/*.png`, `art/concepts/*.png`, `art/jumpscares/*.png`, `art/palette/*.png`, `art/previews/*.png`, `art/comparisons/*.png`, `characters/protagonist/portraits/*.png` | `tools/pixelart.py` (deterministic renderer, no AI) from the sources above | 2026-11-17 | Rendered output of AI-written sources |
| `mibangsong/art/src/*.pix`, `mibangsong/art/src/*.scene`, `mibangsong/art/palette/*.pal`, `mibangsong/README.md` | Anthropic Claude (Claude Code) | 2026-11-17 | 《미방송분》 design pack for the reference storyboard v1.2: the AI wrote the text pixel maps and scenes (via authoring scripts that are not kept) and the design document |
| `mibangsong/art/**/*.png`, `mibangsong/overview/*.png` | `tools/pixelart.py` (deterministic renderer, no AI) from the sources above; three cut composites and the overview sheets are assembled from those renders by a script | 2026-11-17 | Rendered output of AI-written sources |
| `audio/src/*.sfx` | Anthropic Claude (Claude Code) | 2026-11-17 | The AI wrote the synthesis recipes (oscillators, noise, envelopes, filters); the music recipes were generated from note lists the AI composed |
| `audio/sfx/*.wav`, `audio/ambience/*.wav`, `audio/music/*.wav` | `tools/sfxsynth.py` (deterministic synthesizer, no AI) from the recipes above | 2026-11-17 | Rendered output of AI-written recipes; nobody has listened to them yet |
| `mibangsong/audio/src/*.sfx`, `mibangsong/audio/README.md` | Anthropic Claude (Claude Code) | 2026-11-17 | 《미방송분》 chapter 1 placeholder sounds (ambience, generator, a temporary janggu cycle, stingers, camera and deck sounds): the AI wrote the synthesis recipes and the notes |
| `mibangsong/audio/**/*.wav` | `tools/sfxsynth.py` (deterministic synthesizer, no AI) from the recipes above | 2026-11-17 | Rendered output of AI-written recipes; nobody has listened to them yet |

What was **not** involved:

- No image- or audio-generation model. Every pixel and every sample comes from the text sources above. No recordings or third-party sounds were used as input.
- No third-party image was used as input, traced, or edited. The packs in
  `assets/third_party/` and the games in `docs/design-references.md` were used
  only as written references for principles (size contrast, colour as signal,
  darkness and light).

## Replaced by human work

| Files | Replaced on | By |
|---|---|---|
| _(none yet)_ | | |

## Notes before release

- For Steam, this counts as **pre-generated** AI content (made during
  development), which the content survey asks you to describe.
- Whether purely AI-generated images are protected by copyright differs by
  country, and is doubtful in several of them. The "All rights reserved" notice
  in [`LICENSE.md`](LICENSE.md) may not be enforceable for these files. If
  exclusivity matters, have them redrawn or substantially reworked by a person.
- The research report notes that AI art can be a reputational risk in the
  Japanese doujin and RPG Maker community (DLsite separated AI works in 2024).
  Decide how to present it before marketing.

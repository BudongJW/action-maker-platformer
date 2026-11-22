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
| `mibangsong/art/palette/arcanum22.pal` (the 22 colours come from the project's internal ARCANUM XXII concept; the AI assigned its drawing keys to them), `mibangsong/art/src/card_*.pix`, `ins_e5_spread*.pix` | Anthropic Claude (Claude Code) | 2026-11-22 | 《미방송분》 no-hope pack: the prop tarot cards (frame layout after the internal ARCANUM XXII concept; numerals and names set in Galmuri11 by the script) and the card spread. The AI wrote an authoring script of shape-drawing code that emits the `.pix` text (the script stays in the private story pack; the `.pix` text is the source) |
| `mibangsong/art/src/cu_e504.pix`, `e503.pix`, `e5_boat.pix`, `cu_e5_rower.pix`, `cu_e5_hand.pix`, `e5_flooded.pix`; the extra colours in `mibangsong/art/palette/2026_ext.pal` and `linear_ext.pal` | The project owner's "ARCANUM XXII pixel works" package; its README says the images were made in a separate AI chat and does not name the tool | 2026-11-22 | Finished 320x180 PNGs supplied by the project owner as redesigns of these cuts. Claude Code converted them pixel for pixel into `.pix` text (renders are identical to the supplied 1x PNGs); the drawing itself is not Claude Code's. **Confirm how they were made before release** (see the first note below the table) |
| Public art v2: the colours of `art/palette/night-school.pal` (29 keys); in `art/src/` the frames `protagonist_side.pix` idle_0..jump, `enemy_shadow_visitor.pix` idle_0 and grab, `enemy_sobok_gwisin.pix` float_0 and reveal, `enemy_xxii_card.pix`, the 24 redesign tiles in `tiles_night_school.pix`, `corridor_night.pix`, `corridor_otherworld.pix` | The project owner's "ARCANUM XXII pixel works" package (`03_platformer_redesign`); made in a separate AI chat, tool not named | 2026-11-22 | Finished PNGs and a keyed palette supplied by the project owner; Claude Code converted them pixel for pixel into `.pix` text. **Confirm how they were made before release** (see the first note below the table) |
| Public art v2, derived: the other frames of `protagonist_side.pix`, `protagonist_death_gore.pix`, the other states of `enemy_shadow_visitor.pix` (incl. `_eye_glow`), the derived tiles in `tiles_night_school.pix`, the 9 new keys in `otherworld.pal`, `dawn.pal` and the 《미방송분》 track palettes, `palette_swatch.pix`, `lut_*.pix` | Anthropic Claude (Claude Code), from the pixel works above | 2026-11-22 | A script moved, joined and recoloured the received frames and patched a few rows by hand (the script stays in the private story pack); new-key colours of the swap palettes computed as blends of existing keys |
| `mibangsong/art/src/ins_hotline_cover.pix`, `ins_hotline_09.pix`, `ins_hotline_11.pix`, `ins_hotline_back.pix` | The project owner's "ARCANUM XXII pixel works" package (`02_medieval_occult`); made in a separate AI chat, tool not named | 2026-11-22 | Finished PNGs supplied by the project owner; Claude Code converted them pixel for pixel into `.pix` text (the grimoire page cropped to 180 rows and centred on a 320x180 canvas of its own background colour). **Confirm how they were made before release** |
| `mibangsong/art/src/ins_e5_doll.pix`, `ins_e5_talisman.pix`; the 8 extra colours of `mibangsong/art/palette/arcanum22_sacred.pal` | The project owner's "ARCANUM XXII sacred occult" concept package (`05_curses`); made in a separate AI chat, tool not named | 2026-11-22 | Finished PNGs and a 30-colour palette supplied by the project owner; Claude Code converted them pixel for pixel into `.pix` text and put the extra colours on numeric keys. **Confirm how they were made before release** |
| `mibangsong/art/src/mbs_portraits.pix`, `mibangsong/art/palette/portraits.pal` | Anthropic Claude (Claude Code) | 2026-11-22 | 《미방송분》 dialogue portraits, nineteen 64x64 busts (one per character; Eunyoung as a still life of her jacket, the overdubbed thing as caption fragments). The AI wrote a parametric authoring script of shape-drawing code (head, jaw, age lines, hair, clothing, light from the upper left) that emits the `.pix` text; the script stays in the private story pack. Style matched by eye to the project owner's pixel-works close-ups, nothing traced |
| `mibangsong/art/src/e5_boat_veiled.pix`, `e5_flooded_veiled.pix` | Anthropic Claude (Claude Code), from the pixel works above | 2026-11-22 | Veiled versions derived by a script: the festival boat of the pixel works with the bow figure copied from `e5_boat`; the tape shot with the figure and tape removed, an empty chair, headphones and tape loops drawn in, and the room recoloured under water (the script stays in the private story pack) |
| `audio/src/*.sfx` | Anthropic Claude (Claude Code) | 2026-11-17 | The AI wrote the synthesis recipes (oscillators, noise, envelopes, filters); the music recipes were generated from note lists the AI composed |
| `audio/sfx/*.wav`, `audio/ambience/*.wav`, `audio/music/*.wav` | `tools/sfxsynth.py` (deterministic synthesizer, no AI) from the recipes above | 2026-11-17 | Rendered output of AI-written recipes; nobody has listened to them yet |
| `mibangsong/audio/src/*.sfx`, `mibangsong/audio/README.md` | Anthropic Claude (Claude Code) | 2026-11-17 | 《미방송분》 chapter 1 placeholder sounds (ambience, generator, a temporary janggu cycle, stingers, camera and deck sounds): the AI wrote the synthesis recipes and the notes |
| `mibangsong/audio/**/*.wav` | `tools/sfxsynth.py` (deterministic synthesizer, no AI) from the recipes above | 2026-11-17 | Rendered output of AI-written recipes; nobody has listened to them yet |

What was **not** involved:

- No image- or audio-generation model in the work Claude Code did. Every pixel and every sample comes from the text sources above. No recordings or third-party sounds were used as input. The exception to check is the ARCANUM XXII pixel works rows (the 《미방송분》 E5 cuts, the hotline leaflet inserts, the E5 curse inserts and public art v2): those images came finished from a separate AI chat, and the package does not say whether an image-generation model was involved.
- No third-party image was used as input, traced, or edited. (The ARCANUM XXII pixel works are the project's own material, supplied by the project owner.) The packs in
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

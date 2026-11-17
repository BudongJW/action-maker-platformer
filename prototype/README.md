# Prototype

A vertical slice for playtesting the loop, the HI-FI / LINEAR tracks and the jump scares. It is a graybox unless the level file has an `art` block, which swaps the shapes for pixel art from `assets/original/` (see "Art block" below). Code lives in [`scripts/proto/`](../scripts/proto/); [`tools/build_prototype.py`](../tools/build_prototype.py) assembles a standalone Godot 4.7 project in `build/prototype/` (git-ignored) and can run it.

```bash
GODOT_BIN=/path/to/Godot_v4.7-stable python3 tools/build_prototype.py --run
```

## Content

| Source | When | Files |
|---|---|---|
| Private story pack | `private/assets/original/story/project.json` exists (`private/` is git-ignored) | compiled story, `scares.json`, `proto_level.json`, characters |
| Generic demo | otherwise, or `--story demo` | [`demo/story/`](demo/story/), [`demo/characters/`](demo/characters/) |

The demo is placeholder English text with no game story. The prototype code contains no dialogue text.

## Keys

| Key | Action |
|---|---|
| A / D or arrows | Move |
| Space | Jump |
| W / S | Climb a ladder |
| Enter or E | Advance dialogue, close a document; in the workroom, play the tape |
| 1-4, or Up / Down then Enter | Choose |
| Z / X / C | LINEAR / HI-FI / MIX (HI-FI and MIX unlock through the story) |
| R | Camera REC (records evidence inside an evidence area) |
| F | Fast-forward the tape (x4). It pauses while a scare is pending or relaxing, because the scare director runs in real time |
| M | Scare mode: default / soft (quieter, with a short prepulse) / off (no sudden onsets) |
| P | Photosensitivity-safe scares (no flash) |

## Level file (`proto_level.json`)

| Key | Meaning |
|---|---|
| `size`, `player_start`, `water` | Level size, start position, water line (visual) |
| `solids`, `hifi_only`, `linear_only`, `ladders` | `[x, y, w, h]` rectangles. Track-only shapes exist only in that track |
| `npcs`, `labels` | Markers and text drawn on the level; an NPC's optional `sprite` names an entry of `art.npcs` |
| `tape` | `length`, `time_scale`, dubbed `segments`, timeline `events` (`at`, `name`, `flag`) |
| `darkness_event`, `darkness_alpha` | Event that darkens the screen |
| `tracks` | Flags that unlock HI-FI and MIX |
| `hub` | Workroom between loops: `start` and `between` dialogues, `scares` that precede a dialogue, `on_play` dialogue + scare before the tape starts, `start_docs` (a document shown before anything else, such as a content warning) |
| `triggers` | `id` plus conditions (`rect`, `from`/`to` tape seconds, `track`, `loop`, `after_event`) and one action: `dialogue` (list, first available), `cue` (`hifi`/`linear`), `bark`, `doc` (collects it and opens the document viewer), `scare`, `rec_flag` (needs REC) |
| `chaser` | Pursuer that starts after the listed scares in LINEAR and triggers `catch_scare` when it reaches the player |
| `end_flag`, `report_flags` | Flag that ends the slice; flags printed by the bot |
| `bot_route` | Optional `{from, to, x}` windows the bot walks to (smoke test) |
| `art` | Optional pixel art (next section) |
| `audio` | Optional sound ("Audio block" below) |

## Art block

Paths are relative to the repository root. `build_prototype.py` copies every `.png` and `.pal` the block names into the build, copies `shaders/`, and writes `assets/art_atlas.json` with each sprite sheet's frame size, columns and frame names, read from the pixel-art sources in `assets/original/art/src/` and `assets/original/mibangsong/art/src/`. Frames are referred to by name. A missing file stops the build; a missing frame fails the smoke test.

| Key | Meaning |
|---|---|
| `zoom`, `camera_offset_y` | Camera zoom for the world (the art is drawn for a 320x180 screen, so 4 at 1280x720) and the camera's height above the player |
| `base_palette`, `palettes` | The `.pal` the art is drawn with and the per-track palettes (`linear`, `hifi`, optional `mix`). Art drawn with the base palette is recoloured with `shaders/palette_swap.gdshader` when the track changes |
| `backdrop` | `texture` (320x180) scrolled behind the level with `parallax` |
| `hub_backdrop` | Full-screen picture for the workroom between loops |
| `tiles` | `sheet` plus frames for `solid`, `hifi_only`, `linear_only`, `water` (`[top, fill]` or one frame) and `ladder` |
| `props` | Decoration: `{"frame", "at": [x, ground_y]}` or a tile block `{"block", "w", "h", "at"}` (frames `<block>_<col>_<row>`); optional `sheet`, `repeat` and `step` (copies side by side), `track` (`hifi` / `linear`) |
| `player`, `npcs`, `chaser` | Animated sprites: `{"sheet", "fps", "anims": {"idle": [frames], ...}}`. The player uses `idle`, `walk`, `jump`, `climb` and `caught`; the chaser `idle` and `lunge` |
| `viewfinder` | Camera overlay `sheet` with `rec` and `standby` frames; the live timecode is drawn over it |
| `badges` | Track badge frames (`linear`, `hifi`, `mix`) |
| `scares` | Per scare id: `{"sheet", "frame", "anchor": "left" / "right" / "center" / "full", "min_seconds"}`, shown at the onset for the scare's body duration. Without an entry the scare is sound only |
| `ui` | Nine-slice panels `{"sheet", "scale", "window", "nametag", "choice", "paper": {"frame", "margin", "padding"}, "cursor": frame}` for the dialogue window, speaker tag, selected choice, choice cursor and document paper, enlarged `scale` times. Text is always drawn at runtime |
| `voice_wave` | `{"speakers": [character ids], "color"}`: a soft waveform above the dialogue window while those speakers talk (for voices with no body on screen) |

The demo uses the generic art in `assets/original/art/`.

## Audio block

Paths are relative to the repository root and are copied into the build like the art. Without the block the prototype plays a generated noise bed and noise stingers.

| Key | Meaning |
|---|---|
| `ambience` | `linear` and `hifi` loops play together on the `Linear` and `HiFi` buses, which the track mixer crossfades and which send into `Ambience` (the bus the scare director ducks); `hub` plays in the workroom |
| `ambience_db` | Gain for the ambience players |
| `loops` | `{"file", "db", "from", "to", "until_event", "stop"}`: plays during that tape time, stops for good when the timeline event fires and then plays `stop` once (for example a generator cutting out) |
| `stingers` | Per scare id: a file played at the onset instead of noise, at `level_lu - 20` dB (files are normalized to a -1 dBFS peak, which stands for +20 LU over dialogue) |
| `sfx` | Named one-shots: a path, a list (one picked at random) or `{"file", "db"}`. The prototype uses `step`, `rec_on`, `rec_off`, `prepulse` (soft mode), `deck_play`, `deck_rewind` and `tape_start` |
| `step_interval` | Seconds between footsteps. Footsteps stop in the scare director's quiet window (a sound 30-500 ms before a startle stimulus weakens it) |
 Scare frames are the art's own; check them against the photosensitivity rules in [`docs/scare-director.md`](../docs/scare-director.md) (drawn area, no saturated red, one flash per scare).

## Bot

`--smoke` runs the game headless with `-- --bot`: it advances dialogue, picks the first enabled choice, keeps REC on, switches to HI-FI once unlocked and walks the level (or the `bot_route`). It prints one summary line and fails on script errors, missing art or sound, and objects leaked at exit. Falling below the level respawns the player on the last safe ground.

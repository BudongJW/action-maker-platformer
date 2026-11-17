# Prototype

A graybox vertical slice for playtesting the loop, the HI-FI / LINEAR tracks and the jump scares. Code lives in [`scripts/proto/`](../scripts/proto/); [`tools/build_prototype.py`](../tools/build_prototype.py) assembles a standalone Godot 4.7 project in `build/prototype/` (git-ignored) and can run it.

```bash
GODOT_BIN=/path/to/Godot_v4.7-stable python3 tools/build_prototype.py --run
```

## Content

| Source | When | Files |
|---|---|---|
| Private story pack | `assets/original/story/project.json` exists (git-ignored) | compiled story, `scares.json`, `proto_level.json`, characters |
| Generic demo | otherwise, or `--story demo` | [`demo/story/`](demo/story/), [`demo/characters/`](demo/characters/) |

The demo is placeholder English text with no game story. The prototype code contains no dialogue text.

## Keys

| Key | Action |
|---|---|
| A / D or arrows | Move |
| Space | Jump |
| W / S | Climb a ladder |
| Enter or E | Advance dialogue; in the workroom, play the tape |
| 1-4 | Choose |
| Z / X / C | LINEAR / HI-FI / MIX (HI-FI and MIX unlock through the story) |
| R | Camera REC (records evidence inside an evidence area) |
| F | Fast-forward the tape (x4) |

## Level file (`proto_level.json`)

| Key | Meaning |
|---|---|
| `size`, `player_start`, `water` | Level size, start position, water line (visual) |
| `solids`, `hifi_only`, `linear_only`, `ladders` | `[x, y, w, h]` rectangles. Track-only shapes exist only in that track |
| `npcs`, `labels` | Markers and text drawn on the level |
| `tape` | `length`, `time_scale`, dubbed `segments`, timeline `events` (`at`, `name`, `flag`) |
| `darkness_event`, `darkness_alpha` | Event that darkens the screen |
| `tracks` | Flags that unlock HI-FI and MIX |
| `hub` | Workroom between loops: `start` and `between` dialogues, `scares` that precede a dialogue, `on_play` dialogue + scare before the tape starts |
| `triggers` | `id` plus conditions (`rect`, `from`/`to` tape seconds, `track`, `loop`, `after_event`) and one action: `dialogue` (list, first available), `cue` (`hifi`/`linear`), `bark`, `doc`, `scare`, `rec_flag` (needs REC) |
| `chaser` | Pursuer that starts after the listed scares in LINEAR and triggers `catch_scare` when it reaches the player |
| `end_flag`, `report_flags` | Flag that ends the slice; flags printed by the bot |
| `bot_route` | Optional `{from, to, x}` windows the bot walks to (smoke test) |

## Bot

`--smoke` runs the game headless with `-- --bot`: it advances dialogue, picks the first enabled choice, keeps REC on, switches to HI-FI once unlocked and walks the level (or the `bot_route`). It prints one summary line and fails on script errors. Falling below the level respawns the player on the last safe ground.

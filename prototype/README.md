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
| Up / Down, Enter | Title screen: Continue (only when there is a save), New Game (asks first when it would overwrite a save), Options, Quit. After the end credits, Enter goes back to the title |
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
| B | Deduction board in the workroom, once the level's `board` block allows it: Left / Right choose, Up / Down change the row (cards, knots, conclusions), B or Esc close |
| Esc | Pause menu during play: Resume, Options, Back to Title (progress since the last workroom visit is not kept). Options is the settings screen: scare mode, reduce flashing, master / ambience / effects volume, text size, subtitles, effects outside the game window. Labels come from `assets/original/ui/strings.csv` (`ui.options.*`); values are saved to `user://proto_settings.cfg` |

## Level file (`proto_level.json`)

| Key | Meaning |
|---|---|
| `size`, `player_start`, `water` | Level size, start position, water line (visual; `gaps: [[x0, x1]]` leaves room for rising-water zones) |
| `rising_water` | Zones `{x0, x1, track, base_y, linear_y, rate, max_rise, bark, bark_rise, submerge, respawn}`: on `track` (default `hifi`) the water climbs `rate` px/s while the player stays inside and falls back when they leave; on other tracks it stands at `linear_y`. Going under puts the player at `respawn`. `bark` is shown once the rise passes `bark_rise`. With `after_event` and/or `requires` the zone floods only once those hold (for example a path that is under water in HI-FI after 01:40 in a later chapter; use `rate: 0` and a `base_y` above the ground) |
| `solids`, `hifi_only`, `linear_only`, `ladders` | `[x, y, w, h]` rectangles. Track-only shapes exist only in that track. An optional fifth element names the art `tiles` entry for that one shape (for example `"room_floor"`) |
| `npcs`, `labels` | Markers and text drawn on the level; an NPC's optional `sprite` names an entry of `art.npcs` |
| `tape` | `length`, `time_scale`, dubbed `segments`, timeline `events` (`at`, `name`, `flag`). `slow: [{requires, scale}]` changes the tape speed while the flags hold (the last matching rule wins), for example a quarter-speed stretch |
| `darkness_event`, `darkness_alpha` | Event that darkens the screen |
| `tracks` | Flags that unlock HI-FI and MIX. `locks: [{requires, allow}]` keeps the player on the `allow` tracks while the flags hold (the key shows "<TRACK> LOCKED"); a trigger's `set_track` ignores locks and unlocks |
| `hub` | Workroom between loops: `start` and `between` dialogues (or `{"doc": id, "requires": [...]}` to collect and show a document found in the workroom), `scares` that precede a dialogue, `on_play` dialogue + scare before the tape starts, `start_docs` (a document shown before anything else, such as a content warning), `actions` (`[{key, dialogue, requires, prompt, bot}]`: a key that opens a dialogue in the workroom between tapes, such as closing out the job early; its `prompt` UI string is listed in the workroom text while it is available; the bot uses an action once only if it has `bot: true`) |
| `board` | Optional deduction board (B in the workroom): `requires` (flags that must be on), `art` (`sheet`, `frame`: a 320x180 board picture shown full screen) and `cards` `[{flag, doc, tc}]`. A card is pinned once its `flag` is on; its title and text come from the story document `doc` (category `board` by convention) and `tc` (tape seconds) is printed on the card and pinned on the timecode axis. Optional rows: `knots` `{requires, slots: [{flag, doc}]}` lights the seven knot slots as their flags turn on (the doc's title says what the knot is, its text shows once untied), and `conclusions` `{requires, slots: [{flag, docs}]}` shows the chosen answer of each conclusion (an integer flag value n shows `docs[n - 1]`). Up/Down change the row. The layout follows `assets/original/mibangsong/art/fx/mbs_ui_board.png` (axis 01:19 to 01:59, seven knot slots, five card slots that scroll, three conclusion slots) |
| `triggers` | `id` plus conditions (`rect`, `from`/`to` tape seconds, `track` (`hifi` / `linear` / `mix`), `loop`, `after_event`, `requires`: flags that must be on, `"!flag"` for off, `"flag=value"` to compare a number flag, `seen.*` allowed; the same list works wherever a block takes `requires`) and one action: `dialogue` (list, first available), `cue` (`hifi`/`linear`), `bark`, `doc` (collects it and opens the document viewer), `scare`, `rec_flag` (needs REC), `set_flag`, `warp` (`[x, y]`: moves the player, for example through a door into a room built elsewhere in the level). Options: `interact` (fires on Enter/E inside the rect, with the `prompt` UI string key; no prompt while none of its dialogues can start), `mark` (flag set when it fires, for once-only triggers with `requires: ["!flag"]`), `sfx` (named sound), `repeat` (fires again in the same loop, for doors), `set_track` (`hifi` / `linear` / `mix`: switches the track before the action, for a tape that slips by itself). `end_loop` ends the loop (the tape rewinds to the workroom), for example once the story has reached the end of the tape. A trigger fires at most once per loop unless it has `repeat`. When a scare ends, `loop.scare_done_<id>` turns on, so a trigger can wait for it |
| `rules` | `{"all": [flags], "set": flag}`: turns a flag on once all the others are on (for example six lanterns hung) |
| `chaser` | Pursuer that starts after the listed scares in LINEAR and triggers `catch_scare` when it reaches the player. With `start_flag` it starts once per loop when that flag turns on (no dialogue running), `start_offset` pixels from the player (default -360); `stop_flag` sends it away. It holds still while a scare is on screen (from onset to end), so a player startled by one is not caught for it |
| `escorts` | `[{id, path: [[x, y], ...], speed, max_gap, requires, sprite: {sheet, frame, scale}, ribbon: {color, width}, done_flag}]`: something that moves along `path` while the requirements hold and the player keeps within `max_gap` pixels of it (it waits otherwise, and while dialogue runs). The path is drawn as a ribbon. At the end it sets `done_flag` |
| `title` | `{text, sub}`: the title screen's two lines (the menu words come from the UI strings `ui.title.*`) |
| `end_flag`, `report_flags` | Flag that ends the slice; flags printed by the bot |
| `end_docs` | `[{doc, requires}]`: when the end flag turns on, the first document whose flags hold is shown before the end (an ending's card) |
| `credits` | `{doc, secs}`: after the end documents, the document's title and paragraphs scroll up the screen as end credits (Enter or Esc skips). The words come from the story, not the code |
| `bot_route` | Optional `{from, to, x}` windows the bot walks to (smoke test); a window can also set `track`, `ff` (tape speed) and `requires`, and `follow` (an escort id) instead of `x`. The last matching window wins |
| `bot_prefer` | Choice line ids the bot takes whenever they are offered and enabled (for example the route to one ending); otherwise its usual rule applies |
| `bot_ff`, `bot_max_frames`, `bot_loops`, `bot_patrol` | Bot tape speed (default 20), frame limit, loop limit, and `[x_min, x_max]` for wandering outside route windows |
| `art` | Optional pixel art (next section) |
| `audio` | Optional sound ("Audio block" below) |

## Saves

The game saves at the start of every workroom visit, before the workroom's dialogues run: between tapes, and before any choice that ends the game, so Continue after an ending comes back to the workroom just before it. The save holds the story state (`StoryRunner.serialize_save()`: loop and save flags, seen marks and collected documents, one-time choices, the loop count) and the track, in `user://proto_save.json` (Godot's user folder for the project "Story prototype"; delete the file to start over). `meta.*` flags (endings seen) stay in `user://meta.dat`, apart from the save.

Bot runs and reels skip the title and keep their save in memory, so they never touch the player's file. The bot loads its own save once, at its second workroom visit, and the smoke test fails if the story state does not come back unchanged.

## Meta outputs

Lines with a meta target (`os_dialog`, `window_title`, `desktop_file`; see `docs/script-format.md` 6.3) are shown with stand-ins drawn inside the game: a system window with an OK button, a title bar along the top of the screen, and a journal note in the lower right. The runtime picks the stand-in when the player has not allowed meta effects (`sys.meta_os`); when they have, the prototype also changes the real window title and still draws the other two inside the game. The stand-ins' own labels come from `assets/original/ui/strings.csv` (`ui.dialog.ok`, `ui.journal.added`).

## Art block

Paths are relative to the repository root. `build_prototype.py` copies every `.png` and `.pal` the block names into the build, copies `shaders/`, and writes `assets/art_atlas.json` with each sprite sheet's frame size, columns and frame names, read from the pixel-art sources in `assets/original/art/src/` and `assets/original/mibangsong/art/src/`. Frames are referred to by name. A missing file stops the build; a missing frame fails the smoke test.

| Key | Meaning |
|---|---|
| `zoom`, `camera_offset_y` | Camera zoom for the world (the art is drawn for a 320x180 screen, so 4 at 1280x720) and the camera's height above the player |
| `base_palette`, `palettes` | The `.pal` the art is drawn with and the per-track palettes (`linear`, `hifi`). Art drawn with the base palette is recoloured with `shaders/palette_swap.gdshader` when the track changes. With both palettes, MIX shows two pictures at once (`shaders/track_mix.gdshader`): the world is drawn a second time into a view that shares it, HI-FI-only shapes and props appear only in that view and LINEAR-only ones only in the main one, and the two alternate in a checkerboard of art pixels with the HI-FI picture pushed right and recoloured with the HI-FI palette. Without the shader, MIX draws the world halfway to the HI-FI palette and both tracks' shapes half transparent |
| `mix` | `{"shift"}`: how many art pixels the HI-FI picture is pushed to the right in MIX (default 3) |
| `vhs` | VHS texture over the world, below the UI (`shaders/vhs.gdshader`): scanlines on the 180 art rows, colour that smears and trails behind brightness, grain, and a tracking band rolling down the picture. On whenever the block or a `viewfinder` is present; `enabled: false` turns it off. It goes away for good once `off_flag` is on (default: the viewfinder's `off_flag`, the camera switched off). `scanlines`, `chroma`, `chroma_blur` (art pixels), `noise` and `band` tune it. With reduced flashing (P or the settings) the grain stands still and the band is gone |
| `backdrop` | `texture` (320x180) scrolled behind the level with `parallax` |
| `hub_backdrop` | Full-screen picture for the workroom between loops |
| `cuts` | `{dialogue_id: {"texture", "frame"}}`: a picture shown while that dialogue plays (a care home, a 1979 recording, a long take), fitted above the dialogue window on a dark background. Optional `when: [{from_line, requires, texture, frame}]` changes the picture halfway: the last entry whose line has been shown and whose flags hold wins, checked on every line (a close-up after the wide shot; the same shot once the camera is switched off). An entry (or the cut itself) with `none: true` shows no picture; `frames: [names]` with `fps` loops several frames of the texture (a counter ticking over); `text: {rect: [x, y, w, h], size, color, fill}` writes the text of the entry's own `from_line` on the picture, in the picture's pixels (`fill` first covers whatever the art drew there, for example placeholder lines where a headline goes) |
| `tiles` | `sheet` plus frames for `solid`, `hifi_only`, `linear_only`, `water` (`[top, fill]` or one frame) and `ladder`. Extra entries name tiles for single shapes; an entry can be `{"sheet", "frames"}` to take tiles from another sheet |
| `props` | Decoration: `{"frame", "at": [x, ground_y]}` or a tile block `{"block", "w", "h", "at"}` (frames `<block>_<col>_<row>`); optional `sheet`, `repeat` and `step` (copies side by side), `track` (`hifi` / `linear`), `flag` / `unless_flag` (shown only while a flag is on / off, for example a lantern before and after it is hung; a prop with both `track` and a flag still hides on the other track), `scale` (around the bottom-left point, for small items), `recolour: false` (keeps the art's own colours under the track palettes) |
| `player`, `npcs`, `chaser` | Animated sprites: `{"sheet", "fps", "anims": {"idle": [frames], ...}}`. The player uses `idle`, `walk`, `jump`, `climb` and `caught`; the chaser `idle` and `lunge` |
| `viewfinder` | Camera overlay `sheet` with `rec` and `standby` frames; the live timecode is drawn over it. With `off_flag`, the overlay, timecode, track badge and VHS texture disappear and REC stops once that flag is on (the camera switched off for good) |
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

## Reel (demo videos)

`-- --reel <file.json>` plays a scripted sequence of scenes instead of the game: title cards, the workroom, tape scenes at a given time, track switches, walking (or walking beside an escort), dialogues with their choices, documents, subtitle cues, scares, the deduction board and end credits. All visible words come from the reel file and the story; the step list is documented at the top of `scripts/proto/proto_reel.gd`. `prototype/demo/reel.json` is a short example for the demo story.

```
python3 tools/build_prototype.py --story demo --reel prototype/demo/reel.json            # headless check
python3 tools/build_prototype.py --story demo --reel prototype/demo/reel.json --movie reel.mp4
```

With `--movie`, Godot's movie writer records 1280x720 at 30 fps with sound (`.avi`; `.mp4` is converted with ffmpeg). It needs a display; on a server without one, `xvfb-run` is used when it is installed. A reel for the private story belongs in `private/` (for example `private/reels/`), since its title cards and scenes are story material.

## Bot

`--smoke` runs the game headless with `-- --bot`: it advances dialogue, picks the first enabled choice, keeps REC on, switches to HI-FI once unlocked and walks the level (or the `bot_route`). It opens the settings screen once and the board whenever something new is on it, and walks every row. Bot runs and reels keep `meta.*` flags (endings seen, a second playthrough) in memory only, so they neither read nor change the player's `user://meta.dat` and every run starts the same. In a choice menu it meets again (a menu that loops back, such as picking a knot and a card), it takes the next option it has not tried, then the last one, so a looping menu cannot trap it. It prints one summary line (with `board found/total` and `knots untied/total` when the level has a board) and fails on script errors, missing art or sound, and objects leaked at exit. Add `-- --bot --trace` when running Godot directly to print every trigger, dialogue, scare and loop end with its tape time. Falling below the level respawns the player on the last safe ground. The bot presses Enter/E at every prompt, so a `repeat` door on its path needs route windows (with `requires` on the door's `mark` flags) that do not walk it back through the door.

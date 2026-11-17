# Open-source story-driven RPG / strategy / space games: is the character dialogue script in the repo?

Research date: 2026-11-17. Method note: license files, sample scripts and translation templates (.pot) were read from public raw-file URLs (raw.githubusercontent.com, codeberg.org/.../raw/..., gitlab.com/.../-/raw/...). Large text files (.pot, phrase files) were downloaded over HTTPS into the session scratchpad and counted with grep/awk only. Nothing was cloned, and no GitHub API, MCP or gh CLI was used. The Tales of Maj'Eyal source is only reachable as the official release tarball, because its GitLab now redirects anonymous visitors to a sign-in page. The tarball was streamed, and only the license files and the `tome-1.7.6.team` module archive were extracted. Counts were taken on 2026-11-17 and drift as repos change. Quoted samples are kept to a few lines and are there to show structure.

Scope after verification. The requested list was kept. Two titles were added or merged:
- **Added:** The Ur-Quan Masters (Star Control II), a story-driven space game whose full alien dialogue is published under CC BY-NC-SA 2.5.
- **Merged:** Hero of Allacrost, which lives on only through its fork Valyria Tear.
- **Weak fits, kept for contrast:** Dungeon Crawl Stone Soup, A Dark Room and Shattered Pixel Dungeon have almost no speaker-attributed dialogue.

---

## Q0. Overview: which games ship speaker-attributed character scripts, in what format, under what text license?

### Takeaway
Most of these projects keep their story text in the public repo, and much of it is plain-text or script data. Only some mark the speaker explicitly per line:
- **Explicit speaker on every line:** Wesnoth, Naev, FreedroidRPG, Flare, Valyria Tear and Cataclysm DDA (NPC versus player by structure).
- **Speaker only in prose or by file:** Endless Sky (prose), Ur-Quan Masters (one file per alien race).
- **Little or no character dialogue:** Warzone 2100 (briefings), A Dark Room, Shattered Pixel Dungeon and DCSS.

The text licenses vary a lot:
- **GPL family:** Wesnoth, Naev missions, Endless Sky, FreedroidRPG, ToME, Warzone, SPD, DCSS.
- **CC BY-SA 3.0:** CDDA, Flare, Ryzom (Ryzom is dual-licensed with FAL 1.3).
- **CC BY-NC-SA 2.5:** Ur-Quan Masters.
- **MPL-2.0:** A Dark Room.
- **Story reserved by the author despite GPL scripts:** Valyria Tear.

### Cited Findings (summary table — details and sources in each game section below)

| Game (first release) | Story files (path) | Speaker-attributed script? | Format | Dialogue-text license |
|---|---|---|---|---|
| Battle for Wesnoth (2003 dev / 1.0 2005) | `data/campaigns/<Campaign>/scenarios/*.cfg` | **Yes** (`speaker=` per `[message]`) | WML (+gettext .pot in `po/wesnoth-<id>/`) | GPL-2.0+ |
| Naev (c.2005 start) | `dat/missions/**.lua`, `dat/events/**.lua` | **Yes** (VN API: character objects, `vn.na`, `vn.me`) | Lua + gettext `po/naev.pot` | GPL-3 (Lua = code); XML/other files CC BY-SA 4.0+ |
| Endless Sky (2015) | `data/**/*.txt` (e.g. `data/human/free worlds 1 start.txt`) | **Partial** (no speaker field; speech in prose) | custom indented txt `conversation` blocks | GPL-3+ |
| Cataclysm: DDA (2013) | `data/json/npcs/**` | **Yes** (NPC line = `dynamic_line`, player = `responses[].text`) | JSON `talk_topic` | CC BY-SA 3.0 (whole project) |
| FreedroidRPG (Debian 1.0) | `data/storyline/act1/dialogs/*.lua` (82 files) | **Yes** (`Npc:says`, `Tux:says`) | Lua | GPL-2.0+ |
| Flare: Empyrean Campaign (2010–) | `mods/empyrean_campaign/npcs/*.txt` | **Yes** (`you=`, `him=`) | INI-style txt + `languages/data.pot` | CC BY-SA 3.0 (data files) |
| Valyria Tear (2012–; fork of Hero of Allacrost 2004–2011) | `data/story/ep1/**/*_script.lua` | **Yes** (`AddLine(text, sprite)`, emotes) | Lua + `po/ep1-valyriatear.pot` | GPLv2+, but README reserves the **story concept** |
| Tales of Maj'Eyal (2012) | `game/modules/tome/data/chats/*.lua`, `data/lore/*.lua` (inside `tome-*.team`) | **Yes/partial** (chat bound to NPC; player answers) | Lua `newChat{}` / `newLore{}` | GPL-3+ (file headers); gfx "ToME only" |
| Warzone 2100 (1999; GPL 2004) | `data/base/messages/strings/cam*strings.txt`, `data/base/sequenceaudio/**` | **Partial/No** (briefings and subtitles, no speaker field) | ID→`_()` string tables, timed subtitle lines, JS mission logic | GPL-2+/GPL-3+; explicit permission to use "stories, texts" |
| A Dark Room (2013) | `script/events/*.js`, `lang/adarkroom.pot` | **No** (narration, scenes and buttons) | JS objects | MPL-2.0 |
| Shattered Pixel Dungeon (2014) | `core/src/main/assets/messages/**.properties` | **Partial** (NPC lines keyed by NPC class) | Java .properties | GPL-3.0 |
| Dungeon Crawl Stone Soup (2006) | `crawl-ref/source/dat/database/monspeak.txt` | **Partial** (monster barks) | custom `%%%%`-separated weighted DB | GPL-2.0+ |
| Ryzom (2004; Ryzom Core open) | `ryzomcore_leveldesign/translation/**` (`phrase_*.txt`, `*.uxt`) | **Partial** (NPC "bot" phrases; speaker set by mission primitives) | Ryzom phrase files + World Editor primitives | CC BY-SA 3.0 + FAL 1.3 (leveldesign repo) |
| The Ur-Quan Masters (2002) | `sc2/content/base/comm/<race>/<race>.txt` | **Yes (by file)**: one file per alien race, `#(KEY)` blocks | keyed txt + voice file; logic in C | **CC BY-NC-SA 2.5** (NonCommercial) |

### Inferences
- For the user's goal (analyzing published character scripts), the richest sources are Wesnoth, Naev, FreedroidRPG, Valyria Tear, Flare and CDDA:
  - Wesnoth and Naev have the most text: Wesnoth ~11.5k speaker-attributed messages, Naev ~12k mission/event strings.
  - FreedroidRPG, Valyria Tear and Flare are the closest in scale to a small 2D story game.
  - CDDA is the best example of a fully data-driven (JSON) dialogue graph.
- Because the user's repo is GPL-3.0 with an AGM-runtime exception and keeps original content All Rights Reserved, none of these texts can simply be pasted in. The safe path is to borrow **format and structure** and write original text (see Q15).

### Gaps
- First-release dates for Naev and FreedroidRPG are only approximate (see their sections).
- Volume could not be measured the same way for every project. Endless Sky and CDDA have no committed .pot to count from.

---

## Q1. The Battle for Wesnoth

### Takeaway
Wesnoth ships complete campaign dialogue in WML. Every `[message]` names a `speaker=` (a unit id or `narrator`), can override the portrait and name, and supports choices, conditions and voice. All story and WML text is GPL-2.0-or-later. The gettext .pot files even record the speaker for each line, so this is the gold-standard example of a speaker-attributed, localizable campaign script.

### Cited Findings
- **Repo:** https://github.com/wesnoth/wesnoth. Story files are in `data/campaigns/<Campaign>/scenarios/*.cfg`.
  - Campaign folders on master: Dead_Water, Descent_Into_Darkness, Dusk_of_Dawn, Eastern_Invasion, Heir_To_The_Throne (a remake; its scenario file says "scenario by Dalas"), Heir_To_The_Throne_Classic, Legend_of_Wesmere, Liberty, Northern_Rebirth, Of_Pearls_and_Pirates, Sceptre_of_Fire, Secrets_of_the_Ancients, Son_Of_The_Black_Eye, The_Deceivers_Gambit, The_Hammer_of_Thursagan, The_Rise_Of_Wesnoth, The_South_Guard, Two_Brothers, Under_the_Burning_Suns, Winds_of_Fate, World_Conquest (probably the multiplayer World Conquest mode rather than a story campaign; not verified) — [GitHub tree data/campaigns](https://github.com/wesnoth/wesnoth/tree/master/data/campaigns)
  - Translation templates are in `po/wesnoth-<textdomain>/wesnoth-<textdomain>.pot`, e.g. `po/wesnoth-h2tt`, `po/wesnoth-utbs` — [GitHub tree po](https://github.com/wesnoth/wesnoth/tree/master/po)
- **Year:** the copyright header says "Copyright (C) 2003 - 2018 by David White" — [copyright](https://raw.githubusercontent.com/wesnoth/wesnoth/master/copyright). Wikipedia's list gives first release 2005 (1.0) — [Wikipedia list](https://en.wikipedia.org/wiki/List_of_open-source_video_games). Engine: C++ plus WML and Lua.
- **Licenses:**
  - **Code:** README: "All source code is licensed under the GNU GPL v2+." — [README](https://raw.githubusercontent.com/wesnoth/wesnoth/master/README.md)
  - **Art and music:** README: "Most art and music is also licensed under the GNU GPL v2+," and "new contributions are now licensed under the Creative Commons BY-SA v4.0." — [README](https://raw.githubusercontent.com/wesnoth/wesnoth/master/README.md)
  - **Story and WML:** the Copyrights wiki says "Code contributed to the Battle for Wesnoth project is licensed under the GNU GPL v2 or later." It applies this to C++, Lua and WML, plus data files including story content.
  - **Visual and audio assets:** the same page says these are under GPL v2+ or CC BY-SA 4.0, and "all future contributions will be under the CC BY-SA 4.0 license." The page says nothing about the Wesnoth name or logo. — [Wesnoth:Copyrights](https://wiki.wesnoth.org/Wesnoth:Copyrights)
  - The repo-root `copyright` file is just the GPL-2+ header template ("under the terms of the GNU General Public License version 2 or at your option any later version") — [copyright](https://raw.githubusercontent.com/wesnoth/wesnoth/master/copyright)
- **Script format and sample** (H2TT `01_The_Elves_Besieged.cfg`; file starts `#textdomain wesnoth-h2tt` and contains 50 `[message]` tags) — [raw file](https://raw.githubusercontent.com/wesnoth/wesnoth/master/data/campaigns/Heir_To_The_Throne/scenarios/01_The_Elves_Besieged.cfg):
  ```
  [message]
      speaker=Konrad
      #po: the "dream" Konrad refers to is the intro storytext. ...
      message=_"<i>(yawn)</i> What a vivid dream. ..."
  [/message]
  [message]
      speaker=narrator
      caption=_"Delfador"
      image=portraits/delfador-elvish-unknown.webp
      message=_"Wake up, wake up, wake up! ..."
  [/message]
  ```
  - `_"..."` marks a translatable string.
  - `#po:` is a comment passed to translators.
  - `caption`/`image` override the speaker's name and portrait. Here they hide the speaker's identity until he appears.
  - Pango markup (`<span size='small'>`, `<i>`) handles whispering and emphasis.
- **`[message]` keys** — [InterfaceActionsWML](https://wiki.wesnoth.org/InterfaceActionsWML):
  - `speaker`: a unit id, or `narrator` / `unit` / `second_unit`.
  - `image` ("default: profile image of speaker"), with `~RIGHT()` or `image_pos` for placement, and `mirror`.
  - `caption` ("default: name of speaker").
  - `side_for`, `sound`, and `voice` / `male_voice` / `female_voice`.
  - `male_message` / `female_message` (gendered text).
  - `[show_if]` (conditional message).
  - `[option]` with `message`/`description`, `value`, `[show_if]` and `[command]` ("actions which are executed if the option is selected").
  - `[text_input]`.
  - There is no dedicated expression/emotion key. Expressions are done by pointing `image=` at a different portrait.
- **Translator context:** the gettext tool writes the speaker into the .pot automatically, e.g. `#. [message]: speaker=Delfador` followed by `#: data/campaigns/Heir_To_The_Throne_Classic/scenarios/01_The_Elves_Besieged.cfg:272` — [wesnoth-httt.pot](https://raw.githubusercontent.com/wesnoth/wesnoth/master/po/wesnoth-httt/wesnoth-httt.pot)
- **Volume** (pot files downloaded 2026-11-17; counted `^msgid` and `#. [message]: speaker=` comments):

  | Campaign | msgids | speaker lines | words |
  |---|---|---|---|
  | 20 campaigns + tutorial (total) | 19,584 | 11,529 | ~336k |
  | wesnoth-h2tt (new Heir to the Throne) | 3,154 | 1,850 | — |
  | wesnoth-utbs (Under the Burning Suns) | 2,060 | 1,363 | — |
  | wesnoth-ei (Eastern Invasion) | 1,864 | 1,115 | — |
  | wesnoth-httt (Classic HttT) | 1,233 | 838 | — |

  - Most-frequent speakers in Classic HttT: Konrad 196, Delfador 180, Li'sar ("Li") 74, Kalenz 71, narrator 53.
  - Source pots: [wesnoth-h2tt.pot](https://raw.githubusercontent.com/wesnoth/wesnoth/master/po/wesnoth-h2tt/wesnoth-h2tt.pot), [wesnoth-utbs.pot](https://raw.githubusercontent.com/wesnoth/wesnoth/master/po/wesnoth-utbs/wesnoth-utbs.pot)
  - Caveats: msgids include objectives, unit names and storytext as well as dialogue. LoW shows only 56 speaker comments out of 720 msgids, probably because its messages go through macros.
- **Story structure:** separate linear campaigns spread across one world's history, made of scenario chains with occasional branch scenarios. HttT (prince Konrad, guided by the mage Delfador, flees and reclaims a throne) is the flagship. The old and remade versions coexist in the repo — [GitHub tree](https://github.com/wesnoth/wesnoth/tree/master/data/campaigns)

### Inferences
- **Design lessons:**
  - Use a stable **speaker id that resolves to a character record** (name and default portrait), with per-line `caption` and `image` overrides for disguises or expression changes.
  - Use a **narrator** pseudo-speaker.
  - Put **gender variants** in the line itself.
  - Make **choice options** that carry condition and action blocks.
  - Pass **translator comments** (`#po:`) through extraction, and have the extraction tool write the speaker into the .pot. Both carry over directly to Godot (e.g. CSV/PO translations plus a dialogue resource with `speaker_id`, `portrait_override`, `name_override`, `voice`, `condition`, `options[]`).
- **Reuse:**
  - Wesnoth's text is GPL-2+. Incorporating it would make that text GPL in the user's repo, so it could not be All Rights Reserved.
  - The AGM section-7 permission cannot be extended to Wesnoth's code or text without the Wesnoth authors' consent (see Q15).
  - Borrow only the tag design.

### Gaps
- No trademark policy for the name "Wesnoth" was found on the Copyrights page.
- The volume counts mix dialogue with non-dialogue strings. LoW's low speaker count was not investigated.

---

## Q2. Naev

### Takeaway
Naev's story lives in Lua mission and event scripts that use a purpose-built visual-novel (`vn`) API: character objects with portrait and colour, `vn.na` (narrator), `vn.me` (player), menus, labels and jumps, transitions, music and side-effect functions. The license splits by file type:
- **Lua scripts (including all mission dialogue):** GPL-3.
- **XML and other non-code files:** CC BY-SA 4.0+.
- **Portraits:** per-asset licenses.

Development moved to Codeberg; GitHub is now a mirror.

### Cited Findings
- **Repo:** the GitHub page says "Naev has moved to codeberg! This is just a mirror." — [GitHub naev/naev](https://github.com/naev/naev). Official: https://codeberg.org/naev/naev. Its LICENSE is identical to the GitHub copy (verified by diff) — [Codeberg LICENSE](https://codeberg.org/naev/naev/raw/branch/main/LICENSE)
  - Assets are a git submodule, `assets` → `https://codeberg.org/naev/naev-assets-lossy.git` — [.gitmodules](https://raw.githubusercontent.com/naev/naev/main/.gitmodules)
- **Year:** precise start date not confirmed.
  - A 2012 interview puts the start about 7 years earlier (c.2005), when bobbens was a high-school student — [GamingOnLinux interview](https://www.gamingonlinux.com/articles/interviewing-the-naev-team.729) (from search-result summary; not opened directly)
  - 0.5.0 came out in June 2011, 0.7.0 was the first Steam release (July 2017), and 0.12.6 shipped July 2025. These dates come from a web-search summary of naev.org blog and GamingOnLinux pages, which were not opened directly — [GamingOnLinux 2020](https://www.gamingonlinux.com/2020/07/open-source-space-trading-and-combat-game-naev-has-a-fresh-build-up)
  - The Wikipedia article returns 404.
  - Engine: C (now with Rust and meson build files) plus Lua.
- **Licenses (LICENSE, quoted):**
  - "Except where otherwise noted, all source code files (C files, Lua files, and any other files containing software written in a programming language) are distributed under the GNU General Public License version 3". Contributions after 2021-01-06, and those from a listed set of contributors, may be used under any later GPL version.
  - Assets: "Licensing of graphical assets contained in "gfx/" is documented by "gfx/ARTWORK_LICENSE.yaml"", with the same arrangement for fonts and `snd/`.
  - "Except where otherwise noted, all other files, including XML files, are distributed under the Creative Commons Attribution-ShareAlike License, version 4.0 or later" — [LICENSE](https://raw.githubusercontent.com/naev/naev/main/LICENSE)
  - Artwork licenses are per author in `gfx/ARTWORK_LICENSE.yaml`: mostly CC-BY 3.0/4.0, CC-BY-SA 3.0/4.0, PD, CC0 and GPLv3. Example: bobbens' `vn: characters:` art is "CC-by-sa 4.0" — [ARTWORK_LICENSE.yaml](https://codeberg.org/naev/naev-assets-lossy/raw/branch/main/gfx/ARTWORK_LICENSE.yaml)
- **Script inclusion: Yes.** The VN library is `dat/scripts/vn/vn.lua` ("Visual Novel API for Naev — Based on Love2D API"); `dat/scripts/vn.lua` lazy-loads it. Public API — [vn.lua](https://raw.githubusercontent.com/naev/naev/main/dat/scripts/vn/vn.lua):
  - Characters and staging: `vn.newCharacter(who, params)`, `vn.appear`, `vn.disappear`, `vn.move`, `vn.scene()`.
  - Lines: `vn.say(who, what)`, `vn.me` (= say "You"), `vn.na` (= say "Narrator").
  - Flow: `vn.menu(items, handler)`, `vn.label`, `vn.jump`, `vn.func`, `vn.done`, `vn.run`, `vn.clear`.
  - Presentation: `vn.music`, `vn.sfx*`, `vn.transition`, `vn.animation`, `vn.setShader`, `vn.setBackground`.
  - Text speed and autoscroll are stored in player variables.
- **Mission metadata header:** each mission starts with an XML block inside a Lua comment, with `<unique/>`, `<chance>`, `<location>Bar</location>`, `<spob>Minerva Station</spob>`, `<cond>var.peek(...)</cond>`, and `<notes><campaign>Minerva</campaign><requires name="Minerva Altercation 1"/></notes>` — [maikki1.lua](https://raw.githubusercontent.com/naev/naev/main/dat/missions/minerva/maikki1.lua)
- **Sample** (abridged, structure only) — [maikki1.lua](https://raw.githubusercontent.com/naev/naev/main/dat/missions/minerva/maikki1.lua):
  ```lua
  local maikki = vn.newCharacter( minerva.vn_maikki() )
  maikki:rename( _("Distraught Young Woman") )
  vn.na(_("You approach a young woman who seems somewhat distraught. ..."))
  vn.menu( {
     { _("Offer to help her"), "accept" },
     { _("Decline to help"), "decline" },
  } )
  vn.label( "accept" )
  vn.func( function () misn.accept(); mem.misn_state = STATE_STARTED end )
  maikki(_([["My name is Maisie, but you can call me Maikki."]]))
  ```
  - The character object is callable; calling it makes that character speak.
  - `rename()` hides the name until she introduces herself.
  - A shared character factory sets `image` and `colour`: `vn.Character.new( minerva.maikki.name, tmerge({ image=..., colour=... }, params))` — [common/minerva.lua](https://raw.githubusercontent.com/naev/naev/main/dat/scripts/common/minerva.lua)
  - Flags: `mem.*` for per-mission state, `var.push/peek` for global state.
- **Localization:** gettext `_()`. `po/naev.pot` is committed (POT-Creation 2026-10-13) — [naev.pot](https://raw.githubusercontent.com/naev/naev/main/po/naev.pot)
- **Volume** (my count over naev.pot, by first `#:` reference):
  - 23,284 msgids in total.
  - 9,029 from `dat/missions`, across 247 mission files.
  - 3,098 from `dat/events`, across 179 event files.
  - About 270k words of msgid text in mission and event strings.
  - Mission folders by string count: neutral 1,777, minerva 1,670, dvaered 1,622, zalek 1,203, onion 988, pirate 497, taiomi 483, empire 425, sirius 414, tutorial 295, flf 284, shadow 218 …
  - Uncertainty: strings referenced from several files are counted once, under their first reference.
- **Story structure:** a space-trading sandbox with faction-based campaigns (Minerva, Dvaered, Za'lek, Onion Society, Empire, Sirius, FLF, Shadow, Taiomi …) unlocked through bar NPCs and conditions. The setting has a lore timeline built around "the Incident" (a comment in maikki1.lua gives "593:3726.4663 - the Incident") — [maikki1.lua](https://raw.githubusercontent.com/naev/naev/main/dat/missions/minerva/maikki1.lua)

### Inferences
- Naev's VN API is the closest analogue to what a Godot/AGM dialogue layer needs:
  - a queued **state machine** (say, menu, label, jump, func, transition, music) that is built first and then run;
  - **character objects** that bundle a display name, portrait and text colour and can be renamed mid-scene;
  - **narrator and player shorthands**;
  - **side effects** inserted as functions in the queue.
- Mission dialogue is GPL-3 code and cannot be relicensed. XML text (e.g. descriptions) is CC BY-SA 4.0, which CC declared one-way compatible with GPLv3 (Q15). Even so, reusing the text would make it copyleft. Copy only the API design.

### Gaps
- An exact first-release year for Naev was not verified from a primary source.
- The Codeberg web UI blocks automated fetches (it served a bot-trap page), so directory listings came from the GitHub mirror and the .pot.

---

## Q3. Endless Sky

### Takeaway
Every mission conversation ships in `data/**/*.txt`, and all of that text is GPL-3+. The format is prose and has **no speaker field**: speech appears as quoted lines inside narration ("Tomek says…"), with `choice`, `branch`, `label`, `goto`, `action` and `scene` for flow. So character script inclusion is **partial**: the text is there, but speakers are not machine-readable.

### Cited Findings
- **Repo:** https://github.com/endless-sky/endless-sky. Missions are in data files such as `data/human/free worlds 1 start.txt` (152 KB). Each data file carries the header "Copyright (c) 2014 by Michael Zahniser … Endless Sky is free software … GNU General Public License … version 3 … or (at your option) any later version." — [free worlds 1 start.txt](https://raw.githubusercontent.com/endless-sky/endless-sky/master/data/human/free%20worlds%201%20start.txt)
- **Year and engine:** first released 2015 (the infobox says July 22, the body says June); C++ with OpenGL; GPLv3; "over 300 contributors." The stable version has "one human campaign, one incomplete alien campaign, and many shorter mission chains" — [Wikipedia Endless Sky](https://en.wikipedia.org/wiki/Endless_Sky). Note: the alien-campaign statement may be out of date.
- **Licenses:**
  - **Code and text:** the Debian-format `copyright` file starts with `Files: *` / `Copyright: Michael Zahniser … endless-sky contributors` / `License: GPL-3+`. This covers the code and the `data/` text.
  - **Images:** mostly `CC-BY-SA-4.0`, plus CC-BY-SA-3.0, CC-BY-4.0, CC0 and public-domain entries.
  - **Sounds:** mostly `public-domain`, with a few CC-BY-SA-3.0/4.0 and CC-BY-3.0. — [copyright](https://raw.githubusercontent.com/endless-sky/endless-sky/master/copyright)
  - **README:** "The source code is available under the GPL v3 license, and all the artwork is either public domain or released under a variety of Creative Commons (and similarly permissive) licenses." — [README.md](https://raw.githubusercontent.com/endless-sky/endless-sky/master/README.md)
- **Sample** (abridged) — [free worlds 1 start.txt](https://raw.githubusercontent.com/endless-sky/endless-sky/master/data/human/free%20worlds%201%20start.txt):
  ```
  mission "Liberate Kornephoros"
      to offer
          has "Defend Sabik: done"
      on offer
          conversation
              `	You find Tomek walking among the fleet, ...`
              choice
                  `	"Yes, sir. I'll move out immediately."`
                      accept
                  `	"I wish it hadn't come to this."`
  ```
- **Syntax** — [WritingConversations wiki](https://github.com/endless-sky/endless-sky/wiki/WritingConversations):
  - Text nodes in backticks.
  - `label`, `goto`, `choice` (with `to display` / `to activate` conditions since v0.11.0), `branch <if true> [<if false>]` plus conditions.
  - `action`/`apply` for effects (log, outfit, payment, condition set/clear, event, fail).
  - `scene <image>` (≤540 px wide).
  - `name` prompt.
  - Endpoints: `accept`, `decline`, `defer`, `launch`, `flee`, `depart`, `die`, `explode`.
  - Substitutions such as `<first>`/`<last>`.
  - The page "describes no speaker attribute or portrait mechanism."
- **Localization:** none built in. No .pot was found, and the text is English-only in the data files (inferred from the format; not formally verified).
- **Story:** an open-galaxy trading and combat sandbox. The main human arc is the Free Worlds rebellion against the Republic Navy (Tomek and the militia appear in the sample), alongside alien-species storylines and many short mission chains — [Wikipedia](https://en.wikipedia.org/wiki/Endless_Sky); [data file](https://raw.githubusercontent.com/endless-sky/endless-sky/master/data/human/free%20worlds%201%20start.txt)

### Inferences
- Prose-with-quotes is very writer-friendly, but it rules out per-line portraits, voice, and auto-generated "who said what" logs. For a platformer with portraits, Endless Sky's flow keywords are worth copying, but the speaker should be a field.
- The text is GPL-3+, so reuse brings the same copyleft issue as Wesnoth.

### Gaps
- The total number of missions and conversation lines was not counted. There is no .pot, and I avoided downloading the full repo, which includes large image assets.

---

## Q4. Cataclysm: Dark Days Ahead (CDDA)

### Takeaway
NPC dialogue is fully data-driven JSON (`talk_topic`):
- The NPC line is `dynamic_line`, which can be conditional, randomized or gendered.
- Player lines are `responses[].text`, each with `condition`, `effect`, `trial` and `topic` jumps.
- `portrait_override` can set a portrait.

The whole repo (code and data) is CC BY-SA 3.0, which is not one of the CC licenses declared compatible with GPLv3.

### Cited Findings
- **Repo:** https://github.com/CleverRaven/Cataclysm-DDA. Dialogue lives in `data/json/npcs/`: 33 subfolders (e.g. refugee_center, old_guard, hells_raiders, exodii, tacoma_ranch, isherwood_farm, Lighthouse_Family, your_followers …) plus about 60 files such as `TALK_CITY_COP.json` and `NC_*.json` — [GitHub tree](https://github.com/CleverRaven/Cataclysm-DDA/tree/master/data/json/npcs) (the listing may be truncated)
- **Year:** 2013; RPG/roguelike; CC BY-SA 3.0 — [Wikipedia list](https://en.wikipedia.org/wiki/List_of_open-source_video_games). Engine: C++.
- **License:** "Cataclysm is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License." Separate notices cover the fonts (Unifont under OFL/GPL, Terminus under OFL, Roboto under Apache-2.0) and Catch (Boost) — [LICENSE.txt](https://raw.githubusercontent.com/CleverRaven/Cataclysm-DDA/master/LICENSE.txt). No separate code, text or art split was found: one license covers the whole repo.
- **Format** — [doc/JSON/NPCs.md](https://raw.githubusercontent.com/CleverRaven/Cataclysm-DDA/master/doc/JSON/NPCs.md):
  - `type: talk_topic`, `id`.
  - `dynamic_line`: a string, an array (picked at random), or a conditional object (e.g. `npc_male`, `u_has_item`, `is_day`, `math`, with `yes`/`no`).
  - `speaker_effect`, `responses[]` (`text`, `topic`, `condition`, `effect`, `trial` = NONE/LIE/PERSUADE/INTIMIDATE/CONDITION, `success`/`failure`, `opinion`).
  - `replace_built_in_responses`, `portrait_override`.
  - Name tags such as `<npc_name>` / `<u_name>`.
- **Sample** (structure) — [TALK_CITY_COP.json](https://raw.githubusercontent.com/CleverRaven/Cataclysm-DDA/master/data/json/npcs/TALK_CITY_COP.json):
  ```json
  { "type": "talk_topic", "id": "TALK_CITY_COP",
    "dynamic_line": { "compare_string": [ "yes", { "u_val": "dialogue_survivor_cop_talked_to_survivor_cop" } ],
                      "no": { "gendered_line": "STOP, Put your hands in the air! ...", "relevant_genders": [ "npc" ] },
                      "yes": "Hi there, <name_g>." },
    "responses": [ { "text": "What are you doing here?", "topic": "TALK_CITY_COP_INTRO",
                     "effect": { "u_add_var": "dialogue_survivor_cop_talked_to_survivor_cop", "value": "yes" } },
                   { "text": "<end_talking_leave>", "topic": "TALK_DONE" } ] }
  ```
- **Story structure:** a sandbox with emergent play in a post-apocalyptic world, plus faction and NPC quest lines (refugee center, Old Guard, Hell's Raiders, Exodii, etc., going by the folder names) — [GitHub tree](https://github.com/CleverRaven/Cataclysm-DDA/tree/master/data/json/npcs)

### Inferences
- **Design lessons:** a topic graph where *NPC line = node text* and *player choice = edge* with condition, effect and skill check. "Seen this already" uses player variables (`u_add_var`). Lines can vary by gender and condition, and unique strings like `<end_talking_leave>` are shared. All of this maps cleanly onto Godot Resources or JSON.
- **Reuse:** CC BY-SA 3.0 text would have to stay CC BY-SA 3.0 with attribution. CC only declared **BY-SA 4.0** one-way compatible with GPLv3 (Q15), so it can't be folded into a GPL-3 project or kept All Rights Reserved. Borrow the schema only.

### Gaps
- Total talk_topic and line counts were not measured. No .pot is committed under `lang/po/`; `ko.po` and `cataclysm-dda.pot` both returned 404.

---

## Q5. FreedroidRPG

### Takeaway
There is one Lua dialogue file per NPC (82 in act 1). Lines are spoken with explicit `Npc:says(...)` / `Tux:says(...)` calls, and a node list of player options is shown and hidden through script. A built-in "WIKI" metadata block records each NPC's personality, purpose, backstory and relationships. Everything is GPL-2.0-or-later.

### Cited Findings
- **Repo:** official development moved from GitLab to Codeberg. The commit "Switch from gitlab to codeberg." is dated 2022-11-02, and the latest commit seen is 2025-05-14 — [Codeberg freedroid-src](https://codeberg.org/freedroid/freedroid-src). The old GitLab raw URLs still serve files.
  - `./data/storyline/actX : The content data (map, quests, dialogs, bots...) related to actX` — [FILES](https://gitlab.com/freedroid/freedroid-src/-/raw/master/FILES)
  - The act-1 dialogs folder has 82 `.lua` files (Bender, DocMoore, Dixon, Spencer, Tania, Singularity, terminals …) — [Debian sources 1.0-1 listing](https://sources.debian.org/src/freedroidrpg/1.0-1/data/storyline/act1/dialogs/)
- **Year:** not precisely verified (the project grew out of Freedroid in the early 2000s; the Wikipedia page returns 404). The README says the game "can provide about 10 hours of fun" — [README](https://gitlab.com/freedroid/freedroid-src/-/raw/master/README). Engine: C plus Lua.
- **License:** README: "The game itself is licensed under GPL." The dialog file header reads "Freedroid is free software; … GNU General Public License … either version 2 of the License, or (at your option) any later version." — [Bender.lua](https://codeberg.org/freedroid/freedroid-src/raw/branch/master/data/storyline/act1/dialogs/Bender.lua); [COPYING](https://gitlab.com/freedroid/freedroid-src/-/raw/master/COPYING) (GPL-2 text)
- **Sample** (abridged) — [Bender.lua](https://codeberg.org/freedroid/freedroid-src/raw/branch/master/data/storyline/act1/dialogs/Bender.lua):
  ```lua
  --[[WIKI
  PERSONALITY = { "Friendly", "Mentally Diminished" },
  PURPOSE = "$$NAME$$ is the village idiot, strong but dumb",
  WIKI]]--
  FirstTime = function()
      Tux:says(_"Hello! I'm new here.")
      Npc:says(_"Hey, man! I'm Bender, ...")
      show("node0")
  end,
  { id = "node0",
    text = _"What's wrong? You seem to be in pretty good shape for a dead man.",
    code = function()
        Npc:says(_"Yeah. I'm the strongest man in all the world. ...")
        Npc:set_name("Bender - The strongest one")
        show("node1", "node2")
    end },
  ```
  - Other features: `EveryTime` hook, `Tux:has_met("Bender")`, `Tux:update_quest(...)`, `hide(...)`, `next("node60")`, a `NO_WAIT` flag, and `push_topic(...)`.
- **Localization:** gettext `_"..."`. The `po/` tree has `po-dialogs`, `po-data` and `po-src` — [Debian po listing](https://sources.debian.org/src/freedroidrpg/1.0-1/po/)
- **Story:** "a world destroyed by a conflict between robots and their human masters. Play as Tux in a quest to save the world … freedom of choice is everywhere" — [README](https://gitlab.com/freedroid/freedroid-src/-/raw/master/README). Structure: act-based (`data/storyline/actX`), quest-driven, with branching dialogue options.

### Inferences
- **Lessons:**
  1. Keep a per-NPC script file with "first time / every time" entry points.
  2. Use persistent option nodes that the script shows and hides, so the menu remembers progress.
  3. Store a **character bible next to the dialogue** (personality, backstory, relationships) for writers. This is very useful for a story-driven platformer.
- **Reuse:** GPL-2+ text. Copy only the structure.

### Gaps
- No separate art or music license file was examined. The exact first-release year is unconfirmed.
- No committed .pot was found, so line counts are file counts only.

---

## Q6. Flare: Empyrean Campaign

### Takeaway
NPC dialogue sits in very simple INI-style `[dialog]` blocks inside `mods/empyrean_campaign/npcs/*.txt`. Each block has `topic`, `requires_status` / `requires_not_status` / `set_status` flags and `you=` / `him=` speaker lines. The portrait and voice clips are declared in the NPC header. All Empyrean Campaign art **and data files** are CC BY-SA 3.0; the engine is GPL-3+.

### Cited Findings
- **Repos:** game data at https://github.com/flareteam/flare-game, engine at https://github.com/flareteam/flare-engine — [README](https://raw.githubusercontent.com/flareteam/flare-game/master/README.md)
- **Licenses (README):**
  - "Flare: Empyrean Campaign is Copyright ©2010-2013 Clint Bellanger. Contributors retain copyrights to their original contributions."
  - "The Flare engine is released under GPL version 3 or later."
  - "All of the art and data files for Flare: Empyrean Campaign are released under CC-BY-SA 3.0. Later versions are permitted."
  - Fonts are under OFL 1.1.
  - The content "contains depictions of violence, blood, and mild gore." — [README](https://raw.githubusercontent.com/flareteam/flare-game/master/README.md)
- **Sample** (abridged) — [npcs/florin.txt](https://raw.githubusercontent.com/flareteam/flare-game/master/mods/empyrean_campaign/npcs/florin.txt):
  ```
  name=Florin, Apothecary
  portrait=images/portraits/male02.png
  vox_intro=soundfx/npcs/male_merchant_01.ogg
  talker=true

  [dialog]
  topic=Book of the Dead
  requires_status=emp_main_init
  requires_not_status=emp_main_underworld
  you=What can you tell me about the Book of the Dead?
  him=The Book of the Dead tells of redemption for those who ...
  set_status=emp_main_info1
  ```
- **Localization:** gettext. `mods/empyrean_campaign/languages/data.pot` has 1,350 msgids. By source: items 575, npcs 206 (22 files, about 1,930 words), maps 133, enemies 116, powers 100, quests 69, books 65, cutscenes 24. The README table shows Korean (ko) 89% translated — [data.pot](https://raw.githubusercontent.com/flareteam/flare-game/master/mods/empyrean_campaign/languages/data.pot); [README](https://raw.githubusercontent.com/flareteam/flare-game/master/README.md)
- **Story:** "a single-player 2D action RPG with fast-paced action and a dark fantasy style." Quests are gated by status flags (e.g. a gravebloom-ink redemption questline in Florin's file) — [README](https://raw.githubusercontent.com/flareteam/flare-game/master/README.md); [florin.txt](https://raw.githubusercontent.com/flareteam/flare-game/master/mods/empyrean_campaign/npcs/florin.txt). Structure: linear main quest plus side quests; small volume.

### Inferences
- This is the **most directly transferable format** for a small 2D action game with a limited scripting surface like AGM:
  - a flat key/value block per topic;
  - the speaker as a key (`you`/`him`/`her`);
  - three flag operations (require, require-not, set);
  - the portrait and voice defined once per NPC.
- It is easy to parse in GDScript or to represent as a table in an AGM project.
- **Reuse:** CC BY-SA 3.0 text has the same problem as CDDA (Q15). Borrow the format only.

### Gaps
- I did not verify every key the engine supports (e.g. `her=`, voice per line). See the flare-engine wiki and documentation for the full list.

---

## Q7. Valyria Tear (and Hero of Allacrost)

### Takeaway
This open-source JRPG keeps all map dialogue in Lua map scripts using `SpriteDialogue` objects:
- `AddLine(text, sprite)` makes the speaker the actual map sprite.
- `AddLineEmote(text, sprite, "emote")` attaches an emote bubble.
- `AddLineEvent`, `AddOption` and `SetEventAtDialogueEnd` handle events and choices.

The scripts are GPLv2+, but the README explicitly **reserves the story concept**, so it "cannot be reused as is or part of it in another project without the author's consent."

### Cited Findings
- **Repo:** https://github.com/ValyriaTear/ValyriaTear. Top level includes `data/`, `po/`, `COPYING.GPL-2`, `COPYING.GPL-3`, `COPYING.CC-BY-SA-3`, `COPYING.CC-BY-3`, `COPYING.CC0` and `LICENSES.txt` — [GitHub repo page](https://github.com/ValyriaTear/ValyriaTear)
- **Licenses:**
  - README: "Copyright (C) 2012-2021 by Bertram / Copyright (C) 2004-2011 by The Allacrost Project".
  - "The source code is licensed under the *GNU GPL*."
  - "The graphics, sounds, musics and script files are licensed according to the LICENSES file."
  - "While the scripts are under the GNU GPL, the story concept is copyrighted and cannot be reused as is or part of it in another project without the author's consent." — [README.md](https://raw.githubusercontent.com/ValyriaTear/ValyriaTear/master/README.md)
  - LICENSES.txt lists `data/*.lua (including subfolders) GPLv2+ Bertram (unless indicated otherwise)`; art is mixed CC-BY-SA-3.0, CC0, GPLv2+/GPLv3 and CC-BY-3.0. It also states "The licensing of the allacrost's files is assumed to be GPLv2 or later" — [LICENSES.txt](https://raw.githubusercontent.com/ValyriaTear/ValyriaTear/master/LICENSES.txt)
- **Paths:** `data/story/ep1/<area>/<map>_script.lua`, e.g. `data/story/ep1/layna_village/layna_village_center_script.lua` (1,235 lines) — [raw](https://raw.githubusercontent.com/ValyriaTear/ValyriaTear/master/data/story/ep1/layna_village/layna_village_center_script.lua)
- **Sample** — [layna_village_center_script.lua](https://raw.githubusercontent.com/ValyriaTear/ValyriaTear/master/data/story/ep1/layna_village/layna_village_center_script.lua):
  ```lua
  dialogue = vt_map.SpriteDialogue.Create("ep1_layna_village_kalya_wants_to_be_alone");
  text = vt_system.Translate("Do you need something, Bronann?");
  dialogue:AddLineEmote(text, kalya, "interrogation");
  kalya:AddDialogueReference(dialogue);
  ```
  - Usage in this one file: AddLine 60, AddLineEmote 23, AddLineEvent 17, AddLineEventEmote 3, AddOption 1, AddOptionEvent 1.
  - Flags: `GlobalManager:GetGameEvents():DoesEventExist("story", "well_rats_beaten")`.
  - Dialogue as a cutscene step: `vt_map.DialogueEvent.Create("Kalya tells Bronann to follow her", dialogue)`.
- **Localization:** gettext. `po/` holds `ep1-valyriatear.pot` (802 msgids, about 6.7k words, POT 2019-09-22) and `ep2-valyriatear.pot` (empty, header only), plus per-language folders (de, es, fr, gd, gl, it, ja, nl_NL, pt_BR, pt_PT, ru, sv, uk_UA). The top source of strings is `layna_village_center_script.lua` (111) — [GitHub tree po](https://github.com/ValyriaTear/ValyriaTear/tree/master/po); [ep1 pot](https://raw.githubusercontent.com/ValyriaTear/ValyriaTear/master/po/ep1-valyriatear.pot)
- **Story:** Episode 1 follows Bronann, Kalya and Orlinn from Layna village through the forest to Mt. Elbrus (names from the scripts and pot). It is a linear JRPG with side quests, and Episode 2 has no strings yet — [ep1 pot](https://raw.githubusercontent.com/ValyriaTear/ValyriaTear/master/po/ep1-valyriatear.pot)

### Inferences
- **Design lessons:**
  - The **speaker is a live scene object** (sprite reference), so the engine can find the portrait and position automatically.
  - Each line carries an **emote**.
  - Dialogues have **ids** so the game can mark them as seen.
  - Dialogue doubles as a **cutscene event** that can chain other events when it ends.
  - Together these suit a platformer where NPCs are in-scene actors.
- **Reuse:** the strongest restriction among the GPL projects. Even apart from the GPL, the author reserves the story itself. Do not adapt plot or characters.
- **Hero of Allacrost:** the original project (2004–2011) survives here as Valyria Tear's GPLv2+ base. Its own repo was not examined.

### Gaps
- Hero of Allacrost's original repository and its dialogue format were not verified separately.

---

## Q8. Tales of Maj'Eyal (T-Engine4)

### Takeaway
The base ToME module ships 98 chat (dialogue) Lua files and 35 lore files, each with a GPL-3+ header:
- **Chats:** `newChat{ id=…, text=…, answers={ {text, jump=, cond=, action=} } }`. The NPC is implicit (the chat is attached to an NPC entity) and the answers are the player's lines.
- **Lore:** `newLore{ id, category, name, lore }` defines collectible lore notes.
- **Graphics:** "granted to use with the Tales of Maj'Eyal game only."

The source GitLab now requires sign-in, so the official source tarball is the only open access route.

### Cited Findings
- **Access:** `https://git.net-core.org/tome/t-engine4/-/raw/master/COPYING-MEDIA` redirects to `/users/sign_in`. The release tarball `https://te4.org/dl/t-engine/t-engine4-src-1.7.6.tar.bz2` (500 MB) is public. In it, game modules are zipped `.team` archives, e.g. `game/modules/tome-1.7.6.team` (35 MB; `-gfx.team` 306 MB and `-music.team` 144 MB are separate) — [source tarball](https://te4.org/dl/t-engine/t-engine4-src-1.7.6.tar.bz2)
- **Year and engine:** first release 2012 (development from 2009). The engine is C, with game modules in Lua. Expansions (Ashes of Urh'Rok 2014, Embers of Rage 2016, Forbidden Cults 2018) are separate products. The plot is non-linear — [Wikipedia ToME](https://en.wikipedia.org/wiki/Tales_of_Maj%27Eyal)
- **Licenses:**
  - **Code:** the top-level `COPYING` is the GPL-3 text.
  - **Graphics:** `COPYING-MEDIA` says "All the medias located in all the "/data/gfx" folders are granted to use with the Tales of Maj'Eyal game only. Please contact darkgod@te4.org for more informations."
  - **Text:** all 98 chat files and 34 of the 35 lore files carry the header "ToME - Tales of Maj'Eyal / Copyright (C) 2009 - 2019 Nicolas Casalini / … GNU General Public License … either version 3 of the License, or (at your option) any later version." (`lore/arena.lua` has no header.) — [source tarball](https://te4.org/dl/t-engine/t-engine4-src-1.7.6.tar.bz2)
  - Wikipedia: "the game's assets are licensed for use exclusively within Tales of Maj'Eyal" — [Wikipedia](https://en.wikipedia.org/wiki/Tales_of_Maj%27Eyal)
- **Sample** (from `data/chats/message-last-hope.lua` inside tome-1.7.6.team) — [source tarball](https://te4.org/dl/t-engine/t-engine4-src-1.7.6.tar.bz2):
  ```lua
  newChat{ id="welcome",
      text = _t[[Well met, @playername@. I was sent with a message from King Tolak of Last Hope. ...
  #LIGHT_GREEN#He gives you a sealed scroll and vanishes into the shadows.#LAST#]],
      answers = {
          {_t"Thank you for your courage.", action=function(npc, player) ... end},
  ```
  - Usage across all chats: `cond = function` 260, `action = function` 323, `jump=` 259.
  - Text uses inline colour tags (`#LIGHT_GREEN#`) and substitutions (`@playername@`).
- **Lore sample:**
  ```lua
  newLore{
      id = "fearscape-entry",
      category = "fearscape",
      name = _t"a fearsome sight",
      lore = _t[[...]],
  }
  ```
- **Volume:** 98 chat files (about 42k raw words, code tokens included) and 35 lore files (about 80k raw words) in base 1.7.6, excluding DLC. These are overestimates because Lua code is counted.
- **Story structure:** an open-world roguelike RPG with race and class starting zones (`data/texts/intro-*.lua`: intro-dwarf, intro-ghoul, intro-halfling …), lore collectibles by region, and a non-linear plot.

### Inferences
- **Lessons:** separate **conversational chats** (graph with cond/action/jump) from **lore documents** (collectible, categorized text), and keep a single translation wrapper (`_t`). Inline style tags for emphasis or narration inside the text body are also useful.
- **Reuse:** the text is GPL-3+ (same copyleft issue). The graphics are unusable outside ToME. Expansion content isn't in the source at all.

### Gaps
- The music license (`tome-1.7.6-music.team`) was not checked.
- How the T-Engine chat UI shows the NPC portrait was not verified from code.

---

## Q9. Warzone 2100

### Takeaway
The campaign story is told through mission briefing string tables, timed FMV subtitle files and JavaScript mission logic. **No line has a speaker field**, so character scripting is partial at best. Licensing is unusually explicit. The 2004 release notes grant "Permission … to use the name "Warzone 2100", the logos, stories, texts and related materials," and the project now has a formal GPL-3 section-7 additional-terms document (attribution plus no misrepresentation of origin). That document is a useful model next to the user's own section-7 permission.

### Cited Findings
- **Repo:** https://github.com/Warzone2100/warzone2100. Story-related paths:
  - `data/base/messages/strings/cam1strings.txt`, `cam2strings.txt`, `cam3strings.txt` (briefings);
  - `data/base/sequenceaudio/cam1|cam2|cam3/*.txa|.txt` (subtitles for briefing videos);
  - `data/base/script/campaign/cam*.js` (mission logic, e.g. `camPlayVideos({video: "FLIGHT", type: CAMP_MSG})`).
  - Sources: [cam1-1.js](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/data/base/script/campaign/cam1-1.js); [cam1strings.txt](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/data/base/messages/strings/cam1strings.txt)
- **Year:** 1999 (commercial); source released under the GPL on December 6, 2004 — [Wikipedia list](https://en.wikipedia.org/wiki/List_of_open-source_video_games); [COPYING.ORIGRELEASE](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/doc/licenses/COPYING.ORIGRELEASE). Engine: C/C++ with QuickJS mission scripts.
- **Licenses:**
  - **Whole project:** "as a whole, it is distributed under the terms of the GNU General Public License … either version 3 of the License, or (at your option) any later version." — [README.md](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/README.md)
  - **Original-release files:** GPL-2.0-or-later.
  - **Files whose header applies the WZ terms:** GPL-3+ plus section-7 terms. Files with no stated license default to GPL-2+. — [README-LICENSING.md](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/README-LICENSING.md)
  - **2004 notes:** "Everything included (source code and data), as well as the not included videos and music, is released under the terms of the GNU General Public License, version 2 or (at your option) any later version." and "4) Permission is granted to use the name "Warzone 2100", the logos, stories, texts and related materials." — [COPYING.ORIGRELEASE](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/doc/licenses/COPYING.ORIGRELEASE)
  - **Section-7 terms:** "WARZONE 2100 ADDITIONAL TERMS UNDER SECTION 7 OF THE GNU GPL VERSION 3 / Version 1.0". "These terms ask that the Warzone 2100 Project be credited, and that modified versions of the game not be mistaken for official releases." Sections: 1. Attribution (7(b)); 2. Origin and modified versions (7(c), 7(d)) — [COPYING.SECTION7](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/COPYING.SECTION7)
  - **Non-GPL art:** some backdrops/textures are CC BY-SA 3.0 or CC0, listed separately — [COPYING.NONGPL](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/COPYING.NONGPL)
- **Samples:**
  - Briefing string table:
    ```
    CAM1A_MSG1   _("ALPHA BASE MISSION: Scavenger Raiders")
    CAM1A_MSG2   _("Scavenger raiders are approaching our base.")
    ```
  - Subtitle file, with x, y, start and end seconds:
    ```
    20  20  4.04  15.96  _("Dawn, July 4th, 2100")
    ```
  - Sources: [cam1strings.txt](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/data/base/messages/strings/cam1strings.txt); [c001.txa](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/data/base/sequenceaudio/cam1/c001.txa)
- **Volume:** `po/warzone2100.pot` (POT 2026-04-04) has 3,957 msgids. Campaign briefings: cam1strings 91, cam2strings 89, cam3strings 103; about 200 FMV subtitle strings across `sequenceaudio/` — [warzone2100.pot](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/po/warzone2100.pot)
- **Story:** three linear campaigns. Opening briefing: "OBJECTIVE: Locate and recover neural synapse technology … Pre-Collapse structure … vital for the success of the Project". Antagonist factions include "The New Paradigm" — [cam1strings.txt](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/data/base/messages/strings/cam1strings.txt)

### Inferences
- **Lessons:**
  - Use **ID-keyed string tables** (stable IDs referenced from mission scripts).
  - Use **timed subtitle tracks** for cutscenes; the format has screen position plus start and end times.
- **Section-7 model:** WZ's COPYING.SECTION7 is a real example of using GPL-3 §7 for attribution and origin-marking terms. The user's repo uses §7 for an additional *permission* (linking the AGM runtime). Studying WZ's wording could help when drafting the user's own §7 text.
- **Reuse:** WZ is the most permissive here about *story reuse* (an explicit grant for "stories, texts"). The files themselves are still GPL-2+/GPL-3+, though, and the copyleft problem from Q15 still applies to any copied text.

### Gaps
- Some newer campaign scripts may show in-game messages through other APIs. I only checked .pot references, which show few campaign-JS strings (`victory.js` 11, others 1–2).

---

## Q10. A Dark Room

### Takeaway
This minimalist text narrative is written as JavaScript event objects (scenes, text arrays, buttons, and weighted `nextScene`). There is **no speaker-attributed dialogue**: everything is second-person narration. The license is MPL-2.0 (file-level copyleft).

### Cited Findings
- **Repo:** https://github.com/doublespeakgames/adarkroom. Events live in `script/events/*.js` (e.g. `outside.js`), with translations in `lang/adarkroom.pot` (805 msgids, POT 2021-11-29) — [outside.js](https://raw.githubusercontent.com/doublespeakgames/adarkroom/master/script/events/outside.js); [adarkroom.pot](https://raw.githubusercontent.com/doublespeakgames/adarkroom/master/lang/adarkroom.pot)
- **License:** LICENSE.md is "Mozilla Public License Version 2.0" — [LICENSE.md](https://raw.githubusercontent.com/doublespeakgames/adarkroom/master/LICENSE.md). Year 2013; listed as MPL for both engine and content — [Wikipedia list](https://en.wikipedia.org/wiki/List_of_open-source_video_games)
- **Sample** (abridged) — [outside.js](https://raw.githubusercontent.com/doublespeakgames/adarkroom/master/script/events/outside.js):
  ```js
  { title: _('A Ruined Trap'),
    isAvailable: function() { return Engine.activeModule == Outside && ...; },
    scenes: { 'start': { text: [ _('some of the traps have been torn apart.'), ... ],
                         buttons: { 'track': { text: _('track them'), nextScene: {0.5: 'nothing', 1: 'catch'} },
  ```
- **Structure:** an incremental game that slowly reveals a sci-fi twist: linear progression with random events.

### Inferences
- **Lesson:** random event scenes with **probabilistic transitions** (`{0.5:'a', 1:'b'}`) and availability predicates. These are useful for ambient or random encounters, not character dialogue.
- **Reuse:** MPL-2.0 is file-level copyleft; any modified MPL files would have to stay MPL. Not relevant as a character-script source.

### Gaps
- I did not check whether the MPL files carry an "Incompatible With Secondary Licenses" notice, which matters for combining with GPL.

---

## Q11. Shattered Pixel Dungeon

### Takeaway
NPC quest lines and lore are plain `key=value` strings in Java `.properties` files, keyed by class path (e.g. `actors.mobs.npcs.ghost.rat_1`). The speaker is implied by the key prefix, so this is partial. Everything is GPL-3.0. The author asks forks to change the app name.

### Cited Findings
- **Repo:** https://github.com/00-Evan/shattered-pixel-dungeon. Text lives in `core/src/main/assets/messages/actors/actors.properties` (164 `actors.mobs.npcs.*` keys: blacksmith 34, shopkeeper 19, imp 18, wandmaker 17, ratking 17, ghost 9 …) and `messages/journal/journal.properties` (133 `journal.document.*` keys of lore and guide text) — [actors.properties](https://raw.githubusercontent.com/00-Evan/shattered-pixel-dungeon/master/core/src/main/assets/messages/actors/actors.properties); [journal.properties](https://raw.githubusercontent.com/00-Evan/shattered-pixel-dungeon/master/core/src/main/assets/messages/journal/journal.properties)
- **License:** LICENSE.txt is the GNU GPL v3 text — [LICENSE.txt](https://raw.githubusercontent.com/00-Evan/shattered-pixel-dungeon/master/LICENSE.txt). Year 2014; listed as GPL-3.0-or-later — [Wikipedia list](https://en.wikipedia.org/wiki/List_of_open-source_video_games)
- **Fork guidance:**
  - "`appName` defines the user-visible name of your app. You must change this to whatever you wish to call your game."
  - "due to the GPLv3 license, any edits you make to the credits scene must avoid removing any existing credits"
  - The README notes "this repository does not accept pull requests!" Translation is on Transifex.
  - Sources: [recommended-changes.md](https://raw.githubusercontent.com/00-Evan/shattered-pixel-dungeon/master/docs/recommended-changes.md); [README](https://raw.githubusercontent.com/00-Evan/shattered-pixel-dungeon/master/README.md)
- **Sample:**
  ```
  actors.mobs.npcs.ghost.name=sad ghost
  actors.mobs.npcs.ghost.rat_2=Please... Help me... Slay the abomination...\n\n_Fight it near water... Avoid the stench..._
  ```
  Source: [actors.properties](https://raw.githubusercontent.com/00-Evan/shattered-pixel-dungeon/master/core/src/main/assets/messages/actors/actors.properties)
- **Structure:** a roguelike with fixed NPC side-quests per depth region, plus lore documents.

### Inferences
- **Lesson:** hierarchical string keys (`<category>.<npc>.<situation>_<n>`) in a single properties or CSV file make localization trivial. This matches Godot's CSV translation workflow.
- **Reuse:** GPL-3 text; the name must change. Borrow the key scheme only.

### Gaps
- No separate art or audio license statement was found; the repo-wide GPL-3 is assumed.

---

## Q12. Dungeon Crawl Stone Soup

### Takeaway
Crawl has almost no narrative dialogue. Its "character lines" are **randomized monster speech barks** in a custom text database with weights, substitution tokens and visual or verbal variants. GPL-2.0+; most tiles are CC0.

### Cited Findings
- **Repo:** https://github.com/crawl/crawl. File: `crawl-ref/source/dat/database/monspeak.txt` (745 `%%%%`-separated entries; the format is documented in `docs/develop/monster_speech.txt`) — [monspeak.txt](https://raw.githubusercontent.com/crawl/crawl/master/crawl-ref/source/dat/database/monspeak.txt)
- **License:** "Dungeon Crawl Stone Soup Copyright 1997-2025 Linley Henzell, the dev team, and the contributors … GNU General Public License … version 2 … or (at your option) any later version." "The majority of Crawl's tiles and artwork are released under the CC0 license" — [LICENSE](https://raw.githubusercontent.com/crawl/crawl/master/LICENSE). Year 2006 (the Stone Soup fork) — [Wikipedia list](https://en.wikipedia.org/wiki/List_of_open-source_video_games)
- **Sample:**
  ```
  _Sigmund_common_
  w:20
  @The_monster@ laughs darkly.
  VISUAL:@The_monster@ looks at you with fury.
  @The_monster@ says @to_foe@, "Look into my eyes."
  ```
  Source: [monspeak.txt](https://raw.githubusercontent.com/crawl/crawl/master/crawl-ref/source/dat/database/monspeak.txt)

### Inferences
- **Lesson:** a **bark system** (weighted random lines with tokens, separate from the dialogue graph) is cheap and effective for enemy or NPC flavour in an action platformer.

### Gaps
- None material for this scope.

---

## Q13. Ryzom (Ryzom Core)

### Takeaway
The code is AGPL-3. The game's world and translation text was released, in part, in the separate `ryzomcore_leveldesign` repo, described as "Licensed as both CC-BY-SA 3.0 and FAL 1.3". It includes `translation/translated/phrase_en.txt`: 8,874 phrase entries, of which 2,249 involve a "bot" (NPC) parameter, such as city-welcomer NPC answers and newbie-land missions. The project lists leveldesign as **"Demo"** status, so only part of the commercial game's quest and lore content is open.

### Cited Findings
- **Repo licenses:** "released under the terms of the GNU Affero General Public License 3.0 (GNU/AGPLv3) for the source code. The art assets are dual-licenced under the Creative Commons Attributions-ShareAlike 3.0 (CC-BY-SA) and Free Art License 1.3 (FAL 1.3)." Copyright of the original code: "(C) 2001-2022 Winch Gate Property Limited" — [ryzomcore README (core4 branch)](https://raw.githubusercontent.com/ryzom/ryzomcore/core4/README.md)
- **Asset status:** the source downloads list "Leveldesign — Demo — ryzomcore_leveldesign", with graphics "Complete" and sound "Reference". "Graphics, translations, and select leveldesign assets" are under "both the CC-BY-SA 3.0 and Free Art License 1.3" — [ryzomcore wiki](https://github.com/ryzom/ryzomcore/wiki/ms)
- **Leveldesign repo:** https://github.com/ryzom/ryzomcore_leveldesign ("Ryzom Core reference leveldesign repository … Licensed as both CC-BY-SA 3.0 and FAL 1.3")
  - Top-level dirs include `primitives` (fyros, matis, tryker, zorai, newbieland, indoors, r2, `storyline/episode_2`, `_unpublished_`) and `translation` (`diff`, `history`, `translated`, `work`).
  - `languages.txt` = `wk fr en de es ru`.
  - Sources: [repo](https://github.com/ryzom/ryzomcore_leveldesign); [primitives tree](https://github.com/ryzom/ryzomcore_leveldesign/tree/master/primitives); [translation tree](https://github.com/ryzom/ryzomcore_leveldesign/tree/master/translation)
- **Phrase format** (`#include` of topical phrase files such as `nbland_missions.txt`, `nbland_karavan.txt`, `nbland_kamis.txt`, `generic_missions_wk.txt`) — [phrase_wk.txt](https://raw.githubusercontent.com/ryzom/ryzomcore_leveldesign/master/translation/work/phrase_wk.txt):
  ```
  // HASH_VALUE 32B2D627FA8C2D3D
  AVALAE_CITY_WELCOMER_1_P_BC_ANSWER_C_1 (bot trainer_c_1)
  {
      avalae_city_welcomer_1_p_bc_answer_c_1  [$trainer_c_1$ trains the craftsmen in our city, I've put a marker on your map.]
  }
  ```
  Source: [phrase_en.txt](https://raw.githubusercontent.com/ryzom/ryzomcore_leveldesign/master/translation/translated/phrase_en.txt)
- **Volume:** phrase_en.txt is 2.3 MB, with 8,874 phrase entries and about 135k words in bracketed strings (including system messages). The client UI strings are in `en.uxt`.
- **Localization concepts:** static client text lives in `.uxt` files and dynamic server text in phrase files, and translators must keep phrase identifiers unchanged — [Ryzom localization doc](https://wiki.ryzom.dev/leveldesign/localization_system) (from search summary). Note the `HASH_VALUE` lines in the sample.
- **Year:** 2004 (MMORPG) — [Wikipedia list](https://en.wikipedia.org/wiki/List_of_open-source_video_games)
- **Story:** an MMORPG with four nations (Fyros, Matis, Tryker, Zoraï, from the primitives folder names), Kami and Karavan factions (phrase include names `nbland_kamis`, `nbland_karavan`), and episodic storyline primitives (`storyline/episode_2`). Structure: faction-based and persistent-world.

### Inferences
- **Lesson:** typed phrase signatures (`(bot giver)`, `$param$`) plus a hash-based diff workflow across languages. This is relevant if the user's game will be translated: stable ids plus a change-detection hash per source string.
- **Reuse:**
  - CC BY-SA 3.0 / FAL 1.3 text is ShareAlike, so it can't be All Rights Reserved and isn't declared GPL-compatible.
  - FAL 1.3 is copyleft as well (my inference; not verified here).
  - Speaker attribution is only indirect: an NPC is bound to a phrase through World Editor primitives.

### Gaps
- How much of the live game's quest and lore text is actually in the repo was not quantified. The `_unpublished_` and episode folders were not explored.
- FAL 1.3 compatibility was not researched.

---

## Q14. The Ur-Quan Masters (Star Control II) — added

### Takeaway
UQM publishes every alien conversation as keyed text files (one folder per race) with linked voice clips, while the branching logic stays in C. The content, explicitly including "dialogue", is **CC BY-NC-SA 2.5**, so non-commercial only. It is an excellent study object for a story-driven space game and unusable for a commercial adaptation.

### Cited Findings
- **License:** "The content -- voiceovers, dialogue, graphics, sounds, and music -- are copyright (C) 1992, 1993, 2002 Toys for Bob, Inc. or their respective creators. The content may be used freely under the terms of the Creative Commons Attribution-NonCommercial-ShareAlike 2.5 license … The content may also be copied freely as part of a distribution of The Ur-Quan Masters." Code: GPL-2.0+. Documentation: CC BY 2.0 — [UQM COPYING (SourceForge)](https://sourceforge.net/p/sc2/uqm/ci/main/tree/sc2/COPYING?format=raw). The Ubuntu packaging copyright says the same — [Launchpad uqm-content copyright](https://launchpad.net/ubuntu/xenial/+source/uqm-content/+copyright)
- **Year:** first release 2002; content license CC BY-NC-SA 2.5 — [Wikipedia list](https://en.wikipedia.org/wiki/List_of_open-source_video_games)
- **Sample** (`sc2/content/base/comm/arilou/arilou.txt`, 97 keyed blocks) — [arilou.txt](https://sourceforge.net/p/sc2/uqm/ci/main/tree/sc2/content/base/comm/arilou/arilou.txt?format=raw):
  ```
  #(INIT_HELLO)	arilou-000.ogg
  Hello my little one. I am so pleased to see you!

  #(confused_by_hello)
  You sound as if you know me. Have we met?
  ```
  - Uppercase keys with an .ogg are alien lines with voice.
  - Lowercase keys are player responses.
  - The speaker is implicit by file (one race per file).

### Inferences
- **Lesson:** keep the **text and voice keyed by ID in a per-speaker file** and the logic in code. Voice actors and translators then work from one file per character.
- **Reuse:** NonCommercial blocks any commercial use. Study it only.

### Gaps
- The number of comm files and total lines was not counted (the SourceForge tree view is JS-rendered).

---

## Q15. Cross-cutting: can any of this text be reused in the user's GPL-3.0 + AGM-exception (section 7) repo with All Rights Reserved original content?

### Takeaway
In practice, no story text from these projects should be copied into the user's game:
- **GPL texts** (Wesnoth, Naev Lua, Endless Sky, FreedroidRPG, ToME, Warzone, SPD, DCSS) would become GPL parts of the work. They could not be All Rights Reserved, and the user cannot extend the AGM linking permission to other people's GPL material.
- **CC BY-SA 3.0 texts** (CDDA, Flare, Ryzom) stay ShareAlike and are not declared GPL-compatible.
- **UQM** is NonCommercial.
- **Valyria Tear** reserves its story.
- **ToME graphics** are game-only.

What can be borrowed safely is the **format, schema and API design**, plus general structural ideas.

### Cited Findings
- **Exceptions to other people's code:** "Only the copyright holders for the program can legally release their software under these terms." For GPL code by others, "You have to get the approval of the copyright holders of those programs." — [GNU GPL FAQ #GPLIncompatibleLibs](https://www.gnu.org/licenses/gpl-faq.html#GPLIncompatibleLibs)
- **Non-software works:** "You can apply the GPL to any kind of work, as long as it is clear what constitutes the 'source code' for the work." — [GPL FAQ #GPLOtherThanSoftware](https://www.gnu.org/licenses/gpl-faq.html#GPLOtherThanSoftware)
- **Program output:** output is generally not covered by the program's copyright, *except* when the program displays substantial text or art from itself, as in video games — [GPL FAQ #WhatCaseIsOutputGPL](https://www.gnu.org/licenses/gpl-faq.html#WhatCaseIsOutputGPL)
- **CC BY-SA and GPLv3:** "we have added a declaration of one-way compatibility from CC BY-SA 4.0 to GPLv3" (8 Oct 2015). The compatibility mechanism existed in BY-SA 3.0 but "it has yet to be used for that license." — [Creative Commons](https://creativecommons.org/2015/10/08/cc-by-sa-4-0-now-one-way-compatible-with-gplv3/)
- **Project-specific restrictions:**
  - Valyria Tear story concept: "cannot be reused as is or part of it in another project without the author's consent" — [README](https://raw.githubusercontent.com/ValyriaTear/ValyriaTear/master/README.md)
  - ToME gfx: "granted to use with the Tales of Maj'Eyal game only" — [ToME source tarball COPYING-MEDIA](https://te4.org/dl/t-engine/t-engine4-src-1.7.6.tar.bz2)
  - UQM: content is CC BY-NC-SA 2.5 — [UQM COPYING](https://sourceforge.net/p/sc2/uqm/ci/main/tree/sc2/COPYING?format=raw)
  - SPD: forks must change `appName` — [recommended-changes.md](https://raw.githubusercontent.com/00-Evan/shattered-pixel-dungeon/master/docs/recommended-changes.md)
  - WZ: name, stories and texts may be used (2004 grant), but newer files carry section-7 attribution and origin terms — [COPYING.ORIGRELEASE](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/doc/licenses/COPYING.ORIGRELEASE); [COPYING.SECTION7](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/COPYING.SECTION7)
- **Text licenses by family:**
  - **GPL-family (copyleft, could be incorporated only as GPL):** Wesnoth (GPL-2+), Naev missions (GPL-3), Endless Sky (GPL-3+), FreedroidRPG (GPL-2+), ToME chats and lore (GPL-3+), Warzone (GPL-2+/3+), SPD (GPL-3), DCSS (GPL-2+), Valyria Tear scripts (GPLv2+, story reserved). See each section's sources.
  - **CC BY-SA 3.0 (not declared GPL-compatible):** CDDA (whole repo), Flare (data files), Ryzom leveldesign (also FAL 1.3).
  - **CC BY-SA 4.0+ (one-way into GPLv3):** Naev's non-code files (e.g. XML), Wesnoth's newer art.

### Inferences (not legal advice)
- **Why GPL text is a problem here:**
  - If GPL text from these games were shipped inside the user's game, the dialogue data would arguably be part of the covered work, since it is displayed as the game's own content.
  - It would then be GPL, conflicting with the plan to keep original content All Rights Reserved.
  - The user's section-7 permission for the proprietary AGM runtime would not cover that third-party material unless its authors agreed.
- **Simplest compliant strategy:** write all story and dialogue text originally, and reuse only file formats, tag names, schema ideas and API patterns.
  - Formats and ideas are not protected the way specific expressive text is (general copyright principle; not sourced here).
  - Avoid copying distinctive names, characters, settings and plot. Valyria Tear asks for this explicitly.
- **If a copyleft text is ever used for testing** (e.g. a sample dialogue for engine QA), keep it out of release builds, or keep it clearly separated with its own license file and attribution.
- **CC BY-SA 4.0 material** can flow into GPLv3. It still becomes GPL, not All Rights Reserved.
- **WZ's COPYING.SECTION7** shows a well-drafted GPL-3 §7 document (versioning, SPDX identifiers, the scope of "this material"). It could inform how the user words the AGM-runtime additional permission (e.g. naming it, versioning it, stating which files it applies to).

### Gaps
- No lawyer-reviewed source on whether runtime-loaded dialogue data counts as part of the GPL "Program". The FSF FAQ only addresses program output and data in general terms.
- Trademark policies (Wesnoth, Endless Sky, Naev, Flare) were not checked.
- FAL 1.3 compatibility was not researched.

---

## Q16. Cross-cutting: design lessons for a dialogue / character-script system in Godot 4.x / ACTION GAME MAKER

### Takeaway
Across these games, every robust system separates the following:
- (a) a **character registry**: id → display name, default portrait, colour, voice;
- (b) **lines** that reference a speaker id, with optional per-line overrides (portrait or expression, name, emote, voice clip);
- (c) **flow**: labels and jumps, choices, conditions, effects;
- (d) **persistent flags and quest state**;
- (e) **translatable strings** with translator context.

The formats range from a minimal key/value file (Flare) up to a full queued VN API (Naev). A Godot/AGM implementation can sit in the middle.

### Cited Findings (patterns, each with its origin)
- **Speaker id with overrides** — Wesnoth `speaker`, `caption`, `image`, `image_pos`, `mirror`, `voice`, `[show_if]`, `[option][command]` — [InterfaceActionsWML](https://wiki.wesnoth.org/InterfaceActionsWML)
- **Translator context carrying the speaker** — Wesnoth .pot `#. [message]: speaker=Delfador` — [wesnoth-httt.pot](https://raw.githubusercontent.com/wesnoth/wesnoth/master/po/wesnoth-httt/wesnoth-httt.pot)
- **Character objects with portrait, colour and rename; narrator and player shorthands; queued commands** (say, menu, label, jump, func, transition, music, sfx) — Naev `vn.lua` — [vn.lua](https://raw.githubusercontent.com/naev/naev/main/dat/scripts/vn/vn.lua); [maikki1.lua](https://raw.githubusercontent.com/naev/naev/main/dat/missions/minerva/maikki1.lua)
- **Mission metadata header for availability** (`<cond>`, `<requires>`, `<campaign>`) — Naev — [maikki1.lua](https://raw.githubusercontent.com/naev/naev/main/dat/missions/minerva/maikki1.lua)
- **Conditional and gendered NPC lines; player responses with condition, effect and skill-trial; variables for "already talked"; portrait override** — CDDA — [NPCs.md](https://raw.githubusercontent.com/CleverRaven/Cataclysm-DDA/master/doc/JSON/NPCs.md)
- **FirstTime/EveryTime hooks, show/hide option nodes, and a per-NPC character bible block** — FreedroidRPG — [Bender.lua](https://codeberg.org/freedroid/freedroid-src/raw/branch/master/data/storyline/act1/dialogs/Bender.lua)
- **Minimal topic blocks with `requires_status` / `requires_not_status` / `set_status`, `you=` / `him=` speaker keys, and portrait and voice in the NPC header** — Flare — [florin.txt](https://raw.githubusercontent.com/flareteam/flare-game/master/mods/empyrean_campaign/npcs/florin.txt)
- **Speaker = in-scene sprite; per-line emote; dialogue as a cutscene event; dialogue ids** — Valyria Tear — [layna_village_center_script.lua](https://raw.githubusercontent.com/ValyriaTear/ValyriaTear/master/data/story/ep1/layna_village/layna_village_center_script.lua)
- **Chats (graph) vs lore (collectible documents); inline style tags** — ToME — [source tarball](https://te4.org/dl/t-engine/t-engine4-src-1.7.6.tar.bz2)
- **Prose conversations with choice, branch and endpoints, but no speaker field** (a counter-example) — Endless Sky — [WritingConversations](https://github.com/endless-sky/endless-sky/wiki/WritingConversations)
- **ID-keyed string tables and timed subtitles** — Warzone 2100 — [cam1strings.txt](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/data/base/messages/strings/cam1strings.txt); [c001.txa](https://raw.githubusercontent.com/Warzone2100/warzone2100/master/data/base/sequenceaudio/cam1/c001.txa)
- **Weighted random barks with tokens** — DCSS — [monspeak.txt](https://raw.githubusercontent.com/crawl/crawl/master/crawl-ref/source/dat/database/monspeak.txt)
- **Probabilistic scene transitions** — A Dark Room — [outside.js](https://raw.githubusercontent.com/doublespeakgames/adarkroom/master/script/events/outside.js)
- **Hierarchical properties keys** — SPD — [actors.properties](https://raw.githubusercontent.com/00-Evan/shattered-pixel-dungeon/master/core/src/main/assets/messages/actors/actors.properties)
- **Hash-tracked phrases with typed parameters for translation diffing** — Ryzom — [phrase_en.txt](https://raw.githubusercontent.com/ryzom/ryzomcore_leveldesign/master/translation/translated/phrase_en.txt)
- **One file per speaker with keyed text plus voice file; logic in code** — UQM — [arilou.txt](https://sourceforge.net/p/sc2/uqm/ci/main/tree/sc2/content/base/comm/arilou/arilou.txt?format=raw)

### Inferences (recommendations for the user's project)
1. **Data model (Godot Resources or JSON/CSV):**
   - `Character {id, display_name_key, default_portrait, portraits{expression→texture}, name_color, voice_bank, bio(personality/backstory/relationships)}`. The bio follows FreedroidRPG's WIKI block.
   - `Line {speaker_id | "narrator" | "player", text_key, expression?, name_override?, portrait_side?, voice?, emote?, condition?, effects[]}`.
   - `Choice {text_key, condition?, effects[], goto}`.
   - `Dialogue {id, once?, lines/choices/labels}`.
   - `Trigger/Availability {requires_flags[], forbids_flags[], sets_flags[]}`. This is Flare's three operations, which are enough for most platformer NPCs.
2. **Authoring format:**
   - Small NPC talk: a Flare-like flat format, or a spreadsheet (CSV) with columns `dialogue_id, seq, speaker, expression, text_key, condition, effect, goto`.
   - Cutscenes: a Naev-like queued command list (say, choice, label, jump, call, transition, music, wait).
3. **Localization:**
   - Use stable keys (WZ, SPD) rather than English-as-key if text will be revised often.
   - If using gettext/PO, pass the speaker and a translator note into extraction, the way Wesnoth's .pot does.
   - Optionally keep a source-text hash per key to flag stale translations (Ryzom).
   - Godot 4 supports CSV and PO translation natively. Verify AGM's exposure of `tr()`; it was not checked here.
4. **Separate channels:**
   - dialogue (blocking, portrait UI);
   - barks (non-blocking, weighted random; DCSS);
   - lore collectibles (ToME, SPD journal);
   - subtitles for cutscenes (WZ timing columns).
5. **Persistence:** "has met", "dialogue seen" (Valyria Tear ids, CDDA `u_add_var`) and quest flags should live in one save-game dictionary.
6. **Licensing hygiene:** keep the dialogue files in a clearly marked content directory under the user's All Rights Reserved notice, separate from GPL-3 code. Document any third-party format inspiration in credits, though this is not legally required for formats.

### Gaps
- How ACTION GAME MAKER exposes custom data files, GDScript and translations to game logic was not researched here. It needs a separate check against the AGM documentation.
- Godot plugins (Dialogic, Dialogue Manager, Yarn Spinner for Godot) were out of scope for this note.
- Other open strategy or RPG candidates with campaign dialogue were not verified and might be worth a follow-up:
  - Hedgewars: Lua campaign missions with in-game speech.
  - The Mana World: NPC scripts in its server data.
  - Wyrmsun.

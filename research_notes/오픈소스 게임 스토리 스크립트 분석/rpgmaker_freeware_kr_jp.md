# RPG Maker(쯔꾸르/ツクール) 대사 데이터 구조, 오픈 라이선스 RPG Maker 프로젝트, 고전 프리웨어 어드벤처, 한국/일본 오픈소스 스토리 게임: 캐릭터 대사 스크립트 포함 여부와 이용 조건

Research date: 2026-11-17. Scope: what each work actually releases (code/text/art/audio), whether character dialogue scripts are included, how they are encoded, and whether they can be reused in a commercial GPL-3.0 (+section-7 exception) repo whose original content is All Rights Reserved.
Method note: All sources were read through public web pages or raw-file URLs with WebFetch/WebSearch. Nothing was cloned or downloaded. Some citations come from search-result summaries rather than full page reads; these are marked "(search snippet)". No text from commercial games was extracted. Any sample marked "schematic" was built from engine type definitions and is not copied from a game.

---

## Q1. How RPG Maker stores dialogue (MV/MZ JSON event commands; 2000/2003 LCF), and which tools extract it

### Takeaway
RPG Maker dialogue is not a separate script file. It is stored as event-command lists inside the project's data files. In MV/MZ, a Show Text block is command 101 (face file, face index, background, position, and in MZ a speaker name) followed by one 401 command per line of text. Choices use 102/402/403/404. Story flags are switch (121) and variable (122) commands, tested with Conditional Branch (111). RPG Maker 2000/2003 keeps the same idea in binary LCF files (.lmu/.ldb/.lmt), which EasyRPG's MIT-licensed liblcf can convert to XML. So "does this game include a script?" really means "does it ship an unencrypted data/ folder (MV/MZ) or .lmu/.ldb files (2000/2003), and does the license let you read and reuse them?"

### Cited Findings
**MV (corescript 1.x, JavaScript)**
- In `Game_Interpreter.command101` (Show Text), `params[0]`/`params[1]` go to `$gameMessage.setFaceImage(...)`, `params[2]` to `setBackground`, and `params[3]` to `setPositionType`. The function then loops `while (this.nextEventCode() === 401)` and calls `$gameMessage.add(this.currentCommand().parameters[0])`, so each 401 holds one line of text. If a 102 Show Choices immediately follows, it is consumed in the same step via `setupChoices`. — [rpgtkoolmv/corescript Game_Interpreter.js (raw)](https://raw.githubusercontent.com/rpgtkoolmv/corescript/master/js/rpg_objects/Game_Interpreter.js)
- MV `setupChoices(params)`: `choices = params[0].clone()`, `cancelType = params[1]`, `defaultType = params[2]`, `positionType = params[3]`, `background = params[4]`. The selected index is stored in `this._branch[this._indent]`. `command402` (When [**]) skips its branch if `this._branch[this._indent] !== this._params[0]`. `command403` handles When Cancel. — [same file](https://raw.githubusercontent.com/rpgtkoolmv/corescript/master/js/rpg_objects/Game_Interpreter.js)
- MV `command121` (Control Switches) sets switches `params[0]..params[1]` to ON when `params[2] === 0`. `command122` (Control Variables) chooses its operand by `params[3]`: 0 = Constant, 1 = Variable, 2 = Random, 3 = Game Data, 4 = Script (`eval`). — [same file](https://raw.githubusercontent.com/rpgtkoolmv/corescript/master/js/rpg_objects/Game_Interpreter.js)
- The MV community corescript repo is MIT-licensed. The fetched file has no license header. — [search snippet summarizing rpgtkoolmv/corescript](https://github.com/rpgtkoolmv/corescript)

**MZ (rmmz_objects.js v1.1.0 mirror)**
- MZ `command101(params)` adds the speaker field: `$gameMessage.setFaceImage(params[0], params[1]); setBackground(params[2]); setPositionType(params[3]); setSpeakerName(params[4]);` In MZ, `setupChoices` uses `cancelType = params[1] < choices.length ? params[1] : -2`. — [stak/rmmz-corescript rmmz_objects.js (raw, header "rmmz_objects.js v1.1.0")](https://raw.githubusercontent.com/stak/rmmz-corescript/master/rmmz_objects.js)
- The `rmmz-types` TypeScript definitions match: generic command `{ code, parameters }` plus `indent`; `101: [Face Name, Face Index, background, position, Talker Name]`; `401: [Text]`; `102: [Choices[], Cancel Type, Default Type, position, background]`; `402: [number]` (When [**]); `403` (When Cancel); `121: [SwitchID, SwitchID, 0|1]`; `122: [VariableID, VariableID, operation, operand…]`; `111` Conditional Branch, for example `[0, SwitchID, 0|1]` for a switch test; `108/408` comments; `357` MZ plugin command `[pluginFile, commandName, _, args]`. — [rmmz-types commands.d.ts (jsDelivr)](https://cdn.jsdelivr.net/npm/rmmz-types@1.5.0-3/lib/data/commands.d.ts)

**2000/2003 (binary LCF)**
- EasyRPG liblcf "is Free/Libre Open Source Software, released under the MIT License." It reads and writes RPG Maker 2000/2003 data. Its tool `lcf2xml` converts "RPG Maker 2000 and 2003 data format (LMU, LMT, LDB, LSD, ...)" to XML and back, and `lcfstrings` extracts text and filenames from LMU/LMT/LDB/LSD. — [EasyRPG/liblcf](https://github.com/EasyRPG/liblcf)

**Extraction/translation tools (for format study only, not for extracting commercial games)**
- Translator++ (Dreamsavior) says it "can handle RPG Maker XP, VX, VX Ace, MV and Wolf RPG Editor engine." The page I read is an old one. It states no license or price and links to a Terms of Service page and Patreon. — [dreamsavior.net Translator++](https://dreamsavior.net/translator-plusplus/)
- Dreamsavior's Patreon posts show patron-gated features, for example "CT2 Sugoi Translator is currently only available for $10+ active patrons". This is a Patreon-funded proprietary/freeware model, and no open-source license was found. — [Patreon post (search snippet)](https://www.patreon.com/posts/64570423)
- RPG Maker's built-in encryption is weak: a third-party tool vendor notes that free one-click decrypters exist. Technical decryptability does not give anyone legal permission to reuse the content. — [Encrypterator 3000 page (search snippet)](https://arthran2.itch.io/encrypterator-3000)

**Schematic MV/MZ event-list structure (built from the definitions above, not copied from any game)**
```json
[
 {"code":101,"indent":0,"parameters":["<faceFile>",3,0,2,"<SpeakerName>"]},
 {"code":401,"indent":0,"parameters":["<line 1>"]},
 {"code":401,"indent":0,"parameters":["<line 2>"]},
 {"code":102,"indent":0,"parameters":[["<choice A>","<choice B>"],1,0,2,0]},
 {"code":402,"indent":0,"parameters":[0]},
 {"code":121,"indent":1,"parameters":[5,5,0]},
 {"code":403,"indent":0,"parameters":[]}
]
```

### Inferences
- Where the text lives in MV/MZ (standard corescript layout; I did not re-fetch the DataManager source this session): `data/Map###.json` → `events[].pages[].list[]` holds map/NPC dialogue; `data/CommonEvents.json` → `[i].list[]` holds reusable cutscenes; `data/Troops.json` → `pages[].list[]` holds battle dialogue. Names and descriptions in `Actors.json`/`Items.json` etc. are flavor text, not dialogue.
- Speaker, face, and expression encoding: in MV the speaker is not a field. Authors put the name in the first 401 line or use `\N[n]` escape codes, or a plugin. In MZ it is `params[4]`. An "expression" is not an enum. It is a face-sheet file plus an index (`params[0]` + `params[1]`), so changing expression means changing the index or file. Branch structure comes from `indent` and the 402/403 pairs.
- For an AGM G platformer, the MZ 101/401/102 model maps cleanly onto a dialogue resource of the form {speaker, face/expression, lines[], choices[] → flag writes}. Copying this data model is fine. Copying another game's text is the part that needs a license.
- Dialogue in RPG Maker is interleaved with logic (switches, variables, moves, waits). A "script inclusion" check should therefore look at whether 101/401 text and the 111/121/122 flag logic can be read, not only whether some text exists.

### Gaps
- The 2000/2003 command code numbers (e.g., ShowMessage and its continuation line codes in LCF) were not verified this session. Read EasyRPG Player/liblcf sources for exact codes.
- Command 404 (Choice End) appears in neither the MV interpreter (no handler) nor the fetched rmmz-types excerpt. Its existence as a terminator comes from editor knowledge and is unverified here.
- The full Translator++ ToS/license text was not retrieved, so whether it is "freeware" or "proprietary paid" is not confirmed. No open-source RPG Maker MV/MZ text extractor was license-checked.

---

## Q2. Are there RPG Maker games released under open licenses with project files? What do the official sample-game terms say?

### Takeaway
Open-licensed RPG Maker story games with editable project data are effectively nonexistent among well-known titles. I found no CC BY / CC BY-SA / GPL / MIT RPG Maker story game with a full project. The closest verified item is EasyRPG TestGame (GPL-3.0, RPG Maker 2000/2003 format, CC0/CC-BY assets), but it is a set of engine test rooms, not a story. Official GGG/KADOKAWA terms treat bundled sample games as licensed "materials". They prohibit extracting and distributing materials, and they explicitly ban reuse of materials from specific sample games. So official samples cannot be relicensed into a GPL repo.

### Cited Findings
**EasyRPG TestGame** (2000/2003/EasyRPG/Maniac/PowerMode2003 variants)
- The repository is listed as GPL-3.0. README: "EasyRPG TestGame is free software. See the file COPYING for copying conditions." Content: "The test suites consist of collections of test rooms in each map." — [EasyRPG/TestGame](https://github.com/EasyRPG/TestGame)
- It is a "game test suite made with RPG Maker 2000", and editing it needs a copy of RPG Maker 2000. — [Flathub EasyRPG Player page (search snippet)](https://flathub.org/de/apps/org.easyrpg.player)
- Asset licenses per AUTHORS.md: FaceSets `Actor1/Actor2/People1/People2.png` by "Garakuta [CC0]"; ChipSets by "JasonPerry [CC0]"; many CharSets by "VictorSena [CC-BY]" and "Marina Navarro Travesset(base) [CC-BY]"; most music by "Juan Manuel Nigretti [CC-BY]"; some "[OGA-BY]" items. License links are CC0 1.0 and CC BY 4.0. — [TestGame AUTHORS.md (raw)](https://raw.githubusercontent.com/EasyRPG/TestGame/master/AUTHORS.md)

**Official sample games and materials (GGG / RPG Maker terms, current version)**
- Scope: GGG Products Terms Art. 1(2) covers "materials which means game assets and sample games installed at the same time." Art. 1(1): "These Terms shall apply only to personal usage (including commercial usage)." Corporate business use needs a separate agreement. — [GGG Terms (rpgmakerofficial.com/en/?p=1248)](https://rpgmakerofficial.com/en/?p=1248)
- Distribution Terms Art. 2(D) prohibits "extracting and Distribution, etc., of Our Program or Our Material from the User Software." Material Terms Art. 2: "it is not permitted to use the modified materials commercially independent of the User Software." Products Terms Art. 7(2)(B) prohibits creating derivative software, except as the Supplementary Provisions allow. — [same](https://rpgmakerofficial.com/en/?p=1248)
- Material Terms Art. 1 allows authorized purchasers to use "Our Material" "for their programs other than the GGG Products and works created with gaming tools from other companies." — [same](https://rpgmakerofficial.com/en/?p=1248)
- Sample-game blacklist: "The materials and collections of materials included in the sample games listed below shall not be used in the User Software." It is always prohibited for *Hituji no umi* (MV), several XP samples, *Eternal Hermit* ep. 1–6 (2003), and *Hanayome no Kanmuri* (2000). It is prohibited for paid distribution for DUNGEON OF NAZARICK and LA-MULANA2 SAMPLE (Pixel Game Maker MV). — [same](https://rpgmakerofficial.com/en/?p=1248)
- Terms dates: GGG Products Terms effective 2023-04-27, updated 2024-10-08, 2025-06-08, 2026-06-22. Material Terms updated 2023-05-19 and 2026-06-22. — [same](https://rpgmakerofficial.com/en/?p=1248)
- An official forum answer says the RPG Maker Terms apply only to files without their own license, and that demo projects count as "games". — [GGG guild forum (search snippet)](https://guild.rpgmakerofficial.com/t/topic/2049?tl=en)

**Other candidates checked (no open license found)**
- VisuStella MZ Sample Game Project: free/name-your-price starter project with sample maps by Liberty and Deckiller. The page gives no license for maps, events, or text. — [visustella.itch.io/visumz-sample](https://visustella.itch.io/visumz-sample). One user reports that its Fantasy Tiles need a special license for commercial use. — [itch.io post (search snippet)](https://itch.io/post/8662090)
- itch.io has CC BY-SA 4.0 and CC BY 4.0 tag pages for RPG Maker content. The results are asset packs (slimes, icons), not story games with project data. — [itch.io CC BY-SA RPG Maker assets](https://itch.io/game-assets/assets-cc4-by-sa/tag-rpgmaker)
- Searches for "CC BY-SA RPG Maker game project files" returned only plugins (mostly MIT), editors, and non-RPG-Maker CC games such as DRL (GPL-2.0+ code, CC BY-SA 4.0 assets, FreePascal). — [DRL (Wikipedia)](https://en.wikipedia.org/wiki/DRL_(video_game))
- A Yume Nikki fangame template for RPG Maker 2003 exists. Its license was not checked. — [clockworkprince.itch.io/ynfg-template](https://clockworkprince.itch.io/ynfg-template)

### Inferences
- "Few or none exist" is the honest answer for story-bearing RPG Maker projects under OSI or CC licenses. The structural reason is that most RPG Maker games use RTP/DLC materials, which may not be extracted or distributed outside the game. An open project would have to swap every RTP asset for CC0/CC-BY assets, as EasyRPG TestGame did.
- EasyRPG TestGame is GPL-3.0 and therefore compatible with the user's repo license. Its CC-BY assets need attribution. It is useful only as a legal, inspectable example of event-command structure (open it with liblcf `lcf2xml`), not as story material.
- GGG Material Terms Art. 1 (use with other companies' tools for authorized purchasers) matters for AGM G, which itself imports MV/MZ-format sheets. Distributing RTP files inside a public GPL repo still falls under the extraction/distribution prohibition (Art. 2(D)).

### Gaps
- The MZ bundled sample games are not on the blacklist as summarized, but I did not confirm whether their scenario text, as opposed to their art/audio "materials", may be reused. Check the full Japanese terms page and the MZ sample readme.
- "LibreRPG" was searched for indirectly and nothing was found.
- I did not check the COPYING file's exact wording, or whether TestGame's text strings fall under GPL or another license.

---

## Q3. Japanese freeware fan-work guidelines (Yume Nikki, Ib, The Witch's House, Ao Oni): permission scope vs. open licensing

### Takeaway
These famous RPG Maker freeware horror games publish author guidelines (ガイドライン), not open licenses. The guidelines allow certain fan works (art, fiction, videos with conditions) and explicitly forbid fangames, modification, and reuse of game images and music. None allows reuse of scripts or dialogue. Ib bans fangames outright, and The Witch's House bans alternate endings. They can be studied and analyzed, but their text cannot be reused.

### Cited Findings
- **Ib (kouri, 2012, RPG Maker 2000):** The rules page is http://kouri.kuchinawa.com/rule.html, and remake guidelines are at playism.com/game/ib/. Per vgperson's translated summary: "Most fanworks are allowed, but creating fangames is not (sequels, offshoots, usage of the characters in general)." "modification of the original game is not allowed (beyond the purposes of translation)." "Do not modify, misappropriate, or redistribute any images or music from the game." Profit from videos of the free version is forbidden. — [vgperson: Ib](https://www.vgperson.com/games/ib.htm)
- Ib guideline enforcement and history: first posted in April 2012 and later expanded; cease-and-desist letters are threatened for violations. — [search summary of vgperson/wiki sources](https://www.vgperson.com/games/ib.htm)
- **The Witch's House / 魔女の家 (Fummy, 2012, RPG Maker VX):** "Fanworks are allowed if they keep the tone of the game intact, and do not make alternate endings/etc. to the original work." "The rules for the free version forbid profiting from the game itself in any way, including ad revenue." The MV version has separate guidelines. The rules pages are http://majonoie.karou.jp/guideline.html and /mv/mv_guideline.html. — [vgperson: The Witch's House](https://www.vgperson.com/games/witchhouse.htm)
- Witch's House engine and creator: "freeware puzzle-oriented horror game by … Fummy (ふみー), created using … RPG Maker VX." — [The Witch's House (Wikipedia mirror, search snippet)](https://en.wikipedia.org/wiki/The_Witch's_House)
- Witch's House conflict: Namu Wiki (Korean) says crossovers and parallel settings are prohibited, as is reinterpreting or modifying the ending or main story. A DeviantArt user claims the FAQ does not mention crossovers. — [namu.wiki 마녀의 집 (search snippet)](https://en.namu.wiki/w/%EB%A7%88%EB%85%80%EC%9D%98%20%EC%A7%91); [DeviantArt (search snippet)](https://www.deviantart.com/griffonmender/art/The-Witch-s-House-and-crossovers-Read-Desc-633119011)
- The official Witch's House guideline page renders as mojibake (Shift_JIS) through the fetch tool. Visible structure: permitted fan works, prohibited items, restrictions on game images/text/assets, a clause allowing changes, and a latest revision that appears to be **2019.3.22** (tentative). — [majonoie.karou.jp/guideline.html](http://majonoie.karou.jp/guideline.html)
- **Yume Nikki (Kikiyama, 2004, RPG Maker 2003):** No official guideline was found this session. Community norms come from the Dream Diary Jam, which advises against using or recoloring Yume Nikki assets beyond Madotsuki's sprite as a base. — [itch.io Dream Diary Jam](https://itch.io/jam/dream-diary-jam-3)
- **Ao Oni (noprops, RPG Maker XP):** No official guideline text was found. The only confirmed detail is that noprops is the series author and supervised media-mix works. — [pixiv 百科 noprops (search snippet)](https://dic.pixiv.net/a/noprops)

### Inferences
- Guideline ≠ license. A guideline is a unilateral, revocable statement of tolerance. It grants no copyright license to the text, and every case above excludes fangames, modification, or asset reuse. For the user's GPL repo with All Rights Reserved original content: reproducing any dialogue lines is not OK; describing structure and themes in a research note is OK.
- Useful material for analysis without copying (no source needed for the method): story structure types (Ib: gallery-escape with relationship-dependent multiple endings; Witch's House: single-route puzzle horror with a twist ending; Yume Nikki: non-verbal exploration with almost no dialogue). These premises are well known but were not re-verified this session.

### Gaps
- No primary-source text was read for Yume Nikki (Kikiyama/Playism) or Ao Oni (noprops) guidelines. The Ib and Witch's House rules come from an English translator's summary (vgperson), not the Japanese originals; the original Witch's House page was unreadable because of encoding.

---

## Q4. Classic freeware adventures released via ScummVM: exact data licenses and whether dialogue/source was released

### Takeaway
Beneath a Steel Sky, Lure of the Temptress, Flight of the Amazon Queen, and Drascula share a "freeware + modification allowed" license: free redistribution, modification allowed with a "modified" notice, and no fee for the game itself. Dreamweb's freeware license has no modification clause. Soltys was made freeware by authorization to ScummVM, and its exact license text was not found. None of these licenses is open in the CC/OSI sense, because selling the game is forbidden. Dialogue lives inside the original binary data files, not in readable script files, and the copyright stays with the original companies. They are fine to study and are not reusable in a commercial game.

### Cited Findings
- **Beneath a Steel Sky (Revolution, 1994):** "You may distribute this game for free on any medium, provided this readme and all associated copyright notices and disclaimers are left intact." "You may not charge a fee for the game itself. This includes reselling the game as an individual item." "You may modify the game as you wish. You may also distribute modified versions … with the additional requirement that the work is marked with a prominent notice which states that it is a modified version." "All game content is (C) Revolution Software Ltd." — [Debian beneath-a-steel-sky copyright](https://metadata.ftp-master.debian.org/changelogs/main/b/beneath-a-steel-sky/stable_copyright)
- **Lure of the Temptress (Revolution, 1992) and Flight of the Amazon Queen:** Debian notes that "All three games share the same license" (Lure, BASS, FOTAQ): free distribution, a reasonable copying fee only, no fee for the game, modification allowed if marked. — [Debian lure-of-the-temptress copyright](https://metadata.ftp-master.debian.org/changelogs/main/l/lure-of-the-temptress/stable_copyright)
- **Drascula: The Vampire Strikes Back (Alcachofa Soft, 1996):** "Copyright: 1996-2008, Alcachofa Soft S.L." "You may distribute "DRASCULA" for free on any medium…" "You may not charge a fee for the game itself." "You may modify the game as you wish." — [Debian drascula copyright](https://metadata.ftp-master.debian.org/changelogs/main/d/drascula/stable_copyright)
- Free-software distributions treat these licenses as non-free because of the no-sale clause. Guix concluded the license "explicitly prohibits selling of the games themselves". — [Guix devel list (search snippet)](https://lists.gnu.org/r/guix-devel/2022-08/msg00060.html); [Trisquel issue](https://gitlab.trisquel.org/trisquel/ubuntu-purge/-/issues/6)
- **Dreamweb (Creative Reality, 1994):** license text: "You may distribute this game for free on any medium…" "You may not charge a fee for the game itself." "All game content is (C) Neil Dodwell and David Dew trading as Creative Reality." There is no modification clause. — [Gentoo licenses/Dreamweb](https://ftp.fau.de/gentoo-portage/licenses/Dreamweb)
- Dreamweb was released as freeware for ScummVM on 2012-10-21. One summary says Creative Reality "released the original source code … and the CD-ROM and floppy disk versions as freeware". The ScummVM wiki says the engine's original source "was provided by the developer". A 2011 thread says the developers gave explicit permission to use it for a GPL engine. No GPL license text for the original source was found. — [ScummVM news 2012-10-21](https://www.scummvm.org/news/20121021/); [scummvm-devel 2012-02](https://lists.scummvm.org/pipermail/scummvm-devel/2012-February/010598.html) (search snippets)
- **Soltys (L.K. Avalon, 1995, CGE engine):** ScummVM received the English and Polish sources in June 2011. The game was released as freeware via ScummVM on 2011-11-26, with authorization to translate and distribute for free. — [scummvm-devel "Sources received: Soltys"](https://lists.scummvm.org/pipermail/scummvm-devel/2011-June/009809.html); [ScummVM news 2011-11-26](https://scummvm.org/news/20111126) (search snippets)
- ScummVM's games page lists freeware downloads of BASS, Broken Sword 2.5, Dreamweb, FOTAQ, Lure, Drascula, and others. — [scummvm.org/games](https://www.scummvm.org/games)

### Inferences
- Reusability for the user: modifying and redistributing BASS, Lure, FOTAQ, or Drascula is allowed only for free, marked-as-modified distribution. Putting their dialogue into a commercial game would violate the no-fee clause and would not be a license grant. These games are useful only as structural references (verb-object adventure dialogue trees).
- "Source released" does not mean "script readable". Even for Dreamweb and Soltys, where original code was handed over, ScummVM reimplemented the engines, and the dialogue still sits inside the original data files under the old copyright.

### Gaps
- I did not verify how dialogue is stored in each game (e.g., BASS compressed data in sky.dnr/sky.dsk, FOTAQ dialogue resources in queen.1, Drascula text in ScummVM's drascula.dat, Dreamweb text files). ScummVM wiki pages were blocked by an anti-bot page (Anubis) during fetch.
- The exact Soltys license text and the license (if any) of Dreamweb's original assembly source were not found.
- Story premises (BASS: cyberpunk Union City; Lure: fantasy escape from Turnvale; FOTAQ: 1940s pilot in the Amazon; Drascula: comedic vampire parody; Dreamweb: dark near-future thriller; Soltys: Polish comic village adventure) come from general knowledge and were not verified this session.

---

## Q5. The Ur-Quan Masters (Star Control II port): code GPL, content CC BY-NC-SA 2.5; dialogue format

### Takeaway
UQM is the best verified example of a classic story game whose full dialogue text and voice files are openly licensed. The license is CC BY-NC-SA 2.5 for content and GPL for code. The dialogue is plain text, one file per alien race, with records keyed by identifiers that C code references. NC (non-commercial) and SA (share-alike) rule it out for a commercial or All-Rights-Reserved project. Use it only as a format and structure reference.

### Cited Findings
- Content license: "The content -- voiceovers, dialogue, graphics, and music -- are copyright (C) 1992, 1993, 2002 Toys for Bob, Inc. or their respective creators. The content may be used freely under the terms of the Creative Commons Attribution-NonCommercial-ShareAlike 2.5 license." — [Launchpad/Ubuntu uqm-content copyright (search snippet)](https://launchpad.net/ubuntu/xenial/+source/uqm-content/+copyright). The Debian non-free copyright says: "The content may also be copied freely as part of a distribution of The Ur-Quan Masters." — [Debian uqm-content copyright](https://metadata.ftp-master.debian.org/changelogs/non-free/u/uqm-content/stable_copyright)
- Code license: game content CC-BY-NC-SA-2.5, source code GPL. — [The Ur-Quan Masters (Wikipedia, search snippet)](https://www.Wikipedia.org/wiki/Ur-Quan_Masters)
- Dialogue file format (UQM developer doc "script"): files are `content/comm/{race}/*.txt`. Each record starts with `#`, an identifier in parentheses, and for alien lines a tab and audio filename. Example header: `#(HAVING_FUN_WITH_ILWRATH_2)	thrad103.wav`. "Alien identifiers are in ALL_CAPITAL_LETTERS"; the player's (Zelnick's) lines use lower_case identifiers and must fit on one line. Alien lines may contain newlines. When one speech is split across records (e.g., to insert the player's name), only the first record has audio. Lines not ending in punctuation get "..." appended. Each race has `src/sc2code/comm/{race}/strings.h` with an enum in the same order as the .txt records, used by `{race}c.c`. The `scriptcheck` tool verifies they match. — [UQM doc/devel/script](https://jim.sh/svn/jim/vendor/uqm/current/doc/devel/script)
- Conversation logic: `NPCPhrase_cb()` shows NPC speech "with identifier 'index' (and play the associated sample)". `DoResponsePhrase()` adds "a line to the list of remarks the player may choose from". `PLAYER_SAID(said, test)` tests the chosen reply. Special indices insert `GLOBAL_PLAYER_NAME`, `GLOBAL_SHIP_NAME`, etc. — [UQM doc/devel/dialogs](https://jim.sh/svn/jim/vendor/uqm/current/doc/devel/dialogs)
- Voice is a separate optional package ("optional game content that provides in-game speech"). — [Slackware uqm_voice README (search snippet)](https://slackware.uk/sbo/14.2/games/uqm_voice/README)

### Inferences
- Speaker handling: the speaker is implicit, one alien race per comm file or screen. Player and NPC are told apart only by identifier case (lowercase = player). There are no face or expression fields; the alien's animated portrait is driven by code and graphics, not by the text record. Choices and flags live in C (`{race}c.c`, game-state bits), not in the text file.
- This separation (text table keyed by ID, plus logic code that references IDs, plus optional voice clip per record) is a good, license-free design idea for an AGM G project: a localized string table keyed by line ID, with flags in game logic.
- Reusability: NC forbids commercial use, and SA would force derivatives under CC BY-NC-SA, which conflicts with the user's All-Rights-Reserved content and is not GPL-compatible. Do not copy any lines.

### Gaps
- I did not re-verify the exact current repository paths (SourceForge `sc2/content/base/comm/...`) or the timestamp/subtitle-sync files (.ts) used with voice in current UQM versions. The doc version fetched is a historical mirror.

---

## Q6. Dink Smallwood: source and data release status, DinkC, license

### Takeaway
Dink Smallwood (RTSoft, 1997) has a permissive story license chain. The engine source (1.07, 2003) is under a permissive Robinson license. Most game data, meaning everything except non-RTSoft sounds and music, was relicensed under zlib in 2008, and GNU FreeDink (GPL) plus freedink-data ship it with free replacement audio. The story scripts are written in DinkC (C-like `.c` script files). Because the data falls under the zlib-licensed "game data", this is the most commercially reusable classic story dataset in this survey, though attribution and the license history should be double-checked.

### Cited Findings
- 2003 engine source license (1.07): "You may freely use, modify and distribute this source provided that the copyright text below is included…" "Portions Copyright (C) Seth A. Robinson, 1997-2003." "You may use this source in personal and commercial products, you are not required to release the source code." — [codedojo.com/files/dink/license.txt](https://www.codedojo.com/files/dink/license.txt)
- The same 2003 file restricts media: it covers "the name Dink Smallwood and related media includeding graphics, sounds, music, scripts and map data," and "Repackaging or distributing the Dink Smallwood Media in a modified format requires permission from Seth A. Robinson." — [same](https://www.codedojo.com/files/dink/license.txt)
- 2008 relicense: "In 2008, Seth (the man behind Dink Smallwood) agreed to license most of the Dink game data under the free zlib license." "Most of the Dink game data means everything except for sounds: most of the wav and midis in Dink were not made by RTsoft, and could not be released freely." — [GNU FreeDink doc/sounds (search snippet)](https://www.gnu.org/s/freedink/doc/sounds/)
- Wikipedia: "In 2008, the artwork was published (without some sounds) under a Zlib license." Seth initially refused fans' requests for the source, citing embarrassing code. The "HD" source was released in 2017, and "Updated data files remain proprietary." — [Dink Smallwood (Wikipedia, search snippet)](https://en.wikipedia.org/wiki/Dink_Smallwood)
- GNU FreeDink is GPL. freedink-data reuses the zlib-licensed data, "except for sounds and music that RTSoft couldn't release as free software", which were replaced with free alternatives. — [Libregamewiki FreeDink (search snippet)](https://libregamewiki.org/FreeDink)
- RTDink (Dink Smallwood HD) source repo: [github.com/SethRobinson/RTDink](https://github.com/SethRobinson/RTDink)

### Inferences
- The 2003 media restriction, which named scripts explicitly, appears to be superseded for "most game data" by the 2008 zlib relicense. Since GNU says the exclusion is only sounds and music, the original story DinkC scripts and map data are very likely zlib. zlib allows commercial use and modification. It only requires not misrepresenting origin and marking altered versions, so it is GPL-compatible.
- Even so, reusing Dink's story text in an original commercial game would bring in another work's characters and setting. Treat it as a structural reference, or as quoted samples with attribution, not as story content.

### Gaps
- I did not fetch a primary freedink-data COPYING/README listing the exact files under zlib. Confirm that `story/*.c` scripts are included before relying on it.
- DinkC syntax was not verified this session. From memory and unverified: functions like `say_stop("text", &sprite)`, a `choice_start()…choice_end()` block for dialogue choices, and a global `&story` variable for plot progression. Verify against the FreeDink DinkC reference.

---

## Q7. Korean open-source story games and Korean public open content with story scripts

### Takeaway
No Korean-made open-source story game with an openly licensed dialogue script turned up after several Korean and English searches. Verified Korean items are tools or code only: NekoNovel, a Korean VN engine open-sourced in 2011 under BSD with no sample scenario in the repo, and a university MIT escape-room project with code only. Korean public content uses 공공누리 (KOGL) types, where Type 1 allows commercial use and modification with attribution. I did not verify whether KOCCA's 문화원형 library story or scenario items carry Type 1.

### Cited Findings
- **NekoNovel (네코노벨):** a Korean visual-novel engine by 커니스 (kernys), "2011년 12월 9일에 오픈소스화되었다". — [ko.wikipedia 네코노벨 (search snippet)](https://ko.wikipedia.org/wiki/%EB%84%A4%EC%BD%94%EB%85%B8%EB%B2%A8). The repo README says "본 코드는 BSD 라이센스를 따르며" and asks users to link the project site. The repo currently shows only `.gitignore` and `README.md`, with no sample scenario. — [github.com/kernys/nekonovel](https://github.com/kernys/nekonovel)
- **Team_GPL (Kookmin Univ. course project):** an escape-room game repo under MIT, with feature code (inventory, game manager) and apparently no story script. — [github.com/nelumbotus/Team_GPL (search snippet)](https://github.com/nelumbotus/Team_GPL)
- **VNAP**, an older Korean VN tool, was discontinued after the author said the source was lost. — [namu.wiki VNAP (search snippet)](https://namu.wiki/w/VNAP)
- Ren'Py (widely used by Korean VN creators) is MIT-licensed, so games made with it can be sold. — [ko.wikipedia 렌'파이](https://ko.wikipedia.org/wiki/%EB%A0%8C'%ED%8C%8C%EC%9D%B4); [namu.wiki Ren'Py](https://namu.wiki/w/Ren'Py)
- **KOGL (공공누리):** types 0 (free use) through 4. Type 1 (출처표시) allows commercial use and derivative works with attribution. Types 2–4 add non-commercial and/or no-derivatives conditions. Material without a Type 1 mark may not be freely usable, so consult the publishing department. — [문화체육관광부 공공누리 안내](https://www.mcst.go.kr/site/s_open/kogl/intro.jsp) (search snippet)
- itch.io has an "available in Korean" listing and an "open source" visual-novel tag, but no Korean-developer, open-licensed story game was identified from them. — [itch.io lang-ko](https://itch.io/games/lang-ko); [itch.io VN open-source tag](https://itch.io/games/genre-visual-novel/tag-open-source)

### Inferences
- A conservative report statement would be: "As of this survey, no Korean-made story game was confirmed to publish both code and character dialogue scripts under an open license. Korean open releases are mostly engines/tools (NekoNovel BSD) or educational code (MIT)."
- The most promising Korean public source for story material is KOGL Type 1 content (e.g., folklore and cultural-archetype material). Each item's mark must be checked individually.

### Gaps
- I did not check KOCCA 문화원형 라이브러리 (culturecontent.com) item-level KOGL types, or 공유마당 (gongu.copyright.or.kr) game assets.
- I did not search 네이버 카페 or 디시 쯔꾸르 갤러리 directly, since they are often login- or JS-gated. Korean RPG Maker freeware authors' "편집 가능 배포" practices remain unverified.
- I did not survey Korean game-jam (e.g., GGJ Korea, 인디크래프트) source releases with dialogue.

---

## Q8. Japanese open-source novel/RPG engines and their bundled sample scenarios (brief)

### Takeaway
The engines are free, and some are open source. TyranoScript is free with commercial use OK. Kirikiri Z is reportedly modified-BSD, and its SDL2 port is MIT. The licenses cover engine code, though. Bundled sample scenarios and materials do not clearly carry a separate open license, so treat their text as reference only unless a sample states a license.

### Cited Findings
- **TyranoScript** (ShikemokuMK/tyranoscript): README: "ティラノスクリプトは無料でご利用いただけます。" Commercial use is allowed. "作品の製作が目的であれば、改造に制限はありません". Redistributing TyranoScript itself is prohibited. The repo has `LICENCE.txt` and a `data/` folder. — [github.com/ShikemokuMK/tyranoscript](https://github.com/ShikemokuMK/tyranoscript)
- TyranoScript license conflict: one page says it is open source (MIT License) with "Ver2.60: Added MIT License", while an aggregator lists the license as "Other". — [evanburchard.github.io/tyranoscript (search snippet)](https://evanburchard.github.io/tyranoscript); [docsearch listing (search snippet)](https://docsearch.algolia.com/mcp/docs/repo/shikemokumk/tyranoscript)
- In TyranoScript/KAG, `first.ks` is the first scenario file loaded, from `data/scenario`. — [asahi-net TyranoStudio page (search snippet)](https://www.asahi-net.or.jp/~XC9K-HT/text/TyranoStudio.html)
- Official TyranoScript technical samples are described as copy-paste examples, with no license stated. — [tyranobuilder.com samples (search snippet)](https://tyranobuilder.com/samples/tyranoscript-technical-samples)
- **Kirikiri (吉里吉里):** Kirikiri Z is "修正BSDライセンスの下で公開" (secondary source). Kirikiri 2 is described as GPL (secondary). The krkrsdl2 port's src is MIT. — [3rd-in pedia 吉里吉里Z (search snippet)](https://pedia.3rd-in.co.jp/wiki/%E5%90%89%E9%87%8C%E5%90%89%E9%87%8CZ); [moegirl Kirikiri (search snippet)](https://zh.moegirl.org.cn/Kirikiri); [github.com/krkrsdl2/krkrsdl2 (search snippet)](https://github.com/krkrsdl2/krkrsdl2)
- **WOLF RPG Editor (ウディタ):** ships with only minimal sample materials. The Pro version (2022, Ver.3) has stricter terms (e.g., editor sharing limited to the purchaser's family). — [窓の杜 2008 (search snippet)](https://forest.watch.impress.co.jp/article/2008/03/25/wolfrpgeditor.html); [pixiv 百科 WOLF RPG Editor (search snippet)](https://dic.pixiv.net/a/WOLF_RPG_Editor)

### Inferences
- For "script format study", KAG/TyranoScript `.ks` files are tag-based (`[tag param=...]`, `#speaker` lines) and readable. They map onto a dialogue resource more directly than RPG Maker's event JSON does. Engine licenses being free does not make any particular game's `.ks` story open.

#### Cross-item summary matrix (built only from the cited findings in Q1–Q8; see each section for sources)
| Item (year / engine) | Code license | Text/dialogue license | Art / audio | Dialogue script included? (format) | Speaker / face / choices / flags | Reusable in user's commercial GPL-3.0 + ARR project? |
|---|---|---|---|---|---|---|
| EasyRPG TestGame (RM2000/2003 format) | GPL-3.0 (repo) | GPL-3.0 (assumed from repo; COPYING not read) | CC0 / CC BY 4.0 / OGA-BY per AUTHORS.md | Partial: test-room events only, no story (.lmu/.ldb, convert with liblcf lcf2xml, MIT) | RM2000 message/face/choice commands; switches/variables | Yes, as a GPL-compatible structural sample with CC-BY attribution. No story value. |
| RPG Maker official sample games (MV/MZ etc.) | Engine proprietary (corescript MIT for MV) | GGG terms ("materials"), no open license | GGG materials; some samples blacklisted | Yes inside the editor (Map###.json / CommonEvents.json) | 101/401 (+MZ speaker params[4]), 102/402/403, 121/122/111 | No redistribution in a repo (Art. 2(D)). Use only inside games per the terms. Sample text reuse is unclear. |
| Ib / The Witch's House / Yume Nikki / Ao Oni (RM2000/VX/2003/XP) | Proprietary freeware | Author guidelines only | Proprietary (Ib music licensed from third parties) | Yes in game data, but reuse forbidden (no fangames or modification for Ib; no alternate endings for Witch's House) | RPG Maker event commands | No. Analysis only. |
| BASS / Lure / FOTAQ (Revolution etc.) | ScummVM GPL engine; original code not open | Freeware license: modification OK, no fee for game | Same freeware license | Yes, embedded in original data files (format unverified) | Engine-specific | No commercial reuse (no-fee clause; © Revolution). |
| Drascula (Alcachofa, 1996) | ScummVM GPL engine | Same freeware + modification license | Same | Embedded (format unverified) | Engine-specific | No commercial reuse. |
| Dreamweb (Creative Reality, 1994) | Original source handed over (license text not found) | Freeware, no modification clause | Same | Embedded (format unverified) | Engine-specific | No. |
| Soltys (L.K. Avalon, 1995) | Sources given to ScummVM | Freeware by authorization (text not found) | Same | Embedded | Engine-specific | No (unclear terms). |
| The Ur-Quan Masters (1992/2002) | GPL | CC BY-NC-SA 2.5 | CC BY-NC-SA 2.5 (voice is an optional package) | Yes: `content/comm/{race}/*.txt`, `#(ID)<TAB>clip.wav` records | Speaker implicit per race file; player lines lowercase IDs; choices and flags in C (`DoResponsePhrase`, `PLAYER_SAID`) | No (NC + SA). Format idea only. |
| Dink Smallwood (RTSoft 1997; FreeDink) | Robinson permissive (2003); FreeDink GPL | Most game data zlib (2008), scripts likely included (to verify) | Art zlib; original non-RTSoft sounds/music excluded, replaced in freedink-data | Yes: DinkC `.c` scripts (syntax unverified) | `say` functions with sprite as speaker, choice blocks, `&story` variable (unverified) | Likely yes under zlib (verify file list). It is still another IP's world, so use for structure or attributed samples. |
| NekoNovel (KR, 2011) | BSD | n/a (no scenario in repo) | n/a | No | n/a | Engine only. |
| TyranoScript (JP) | Free, commercial OK (MIT claimed; LICENCE.txt not read) | Sample text license unclear | Unclear | Sample `.ks` scenarios (first.ks) | `#name` speaker, tag commands (unverified) | Engine yes. Sample text unclear. |
| UQM-style design / MZ 101 model | Not applicable (data-model ideas are not copyrightable text) | — | — | — | — | Yes. Reuse structure, not text. |

### Gaps
- I did not read TyranoScript's LICENCE.txt verbatim or check whether the bundled sample game's text and images are under the same terms.
- The licenses of the Kirikiri 2 / KAG3 sample scenarios and the WOLF RPG Editor 基本システム sample game terms were not found from primary sources.
- The `.ks` syntax details above (`#name` speaker lines) are from general knowledge and were not verified this session.

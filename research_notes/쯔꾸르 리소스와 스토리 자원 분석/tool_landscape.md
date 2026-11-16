# RPG Maker (쯔꾸르/ツクール) tool landscape and ACTION GAME MAKER: fact-check notes (as of 2026-11-16)

Research date: 2026-11-16. Every fact below carries the date of the source or event. "Fetched 2026-11-16" means the live page was read on that date. Steam review counts quoted from store pages may be filtered to one language, because Steam store pages often show reviews in the viewer's language by default. Treat them as indicative only.

## 1. Fact-check of the three pasted trend claims

### Takeaway
- **(a) "RPG Maker U2U introduced P2D … making HD-2D style common": PARTIALLY VERIFIED, and the conclusion is FALSE.** RPG Maker U2U is real. Gotcha Gotcha Games announced it on 2026-05-21, and P2D officially stands for "Perspective 2D": 2D maps given depth, light, shadow and effects. But as of 2026-11-16 U2U is **unreleased**. It has no release date or price, and the only public build was a P2D *map-editor-only* demo (2026-10-20 to 2026-11-16) with no game-creation features. No U2U game can have shipped yet, so "made HD-2D style common" cannot be true. The official wording also never says "HD-2D". That label comes from the press.
- **(b) "4-layer map layer systems are now universal": FALSE as a generalization. It is true only for RPG Maker MZ, and has been since 2020.** MZ (2020) lets you pick one of "the four map layers" or leave layering on "Automatic". This is not new in 2026 and is not universal. U2U uses blocks on a heightmap in 3D space. ACTION GAME MAKER uses Godot tile layers and added "Sublayers" in v2.0. Bakin is a 3D-map tool.
- **(c) "ACTION GAME MAKER, a Godot-based derivative tool, lets people make 2D action games without programming": VERIFIED as official marketing, with caveats.** It is an official Gotcha Gotcha Games product in the "Maker" series, not a community derivative. It is built on Godot (4.3 at launch). It uses visual scripting and state machines, and GDScript is optional. Since 2026-10-02 (v2.0) it has been renamed **ACTION GAME MAKER G**. Independent reviewers questioned how easy the no-code workflow is in 1.x, and v2.0 was a large usability overhaul.

### Cited Findings
- (a) The U2U teaser came first, on 2026-03-26 ("新たな表現の扉を開くRPGツクール新プロジェクト"). — [RPG Maker Official news 4157](https://rpgmakerofficial.com/news/4157/); [AUTOMATON JP 2026-03-26 ("HD-2D風"映像)](https://automaton-media.com/articles/newsjp/20260326-432265/)
- (a) The official title "RPGツクールU2U（ユーツーユー）" was announced on 2026-05-21. P2D is defined as "「P2D（Perspective 2D，パースペクティブ・ツーディー）」… 従来のツクールシリーズの2Dマップに，奥行きのある立体的な表現やエフェクトをプラスした映像表現". Release date and price: "未定". — [4Gamer 2026-05-21](https://www.4gamer.net/games/993/G099342/20260521007/)
- (a) Steam page wording (fetched 2026-11-16): P2D "expands traditional 2D maps with depth, light, shadow, and a variety of beautiful effects". It supports slopes, ledges, multi-story buildings and overpasses, plus depth of field, rain/fog, interior lighting and street lamps. Release: "Coming soon". — [Steam: RPG MAKER U2U](https://store.steampowered.com/app/4856440/RPG_MAKER_U2U/)
- (a) Official feature page: "Add 3D depth and rich effect expression to conventional 2D maps!" and "By adopting a fixed perspective similar to the classic 2D RPG Maker view". — [u2u.rpgmakerofficial.com/en/feature](https://u2u.rpgmakerofficial.com/en/feature/)
- (a) The demo is map-editor only: "The demo is scheduled to be available from Tuesday, October 20 through Monday, November 16, 2026" and "This demo does not include game creation features." — [Gematsu 2026-10-19](https://www.gematsu.com/2026/10/rpg-maker-u2u-p2d-map-editor-demo-now-available)
- (a) Several outlets use the term "HD-2D" for U2U, but the official materials say "P2D". — [AUTOMATON JP 2026-05-21 ("HD-2D風"の奥行き表現が簡単にできる「P2D」)](https://automaton-media.com/articles/newsjp/20260521-444328/); [Notebookcheck ("HD-2D akin to Octopath Traveler")](https://www.notebookcheck.net/RPG-Maker-returns-with-HD-2D-akin-to-Octopath-Traveler.1302108.0.html); [GameMeca EN ("Featuring HD-2D Style")](https://www.gamemeca.com/en/view.php?gid=1773353)
- (a) One Chinese-language commentary says the official name avoids "HD-2D" because Square Enix holds the HD-2D trademark in Japan. This is analysis, not an official statement. — [Xiaomi Game viewpoint](https://game.xiaomi.com/viewpoint/1393220466_1779697385027_100)
- (b) RPG Maker MZ official product page: "You can now select which of the four map layers you are drawing onto, or leave it on Automatic to keep the behavior from MV." — [rpgmakerweb.com: RPG Maker MZ](https://www.rpgmakerweb.com/products/rpg-maker-mz)
- (b) MZ preview blog (2020-07-02): "The layer system is no longer only automatic!" and "Stack 4 A tiles, or 4 B-E tiles, or any mix in any order!" This is the most likely origin of the "4-layer" phrase. — [RPG Maker MZ Preview 2](https://www.rpgmakerweb.com/blog/rpg-maker-mz-preview-2-graphics-mapping-eventing)
- (b) U2U turns "traditional 2D map tiles into blocks placed in a 3D space", with a black-and-white heightmap for ground height (interview dated 2026-10-21). — [80.lv interview](https://80.lv/articles/interview-rpg-maker-u2u-lets-you-build-hd-2d-worlds-without-learning-3d)
- (b) ACTION GAME MAKER G v2.0 (2026-10-02) lists "Sublayers" and a "Tile Palette" among its new features. — [RPG Maker Official news 4271](https://rpgmakerofficial.com/en/news/4271/)
- (c) Steam page (fetched 2026-11-16): characters are built "without writing a single line of code" by "laying out a character's states as boxes and connecting them with arrows". The page also says "You can also create your own visual scripting Actions and Conditions using GDScript." — [Steam: ACTION GAME MAKER G](https://store.steampowered.com/app/2987180/ACTION_GAME_MAKER/)
- (c) Final Weapon's review of v1.1 gave 3/5 and said the tool "promises no-code simplicity on top of Godot's powerful foundation—but struggles to deliver on that promise". — [Final Weapon 2025-09-30](https://finalweapon.net/2025/09/30/action-game-maker-version-1-1-available-now-on-steam/)

### Inferences
- The pasted summary seems to take marketing and press framing ("HD-2D") for something already in use. On 2026-11-16, U2U is a wishlist item plus a finished map-editor demo, so no market trend can come from it yet.
- The "4-layer" claim most likely comes from MZ's 2020 manual-layer feature, overgeneralized to all tools.
- For the user's 2D platformer, U2U is not relevant. It is a top-down RPG tool with a fixed camera. ACTION GAME MAKER G is the right Gotcha Gotcha Games tool.

### Gaps
- I found no official U2U release window as of 2026-11-16. Every source says "未定" or "Coming soon".
- I could not find an official statement on how many map layers U2U has.

## 2. RPG Maker U2U: existence, developer, dates, engine, P2D definition

### Takeaway
RPG Maker U2U exists. It is developed and published by Gotcha Gotcha Games, a KADOKAWA group company. Timeline: teaser 2026-03-26, title announced 2026-05-21, Steam page opened 2026-08-27, map-editor demo 2026-10-20 to 2026-11-16. It is a standalone, Unity-powered PC (Windows 11) tool. Its headline feature is P2D (Perspective 2D). It is unreleased and unpriced as of 2026-11-16.

### Cited Findings
- **Developer/publisher:** Gotcha Gotcha Games. Gematsu (2026-05-21) lists it under Kadokawa Corporation. — [Gematsu 2026-05-21](https://www.gematsu.com/2026/05/rpg-maker-u2u-announced-for-pc); [Steam](https://store.steampowered.com/app/4856440/RPG_MAKER_U2U/)
- **Engine:** "Unity Engine powers the P2D system's rich sense of depth and beautiful effects." (Gematsu, 2026-05-21) — [Gematsu](https://www.gematsu.com/2026/05/rpg-maker-u2u-announced-for-pc)
- **Standalone:** U2U was first developed inside Unity but ships as a standalone Steam application. It needs no Unity install, Unity Hub or Unity ID (80.lv interview with producer Hiroyuki Ichinose, 2026-10-21). — [80.lv](https://80.lv/articles/interview-rpg-maker-u2u-lets-you-build-hd-2d-worlds-without-learning-3d)
- **Plugins:** U2U uses **Luau** for a new runtime plugin system, described as the successor to MV/MZ plugins. MV/MZ "JavaScript plugins … won't work as is", and Editor Plugins are planned (80.lv, 2026-10-21). This comes from a single source, and no Japanese source in my searches confirmed "Luau". — [80.lv](https://80.lv/articles/interview-rpg-maker-u2u-lets-you-build-hd-2d-worlds-without-learning-3d)
- **Lighting and effects:** point lights, spotlights, self-illuminating elements (windows), depth of field, cloud shadows, dust, heat haze, water surfaces, fog, light particles, wind. Time of day is set via event commands. — [80.lv](https://80.lv/articles/interview-rpg-maker-u2u-lets-you-build-hd-2d-worlds-without-learning-3d)
- **Camera:** fixed at a chosen angle, with no free rotation. — [80.lv](https://80.lv/articles/interview-rpg-maker-u2u-lets-you-build-hd-2d-worlds-without-learning-3d); [official feature page](https://u2u.rpgmakerofficial.com/en/feature/)
- **Asset reuse:** "2D assets made for RPG Maker MZ and RPG Maker MV can be reused as decorative tiles in P2D maps." The tool ships "more than 100 ready-to-use P2D maps". — [official feature page](https://u2u.rpgmakerofficial.com/en/feature/)
- **Asset reuse (interview):** MV/MZ map tiles import without conversion and U2U keeps the same tile specifications. Character sprites, faces, busts and backgrounds can also be reused. — [80.lv](https://80.lv/articles/interview-rpg-maker-u2u-lets-you-build-hd-2d-worlds-without-learning-3d)
- **Asset reuse (Japanese press):** "過去にRPGツクールに向けてリリースされたアセットも全てRPGツクールU2Uで再利用できます" (gamemakers.jp, 2026-08-27). — [ゲームメーカーズ](https://gamemakers.jp/article/2026_08_27_143818/)
- **No project/plugin conversion:** "conversion of project data and plug-ins created with previous RPG Maker titles is not supported." — [Steam](https://store.steampowered.com/app/4856440/RPG_MAKER_U2U/)
- **UI lineage:** "U2U is based on the game-making experience of RPG Maker MZ". — [official feature page](https://u2u.rpgmakerofficial.com/en/feature/)
- **Steam store page:** opened 2026-08-27 and began taking wishlists. The page also revealed the event editor and database. — [RPG Maker Official news 4265](https://rpgmakerofficial.com/en/news/4265/); [ゲームメーカーズ 2026-08-27](https://gamemakers.jp/article/2026_08_27_143818/)
- **Earlier trial:** a P2D map editor trial was shown at the BitSummit PUNCH booth from 2026-05-22. — [4Gamer](https://www.4gamer.net/games/993/G099342/20260521007/)
- **Steam Next Fest demo:** ran 2026-10-20 to 2026-11-16. Map data carries over to the full version. — [RPG Maker Official news 4314](https://rpgmakerofficial.com/en/news/4314/); [Gematsu](https://www.gematsu.com/2026/10/rpg-maker-u2u-p2d-map-editor-demo-now-available)
- **Minimum specs:** Windows 11 64-bit, 8 GB RAM, DirectX 11 GPU, 10 GB storage. Interface in 12 languages, including Korean (fetched 2026-11-16). — [Steam](https://store.steampowered.com/app/4856440/RPG_MAKER_U2U/)
- **Lineage:** coverage describes U2U as the successor to RPG Maker Unite (2023), now standalone rather than a Unity extension. — [RPG Maker fandom wiki (secondary)](https://rpgmaker.fandom.com/wiki/RPG_Maker_U2U)
- **Press interviews:** developer interviews ran in Japanese press on 2026-06-28/29. — [GameBusiness.jp 2026-06-29](https://www.gamebusiness.jp/article/2026/06/29/27348.html); [Game*Spark 2026-06-28](https://www.gamespark.jp/article/2026/06/28/168535.html)
- **Covered by GGG asset terms:** "RPG Maker U2U" appears in the GGG Products list of the Gotcha Gotcha Games terms. — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **"Built from scratch":** AUTOMATON EN's headline calls it a "brand-new built-from-scratch engine" for "HD-2D style games". I could only read the headline. — [AUTOMATON EN](https://automaton-media.com/en/news/rpg-makers-brand-new-built-from-scratch-engine-will-let-developers-create-hd-2d-style-games-with-extensive-customization/)

### Inferences
- "Engine" claims conflict only on the surface. Unity is the underlying runtime per Gematsu, and the "built from scratch" headline most likely refers to the RPG Maker application layer, not a new rendering engine.
- Because U2U reuses MV/MZ tile specs, existing 48px MZ assets keep their value. That matters for RPG projects, not for the user's platformer.

### Gaps
- Export targets for games made with U2U are not stated anywhere I found. The Steam page lists only Windows 11 for the editor.
- I found no official tile-size, resolution or layer-count specification for P2D maps.
- "Luau" plugins appear in only one English interview (80.lv), so this needs confirmation from official docs.

## 3. RPG Maker MZ / MV / Unite / WITH: status and technical specs

### Takeaway
- **MZ (2020):** still the current PC RPG Maker. JavaScript plugins, 48x48 default tiles (16/24/32/48 selectable), 4 selectable map layers or Automatic, 954 DLC items on Steam as of 2026-11-16.
- **MV (2015):** covered by GGG terms and a separate KADOKAWA EULA.
- **Unite (2023):** Unity-based. It is no longer sold on Steam but is still on the Epic Games Store, and is succeeded by U2U.
- **WITH:** console-only (Switch 2024, PS4/PS5 2025).

### Cited Findings
- **MZ basics:** Steam release 2020-08-27. Developer: Gotcha Gotcha Games / KADOKAWA / Yoji Ojima. Price $79.99. Steam showed "Very Positive (1,114) – 86%" when fetched on 2026-11-16 (possibly language-filtered). Korean interface supported. "Browse all (954)" DLC. — [Steam: RPG Maker MZ](https://store.steampowered.com/app/1096900/RPG_Maker_MZ/)
- **MZ tile sizes:** "Tile size can be selected from "16x16", "24x24", "32x32", and "48x48"". 48x48 is the default, per creator posts. — [Steam: RPG Maker MZ](https://store.steampowered.com/app/1096900/RPG_Maker_MZ/); [itch.io creator post](https://itch.io/post/10240128)
- **MZ layers:** "select which of the four map layers you are drawing onto, or leave it on Automatic to keep the behavior from MV". — [rpgmakerweb MZ page](https://www.rpgmakerweb.com/products/rpg-maker-mz)
- **MZ automatic mode:** in automatic mode you can stack two kinds of upper tiles (B–E), and a third replaces the first. Shadows are auto-drawn, with a Shadow Pen to toggle them. — [MZ Help 01_07_01](https://rpgmakerofficial.com/product/MZ_help-en/01_07_01.html)
- **MZ bundled assets:** 31 tileset sheets, 44 character sprite sheets, 120 busts, 120 full-art, 105 enemy battlers, 120 animations, 48 BGM, 29 BGS, 27 ME, 345 SE. — [rpgmakerweb MZ page](https://www.rpgmakerweb.com/products/rpg-maker-mz)
- **MV/MZ plugin language:** JavaScript. This is implied by "JavaScript plugins from MV and MZ won't work as is" in U2U. — [80.lv](https://80.lv/articles/interview-rpg-maker-u2u-lets-you-build-hd-2d-worlds-without-learning-3d)
- **Qt licensing:** MZ, MV and Pixel Game Maker MV use Qt under LGPL. — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **Unite:** released 2023-05-08 on the Unity Asset Store. The Steam page now says it is no longer available, but it is still listed on the Epic Games Store. The latest version seen in official notices is 1.3.0 (date not visible). — [Steam app 1650950](https://store.steampowered.com/app/1650950); [Epic Games Store](https://store.epicgames.com/p/rpgunite-819421); [notice.rpgmakerofficial.com](https://notice.rpgmakerofficial.com/tag/en/page/2/)
- **Unite terms:** Unite is not in the GGG Products list. It has its own Terms and Conditions and its own Official DLC Terms. — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **WITH, Switch:** Japan 2024-04-11, West 2024-10-11. — [Gematsu 2024-06](https://www.gematsu.com/2024/06/rpg-maker-with-for-switch-launches-october-11-in-the-west)
- **WITH, PlayStation:** PS5/PS4 Japan 2025-01-30 (¥8,580), West 2025-02-21 (NIS America). Cross-platform asset sharing. — [Famitsu 2024-10](https://www.famitsu.com/article/202410/21225); [Gematsu 2024-10](https://www.gematsu.com/2024/10/rpg-maker-with-for-ps5-ps4-launches-february-21-2025-in-the-west)

### Inferences
- For a PC asset pipeline, only MZ/MV (and later U2U) matter. WITH is console-only, and Unite is effectively being phased out in favor of U2U.
- MZ's selectable tile sizes and AGM G's one-button MV/MZ importer (section 4) make MZ-format pixel assets the most portable format inside the GGG ecosystem.

### Gaps
- I did not verify MZ's official export target list (commonly cited as Windows/macOS/Android/iOS/Web) on an official page in this session. The rpgmakerweb page lists only editor OS (Windows/Mac).
- I did not verify MZ's default screen resolution from an official page.
- I found no 2025–2026 Unite update dates.

## 4. ACTION GAME MAKER (now ACTION GAME MAKER G): technical profile and history

### Takeaway
ACTION GAME MAKER is an official Gotcha Gotcha Games "Maker"-series tool, the first Godot-based one. It launched on Steam on 2025-06-16 (Windows, $99.99) on Godot 4.3. Godot moved to 4.4.1 in v1.1 (2025-09-30). On 2026-10-02 it was overhauled as v2.0 and renamed **ACTION GAME MAKER G**, and the Steam page now cites Godot 4.7.0. It offers visual scripting, state machines and optional GDScript. Export targets are Windows/macOS/Linux/Web/Android/iOS. It bundles 1,000+ assets and imports MV/MZ-format sprite sheets and tilesets with one button. Reception was mixed in 1.x.

### Cited Findings
- **Announcement:** announced in July 2024 as "A Maker Series First: A new Godot-based ACTION GAME MAKER in development for 2025!" — [GamesPress](https://www.gamespress.com/A-Maker-Series-First-A-new-Godot-based-ACTION-GAME-MAKER-in-developmen); [Famitsu 2024-07](https://www.famitsu.com/article/202407/10551)
- **Release:** 2025-06-16 on Steam (Windows), $99.99. Japanese press gives 6月17日 (JST). — [Gematsu 2025-02](https://www.gematsu.com/2025/02/action-game-maker-launches-june-16); [Game*Spark 2025-02-04](https://www.gamespark.jp/article/2025/02/04/149090.html); [Wikipedia](https://en.wikipedia.org/wiki/Action_Game_Maker)
- **Base engine at launch:** "built on top of Godot 4.3". It "builds on the node-based visual scripting system created for 'Pixel Game Maker MV'". Launch features: state machine, database, Tile Map Editor with auto-tile, sprite and 2D bone animation, Godot particles/shaders, dynamic lighting and shadows. GDScript is available for users who want more. — [GameFromScratch 2025-06-16](https://gamefromscratch.com/godot-powered-action-game-maker-released/)
- **v1.1 (2025-09-30):** visual script UI redesign (flows in all four directions), new beginner tutorial, engine "from Godot 4.3 to 4.4.1". — [GamesPress v1.1](https://www.gamespress.com/Gotcha-Gotcha-Games-Announces-Release-of-ACTION-GAME-MAKER-Version-11-)
- **Linux plans:** Linux support for the editor and game exports was confirmed as a plan in 2025-06. — [GamingOnLinux 2025-06](https://www.gamingonlinux.com/2025/06/action-game-maker-confirm-plans-for-linux-support-for-the-editor-and-game-exports/)
- **v2.0 beta (GameFromScratch, 2026-09-21):** Maker Mode UI (old layout available as "Godot Mode"), integrated tutorial, environment templates, reference search, collision checker, "Sprite Anime"/"Hitbox Anime", live debugger, official imports system. The author called 1.x "really didn't offer much over the vanilla Godot experience" and 2.0 "a MASSIVE improvement". — [GameFromScratch](https://gamefromscratch.com/action-game-maker-massive-2-0-beta/)
- **v2.0 release and rename (2026-10-02):** "ACTION GAME MAKER has been renamed ACTION GAME MAKER G." and "There are no changes to the sales model or licenses as a result of the name change."
  - New: Setup Wizard, Screen Tour, Tile Palette, Sprite Animation, top-down water and pathfinding, mouse/touch controls, "23 new actions and conditions and 14 new nodes", Sublayers, Object Pooling, AGM Debug Monitor.
  - "Character sprite sheets and tilesets in RPG Maker MV and RPG Maker MZ formats can be imported with a single button."
  - Launch sale: 40% off at JPY 6,540 until 2026-10-09.
  - Free trial until 2026-11-02, with all features except game export.
  - Source: [RPG Maker Official news 4271](https://rpgmakerofficial.com/en/news/4271/)
- **Steam page for G (fetched 2026-11-16):**
  - "Access Every 2D Feature of Godot Engine 4.7.0".
  - Exports "Windows / macOS / Linux / Web（HTML5） / Android / iOS".
  - "Over 1,000 built-in assets, including images, sounds, animations, and particles".
  - Local multiplayer up to 8 players, 2.5D with 3D backgrounds, bullet-hell pattern generation, save/load.
  - Korean interface supported. 24 DLC items.
  - Reviews: "Mixed (72) – 63%" (possibly language-filtered).
  - Source: [Steam: ACTION GAME MAKER G](https://store.steampowered.com/app/2987180/ACTION_GAME_MAKER/)
- **Earlier bundle listing:** 400+ images, 400+ sound effects and music tracks, 200+ 2D bone animations. — [Steam sub 1062967](https://store.steampowered.com/sub/1062967)
- **Post-2.0 patches:** 2.0.4 (2026-10-15) added Action Buttons. 2.0.5 (2026-10-21) followed. Music DLC "Small Sounds Battle" released 2026-10-07. These come from Steam community/news listings via search, not read in full. — [Steam community](https://steamcommunity.com/app/2987180); [Steam: Small Sounds Battle](https://store.steampowered.com/app/5324160/ACTION_GAME_MAKER__Small_Sounds_Battle/)
- **Price data (SteamDB):** current price $94.48, lowest recorded $57.36 on 2026-06-25. SteamDB itself returned 403 to me, so this figure comes from a search snippet. — [SteamDB](https://steamdb.info/app/2987180/)
- **Producer Letter #19 (2026-06-17):** "First Anniversary and Future Updates". At that point 2.0 was still described as upcoming. — [SteamDB patchnotes (title only; page returned 403)](https://steamdb.info/patchnotes/23774987/)
- **Engine license:** "Godot Engine (used in ACTION GAME MAKER G) is licensed under the MIT License". — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **Known problems:** Wikipedia notes a "clunky animation system and crashes" (citing Eneba Hub, 2025-06-16). Final Weapon gave v1.1 3/5. — [Wikipedia](https://en.wikipedia.org/wiki/Action_Game_Maker); [Final Weapon](https://finalweapon.net/2025/09/30/action-game-maker-version-1-1-available-now-on-steam/)
- **Community:** official multilingual forum "RPG Maker Guild" (guild.rpgmakerofficial.com) has AGM threads, including a community-distributed sample "AGMakerサンプル≪滅獄スマッシュ≫". — [guild topic 1316 (related links)](https://guild.rpgmakerofficial.com/t/topic/1316)
- **Godot showcase:** godotengine.org lists ACTION GAME MAKER in its showcase. — [Godot showcase](https://godotengine.org/showcase/action-game-maker/)

### Inferences
- A 2D platformer started in November 2026 should target **ACTION GAME MAKER G v2.0.x**. The 1.x-era tutorials and critiques are partly outdated.
- AGM G is built on Godot TileMap/TileSet and imports MV/MZ tilesets, so tile size is configurable rather than fixed. This is inferred from Godot's design and the importer, not from an official spec. For pixel platformers, 16x16 or 32x32 tiles are typical, and 48x48 MZ tiles can still be imported.
- The GDScript extension path means "no programming" is optional rather than a hard limit. Advanced platformer mechanics (coyote time, slope handling) may still need custom actions or conditions.

### Gaps
- **Official asset/tile specification:** I found no official AGM spec for recommended tile or sprite sizes.
- **Notable games:** I found no notable commercial games shipped with AGM. Searches for "made with ACTION GAME MAKER" returned only tool pages.
- **Official contests:** I found no AGM-specific contest results. The rpgmakerofficial.com homepage shows an undated "GameJam 2025 Winners Announced!" banner that I did not open.
- **Community and sales:** I found no Discord member counts or sales figures. The anniversary producer letter (#19) could not be read because SteamDB returned 403.
- **Review counts:** the all-language Steam review count could not be confirmed. Requests to the Steam reviews API failed through the proxy.
- **Official sample games:** I found no list of samples bundled with v2.0.

## 5. Asset licensing (EULA) across tools, and implications for a public GPL-3.0 repository

### Takeaway
- **Cross-tool use is allowed:** under Gotcha Gotcha Games' current terms (last updated 2026-06-22), anyone who legitimately bought a GGG product may use its materials in other GGG products. That list now includes ACTION GAME MAKER G, MZ, MV and U2U, so MZ/MV RTP and official DLC can be used in AGM projects, and vice versa.
- **Public redistribution is not allowed:** materials may be passed only to other *Users* (purchasers) free of charge. They must not be distributed to third parties or extracted from games.
- **Consequence for the repository:** proprietary RTP, DLC and AGM-bundled assets **must not be committed to a public GitHub repo**, whatever license the repo carries. GPL-3.0 cannot be applied to them.

### Cited Findings
- **Covered products:** the GGG Products list includes "RPG Maker U2U, Tileset Builder, ACTION GAME MAKER G, RPG Maker MZ, MV, MV Tool SAKAN/MADO/GENE, Pixel Game Maker MV, VX Ace, VX, Samurai Resource Pack, XP, 2000, and 2003". Unite has separate terms. — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **Term dates:** GGG Products Terms effective 2023-04-27, updated 2024-10-08, 2025-06-08 and 2026-06-22. Material Terms updated 2023-05-19 and 2026-06-22. Distribution Terms updated 2026-03-12 and 2026-06-22. — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **Material Terms Art. 1:** "Only users who have purchased the GGG Products in an authorized manner may use Our Material in the GGG Products". The same article mentions "works created with gaming tools from other companies". — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **Material Terms Art. 2:** modified material may be transferred or distributed "only to other Users free of charge". It prohibits distributing "to third-party other than the Users, etc., Our Material". — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **Distribution Terms Art. 2:** "Prohibit the act of extracting and Distribution, etc., of Our Program or Our Material from the User Software". Item F: "Prohibit the act of extracting Our Material from the User Software and using it for their own games". — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **Distribution Terms Art. 1-A:** distributed software must be "created by the User who has purchased the GGG Products in an authorized manner". Games must state they were made with the GGG Products and show the required copyright notices. — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **Add-on Terms:** Official Add-Ons "may be distributed, etc., only if they are distributed, etc., together with the User Software". — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **Restricted sample-game assets:** some sample-game materials are banned from reuse, e.g. RPG Maker MV "Hituji no umi". Pixel Game Maker MV's "DUNGEON OF NAZARICK" and "LA-MULANA2 SAMPLE" are banned from paid distribution. Samurai Resource Pack materials are entirely prohibited. — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **Generative AI:** using GGG products to train generative AI is prohibited unless authorized. — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/); [Maker Series Generative AI Guidelines](https://rpgmakerofficial.com/en/support/faq/guidelines)
- **Conflicting older EULAs:** the rpgmakerweb.com EULA for MZ (Art. 5) requires the Company's "advance written consent" before using Company Assets in games made with third-party tools. MV (KADOKAWA EULA Art. 5) says the same. VX Ace RTP (2012) allows use "with other RPG MAKER products … as long as you own both". — [rpgmakerweb.com/eula](https://www.rpgmakerweb.com/eula)
- **Community answer on DLC in AGM:** an answer on the official Guild (2026-05-21) says RPG Maker DLC can be used in AGM because the GGG terms list AGM. Each DLC readme's conditions still apply: you must be the registered owner, use the pack only for game creation and promotion, and credit the pack's creator. — [Guild topic 1316](https://guild.rpgmakerofficial.com/t/topic/1316)

### Inferences
These are not legal advice.
1. **Keep assets out of the repo.** Do not commit RTP, DLC or AGM built-in assets to the public GPL-3.0 repo. A public GitHub repo distributes to non-Users, which Material Terms Art. 2 prohibits. GPL-3.0 also cannot be granted over assets the repo owner does not own. Keep them out with .gitignore, and document which purchases are required to rebuild the game.
2. **Use separate licenses for code and art.** Put original or CC0/CC-BY art in the repo under a separate content license, and keep GPL-3.0 for the user's own code and scripts. GPL-3.0 is unusual for art. Many projects pair GPL/MIT code with CC-BY-SA assets.
3. **Watch for proprietary GGG files in the project folder.** If an AGM G project contains GGG-proprietary scripts or add-ons, those are covered by the Add-on Terms and cannot be published standalone. Check the project folder before the first push.
4. **Consider a linking exception for the exported game.** The exported game binary combines user code with GGG's proprietary AGM runtime on top of MIT-licensed Godot. Since the user owns their code, licensing it as GPL-3.0 is legal. But third parties who fork it could not lawfully distribute a combined build without a GPL section 7 additional permission ("linking exception"). An alternative is a permissive license such as MIT for the code.
5. **Prefer the newer GGG terms page, but stay cautious.** The rpgmakerweb.com EULA text (third-party tools need written consent) appears older than the GGG rule page (updated 2026-06-22, allowing use in other GGG products). The GGG page is newer and is published by the rights holder. Even so, cautious users should treat non-GGG-engine use (e.g. raw Godot without AGM) as needing consent, especially for MV assets under the KADOKAWA EULA.

### Gaps
- I did not determine what files an AGM G project folder actually contains, and whether any are GGG-proprietary. This needs a local inspection after installing.
- I could not see the exact AGM bundled-asset license text, i.e. whether AGM built-in assets can be used in non-GGG engines. The GGG terms appear to cover AGM's materials, but I found no AGM-specific asset readme.
- I found no official GGG statement about public source repositories (GitHub) specifically.

## 6. Related alternatives: Pixel Game Maker MV, RPG Developer Bakin, plain Godot

### Takeaway
- **Pixel Game Maker MV:** the visual-scripting ancestor of AGM. It is still covered by GGG terms but has been superseded by AGM.
- **RPG Developer Bakin (SmileBoom):** a 3D-map plus 2D-sprite "no code" RPG tool. Press calls its output "HD-2D style". It left Early Access in August 2025 and was updated through November 2026 (v2.7.0.4 on 2026-11-12), with shadow maps, Live2D and DX12.
- **Plain Godot:** free and MIT-licensed. It is the underlying engine for AGM.

### Cited Findings
- **Pixel Game Maker MV:** AGM "builds on the node-based visual scripting system created for 'Pixel Game Maker MV'". — [GameFromScratch 2025-06-16](https://gamefromscratch.com/godot-powered-action-game-maker-released/)
- **PGMMV terms:** Pixel Game Maker MV is in the GGG Products list and uses Qt (LGPL). — [RPG Maker Official rules](https://rpgmakerofficial.com/en/support/rule/)
- **Bakin's approach:** 3D maps with 2D sprites. AUTOMATON EN: "Japanese no-code RPG engine Bakin makes developing HD-2D style games easy". — [AUTOMATON EN](https://automaton-media.com/en/game-development/japanese-no-code-rpg-engine-bakin-makes-developing-hd-2d-style-games-easy-just-start-making-your-game-and-stop-overthinking/)
- **Bakin 1.0:** left Early Access, with full launch in August 2025 (EA began October 2022). — [finalboss.io](https://finalboss.io/rpg-developer-bakin-leaves-early-access-heres-what); [Shazoo 2025-08-28](https://shazoo.ru/2025/08/28/172213/iaponskii-dvizok-bakin-uproshhaet-sozdanie-rpg-v-stile-hd-2d-bez-programmirovaniia)
- **Bakin 2026 updates:**
  - Major update 2026-03-12: battle and shop features. — [AUTOMATON JP](https://automaton-media.com/articles/newsjp/rpg-developer-bakin-20260312-428469/)
  - Shadow maps (Ver. 2.4, around April 2026, per search summary): no direct source fetched.
  - Live2D support (2026-06-18). — [AUTOMATON JP](https://automaton-media.com/articles/newsjp/20260618-450327/)
  - Ver. 2.7 (2026-10-15): improved "3D空間の表現", color correction, DX12 beta, Steam Deck support. — [AUTOMATON JP](https://automaton-media.com/articles/newsjp/20261015-473520/)
  - Ver. 2.7.0.4 on 2026-11-12. — [rpgbakin.com](https://rpgbakin.com/en)
- **Engine detection:** SteamDB has a separate "RPG Developer Bakin" engine-detection page. — [SteamDB tech: Bakin](https://steamdb.info/tech/Engine/RPG_Developer_Bakin)

### Inferences
- For "HD-2D-like" RPG visuals today (November 2026), Bakin is the shipping option, and U2U is the upcoming one. Neither is relevant to a side-scrolling platformer.
- For a platformer, the realistic choice is between AGM G (paid, visual scripting, GGG asset ecosystem) and plain Godot (free, code-first, any license). The repo's GPL-3.0 license fits plain Godot more cleanly. See the section 5 inferences.

### Gaps
- I found no 2025–2026 Pixel Game Maker MV update news.
- I did not fetch Bakin's export targets or pricing.

## 7. Market and scene data: Steam counts, Korean and Japanese scenes, contests

### Takeaway
- **Steam counts:** SteamDB tracks an "RPGMaker" engine technology page, but I could not get a reliable current count. Historical figures: about 1,942 games in 2021 (4th most common engine) and a later estimate of 3,411 (3.3%).
- **Japan:** RPG Atsumaru / Game Atsumaru (niconico) ended in 2023.
- **Contests:** the first official "RPG Maker Award 2026" (February 2026) drew 215 entries. Its Grand Prize went to "Artis Impact".
- **Korea:** Korean-scene data is thin. All current GGG PC tools (MZ, AGM G, U2U) have Korean interfaces on Steam, and MZ is also sold on STOVE.

### Cited Findings
- **Steam engine counts:**
  - SteamDB technology page "Engine » RPGMaker" exists. The page could not be read (SteamDB returns 403 to automated fetches). — [SteamDB tech RPGMaker](https://steamdb.info/tech/Engine/RPGMaker)
  - At the 2021 launch of engine detection, RPGMaker (1,942 games) ranked 4th after Unity, Unreal and GameMaker. — [Game World Observer 2021-08-09](https://gameworldobserver.com/2021/08/09/lars-doucet-launches-new-tool-to-detect-game-engines-used-in-all-titles-on-steam)
  - A later article estimates RPG Maker at 3.3% of Steam games (3,411 games). Its date is not confirmed, and detection undercounts. — [mezha.ua](https://mezha.ua/en/articles/the-most-popular-game-engines-on-steam-unity-unreal-and-what-are-the-others/amp/)
- **RPG Maker Award 2026:** the first edition was announced around 2026-02-09. Grand Prize: "Artis Impact" (from 215 entries). Best RPG: "Beloved Rapture" (Rapturous Studio). Best Adventure: "Flower in Us". — [Gamer.ne.jp 2026-02-09](https://www.gamer.ne.jp/news/202602090002/); [GameBusiness.jp 2026-02-09](https://www.gamebusiness.jp/article/2026/02/09/26166.html); [Final Weapon 2026-02-17](https://finalweapon.net/2026/02/17/rpg-maker-awards-2026-winners/)
- **Artis Impact at BitSummit:** reportedly also won BitSummit's top "Vermilion Gate Award". This comes from a search summary and was not verified by a direct fetch. — [indiegame.com BitSummit report](https://indiegame.com/en/archives/28048?amp=1)
- **RPG Maker Festival 2026:** ran 2026-02-10 to 2026-02-24 (JST). — [rpgmakerofficial.com](https://rpgmakerofficial.com/en/?p=4101)
- **2025 itch.io jams:** RPG Maker 2025 Game Jam (2025-03-20 to 2025-04-21). RPG Maker Asset Contest (2025-03-06 to 2025-05-31, 42 entries). — [itch.io RPG Maker 2025 Game Jam](https://itch.io/jam/rpg-maker-2025-game-jam); [itch.io RPG Maker Asset Contest](https://itch.io/jam/rpg-maker-asset-contest)
- **Japan:** Game Atsumaru (formerly RPG Atsumaru) ended its service in 2023 (2023-06-28 per secondary summary). A project-file download feature was added on 2022-12-20. Some titles moved to "ニコ生ゲーム". PLiCy is a similar service but was not an official successor. — [窓の杜](https://forest.watch.impress.co.jp/docs/news/1466159.html); [窓の杜](https://forest.watch.impress.co.jp/docs/news/1512212.html); [ニコニコ大百科](https://dic.nicovideo.jp/a/%E3%82%B2%E3%83%BC%E3%83%A0%E3%82%A2%E3%83%84%E3%83%9E%E3%83%BC%E3%83%AB); [pixiv百科事典 PLiCy](https://dic.pixiv.net/history/PLiCy/8189649/source)
- **"To the Moon" interview:** AUTOMATON JP interviewed the "To the Moon" developer on why they keep using RPG Maker (2026-08-28). — [AUTOMATON JP](https://automaton-media.com/articles/interviewsjp/to-the-moon-20260828-463781/)
- **Korea, language support:** MZ, AGM G and U2U all list Korean interface support on Steam (fetched 2026-11-16). — [Steam MZ](https://store.steampowered.com/app/1096900/RPG_Maker_MZ/); [Steam AGM G](https://store.steampowered.com/app/2987180/ACTION_GAME_MAKER/); [Steam U2U](https://store.steampowered.com/app/4856440/RPG_MAKER_U2U/)
- **Korea, MZ on STOVE:** MZ reportedly launched on STOVE on 2024-02-15, and its Korean translation carries over translation errors from MV. Source is namu wiki, used for orientation only. — [namu.moe RMMZ](https://namu.moe/w/RMMZ)
- **Korea, slang:** Korean users call RPG Maker "알만툴" (from "RPG 만들기 툴"), and a Korean comment distinguishes "액션게임 메이커 MV (Pixel Game Maker MV)" from 알만툴. The comment surfaced in a search result set, and I could not tell which of the returned pages it came from. The STOVE lounge link below is the most likely match but was not opened. — [STOVE lounge (unverified match)](https://lounge.onstove.com/view/10831602)

### Inferences
- The Japanese browser-hosting niche lost its largest RPG Maker-specific host in 2023. Japanese creators now rely more on Steam, ふりーむ, PLiCy and itch.io. This is an inference, since ふりーむ/unityroom are not verified here.
- Gotcha Gotcha Games is investing in official promotion (the first RPG Maker Award in 2026, BitSummit presence). That suggests a push toward commercial-quality RPG Maker games.

### Gaps
- I found no reliable current (2026) count of RPG Maker games on Steam. SteamDB and Gamalytic could not be read.
- I found no Korean scene data on Tumblbug campaigns, Korean RPG Maker communities or Korean Steam releases. Korean searches returned little.
- I could not verify the status of ふりーむ, unityroom or a "ゲームアツマール" successor in 2026.
- I found no data on AGM-specific contests or shipped AGM games.

## 8. "탈쯔꾸르" (moving beyond the stock RTP look) and HD-2D-like trends

### Takeaway
- **"탈쯔꾸르":** I found no source using or discussing the term. It is unverified as a named trend.
- **HD-2D-like look:** well documented in two places. Bakin (shipping since 2025) is marketed as making "HD-2D style" easy. U2U (announced 2026, unreleased) is widely framed by the press as "HD-2D風" through its P2D system.

### Cited Findings
- Korean-language searches for "탈쯔꾸르" turned up no relevant articles or community posts (searches run 2026-11-16). This is a negative result, with no source to cite.
- **Bakin:** "Japanese no-code RPG engine Bakin makes developing HD-2D style games easy". — [AUTOMATON EN](https://automaton-media.com/en/game-development/japanese-no-code-rpg-engine-bakin-makes-developing-hd-2d-style-games-easy-just-start-making-your-game-and-stop-overthinking/)
- **U2U teaser:** the project teaser was reported as including "HD-2D風" footage (2026-03-26). — [AUTOMATON JP](https://automaton-media.com/articles/newsjp/20260326-432265/)
- **MZ-era tool support for custom looks:**
  - Third-party tools exist for custom map layering in MZ, e.g. a Hakuen Studio map layers plugin and a VisuStella Tiled plugin. — [itch.io Hakuen Studio](https://hakuenstudio.itch.io/hakuen-studio-map-layers-for-rpg-maker-mz); [Yanfly wiki: Tiled VisuStella MZ](https://www.yanfly.moe/wiki/Tiled_VisuStella_MZ)
  - Official store lighting tilesets exist. — [RPG Maker Official Store: KIM Lighting tileset MZ](https://store.rpgmakerofficial.com/products/kim-lighting-tileset-mz)

### Inferences
- The "move beyond RTP look" idea is real in practice: plugins, the 954 MZ DLCs, the Tiled workflow and the RPG Maker Award's emphasis on distinct art. But I could not source the Korean term "탈쯔꾸르" itself.
- For the user's AGM platformer, the closest equivalent is not relying on AGM's 1,000+ bundled assets as the final art. Doing so also keeps the GPL repo clean (section 5).

### Gaps
- I found no Korean or Japanese article that defines or tracks "탈쯔꾸르".
- I found no quantitative data on how many RPG Maker games use custom versus RTP art.

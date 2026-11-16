# Visual Asset Resources for an ACTION GAME MAKER / RPG Maker-style 2D Platformer (비주얼 에셋 리소스와 라이선스)

Research date: 2026-11-16. Scope: tilesets, character/sprite sheets, backgrounds, standing portraits (스탠딩 일러스트) and expression parts, UI, lighting/VFX, plus licenses, tools, and "탈쯔꾸르" (non-RTP look) techniques.

Dead or inaccessible links encountered during research (do not cite as live):
- `https://pipoya.net/sozai/agreement/` returns 404. The live terms page is `https://pipoya.net/sozai/terms-of-use/`.
- `https://timefantasy.net/license` returned HTTP 500 at fetch time (possibly temporary).
- `https://finalbossblues.itch.io/time-fantasy-rpg-assets` returned 404 (the pack may live under a different slug).
- `https://store.rpgmakerofficial.com/pages/rpg-maker-festival-2026-free-dlc` returned 404 (campaign page probably expired).
- `https://opengameart.org/content/faq`, `https://lpc.opengameart.org/`, and OGA LPC licensing article returned 403 to the automated fetcher. They probably still exist for browsers, but their content could not be read directly in this session.

---

## Q1. Official assets: ACTION GAME MAKER (bundled + DLC) and RPG Maker MZ DLC, prices, EULA terms

### Takeaway
ACTION GAME MAKER (AGM, $99.99, now on Godot 4.7.0 per its Steam page) ships with "over 1,000 built-in assets", but its visual DLC is thin and mostly not platformer-specific (RPG Monsters packs, a skin pack for its 2D-bone sample characters, a top-down bullet-hell pack). RPG Maker MZ DLC is large but almost entirely top-down tilesets and side-view *battlers* (not platformer run/jump sprites). The current Japanese GGG product terms let legitimate purchasers use GGG materials in other GGG tools (including AGM) and even in non-GGG tools, but forbid standalone redistribution, extraction, AI training, and require a "made with GGG products" credit; the older English EULA text on rpgmakerweb.com is stricter, so the two documents conflict on third-party-engine use. Official assets can never be committed to a public GPL repo.

### Cited Findings

**ACTION GAME MAKER base product**
- AGM standalone price is $99.99; Steam page states "Access Every 2D Feature of Godot Engine 4.7.0"; "Over 1,000 built-in assets, including images, sounds, animations, and particles"; features "dynamic lights and shadows", "shader-based water", screen/object filters; export to "Windows / macOS / Linux / Web（HTML5） / Android / iOS"; "Completely royalty-free... No fees on sales of the games you create." — [Steam: ACTION GAME MAKER](https://store.steampowered.com/app/2987180/ACTION_GAME_MAKER/)
- Earlier sources described AGM as built on Godot 4.3 / 4.4.1 (version has been updated since the June 16, 2025 release). — [GameFromScratch](https://gamefromscratch.com/godot-powered-action-game-maker-released/); [Wikipedia: Action Game Maker](https://en.wikipedia.org/wiki/Action_Game_Maker); current version per [Steam page](https://store.steampowered.com/app/2987180/ACTION_GAME_MAKER/)
- A search summary of the Japanese store page claimed 400+ SE/music, 400+ images, and 200+ 2D bone animations bundled; the current Steam page only says "over 1,000 built-in assets" without breakdown. Treat the breakdown as unverified. — [Steam (JP/ES variants)](https://store.steampowered.com/app/2987180); [Steam current page](https://store.steampowered.com/app/2987180/ACTION_GAME_MAKER/)
- AGM supports both sprite animation and 2D bone animation, a tile map editor with auto-tiling, visual (node-based) scripting and GDScript (per review/press coverage). — [GameFromScratch](https://gamefromscratch.com/godot-powered-action-game-maker-released/); [Final Weapon review](https://finalweapon.net/2025/07/11/action-game-maker-review-pc-steam/)

**ACTION GAME MAKER DLC (Steam DLC list showed "1-10 of 24 results"; partial listing as of Nov 2026)**
- RPG Monsters Asset Pack 4 and 5 ("ACTION GAME MAKER G - ..."), $5.99 each, released Nov 11, 2026 — pixel monster graphics. — [Steam DLC list](https://store.steampowered.com/dlc/2987180/ACTION_GAME_MAKER/)
- Maker All-Stars Skin Pack, $7.99, released Jun 16, 2025: 20 characters from the MAKER series; skins replace the 2D bone-animation sample characters. — [Steam: Maker All-Stars Skin Pack](https://store.steampowered.com/app/3739220/ACTION_GAME_MAKER__Maker_AllStars_Skin_Pack/); [Steam DLC list](https://store.steampowered.com/dlc/2987180/ACTION_GAME_MAKER/)
- Bullet Hell Assets Pack: Sci-Fi & Japanese Style, $7.99, released Mar 31, 2026: 2 player types, 3 bosses, 11 enemies, 12 bullet types, 2 backgrounds, 4 explosion FX, 2 UI sets, 10 items, 8 obstacles, 1 sample project; tagged "Top-Down Shooter"; requires the base app; no separate terms-of-use section on the page. — [Steam: Bullet Hell Assets Pack](https://store.steampowered.com/app/4559270/ACTION_GAME_MAKER__Bullet_Hell_Assets_Pack_SciFi__Japanese_Style/)
- "HEART WARMING DAYS" $9.99 (type not described on the DLC list). Music/SE packs include Grade D Glitch Arcade ($13.99), Fantasy Fanfare ($14.99), Alchemist Garden Music Pack2 ($19.99), Depths of the World ($24.99), Dusk of the Elves ($24.99), Small Sounds Adventure/Battle/Country/Story ($11.99 each). — [Steam DLC list](https://store.steampowered.com/dlc/2987180/ACTION_GAME_MAKER/)
- Starter Pack bundle (base + Maker All-Stars Skin Pack + Bullet Hell pack) $104.37 after 10% off ($115.97). — [Steam: Bullet Hell pack page](https://store.steampowered.com/app/4559270/ACTION_GAME_MAKER__Bullet_Hell_Assets_Pack_SciFi__Japanese_Style/)

**RPG Maker MZ DLC relevant to visuals**
- Omega Modern Graphics Pack: 26 tileset sheets incl. TileA x10 (ground, water, buildings, walls, floors, dungeons, nature, towns) plus 16 human characters with animated side-view battlers. — [rpgmakerweb.com: Omega Modern Graphics Pack](https://rpgmakerweb.com/dlc/omega-modern-graphics-pack)
- Fantasy Dreamland Starter Pack: 3,200+ tiles, 20 character sprites, 5 boss sprites with side-view battlers. Time Fantasy Side-View Animated Battlers: battle animations for 80 characters from the first two Time Fantasy sets. Other MZ packs found: SRPG Maker Asset Pack, NEONPIXEL Mega Classic set, The Story of Pixels Sunny Village. — [search results incl. dekudeals listings](https://dekudeals.com/items/rpg-maker-mz-time-fantasy-side-view-animated-battlers); [Fantasy Dreamland Extra Pack](https://dekudeals.com/items/rpg-maker-mz-fantasy-dreamland-extra-pack)
- PXL! Pack: NES-themed, 40+ interior/exterior wall tiles and 50+ characters for RPG Maker MZ and MV. — [crackedghostgames.itch.io/pxl-rpgmaker](https://crackedghostgames.itch.io/pxl-rpgmaker)
- No MZ DLC built specifically for side-view platformers was found in this search; "side-view" in MZ DLC means battle sprites (battlers), not run/jump platformer sprites. — [search summary of MZ DLC listings](https://rpgmakerweb.com/dlc/omega-modern-graphics-pack)

**GGG (Gotcha Gotcha Games) product terms — current Japanese terms (rpgmakerofficial.com)**
- Covered products list includes RPGツクールMZ, MV, VX Ace, XP, 2000, 2003, U2U, Tileset Builder and アクションゲームツクールG (ACTION GAME MAKER). — [GGG製品利用規約](https://rpgmakerofficial.com/?p=120)
- 第1条: "本規約は、個人的利用（商業的利用を含みます。）にのみ適用されます。" Corporations excluded (doujin circle representatives covered). — [GGG製品利用規約](https://rpgmakerofficial.com/?p=120)
- 素材利用規約 第1条: "弊社が認める正規の方法でGGG製品を購入したユーザーに限り" materials may be used in works made with non-GGG programs and third-party creation tools; 第2条: standalone commercial use/redistribution of materials not allowed (blog/portfolio use OK). — [GGG製品利用規約](https://rpgmakerofficial.com/?p=120)
- 素材利用規約 第3条: materials from GGG products can be used in other GGG products; RPG Maker Unite materials only if you agree to the Unite terms. Sample-game materials cannot be reused; some materials are limited to non-paid use. — [GGG製品利用規約](https://rpgmakerofficial.com/?p=120)
- ソフトウェア等頒布条件 第2条: must state the game was made with GGG products ("ユーザーソフトウェアがGGG製品で制作されたものであることを明示すること。") and include "RPG MAKERは、株式会社Gotcha Gotcha Gamesの登録商標又は商標です。"; extracting GGG software/materials for distribution is prohibited. — [GGG製品利用規約](https://rpgmakerofficial.com/?p=120)
- Adult/R18: not directly addressed; distributed works must not violate 公序良俗 (頒布条件 第1条1項5号). — [GGG製品利用規約](https://rpgmakerofficial.com/?p=120)
- 第7条2項6号 prohibits "GGG製品の全部又は一部を、弊社が許諾しない方法で生成AIに学習させること。" — [GGG製品利用規約](https://rpgmakerofficial.com/?p=120)

**English EULA on rpgmakerweb.com (older/Western-site text) — conflicts with the above on third-party tools**
- MZ EULA Art. 5(1): users "may not load, use, or otherwise utilize Company Assets into original games created with personally-created programs" without prior consent; Appendix Art. 2: "may not perform Distribution, etc. of individual Company Assets"; Appendix Art. 3 prohibits "Extraction of Company Assets from User Games for use in original games". VX Ace RTP "can be used with other RPG MAKER products from LICENSOR as long as you own both." AGM is not mentioned on this page. — [rpgmakerweb.com/eula](https://www.rpgmakerweb.com/eula); contradicted (for non-GGG tools) by [GGG製品利用規約 素材利用規約 第1条](https://rpgmakerofficial.com/?p=120)

**Third-party DLC in AGM (community answer, not official)**
- On the official RPG Maker Guild (May 21, 2026), a community user (not staff) said RPG Maker DLC packs can be used in AGM because AGM is listed in GGG product terms, provided the pack readme conditions are met: registered owner of the pack, use only for game creation and promotion, and credit the pack's creator in-game. — [RPG Maker Guild topic 1316](https://guild.rpgmakerofficial.com/t/topic/1316)

### Inferences
- For a side-view platformer in AGM, official visual DLC alone will not give a full platformer art set; realistic official contributions are the bundled AGM sample assets (2D bone characters, particles, shader effects) and RPG Monsters packs for enemies. MZ tilesets are top-down and need repainting/re-cutting to work as side-view platform tiles.
- Because the two official license texts conflict on non-GGG tool use, the project should rely only on the rule both agree on: GGG materials used inside GGG products (AGM) by a legitimate owner are OK; every third-party DLC pack must still be checked against its own readme (many third-party MZ DLC have their own credit/ownership clauses).
- Any RTP/DLC images must be excluded from the public GPL repository (`.gitignore` or private submodule), because standalone redistribution and extraction are prohibited under both texts. Collaborators would each need their own license.
- Credit obligations to add to the game credits: "Made with ACTION GAME MAKER (GGG products)" + the trademark notice, plus any DLC creator names.

### Gaps
- Full list of all 24 AGM DLC items (only 13 were visible on the fetched page); whether RPG Monsters Asset Packs 1–3 and "HEART WARMING DAYS" contain graphics.
- Whether AGM-specific DLC carries separate readme/EULA terms beyond GGG product terms (Steam pages show none).
- Exact resolution/format of AGM bundled sprites and 2D bone files (Steam page gives no format details).
- Which of the two GGG license texts governs English-language Steam purchasers in case of conflict; no official statement found.
- MZ DLC Steam prices were not retrieved for individual packs.

---

## Q2. Free/open international asset sources (license, attribution, style, tile size, platformer suitability)

### Takeaway
Safest sources for a public GPL repo are CC0 packs (Kenney, Pixel Frog's Pixel Adventure, Ansimuz Sunny Land, 0x72 DungeonTileset II, Ninja Adventure). LPC is dual CC-BY-SA 3.0 / GPL 3.0 and can be used under GPL 3.0. CraftPix freebies, Szadi Art, and Time Fantasy are commercial-friendly but forbid redistribution/resale of raw files, so they must stay out of the public repo. For side-view platformer use: Pixel Frog, Ansimuz (Sunny Land, Gothicvania, Warped, Legacy, Super Grotto Escape), Szadi "SideScroll Worlds"/"Pixel Fantasy", Kenney platformer packs. Ninja Adventure, 0x72, LPC, Time Fantasy are top-down (useful for RPG-Maker-style sections).

### Cited Findings

**Kenney (kenney.nl)** — CC0
- "all game assets on the asset pages are public domain licensed (CC0)"; "You're free to use them, even in commercial projects."; "Attribution is not required." Kenney logo should not be used separately. — [Kenney support](https://kenney.nl/support)

**Ninja Adventure (Pixel-boy)** — CC0, top-down, 16x16
- "released under the Creative Commons Zero (CC0) license"; "Attribution is not required but appreciated"; "You can use any and all of the assets ... even commercial ones." Tagged 16x16 and Top-Down. Contents: 50+ characters with animations and facesets, 30+ monsters, 9 bosses, 60+ items, tilesets with autotiling, 100+ SFX, 37 music tracks, UI, 30+ VFX, 2 fonts, Godot 3.x and 4.x example projects. "Name your own price." — [itch.io: Ninja Adventure](https://pixel-boy.itch.io/ninja-adventure-asset-pack)

**Pixel Frog — Pixel Adventure 1** — CC0, side-view platformer
- CC0 1.0: "Attribution is not required." "You can distribute, remix, adapt, and build upon the material in any medium or format, even for commercial purposes." Characters, objects, tilesets, items; animations at 20 FPS; genre Platformer; "Name your own price". Pixel Adventure 2 adds 20 enemies. — [itch.io: Pixel Adventure 1](https://pixelfrog-assets.itch.io/pixel-adventure-1)

**Ansimuz** — mixed (Sunny Land CC0; others per-pack)
- Sunny Land listed under "Creative Commons Zero v1.0 Universal"; includes animated player characters, enemies, props, VFX, music, plus Phaser and Godot projects; "Name your own price" with some files shown "if you pay $5 USD or more". — [itch.io: Sunny Land](https://ansimuz.itch.io/sunny-land-pixel-game-art)
- Profile packs: The 16-bit Collection $349.99; Gothicvania Collection $149.99 (Castlevania-style metroidvania); Warped Collection $99.99 (sci-fi cyberpunk); free: Legacy Collection, SunnyLand, Super Grotto Escape (sci-fi cave platformer); Magic Cliffs environment. Profile shows no license text — check each pack page. — [ansimuz.itch.io](https://ansimuz.itch.io/)

**0x72 — 16x16 DungeonTileset II** — CC0 (code MIT)
- Asset license CC0 1.0, code MIT; "You can use this tileset for whatever you like."; "Credit is not necessary"; 16x16 (walls 16x32); v1.7 added autotiles; "Name your own price". Perspective appears 3/4 top-down (inferred from tall walls). — [itch.io: DungeonTileset II](https://0x72.itch.io/dungeontileset-ii)

**Szadi Art** — custom license, commercial OK, resale forbidden
- License: may edit/modify, "sell works created with the assets (games, animations, movies etc)"; may not use in logo/trademark; may not "Resell it, original or modified (partial or complete)"; "Credit is not required but appreciated." No AI clause. Side-view packs: SideScroll Worlds SET1–7 and Worlds 2 sets ($4.80 each), Castle Pack $4.80, Village Packs $5.60, SideScroll Game Player $2, Dark Platformer Complete $7.99, Fantasy Platformer All Sets $6, Pixel Fantasy (Mountain Pass, Castle, Deep Forest, etc.) $3.20 each. — [szadiart.itch.io](https://szadiart.itch.io)

**CraftPix.net** — freebies commercial OK, no source redistribution
- Freebies 2.1.1: "You are permitted to use the resources in any number of personal and commercial projects"; "No attribution or link back to this site is required"; 2.2.1: "You can NOT resell the art source files (PNG, JPG, EPS, Adobe Illustrator, etc) or slightly modified version of the art." Premium 1.1.3: "Distribution of source files is NOT permitted"; 1.2.1: cannot redistribute art "in a manner that would make" files usable to another end user. Section 3.1.1: licensed assets may not be used to train/fine-tune AI/ML systems. — [CraftPix file licenses](https://craftpix.net/file-licenses/)

**Time Fantasy (finalbossblues / Jason Perry)** — commercial OK, any engine, no direct redistribution
- Author comments on itch: edits welcome, "no engine restrictions", OK for commercial use; summarized as "pretty much anything other than redistribute the assets directly"; credit not required ("Final Boss Blues" acceptable); for individual projects, not reselling — selling an engine might count as reselling. Full legal text referenced as GameDevMarket "pro licence" (not retrieved). Style: 16x16 top-down JRPG; MZ DLC versions exist (e.g., Side-View Animated Battlers). — [itch.io comment thread](https://finalbossblues.itch.io/fantasy-rpg-tileset-pack/comments?before=61); [itch.io post](https://itch.io/post/5396576); MZ DLC listing [dekudeals](https://dekudeals.com/items/rpg-maker-mz-time-fantasy-side-view-animated-battlers)

**Liberated Pixel Cup (LPC) / OpenGameArt** — CC-BY-SA 3.0 + GPL 3.0 (dual), top-down 32x32-style
- LPC base assets are dual-licensed GPLv3 and CC BY-SA 3.0 when taken from the Cup proper; some LPC-derived entries add OGA-BY 3.0 or CC-BY 3.0; attribution must be handled per asset (OGA "CREDITS.TXT" files; some state "You MUST include all information in this file"). — [OGA LPC licensing article](https://opengameart.org/content/properly-licensing-your-liberated-pixel-cup-game-entry) (403 to fetcher; info via search snippets); [OGA collection CREDITS.TXT](https://opengameart.org/collection/30330/CREDITS.TXT); [Warptown LPC credits](https://warptown.com/docs/credits/lpc)
- OGA community notes CC-BY / CC-BY-SA 3.0 contain an anti-DRM clause and debate whether Steam distribution conflicts; some artists explicitly waive it ("You may freely use these assets on platforms like iOS or Steam provided you give credit"); one suggestion is shipping a DRM-free copy of CC-BY assets alongside. — [OGA forum node 11881](https://opengameart.org/node/11881); [OGA FAQ update discussion](https://opengameart.org/node/51649)

### Inferences
- Recommended "public-repo-safe" baseline: Pixel Frog Pixel Adventure 1/2 + Ansimuz Sunny Land (both CC0, side-view) for prototype art; Kenney for UI/placeholder; Ninja Adventure / 0x72 for any top-down RPG-style segment.
- A consistent final look is unlikely if mixing many free packs (different palettes, pixel densities). The "탈쯔꾸르" goal argues for using CC0 packs only as placeholders/greyboxing, then replacing with original art.
- Szadi / CraftPix / Time Fantasy / Ansimuz paid packs: use in shipped builds is fine, but keep the raw PNGs out of the public GitHub repo (local `assets_private/`, git-ignored), since their terms forbid making raw files available to other end users.

### Gaps
- Exact tile sizes for Pixel Adventure (commonly 16x16, 32x32 characters) and Sunny Land were not stated on fetched pages.
- Licenses of Ansimuz paid packs (Gothicvania/Warped) — the profile shows none; pack pages not fetched.
- Pixel Frog's Treasure Hunters, Kings and Pigs, Tiny Swords licenses not verified (not mentioned on the fetched page).
- OpenGameArt's official FAQ text could not be fetched (403); OGA-BY license specifics are from memory and not verified this session.
- Time Fantasy's full license text (timefantasy.net/license returned 500; GameDevMarket text not fetched).

---

## Q3. Japanese free material sites (ツクール素材サイト) and character generators

### Takeaway
ぴぽや倉庫 (pipoya) was verified and is one of the most permissive: commercial and age-restricted use allowed, no credit required, usable in any software, modification allowed, but no resale of raw materials (free materials may be redistributed free with the terms attached; paid/support-site materials may not). DOTOWN (前田デザイン室) is commercial-OK with no redistribution. Most other site names in the brief (ドット絵世界, Rド, 白黒洋菓子店, ねくらマップ素材, みにくる, トリスケリオン, 鉱山) could not be verified in this session, nor could Charat's terms.

### Cited Findings
- ぴぽや倉庫 terms are at `/sozai/terms-of-use/` with three tiers (Free / Paid on DLsite・BOOTH / Support-site on Fantia・Ci-en・pixiv FANBOX). Free: "個人・法人、営利・非営利利用での制限はありません。" All tiers: "年齢制限コンテンツでの利用も制限いたしません。"; copyright notice "不要です"; modification allowed ("色変更・コマ数変更・サイズ変更、デザイン調整など自由に加工できます。"). — [ぴぽや倉庫 利用規約](https://pipoya.net/sozai/terms-of-use/)
- Pipoya: scope covers "ソフトウェア・WEBサイト・動画などのデジタルコンテンツ、印刷物などあらゆるコンテンツ" (no RPG Maker lock-in). Redistribution of free materials allowed only "本規約の内容とともに、無償・無条件" ; paid and support-site materials may not be redistributed; selling raw materials as material collections ("素材データを、そのまま素材データ・素材集として転売する行為") prohibited in all tiers; modified free materials must note origin as Pipoya. No AI clause. Individual asset licenses take precedence ("その個別の利用規約を優先とします。"). Scratch use requires credit "ぴぽや". — [ぴぽや倉庫 利用規約](https://pipoya.net/sozai/terms-of-use/); [ぴぽや Scratch notice](https://pipoya.net/sozai/admin/infomation/news20201025/)
- Pipoya also directs overseas users to itch.io where main free materials are distributed. — [ぴぽや Scratch notice](https://pipoya.net/sozai/admin/infomation/news20201025/)
- Pipoya paid BOOTH items (e.g., effect animation sets) state "営利・非営利問わずの利用OK", "スタッフロールなどへの名前の記述・使用連絡不要", "二次配布NG", and that paid and free terms differ slightly. — [BOOTH: ぴぽや エフェクトアニメ素材集](https://booth.pm/ja/items/1122230)
- DOTOWN: free pixel-art material site released in 2022 by 前田デザイン室 (led by ex-Nintendo designer 前田高志); commercial use allowed; redistribution, sale and trademark registration not allowed (per Gizmodo). — [Gizmodo Japan](https://www.gizmodo.jp/2022/02/dotown-free-dot-art-sites.html)
- Charat (キャラット): only secondary description found — a parts-based avatar web service whose avatars can be used as "フリー素材" for SNS icons; no official terms for game use were found. — [ピクシブ百科事典: CHARAT](https://dic.pixiv.net/a/charat)

### Inferences
- Pipoya is the best-verified Japanese source for a GPL public repo: its *free* materials may be redistributed for free if the terms text accompanies them, so they can be committed with a copy of the Pipoya terms in `assets/third_party/pipoya/`. Paid Pipoya materials must stay out of the repo.
- Japanese 素材サイト typically separate "use in a work" (permitted) from "redistribution as material" (forbidden), and often have their own clauses on 公序良俗/R18 and AI; each site's 利用規約 must be checked individually before use, since there is no common license.
- Charat should not be used for a commercial game without official confirmation.

### Gaps
- Could not verify existence or terms for: ドット絵世界, Rド, 白黒洋菓子店, ねくらマップ素材, みにくる, トリスケリオン, 鉱山 (searches returned nothing relevant). Other widely used sites (e.g., First Seed Material, Kure, ゆうひな, Rド?) were not checked — would need direct visits.
- RPG Maker MZ's built-in Character Generator output terms (whether generated faces/sprites count as RTP and inherit GGG terms) — not researched this session.
- Charat official terms (charat.me) not retrieved.
- ニコニ・コモンズ terms not checked.

---

## Q4. Korean free asset sources

### Takeaway
No notable Korean free *game* (pixel/tileset/standing-portrait) asset distribution site was found in this session. Korean RPG Maker communities appear to rely on Japanese sites, itch.io, and RPG Maker DLC.

### Cited Findings
- A Korean search for 쯔꾸르 free pixel/standing-illustration distribution returned only general free resources: e.g., 나인글로리 free sources (pixel patterns, not game sprites; IP retained, credit required for commercial use, banned for contests/portfolios/pattern sales). — [웹툰가이드 리소스 게시판](https://www.webtoonguide.com/ko/board/resource/5771)
- General illustration resources like Open Doodles (CC0) appeared in Korean results but are not game sprite assets. — [GeekNews](https://news.hada.io/topic?id=2106)

### Inferences
- For Korean-language creators, the practical route is the same international + Japanese source mix; Korean community value is more in tutorials/plugins than asset sites.

### Gaps
- Naver Cafe / DC Inside 쯔꾸르 갤러리 resource boards were not searchable/fetchable; existence of Korean asset-sharing boards with clear licenses is unverified.
- Korean community attitudes toward AI art were not found in sources this session.

---

## Q5. License compatibility with a GPL-3.0 code repository and repo structure

### Takeaway
Code (GPL-3.0) and art can carry different licenses in the same repo as long as each is clearly marked. CC0 is unproblematic. CC BY-SA 4.0 is officially one-way compatible with GPLv3; CC BY-SA 3.0 is not on that list (but LPC is dual GPL3/CC-BY-SA3, so use it under GPL3). Proprietary-but-free assets (CraftPix, Szadi, Time Fantasy, RTP/DLC, pipoya paid) cannot be committed to a public repo because they forbid raw redistribution. DRM on Steam is a known friction point for CC-BY(-SA) assets.

### Cited Findings
- Creative Commons: "Version 4.0 of CC's Attribution-ShareAlike (BY-SA) license is one-way compatible" "with the GNU General Public License version 3.0 (GPLv3)"; "This compatibility mechanism is designed for situations in which content is integrated into software code." CC: "We recommend against using Creative Commons licenses for software"; CC licenses can be used for separate artistic elements such as game art or music. — [Creative Commons FAQ](https://creativecommons.org/faq/)
- LPC assets are dual CC-BY-SA 3.0 / GPL 3.0, with some also OGA-BY/CC-BY. — [OGA LPC licensing](https://opengameart.org/content/properly-licensing-your-liberated-pixel-cup-game-entry); [OGA comment](https://opengameart.org/comment/23443)
- CC 4.0 legal code: "You may not offer or impose any additional or different terms or conditions on, or apply any Effective Technological Measures to, the Licensed Material if doing so restricts exercise of the Licensed Rights by any recipient"; licensor waives right to forbid technical modifications needed to exercise rights, including circumventing ETMs. — [CC BY 4.0 legalcode](https://creativecommons.org/licenses/by/4.0/legalcode)
- CC wiki: parallel-distribution exception was considered and rejected in both 3.0 and 4.0; uploads to DRM platforms are acknowledged as a compliance issue. — [CC wiki: 4.0/Technical protection measures](https://wiki.creativecommons.org/4.0/Technical_protection_measures)
- CraftPix forbids distribution of source files; Szadi forbids resale "original or modified"; Time Fantasy forbids redistributing assets directly; GGG forbids standalone distribution/extraction of materials. — [CraftPix](https://craftpix.net/file-licenses/); [Szadi](https://szadiart.itch.io); [Time Fantasy itch comment](https://itch.io/post/5396576); [GGG製品利用規約](https://rpgmakerofficial.com/?p=120)
- Pipoya free materials may be redistributed free together with the terms. — [ぴぽや倉庫 利用規約](https://pipoya.net/sozai/terms-of-use/)

### Inferences
- Recommended repo layout:
  - `LICENSE` (GPL-3.0) for code only; state in README that "GPL-3.0 applies to source code; art/audio licenses are listed in `assets/LICENSES.md` / `CREDITS.md`".
  - `assets/original/` — the team's own art, licensed separately (e.g., CC BY-SA 4.0 for openness and GPLv3 compatibility, or "All rights reserved" if the team wants to sell; note GPL does not force art to be GPL when it is a separate work, but a clear statement avoids ambiguity).
  - `assets/third_party/<source>/` — CC0 / CC-BY / CC-BY-SA / GPL / pipoya-free only, each with its original license file and a CREDITS entry (author, URL, license, modifications).
  - `assets_private/` (git-ignored) — RTP/DLC, CraftPix, Szadi, Time Fantasy, paid packs; build pipeline pulls these locally.
  - Consider the REUSE convention (SPDX headers / `.license` sidecar files) to make per-file licensing machine-readable.
- If any CC BY-SA asset (3.0 especially) ends up in a Steam build, either prefer artists who waive anti-DRM, publish DRM-free (Steam allows DRM-free builds), or avoid SA assets in the shipped game.
- Selling the game is compatible with GPL code + CC0 art; if the team wants proprietary original art, keep it under a non-free license and say so explicitly.

### Gaps
- REUSE specification and FSF license list were not fetched this session (recommendation is from general knowledge).
- Whether AGM's own runtime/editor files that end up in the exported game are compatible with distributing a GPL-3.0 game project (the GGG terms prohibit distributing parts of GGG products; interaction of GPL code with a proprietary engine/runtime) — not researched here; may be covered by another researcher, but it is a real risk for a "GPL-3.0" AGM project.
- OGA-BY 3.0 text not verified.

---

## Q6. Production tools for original art and AI-generated art policies

### Takeaway
Pixel art: Aseprite (source-available paid EULA since 2016), LibreSprite (GPLv2 fork), Pixelorama (MIT, Godot-based). Maps: LDtk and Tiled both have Godot 4 importers (LDtk Importer 2.0.1 for 4.3; YATI for 4.3+), but whether these editor plugins run inside AGM's editor is unverified. Live2D can be used in Godot via the unofficial GDCubism (MIT wrapper, but Cubism SDK proprietary and a paid publication agreement may be required). Steam requires disclosure of player-facing AI content (pre-generated/live-generated); GGG permits AI use at your own responsibility but forbids training AI on GGG assets; Japanese doujin market (DLsite) segregates AI-generated works.

### Cited Findings
**Pixel/2D art tools**
- Pixelorama: free, open source, MIT license, made with Godot Engine / GDScript. — [GitHub: Orama-Interactive/Pixelorama](https://github.com/orama-interactive/pixelorama); [Pixelorama docs FAQ](https://Orama-Interactive.github.io/Pixelorama-Docs/faq)
- Aseprite moved from GPLv2 to a proprietary EULA in v1.1.8 (2016): source can be downloaded/compiled for personal use but not redistributed; LibreSprite forked from the last GPLv2 commit (Aug 26, 2016) and remains GPLv2. — [Wikipedia: Aseprite](https://en.wikipedia.org/wiki/Aseprite); [Aseprite dev blog: new source code license](https://dev.aseprite.org/2016/09/01/new-source-code-license/); [isitreallyfoss](https://isitreallyfoss.com/projects/aseprite)

**Map editors → Godot**
- heygleeson's LDtk Importer: "most fully-featured, up-to-date LDtk Importer Plugin for Godot 4", v2.0.1 for Godot 4.3, imports `.ldtk` as scenes. — [GitHub: godot-ldtk-importer](https://github.com/heygleeson/godot-ldtk-importer); [Godot Asset Library](https://godotengine.org/asset-library/asset/2181)
- YATI (Yet Another Tiled Importer): Godot 4.3+, all layer types and map orientations, animated tiles skipped; older Godot4-TiledImporter is alpha and points to YATI. — [GitHub: Kiamo2/YATI](https://github.com/Kiamo2/YATI); [Godot4-TiledImporter](https://github.com/feendrache/Godot4-TiledImporter)

**Live2D / skeletal**
- GDCubism: unofficial GDExtension for Godot 4.3+ wrapping the Cubism Native Framework; wrapper MIT, but Native Framework is under Live2D Open Software License and Cubism Core under Live2D Proprietary Software License. — [GDCubism docs](https://mizunagikb.github.io/gd_cubism/gd_cubism/0.9/en/index.html)
- Live2D: a paid Publication License Agreement must be entered into before releasing content using the Cubism SDK (to be completed at least one month before release); a third-party LICENSE file cites a 10M JPY annual revenue threshold for "Business" (secondhand). — [Live2D SDK license](https://www.live2d.com/en/sdk/license/); [third-party copy of Live2D license](https://cdn.jsdelivr.net/npm/phaser3-rex-plugins@1.80.20/plugins/gameobjects/live2d/framework/LICENSE.md)
- AGM supports 2D bone animation natively (bundled 2D bone characters; Maker All-Stars pack reskins them). — [Steam: Maker All-Stars Skin Pack](https://store.steampowered.com/app/3739220/ACTION_GAME_MAKER__Maker_AllStars_Skin_Pack/); [GameFromScratch](https://gamefromscratch.com/godot-powered-action-game-maker-released/)

**AI art policies**
- Steamworks content survey: covers AI content "that ships with your game and is consumed by players" (art, sound, narrative, localization); "Efficiency gains through the use of these tools is not the focus of this section." Pre-Generated AI content is evaluated "the same way we evaluate all non-AI content"; Live-Generated AI requires describing guardrails; Valve does not "want to ship Live-Generated AI Adult Only Sexual Content at this time." — [Steamworks: Content Survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey)
- Third-party reports: Valve revised the AI disclosure form around Jan 16–17, 2026 to focus on player-facing content and exempt dev tools (e.g., code assistants); disclosures shown in an "AI Generated Content Disclosure" store section; >7,300 games disclosed AI content by March 2026 (unverified third-party stat). — [tbreak](https://tbreak.com/steam-ai-disclosure-policy-update-developers/); [BigGo Finance](https://finance.biggo.com/news/202601171220_Steam_AI_Disclosure_Update_Focuses_on_Player_Content); [dig.watch](https://dig.watch/updates/new-steam-rules-redefine-when-ai-use-must-be-disclosed)
- GGG Generative AI guidelines: "Using AI as a tool to help create your game is generally allowed"; "If you own the rights to the content, you may use it with AI at your own responsibility"; prohibited: training AI on GGG engine/core scripts/official assets, publishing datasets with GGG assets; no disclosure requirement stated. — [GGG Generative AI Guidelines](https://rpgmakerofficial.com/en/?p=4228)
- DLsite: suspended sales of AI-generated works in May 2023 (games/novels were outside the suspension; partial AI use not targeted); in Feb 2024 resumed with a separate "AI生成フロア" and per-circle monthly limits. — [AUTOMATON](https://automaton-media.com/en/nongaming-news/20230512-18862/); [窓の杜](https://forest.watch.impress.co.jp/docs/news/1569791.html)
- FANZA同人 reportedly began reducing exposure of AI works from summer 2025 with categories "AI生成 / AI一部使用 / AI補助" (secondary Chinese-language report; unverified). — [toy-people](https://www.toy-people.com/?p=101168)

### Inferences
- Tool stack suggestion: Aseprite (or free Pixelorama/LibreSprite) for sprites; Krita/CLIP STUDIO for high-res portraits; AGM's built-in tilemap for maps (LDtk/Tiled only if their importers can run inside AGM or via a plain Godot project → AGM scene import).
- For a GPL project with community contributions, MIT/GPL tools (Pixelorama, LibreSprite, Krita) keep the pipeline reproducible for contributors.
- If AI art is used, it must be disclosed on Steam and is reputationally risky in the Japanese doujin/ツクール scene (AI segregation on DLsite/FANZA); never feed RTP/DLC assets into AI (GGG prohibits training).

### Gaps
- Whether AGM's editor accepts Godot editor plugins (addons like LDtk Importer/YATI/GDCubism GDExtension) — not confirmed by any source found.
- Krita license (GPL) and Spine pricing/Godot runtime were not verified this session.
- Korean community AI attitudes: no sources found.
- Official Valve announcement text for the Jan 2026 revision (only third-party summaries found; the Steamworks doc itself is cited above).

---

## Q7. Techniques for the "탈쯔꾸르" look in a Godot-based tool (lighting, parallax, layering, HD-2D-like post)

### Takeaway
Because AGM exposes Godot's 2D renderer, the full 2D lighting stack (CanvasModulate ambient, PointLight2D/DirectionalLight2D, LightOccluder2D shadows, normal/specular maps via CanvasTexture), HDR-2D glow/bloom via WorldEnvironment, Parallax2D layered backgrounds, and custom shaders (vignette, fog, god rays, heat haze, wind grass) are available; an official-category AGM guild tutorial ships sample shaders for exactly these effects.

### Cited Findings
- Godot 2D lighting: CanvasModulate sets ambient base color; PointLight2D for torches/fire; DirectionalLight2D for sun/moon (shadows infinitely long unless a custom SDF shader is used); LightOccluder2D defines shadow casters (can auto-generate from Sprite2D); normal and specular maps assigned via CanvasTexture; shadow filters None/PCF5/PCF13; blend modes Add/Subtract/Mix; additive sprites as cheap light alternatives; lighting is computed at viewport resolution, so pixel-art-consistent lighting needs a shader snapping LIGHT_VERTEX/SHADOW_VERTEX. — [Godot docs: 2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
- Godot HDR 2D: since Godot 4.2, HDR can be enabled for 2D (Forward+/Mobile) via Rendering > Viewport > HDR 2D; alternative cheaper glow with Background=Canvas and lowered glow HDR threshold; Canvas Max Layer controls which layers get glow. — [godot-docs PR diff](https://github.com/godotengine/godot-docs/pull/8285.diff); [Godot docs: Environment and post-processing](https://docs.godotengine.org/en/4.5/tutorials/3d/environment_and_post_processing.html)
- A forum thread suggests 2D glow threshold behavior changed in Godot 4.6 (unverified). — [Godot forum](https://forum.godotengine.org/t/2d-glow-threshold-removed-from-4-6/140229)
- AGM "Manual: Shader&HDR Sample" (RPG Maker Guild, OfficialTutorial category, June 16, 2026): enable HDR 2D in Project Settings; WorldEnvironment glow; sprite RAW values >1.0 emit glow; sample shaders Shader_Vignette, Shader_Fog, Godray, Heat_Noise, Shadow_Gradation, grass_windshader (on TileMap layer), RainDropEffect; particles Sparkle/Snow/Fluff/rain/rainsplash; ACES tonemap; CanvasModulate after bloom to keep glow bright in dim scenes; DirectionalSunLight2D/PointSunlight2D in grassland; HDR threshold 1.1 in snow scene; GlowMap for neon city color bleeding; AGM filters/screen effects/water nodes are shader-based. — [RPG Maker Guild: Shader&HDR Sample](https://guild.rpgmakerofficial.com/t/topic/1337?tl=en)
- Godot Parallax2D: recommended over ParallaxBackground/ParallaxLayer (change from pre-4.3 guidance); scroll_scale per-axis multiplier (e.g., forest 0.7, sky 0.1); repeat_size for infinite scrolling; repeat_times for zoom-out; split-screen via cloning into SubViewports. — [Godot docs: 2D parallax](https://docs.godotengine.org/en/stable/tutorials/2d/2d_parallax.html)
- AGM Steam page advertises "dynamic lights and shadows", "shader-based water", "beautifully reflective water", filters on screen or specific objects. — [Steam: ACTION GAME MAKER](https://store.steampowered.com/app/2987180/ACTION_GAME_MAKER/)

### Inferences
- "탈쯔꾸르" checklist for a side-view platformer in AGM:
  1. Replace grid-tile look with layered scenes: background Parallax2D layers (sky 0.1, far mountains 0.3, mid forest 0.7), gameplay TileMap layer, foreground occluding props layer (scroll >1.0) for depth.
  2. Hand-painted "parallax mapping" style: paint large background/foreground images over a collision TileMap (the RPG Maker "parallax mapping" technique transfers directly as Sprite2D/Parallax2D layers).
  3. Lighting: dark CanvasModulate + PointLight2D on torches/player, LightOccluder2D on terrain, normal maps for hero/props (tools like Laigter/SpriteIlluminator generate them — unverified here).
  4. Post: HDR 2D + glow, vignette, fog/god-ray shaders, heat haze, color grading via tonemap/contrast/saturation (as in the AGM HDR sample).
  5. "HD-2D-like" tilt-shift/depth-of-field: no native 2D DOF; achievable with a screen-space blur shader masked by vertical gradient or by blurring far parallax layers (inference).
- Keep pixel-perfect consistency: snap lights to the pixel grid or render at low resolution and upscale, otherwise smooth lights over chunky pixels can look off-style.

### Gaps
- No source fetched on tilt-shift/DOF shaders for Godot 2D or on normal-map generation tools (Laigter, SpriteIlluminator).
- Whether AGM exposes Godot's custom shader editing UI fully (the AGM sample says shaders are written in a shader language but does not confirm custom shader authoring support).
- Godot 4.6/4.7 changes to 2D glow not confirmed.

---

## Q8. Standing illustration (스탠딩 일러스트 / 立ち絵) and portrait systems: resolution, expression parts, lip-flap/blink

### Takeaway
No single standard resolution was found. RPG Maker MZ's fixed face sheet is 144x144 per face (4x2 grid), which is the baseline that plugins like "Talking Faces" build on. Layered 立ち絵 conventions from Japanese tools (YMM4, TyranoScript) split parts into folders like 眉/目/口/髪 with numbered frames for blink (e.g., `パーツ名.png` open, `パーツ名.0.png` closed) and mouth-flap.

### Cited Findings
- Talking Faces for RPG Maker MZ uses the standard MZ face sheet format: 4 columns x 2 rows, 8 faces, 144x144 px per face; plays talk animation when a matching `_talk` file exists. — [itch.io: Talking Faces](https://danramone.itch.io/talking-faces)
- YMM4 "動く立ち絵" guide: parts organized in folders such as 「眉」「目」「口」「髪」; blink uses eye images named 「パーツ名.png」 (open) and 「パーツ名.0.png」 (closed) frames. — [YMM4 FAQ: 動く立ち絵素材の作り方](https://www.manjubox.net/ymm4/faq/立ち絵機能/動く立ち絵素材の作り方)
- SinTachiePlugin (YMM4) treats difference images in arbitrarily named folders (e.g., 目, 体) as parts for layered 立ち絵. — [SinTachiePlugin scrapbox](https://scrapbox.io/SinTachiePlugin/sin%E5%9E%8B%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%A0%E3%83%91%E3%83%BC%E3%83%84%E7%AB%8B%E3%81%A1%E7%B5%B5%E3%83%97%E3%83%A9%E3%82%B0%E3%82%A4%E3%83%B3)
- A 目パチ・口パク (blink/lip-flap) plugin page exists in the violetgametips knowledge base (ツクール context). — [violetgametips: 目パチ・口パクプラグイン](https://scrapbox.io/violetgametips/目パチ・口パクプラグイン)
- Live2D via GDCubism is an option for animated portraits in Godot 4.3+ (licensing caveats in Q6). — [GDCubism docs](https://mizunagikb.github.io/gd_cubism/gd_cubism/0.9/en/index.html)

### Inferences
- Practical spec for AGM (1920x1080 output): draw portraits at roughly full screen height (≈1000–1400 px tall) or 2x for crispness, export as layered PNGs: `body_base`, `outfit`, `hair_back`/`hair_front`, `brow_{neutral,angry,sad,...}`, `eyes_{open,half,closed}` × expression, `mouth_{closed,half,open}` × expression, `blush`/`sweat`/`tears` overlays. Composite at runtime with stacked Sprite2D/AnimatedSprite2D nodes; blink = random timer cycling eyes open→half→closed→open; lip-flap = cycle mouth frames while text is printing.
- AGM's native 2D bone animation (or Godot Skeleton2D) can add breathing/sway to portraits without Live2D's licensing overhead.
- Pixel-art games often pair a high-res portrait with pixel sprites; for style unity, consider pixel-art busts (e.g., 96–192 px) scaled with nearest-neighbor.

### Gaps
- No authoritative source on "typical" 立ち絵 resolution in commercial ツクール/AGM games.
- Did not verify whether AGM has a built-in message/portrait system with expression switching (would need AGM manual).
- Krita/CLIP STUDIO PSD export workflows to Godot (e.g., PSD importer plugins) not researched.

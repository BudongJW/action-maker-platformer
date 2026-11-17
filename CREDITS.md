# CREDITS

게임 내 크레딧 화면과 배포물 동봉 문서의 원본입니다. **게임에 들어가는 모든 외부 요소**를 여기에 적습니다. 저장소에 커밋하지 않는 `assets_private/` 에셋도 크레딧 의무가 있으면 반드시 포함합니다(입수 방법은 [`SOURCES.md`](SOURCES.md)에 따로 기록).

출시 전에 각 약관 원문을 다시 확인하고, 이 파일의 내용을 게임 내 크레딧과 배포물의 `CREDITS.txt`(또는 동봉 문서)에 반영합니다.

---

## 1. 필수 표기: Gotcha Gotcha Games (ACTION GAME MAKER G)

출처: [GGG Products Terms of Use](https://rpgmakerofficial.com/en/support/rule/) (2026-06-22 개정, 2026-11-17 확인)

- [ ] 동봉 문서(없으면 사용자가 볼 수 있는 곳)에 GGG 제품으로 제작했음을 명시
- [ ] 오프닝 크레딧에 GGG 제품 로고와 지정 표기를 가능한 한 표시 (로고 파일은 GGG 배포본 사용, 저장소에 커밋하지 않음)
- [ ] 저작권 표기: `©2025 Gotcha Gotcha Games Inc.`
- [ ] 상표 표기: `RPG MAKER is a registered trademark or trademark owned by Gotcha Gotcha Games Inc.`
- [ ] GGG의 사전 허가 없이 GGG를 개발사·퍼블리셔로 표기하지 않음
- [ ] 개인 이용 기준 약관임. 법인·단체로 출시하면 별도 계약 필요

표기 예시:

```
Made with ACTION GAME MAKER G
©2025 Gotcha Gotcha Games Inc.
RPG MAKER is a registered trademark or trademark owned by Gotcha Gotcha Games Inc.
```

## 2. 엔진: Godot Engine (MIT)

ACTION GAME MAKER G는 Godot Engine을 기반으로 합니다. Godot의 MIT 라이선스는 배포물에 저작권 표기와 라이선스 전문을 포함하도록 요구합니다. 엔진에 포함된 서드파티 구성 요소(FreeType 등)의 표기도 필요하며, 전체 목록은 런타임에서 `Engine.get_copyright_info()`와 `Engine.get_license_info()`로 얻을 수 있습니다. 참고: [Complying with licenses](https://docs.godotengine.org/en/stable/about/complying_with_licenses.html)

ACTION GAME MAKER G의 내보내기 기능이 이 표기를 자동으로 넣는지는 확인되지 않았습니다. 확인 전까지는 직접 넣습니다.

```
This game uses Godot Engine, available under the following license:

Copyright (c) 2014-present Godot Engine contributors.
Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 3. 외부 에셋

`assets/third_party/`(커밋됨)와 `assets_private/`(커밋 안 됨) 에셋을 모두 적습니다. CC0처럼 크레딧이 필수가 아니어도 출처 추적을 위해 기록합니다.

2026-11-17에 수집한 CC0 팩 25종은 프리프로덕션용 참고 자료·임시 아트입니다. 최종 게임에 실제로 쓰는 팩만 남기고, 쓰지 않는 행은 출시 전에 크레딧 화면 원고에서 빼도 됩니다(CC0이므로 표기 의무 없음). 팩 목록과 미리보기는 [`assets/third_party/README.md`](assets/third_party/README.md)에 있습니다.

| 에셋 | 작가 | 출처 URL | 라이선스 | 크레딧 필수 | 위치 | 크레딧 문구 |
|---|---|---|---|---|---|---|
| GothicVania Cemetery Pack | ansimuz (Luis Zuno) | https://opengameart.org/content/gothicvania-cemetery-pack | CC0 1.0 | 아니오 | assets/third_party/ansimuz-gothicvania-cemetery/ | GothicVania Cemetery Pack by ansimuz (Luis Zuno) |
| GothicVania Church Pack | ansimuz (Luis Zuno) | https://opengameart.org/content/gothicvania-church-pack | CC0 1.0 | 아니오 | assets/third_party/ansimuz-gothicvania-church/ | GothicVania Church Pack by ansimuz (Luis Zuno) |
| Gothicvania Town | ansimuz (Luis Zuno) | https://opengameart.org/content/gothicvania-town | CC0 1.0 | 아니오 | assets/third_party/ansimuz-gothicvania-town/ | Gothicvania Town by ansimuz (Luis Zuno) |
| Gotthicvania Swamp | ansimuz (Luis Zuno) | https://opengameart.org/content/gotthicvania-swamp | CC0 1.0 | 아니오 | assets/third_party/ansimuz-gothicvania-swamp/ | Gotthicvania Swamp by ansimuz (Luis Zuno) |
| Free Graveyard Platformer Tileset | pzUH (gameart2d.com) | https://opengameart.org/content/free-graveyard-platformer-tileset | CC0 1.0 | 아니오 | assets/third_party/pzuh-graveyard-platformer-tileset/ | Free Graveyard Platformer Tileset by pzUH (gameart2d.com) |
| Graveyard Platformer 32x Tileset | Vicplay | https://opengameart.org/content/graveyard-platformer-32x-tileset | CC0 1.0 | 아니오 | assets/third_party/vicplay-graveyard-platformer-32x/ | Graveyard Platformer 32x Tileset by Vicplay |
| Seamless 2D Graveyard Background | LarryIRL | https://opengameart.org/content/seamless-2d-graveyard-background | CC0 1.0 | 아니오 | assets/third_party/larryirl-seamless-graveyard-background/ | Seamless 2D Graveyard Background by LarryIRL |
| Haunted Forest Trees + Misc. Dark Fantasy Scenery Sprites | ETTiNGRiNDER | https://opengameart.org/content/haunted-forest-trees, https://opengameart.org/content/misc-dark-fantasy-scenery-sprites | CC0 1.0 | 아니오 | assets/third_party/ettingrinder-dark-fantasy-scenery/ | Haunted Forest Trees + Misc. Dark Fantasy Scenery Sprites by ETTiNGRiNDER |
| Spooky House + RPG Asset Tile Set 'Cemetery' NES | Chasersgaming | https://opengameart.org/content/spooky-house, https://opengameart.org/content/rpg-asset-tile-set-cemetery-nes | CC0 1.0 | 아니오 | assets/third_party/chasersgaming-spooky-house-and-cemetery/ | Spooky House + RPG Asset Tile Set 'Cemetery' NES by Chasersgaming |
| haunted graveyard tileset | biodegradableguy | https://opengameart.org/content/haunted-graveyard-tileset | CC0 1.0 | 아니오 | assets/third_party/biodegradableguy-haunted-graveyard-tileset/ | haunted graveyard tileset by biodegradableguy |
| 1-Bit Graveyard Pixel Art Asset Pack (+ Halloween icons) | Fava Beans | https://opengameart.org/content/1-bit-graveyard-pixel-art-asset-pack | CC0 1.0 | 아니오 | assets/third_party/fava-beans-1-bit-graveyard/ | 1-Bit Graveyard Pixel Art Asset Pack (+ Halloween icons) by Fava Beans |
| Skeleton and Ghost spritesheets (Ars Notoria) | Balmer | https://opengameart.org/content/skeleton-and-ghost-spritesheets-ars-notoria | CC0 1.0 | 아니오 | assets/third_party/balmer-skeleton-ghost/ | Skeleton and Ghost spritesheets (Ars Notoria) by Balmer |
| Forest / Graveyard tileset | marionline | https://opengameart.org/content/forest-graveyard-tileset | CC0 1.0 | 아니오 | assets/third_party/marionline-forest-graveyard-tileset/ | Forest / Graveyard tileset by marionline |
| Fumiko Complete Charset | skoam (Sylvius Fischer) | https://opengameart.org/content/fumiko-complete-charset | CC0 1.0 | 아니오 | assets/third_party/skoam-fumiko-charset/ | Fumiko Complete Charset by skoam (Sylvius Fischer) |
| 32x32 RPG Character Sprites | Eldiran | https://opengameart.org/content/32x32-rpg-character-sprites | CC0 1.0 | 아니오 | assets/third_party/eldiran-32x32-rpg-character-sprites/ | 32x32 RPG Character Sprites by Eldiran |
| RPG character sprites | GrafxKid | https://opengameart.org/content/rpg-character-sprites | CC0 1.0 | 아니오 | assets/third_party/grafxkid-rpg-character-sprites/ | RPG character sprites by GrafxKid |
| 24x32 bases | Cabbit | https://opengameart.org/content/24x32-bases | CC0 1.0 | 아니오 | assets/third_party/cabbit-24x32-bases/ | 24x32 bases by Cabbit |
| Puny Characters | Shade | https://opengameart.org/content/puny-characters | CC0 1.0 | 아니오 | assets/third_party/shade-puny-characters/ | Puny Characters by Shade |
| Pixel Adventure 1 | Pixel Frog | https://pixelfrog-assets.itch.io/pixel-adventure-1 | CC0 1.0 | 아니오 | assets/third_party/pixelfrog-pixel-adventure-1/ | Pixel Adventure 1 by Pixel Frog |
| Ninja Adventure - Asset Pack | Pixel-boy and AAA | https://pixel-boy.itch.io/ninja-adventure-asset-pack | CC0 1.0 | 아니오 | assets/third_party/pixel-boy-ninja-adventure/ | Ninja Adventure - Asset Pack by Pixel-boy and AAA |
| Zelda-like tilesets and sprites | ArMM1998 | https://opengameart.org/content/zelda-like-tilesets-and-sprites | CC0 1.0 | 아니오 | assets/third_party/armm1998-zelda-like-tilesets/ | Zelda-like tilesets and sprites by ArMM1998 |
| Simple broad-purpose tileset | surt (contributors: Sharm, surt, vk) | https://opengameart.org/content/simple-broad-purpose-tileset | CC0 1.0 | 아니오 | assets/third_party/surt-simple-broad-purpose-tileset/ | Simple broad-purpose tileset by surt (contributors: Sharm, surt, vk) |
| Roguelike/RPG pack | Kenney (with Lynn Evers) | https://opengameart.org/content/roguelikerpg-pack-1700-tiles | CC0 1.0 | 아니오 | assets/third_party/kenney-roguelike-rpg-pack/ | Roguelike/RPG pack by Kenney (with Lynn Evers) |
| 1-Bit Pack 1.1 | Kenney | https://opengameart.org/content/1-bit-pack | CC0 1.0 | 아니오 | assets/third_party/kenney-1-bit-pack/ | 1-Bit Pack 1.1 by Kenney |
| 16x16 DungeonTileset II v1.7 (+ pumpkin_dude Halloween character) | 0x72 (Robert) | https://0x72.itch.io/dungeontileset-ii | CC0 1.0 | 아니오 | assets/third_party/0x72-dungeontileset-ii/ | 16x16 DungeonTileset II v1.7 (+ pumpkin_dude Halloween character) by 0x72 (Robert) |

<!--
작성 예시:
| Pixel Adventure 1 | Pixel Frog | https://pixelfrog-assets.itch.io/pixel-adventure-1 | CC0 1.0 | 아니오 | assets/third_party/pixelfrog-pixel-adventure-1/ | Pixel Adventure by Pixel Frog |
| (BGM 제목) | 魔王魂 | https://maou.audio/ | CC BY 4.0 + 사이트 규칙 | 예 | assets_private/audio/bgm/ | 音楽：魔王魂 |
| (곡 제목) | Kevin MacLeod | https://incompetech.com/ | CC BY 4.0 | 예 | assets/third_party/incompetech/ | "곡 제목" Kevin MacLeod (incompetech.com) Licensed under Creative Commons: By Attribution 4.0 License |
-->

## 4. 외부 코드·애드온

| 애드온 | 저작권자 | 출처 URL | 라이선스 | 위치 |
|---|---|---|---|---|
| _(아직 없음)_ | | | | |

<!--
작성 예시:
| Dialogue Manager | Nathan Hoad | https://github.com/nathanhoad/godot_dialogue_manager | MIT | addons/dialogue_manager/ |
-->

## 5. 오리지널 콘텐츠

| 분야 | 제작자 |
|---|---|
| _(아직 없음)_ | |

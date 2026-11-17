# 디자인 레퍼런스: 쯔꾸르풍 2D 픽셀 캐릭터·호러·맵

조사일: 2026-11-17. 이 문서는 아트 방향을 정할 때 참고할 **규격·레퍼런스 게임·학습 자료·팔레트·맵 도구·구매처**를 한곳에 모은 것입니다. 저장소에 커밋한 CC0 에셋 팩은 아래 [수집한 에셋 목록](#수집한-에셋-목록)에 정리했습니다.

## 개요

### 범위와 다른 문서와의 관계

| 주제 | 이 문서 | 이미 정리된 곳 (중복하지 않음) |
|---|---|---|
| 쯔꾸르 버전별 그래픽 규격, AGM G 타일 규칙 | 1절 | AGM G 연혁·엔진 버전은 [`tool_landscape.md` 4절](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/tool_landscape.md) |
| 호러 게임의 **화면 연출** | 2절 | 같은 게임들의 **서사·엔딩 구조**는 [`narrative_case_studies.md`](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/narrative_case_studies.md) |
| 픽셀아트 학습 자료, 호러 팔레트 | 3~4절 | 제작 도구 라이선스·AI 정책은 [`visual_assets.md` Q6](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/visual_assets.md) |
| 맵 디자인 자료와 도구 | 5절 | Godot 조명·Parallax2D·HDR 등 "탈쯔꾸르" 구현 기법은 [`visual_assets.md` Q7](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/visual_assets.md) |
| 스탠딩 일러스트 규격 | (다루지 않음) | [`visual_assets.md` Q8](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/visual_assets.md) |
| 재배포 불가 구매처 | 6절 | 무료·CC0 소스와 일본 소재 사이트는 [`visual_assets.md` Q2·Q3](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/visual_assets.md) |

### 표기 규칙

- 외부 사실에는 모두 출처 링크를 붙였습니다. 공식 문서가 없어 커뮤니티 글에 기댄 값은 **(커뮤니티)**, 직접 확인하지 못한 값은 **미확인**으로 표시합니다.
- **(추론)**은 출처가 아니라 이 프로젝트를 위한 해석입니다.
- 가격은 2026-11-17 Steam 미국 스토어 기준이며 바뀔 수 있습니다.

### 레퍼런스 사용 원칙

1. **2절의 게임은 분석 대상일 뿐입니다.** 캐릭터·괴물 디자인, 맵 배치, UI, 컷인 연출을 다시 그리거나 트레이스하거나 "오마주"로 재현하지 않습니다. 색 사용 방식, 화면 구성, 정보 노출 타이밍 같은 **원리**만 가져옵니다.
2. 레퍼런스 스크린샷·팬아트를 저장소에 커밋하지 않습니다. 링크로만 남깁니다.
3. 에셋을 실제로 들일 때는 [`assets/README.md`](../assets/README.md)의 분류를 따릅니다. 원본 재배포가 명시적으로 허용되지 않으면 `assets_private/` + [`SOURCES.md`](../SOURCES.md)입니다.

## 수집한 에셋 목록

2026-11-17에 수집한 **CC0 1.0** 팩 25종이 [`assets/third_party/`](../assets/third_party/README.md)에 커밋되어 있습니다. 각 폴더에 `LICENSE`(출처 URL + CC0 법률 문구), `SOURCE.md`(작가·제외한 파일·내용), `preview.png`(미리보기 시트)가 있습니다. 크레딧은 의무가 아니지만 [`CREDITS.md`](../CREDITS.md)에 모두 기록했습니다.

용도는 **스타일 연구와 임시 아트(그레이박싱)** 입니다. 팩마다 팔레트와 픽셀 밀도가 달라 여러 팩을 섞으면 화면이 통일되지 않으므로, 프로토타입마다 1~2개 팩만 고르고 최종 아트는 오리지널로 교체하는 것을 전제로 합니다. 쯔꾸르 규격과의 관계는 [쯔꾸르 그래픽 규격](#1-쯔꾸르-그래픽-규격) 표와 함께 보세요.

### 호러: 횡스크롤 (플랫포머 본편에 가장 가까움)

| 폴더 | 규격·시점 | 볼 만한 점 |
|---|---|---|
| [`ansimuz-gothicvania-cemetery`](../assets/third_party/ansimuz-gothicvania-cemetery/preview.png) | 16x16 타일, 캐릭터 프레임 100x59, 패럴랙스 배경 3장 | 보라·남색 위주의 저채도 팔레트, 랜턴 든 유령, 해골이 땅에서 일어나는 연출 프레임 |
| [`ansimuz-gothicvania-church`](../assets/third_party/ansimuz-gothicvania-church/preview.png) | 16x16 타일, Aseprite 원본(`.ase`) 포함 | 실내 고딕 성당 배경 모듈, 천사·불타는 구울·해골 마법사 |
| [`ansimuz-gothicvania-town`](../assets/third_party/ansimuz-gothicvania-town/preview.png) | 16x16 타일, 주민 NPC 걷기·대기 | 밤 마을 배경 레이어, 주민 NPC 4종의 걷기 사이클 |
| [`ansimuz-gothicvania-swamp`](../assets/third_party/ansimuz-gothicvania-swamp/preview.png) | 16x16 타일, `.ase` 원본 포함 | 늪 배경 3레이어, 거미·늪괴물·유령 |
| [`pzuh-graveyard-platformer-tileset`](../assets/third_party/pzuh-graveyard-platformer-tileset/preview.png) | 128x128 타일(벡터 원본 SVG) | 카툰풍 묘지. 고해상도 비픽셀 스타일 비교용 |
| [`vicplay-graveyard-platformer-32x`](../assets/third_party/vicplay-graveyard-platformer-32x/preview.png) | 32x32 타일 75개 | 배경색(0,128,128)이 투명 처리되어 있지 않음 |
| [`larryirl-seamless-graveyard-background`](../assets/third_party/larryirl-seamless-graveyard-background/preview.png) | 1918x1079 배경 2장 | 이어 붙이면 끊김 없이 스크롤되는 묘지 배경 |
| [`ettingrinder-dark-fantasy-scenery`](../assets/third_party/ettingrinder-dark-fantasy-scenery/preview.png) | 페인팅풍 소품 | 고목, 쇠사슬·갈고리, 새장, 해골 장식 등 분위기 소품 |

### 호러: 탑다운 (쯔꾸르식 탐색 구간)

| 폴더 | 규격·시점 | 볼 만한 점 |
|---|---|---|
| [`chasersgaming-spooky-house-and-cemetery`](../assets/third_party/chasersgaming-spooky-house-and-cemetery/preview.png) | 16x16(흉가, 4색), 8x8·16x16(NES 팔레트 묘지) | 4색만으로 흉가를 만드는 제한 팔레트 예시 |
| [`biodegradableguy-haunted-graveyard-tileset`](../assets/third_party/biodegradableguy-haunted-graveyard-tileset/preview.png) | 224x96 시트, Endesga 32 팔레트 | 작은 묘지 타일셋 |
| [`fava-beans-1-bit-graveyard`](../assets/third_party/fava-beans-1-bit-graveyard/preview.png) | 16x16, 1비트 205종 + UI 아이콘 55종 | 흑백 1비트 호러 톤 실험용 |
| [`balmer-skeleton-ghost`](../assets/third_party/balmer-skeleton-ghost/preview.png) | 25x35 프레임, DB32 팔레트 | 유령 색상 바리에이션(기본·녹색·적색) |
| [`marionline-forest-graveyard-tileset`](../assets/third_party/marionline-forest-graveyard-tileset/preview.png) | 20x20 타일(OHRRPGCE용), 팔레트 포함 | `map.bmp`는 샘플 맵이 아니라 타일셋 BMP 판 |

### 캐릭터

| 폴더 | 규격·시점 | 쯔꾸르 규격과의 차이 |
|---|---|---|
| [`skoam-fumiko-charset`](../assets/third_party/skoam-fumiko-charset/preview.png) | 탑다운, 864x256 시트 1장 | 여전사 1명의 전체 동작 세트. 셀 배치는 쯔꾸르 표준이 아님 |
| [`eldiran-32x32-rpg-character-sprites`](../assets/third_party/eldiran-32x32-rpg-character-sprites/preview.png) | 탑다운 32x32 셀(384x672 = 12열x21행) | 셀 크기는 VX/VX Ace와 같지만 배치가 달라 재배열 필요 |
| [`grafxkid-rpg-character-sprites`](../assets/third_party/grafxkid-rpg-character-sprites/preview.png) | 탑다운, 128x128 시트 | 빈 템플릿 캐릭터 포함 |
| [`cabbit-24x32-bases`](../assets/third_party/cabbit-24x32-bases/preview.png) | 24x32 4방향 보행 + 얼굴 템플릿(마른·통통 체형) | 쯔꾸르 2000(24x32 셀)과 같은 셀 크기라 오리지널 캐릭터를 그릴 때 바탕으로 쓰기 좋음 |
| [`shade-puny-characters`](../assets/third_party/shade-puny-characters/preview.png) | 32x32 캔버스, **8방향**, 대기·걷기·공격·피격·사망 | 쯔꾸르(4방향)보다 방향이 많음 |
| [`pixelfrog-pixel-adventure-1`](../assets/third_party/pixelfrog-pixel-adventure-1/preview.png) | **횡스크롤** 32x32 캐릭터 4종, 20 FPS | 플랫포머 조작감 프로토타입용 |
| [`pixel-boy-ninja-adventure`](../assets/third_party/pixel-boy-ninja-adventure/preview.png) | 탑다운 16x16, 캐릭터별 `SpriteSheet.png`(4열x7행) + `Faceset.png`(38x38) | 쯔꾸르 페이스 그래픽처럼 쓸 수 있는 얼굴 이미지가 캐릭터마다 있음. 오디오는 제외 |

### 맵·타일셋

| 폴더 | 규격 | 볼 만한 점 |
|---|---|---|
| [`armm1998-zelda-like-tilesets`](../assets/third_party/armm1998-zelda-like-tilesets/preview.png) | 16x16, 필드·동굴·실내 | 탑다운 맵 구성의 기본 세트 |
| [`surt-simple-broad-purpose-tileset`](../assets/third_party/surt-simple-broad-purpose-tileset/preview.png) | 800x1280 시트, Arne 16색 팔레트 | 16색 제한 팔레트 예시 |
| [`kenney-roguelike-rpg-pack`](../assets/third_party/kenney-roguelike-rpg-pack/preview.png) | 16x16, 타일 사이 1px 여백, Tiled 샘플 맵 2개(`Map/*.tmx`) | 실외·실내 샘플 맵이 있어 맵 배치 참고용 |
| [`kenney-1-bit-pack`](../assets/third_party/kenney-1-bit-pack/preview.png) | 16x16, 흑백·컬러, 샘플 맵 이미지 4장(`Sample_*.png`) + Tiled 원본 | 판타지·실내·플랫포머·도시 샘플 맵 이미지 |
| [`0x72-dungeontileset-ii`](../assets/third_party/0x72-dungeontileset-ii/preview.png) | 16x16(벽 16x32), Godot 3x3 최소 오토타일 규칙 | 어두운 던전, 좀비·악마 몬스터. AGM G(Godot 기반) 오토타일과 구조가 맞음 |

맵 **이미지**가 바로 있는 팩: `kenney-1-bit-pack/Sample_*.png`, `pixel-boy-ninja-adventure/Example 5 ( Old Version).png`, 각 GothicVania 팩의 배경·`environment-preview.png`.

### 검토했지만 커밋하지 않은 것

| 후보 | 이유 |
|---|---|
| ぴぽや(Pipoya) itch.io 무료 캐릭터 32x32·RPG 타일셋 32x32 | itch.io 페이지 라이선스가 "Not redistribute or resell this assets." 게임에는 쓸 수 있으나 `assets_private/` 대상 ([캐릭터](https://pipoya.itch.io/pipoya-free-rpg-character-sprites-32x32), [타일셋](https://pipoya.itch.io/pipoya-rpg-tileset-32x32)) |
| Mage City Arcanos (Hyptosis, OGA, CC0) | 작가 설명이 "rpgmakerxp 타일셋을 전면 변환한 것". RTP 파생물일 수 있음 ([OGA](https://opengameart.org/content/mage-city-arcanos)) |
| 2d JRPG dot character (OGA) | 일본 작가 소재를 제3자가 올린 것. 원 사이트 약관 미확인 |
| Misc household items (NaRNeRZz, OGA) | 일부가 다른 작가의 선화를 바탕으로 함. 그 라이선스 미기재 |
| GothicVania 팩의 음악(Pascal Belisle) | "크레딧 표기 시 프로젝트에 사용 가능"만 명시, 파일 재배포 허용 문구 없음 |
| Ninja Adventure 오디오 | 용량(약 100MB) 때문에 제외. CC0이므로 필요하면 원본에서 받으면 됨 |

---

## 1. 쯔꾸르 그래픽 규격

RPG Maker 시리즈는 탑다운 RPG용 규격입니다. 횡스크롤 플랫포머에 그대로 쓰지는 않지만, AGM G가 MV/MZ 형식을 바로 임포트하고(1.3절) 대부분의 쯔꾸르 소재가 이 규격으로 유통되므로 기준표로 둡니다.

### 1.1 버전별 요약

| 버전 | 타일 | 맵 시트 | 걷기 캐릭터 | 얼굴 | 전투 그래픽 | 기본 화면 |
|---|---|---|---|---|---|---|
| **2000 / 2003** | 16x16 | ChipSet 1장 480x256 | CharSet 288x256 = 8명(4x2), 1명당 3프레임 x 4방향, 프레임 24x32 | FaceSet 192x192, 얼굴 48x48 (4x4) | 몬스터 최대 320x160. 2003 사이드뷰 BattleCharSet 144x384(48x48 프레임 3열 x 8행) | 320x240 |
| **XP** | 32x32 (미확인) | 가로 256px 타일셋 + 오토타일 96x128 (미확인) | "스프라이트 시트에 특정 크기 규정 없음". 1파일 1캐릭터 4x4(4프레임 x 4방향) 배치는 미확인 | 기본 얼굴 그래픽 없음 (미확인) | 임의 크기 (미확인) | 640x480 |
| **VX / VX Ace** | 32x32 | A1·A2 512x384, A3 512x256, A4 512x480, A5 256x512, B~E 512x512 (커뮤니티) | 셀 32x32, 1명당 3x4, 1장 8명(4x2), `$`·`!` 접두사 (커뮤니티) | 96x96, 4x2 = 8개 (커뮤니티) | 프런트뷰 적: 임의 크기 (미확인) | 544x416 |
| **MV** | 48x48 | A1·A2 768x576, A3 768x384, A4 768x720, A5 384x768(8x16), B~E 768x768(16x16) | 셀 기본 48x48(변경 가능), 1명당 3x4, 1장 8명(4x2) → 576x384 | 144x144, 4x2 = 8개 | 사이드뷰 아군 576x384 = 9x6 칸(칸당 64x64, 계산값), 적 임의 크기(짝수 폭 권장) | 816x624 |
| **MZ** | 기본 48x48, 16·24·32·48 선택 | MV와 같음 | MV와 같음 | MV와 같음 | MV와 같음 | 기본 816x624, System 2에서 변경 |

출처:

- **2000/2003**: [EasyRPG: 미디어 파일 규격](https://wiki.easyrpg.org/development/rtp-replacement/media-file-format-specifications). 화면 320x240은 같은 문서의 Title·Frame 크기(320x240)와 "4:3, 예: 320x240" 권장에서 읽은 값입니다. 얼굴 크기는 검색 요약에서 본 rpgmaker.net 포럼 글에 "42x42, 16개"라는 다른 값이 있었으나, 사이트가 자동 열람을 막아 원문을 확인하지 못했습니다 (미확인).
- **XP**: 640x480과 "no specific image size regulation for sprite sheets"는 [Wikipedia: RPG Maker](https://en.wikipedia.org/wiki/RPG_Maker_XP). 나머지 값은 공식 문서를 찾지 못했습니다.
- **VX / VX Ace**: 타일 32x32는 공식 블로그 [Upcycling VX Ace Tiles for MV/MZ](https://rpgmakerweb.com/blog/upcycling-vx-ace-tiles-for-mv-mz). 시트 크기는 [LimeZu의 itch.io 댓글](https://itch.io/post/1601056)(커뮤니티)이며 MV 공식값의 정확히 2/3입니다. Ace 캐릭터 시트를 MV/MZ에 "크기 조정 없이" 넣을 수 있다는 점(같은 배치)은 공식 블로그 [Charsets: structure and avoiding traps](https://rpgmakerweb.com/blog/charsets-structure-and-avoiding-traps). 화면 544x416은 [MV 도움말: 새 기능](https://rpgmakerofficial.com/product/MV_Help/page/01_01_01_02.html)("544x416에서 816x624로"). VX는 고유 타일 수 제한이 있었고 Ace에서 풀렸습니다 ([Wikipedia](https://en.wikipedia.org/wiki/RPG_Maker_VX)).
- **MV**: [MV 도움말: Asset Standards](https://rpgmakerofficial.com/product/MV_Help/page/01_11_01.html), [MV 도움말: Side-view Character Standards](https://rpgmakerofficial.com/product/MV_Help/page/01_11_02.html), 화면은 [MV 도움말: 새 기능](https://rpgmakerofficial.com/product/MV_Help/page/01_01_01_02.html).
- **MZ**: [MZ 도움말: Asset Standards](https://rpgmakerofficial.com/product/MZ_help-en/01_11_01.html), [MZ 도움말: 사이드뷰 규격](https://rpgmakerofficial.com/product/MZ_help-en/01_11_02.html). 타일 크기 선택은 [Steam: RPG Maker MZ](https://store.steampowered.com/app/1096900/RPG_Maker_MZ/). 화면 크기를 System 2에서 바꾼다는 점은 [MZ 도움말: System 2](https://rpgmakerofficial.com/product/MZ_help-en/01_08_12_02.html)에 있으나 기본값은 적혀 있지 않아, 816x624는 [zenn.dev 글](https://zenn.dev/tonbi/articles/b08b4c4bf2b850)(커뮤니티) 기준입니다.

### 1.2 MV/MZ 시트 세부 규칙

| 규칙 | 내용 | 출처 |
|---|---|---|
| 셀 크기 | 자유. 단 한 시트 안의 셀은 모두 같아야 함. 캐릭터 크기 = 파일 폭의 1/12, 높이의 1/8 | [MZ Asset Standards](https://rpgmakerofficial.com/product/MZ_help-en/01_11_01.html), [공식 블로그](https://rpgmakerweb.com/blog/charsets-structure-and-avoiding-traps) |
| 방향 순서 | 위에서부터 아래·왼쪽·오른쪽·위. 가운데 열이 정지 프레임, 걷기는 2-1-2-3 반복 | [공식 블로그](https://rpgmakerweb.com/blog/charsets-structure-and-avoiding-traps) |
| `$` 접두사 | 파일 1개 = 캐릭터 1명(3x4 한 벌) | 같은 곳 |
| `!` 접두사 | 6px 위로 올려 그리는 오프셋 제거 + 수풀 반투명 무시. 문·상자 같은 오브젝트용. `!$` 병용 가능 | 같은 곳 |
| 원경(parallaxes) | 임의 크기, 반복 시 가장자리 연결. 파일명 앞 `!`이면 시차 없이 바닥처럼 고정 | [MZ Asset Standards](https://rpgmakerofficial.com/product/MZ_help-en/01_11_01.html) |
| 기타 | 전투 배경 1000x740, 타이틀 816x624, 애니메이션 셀 192x192(MV) | [MV Asset Standards](https://rpgmakerofficial.com/product/MV_Help/page/01_11_01.html) |
| 사이드뷰 모션 | 3프레임 = 1모션. 대기 모션은 1-2-3-2 반복, 피격 등은 1-2-3 1회 | [MZ 사이드뷰 규격](https://rpgmakerofficial.com/product/MZ_help-en/01_11_02.html) |

### 1.3 ACTION GAME MAKER G (Godot 기반)

AGM G에는 RPG Maker 같은 고정 규격표가 공개되어 있지 않습니다. 공식 튜토리얼과 Godot 문서로 확인한 내용은 다음과 같습니다.

| 항목 | 내용 | 출처 |
|---|---|---|
| 타일 크기 | 고정값 없음. TileSet의 Tile Size를 "만든 타일 1개 크기에 맞춰" 설정. 공식 샘플 타일은 24x24 | [RPG Maker Guild 공식 튜토리얼: Graphics Course #1](https://guild.rpgmakerofficial.com/t/topic/27?tl=en) (GGG-Administrator, 2025-05) |
| 맵 노드 | TileMapLayer 사용(TileMap은 구형 기능). 충돌에는 TileSet의 Physics Layer가 필요 | 같은 곳 |
| 오토타일 | Godot Terrain 기능 사용. 형식에 맞는 이미지는 24x24가 아니어도 자동 설정됨 | 같은 곳, [일본어판](https://guild.rpgmakerofficial.com/t/topic/54) |
| 배경 | 배경을 3개 레이어로 나눈 Parallax2D. Repeat Size는 보통 텍스처 크기와 같게 | 같은 곳 |
| 쯔꾸르 소재 임포트 | v2.0부터 "RPG Maker MV/MZ 형식 캐릭터 시트와 타일셋을 버튼 하나로 임포트". Tile Palette로 여러 씬에서 공유 | [공식 뉴스: v2.0 출시](https://rpgmakerofficial.com/en/news/4271/) |
| 타일 모양 | Godot TileSet은 정사각형 외에 직사각형·아이소메트릭·육각형 지원 | [Godot 문서: Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html) |
| 기본 해상도 | **미확인** (공식 문서 없음) | — |
| 픽셀아트 해상도 권장(Godot) | stretch mode `viewport`, scale mode `integer`. 640x360이 좋은 기준(720p·1080p·1440p·4K로 정수배). 대부분의 픽셀 게임은 256x224~640x480 | [Godot 문서: Multiple resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html) |

**(추론) 이 프로젝트에 대한 시사점**

- 횡스크롤에서는 타일 크기보다 **"캐릭터 키 : 타일 : 화면 높이" 비율**이 먼저입니다. 예를 들어 640x360 화면에 16px 타일이면 세로 22.5타일, 24px면 15타일이 보입니다. 첫 프로토타입 전에 하나로 고정합니다.
- MV/MZ 임포트 기능은 48px 탑다운 소재용입니다. 플랫포머 본편에 섞으면 픽셀 밀도가 어긋나므로, 탑다운 막간 장면이나 그레이박스 용도로만 씁니다.
- 조명·후처리 구현은 [`visual_assets.md` Q7](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/visual_assets.md)을 따릅니다. 저해상도 뷰포트를 정수배로 키우면 조명도 픽셀 격자에 맞게 계산되어 도트와 어울립니다.

---

## 2. 호러 쯔꾸르 비주얼 레퍼런스

서사·반전·엔딩 분석은 [`narrative_case_studies.md`](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/narrative_case_studies.md)에 있으므로, 여기서는 **화면에 보이는 것**만 다룹니다. "확인된 특징"은 출처에 적힌 내용, "볼 것"은 직접 플레이·영상으로 관찰할 포인트(추론)입니다.

> 다시 한 번: 아래 작품의 캐릭터·괴물·맵을 재현하지 않습니다. 원리만 가져옵니다.

### 2.1 쯔꾸르·WOLF RPG 에디터 계열 (탑다운)

| 작품 | 연도·엔진 | 확인된 특징 | 볼 것 (추론) |
|---|---|---|---|
| [Yume Nikki](https://en.wikipedia.org/wiki/Yume_Nikki) ([Steam](https://store.steampowered.com/app/650700)) | 2004, RPG Maker 2003 | 평론가들이 "독특한 초현실 비주얼"을 높이 평가. 레이어 효과와 눈길을 끄는 애니메이션으로 좋은 비주얼을 냈다는 평. 허브 Nexus의 문마다 고유 환경. 이펙트 24종이 외형을 바꿈. Ao Oni·Ib 등 인디 호러에 영향 | 구역마다 팔레트·패턴을 통째로 바꾸는 방식. 외형 변화로 능력을 보여 주는 방식 |
| [Ao Oni](https://en.wikipedia.org/wiki/Ao_Oni) | 2004 첫 공개, 2011 최종판, RPG Maker XP | 그래픽은 "기능적일 뿐"이라는 평. 괴물이 무작위·스크립트 시점 양쪽에서 추격. BGM이 분위기의 핵심 | 그래픽 품질보다 **등장 타이밍**이 공포를 만드는 사례. 추격 시작 직전의 정적 |
| [Corpse Party (원작)](https://en.wikipedia.org/wiki/Corpse_Party) | 1996, PC-9801, RPG Tsukūru Dante 98 | 리메이크 *Blood Covered* 등에서 더미헤드 마이크로 "입체 음향"을 녹음(원작 적용 여부는 문서에 없음). 리메이크마다 그래픽 갱신 | 저해상도 화면을 소리로 보완하는 설계 |
| [Ib](https://en.wikipedia.org/wiki/Ib_%28video_game%29) ([Steam 리메이크](https://store.steampowered.com/app/1901370)) | 2012, RPG Maker 2000 (게임 목록 문서는 2003으로 기재, 출처 충돌). 2022 리메이크 MV | 정적과 갑작스러운 소리로 허를 찌름. Famitsu "귀엽지만 섬뜩함". 적과 싸우지 않고 도망. 그림이 살아 움직임. HP = 장미 꽃잎. 리메이크는 그래픽 갱신 | 미술관 액자·조각 같은 **평범한 오브젝트가 적이 되는 순간**의 프레이밍. HP를 화면 속 사물로 표시 |
| [The Witch's House](https://en.wikipedia.org/wiki/The_Witch%27s_House) ([Steam MV](https://store.steampowered.com/app/885810)) | 2012, RPG Maker VX. 2018 MV 리메이크 | 조감 시점의 "화려한 16비트 그래픽". 수수께끼·점프스케어·함정·고어. MV판은 그래픽 전부 재작업 | 즉사 함정 직전의 "이상한 디테일" 배치. 귀여운 맵과 고어의 대비 |
| [Mad Father](https://en.wikipedia.org/wiki/Mad_Father) ([Steam](https://store.steampowered.com/app/483980)) | 2012, WOLF RPG Editor. 2020 리메이크 | "제한된 8비트 비주얼"로도 공포를 만든다는 평(TheGamer). 전기톱 추격, QTE 탈출 | 저해상도 사망 장면을 암시로 처리하는 방식 |
| [Misao](https://en.wikipedia.org/wiki/Misao_%28video_game%29) ([Steam](https://store.steampowered.com/app/691450)) | 2011, WOLF RPG Editor. 2017 Definitive, 2024 HD 리마스터 | Definitive판에서 일부 그래픽·민감 묘사를 바꿈. HD판은 그래픽을 HD 에셋으로 교체 | 같은 장면을 수위별로 다르게 그린 사례 (등급 대응 참고) |
| Paranoiac / [The Crooked Man](https://store.steampowered.com/app/736570) | Uri, WOLF RPG Editor. Crooked Man Steam 2018 | 번역판 페이지가 추격 장면·점프스케어를 내용 경고로 명시. 원작 연도는 출처마다 달라 미확인 | 일상 공간(이사한 집)이 점점 뒤틀리는 연출 — [vgperson: Paranoiac](https://www.vgperson.com/games/paranoiac.htm), [vgperson: The Crooked Man](https://vgperson.com/games/crookedman.htm) |
| [OFF](https://en.wikipedia.org/wiki/Off_%28video_game%29) | 2008, RPG Maker 2003. 2025 리메이크(Fangamer, Unity) | Zone마다 연기 광산·금속 농장·도서관 등 재료 테마. "기이한 상징"(PC Gamer) | 구역 = 재료 1개 = 팔레트 1개로 묶는 방식 |
| [LISA: The Painful](https://en.wikipedia.org/wiki/Lisa:_The_Painful) ([Steam](https://store.steampowered.com/app/335670)) | 2014, RPG Maker VX Ace | **2D 횡스크롤 오버월드**. EarthBound 화풍이 주된 영감. "RPG Maker 엔진을 한계까지 밀어붙였다"는 평 | 쯔꾸르 계열로 횡스크롤 화면을 만든 가장 가까운 선례 |
| [Fear & Hunger](https://en.wikipedia.org/wiki/Fear_%26_Hunger) ([Steam](https://store.steampowered.com/app/1002300)) | 2018, RPG Maker MV | 개발자가 노린 "끝없는 어둠의 감각". 분위기 호평, "그림 품질이 들쭉날쭉"하다는 지적(RPS) | 어둠으로 정보를 가릴 때 생기는 득실 |
| [OMORI](https://en.wikipedia.org/wiki/Omori_%28video_game%29) ([Steam](https://store.steampowered.com/app/1150690)) | 2020, RPG Maker MV | 밝고 아이 같은 세계 ↔ "글리치, 흑백, 불길한" 화풍의 대비. 여러 화풍이 섞인 몬스터가 공포를 키운다는 평(PC Gamer). 애니풍 컷인 | **같은 캐릭터를 두 화풍으로** 그려 세계 전환을 알리는 방식 |
| [In Stars and Time](https://en.wikipedia.org/wiki/In_Stars_and_Time) | 2023, RPG Maker MV | 흑백 그래픽을 "단순함을 위해" 선택. 단색 팔레트가 주제와 맞는다는 평 | 1인 개발에서 색 수를 줄여 작업량을 통제한 사례 |
| 학생들의 공포괴담 終 ([Steam](https://store.steampowered.com/app/1627040)) | 2021, Alman, RPG Maker XP(한국) | 한국 학교 괴담 소재 (출처: [narrative_case_studies.md Q3](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/narrative_case_studies.md)) | 시각 연출은 미조사 |

### 2.2 횡스크롤·2.5D 호러 (플랫포머에 직접 참고)

| 작품 | 연도·엔진 | 확인된 특징 | 볼 것 (추론) |
|---|---|---|---|
| [Detention](https://en.wikipedia.org/wiki/Detention_%28video_game%29) ([Steam](https://store.steampowered.com/app/555220)) | 2017, Red Candle Games, Unity | "1960년대 계엄기 대만의 2D 분위기 호러 횡스크롤". 대만 종교·신화 요소 | 지역 민속을 배경 소품·간판·부적으로 녹이는 방식. 한국 소재로 옮길 때의 기준점 |
| [The Coma: Recut](https://store.steampowered.com/app/600090) | 2017, Dvora Studio | "2D 손그림 비주얼", Side Scroller 태그. 그림자에 웅크려 숨기, 발소리로 살인마 접근 감지. 세화고 배경, "한국 호러를 생존 어드벤처에 녹였다"는 소개 | 숨는 동안의 화면 연출(전경 가림, 소리 단서) |
| [LIMBO](https://en.wikipedia.org/wiki/Limbo_%28video_game%29) ([Steam](https://store.steampowered.com/app/48000)) | 2010, Playdead 자체 엔진 | 어두운 그레이스케일, 필름 그레인, 조명이 필름 누아르에 비유됨. 실루엣으로 정체를 숨김. 실수를 막으려고 잔혹한 사망 애니메이션 사용("trial and death") | 실루엣 + 전경 레이어로 깊이감. 사망 연출이 학습 장치가 되는 방식 |
| [INSIDE](https://en.wikipedia.org/wiki/Inside_%28video_game%29) ([Steam](https://store.steampowered.com/app/304430)) | 2016, Playdead, Unity + 자체 렌더링 | 대부분 단색 계열, "색은 플레이어와 환경 일부를 강조할 때만" 씀. 2.5D. 사망 장면이 사실적·잔혹해 ESRB M | **색 = 신호** 규칙. 등급 영향 |
| [Little Nightmares](https://en.wikipedia.org/wiki/Little_Nightmares) ([Steam](https://store.steampowered.com/app/424840)) | 2017, Tarsier Studios, Unreal Engine 4 | 2.5D 퍼즐 플랫포머. 아홉 살 주인공 vs 거대한 어른의 크기 대비. 개발자는 "숨바꼭질"이라 부름. 눈 감시 장치의 빛에 닿으면 석화. 노란 우비 | 크기 대비로 무력감을 만드는 구도. 빛 자체가 위험인 장치 |
| [FAITH: The Unholy Trinity](https://store.steampowered.com/app/1179080/FAITH_The_Unholy_Trinity/) | 2022, Airdorf Games / New Blood | "고전 8비트에서 영감 받은 픽셀 호러", 굵은 픽셀, 수작업 로토스코프 애니메이션. 시점(탑다운 여부)은 페이지에 없음 | 극저해상도 화면 + 매끄러운 로토스코프 동작의 대비 |
| [World of Horror](https://en.wikipedia.org/wiki/World_of_Horror) ([Steam](https://store.steampowered.com/app/913740)) | 얼리 액세스 2020, 정식 2023, panstasz | 1비트 픽셀아트를 MS 그림판으로 제작. 이토 준지·러브크래프트가 주 영감. PC-98·초기 Mac 화면을 연상 | 2색 제약이 오히려 스타일이 되는 사례 |
| [Rusty Lake Hotel](https://en.wikipedia.org/wiki/Rusty_Lake_Hotel) ([Steam](https://store.steampowered.com/app/435120)) | 2015~2016, Rusty Lake(암스테르담) | 포인트앤클릭. 기괴한 분위기, Edward Gorey에 비유된 그림. 무료 Cube Escape 시리즈와 세계관 공유 | 정지 화면 한 장의 구도와 소품 배치 |

### 2.3 플랫포머로 옮길 연출 체크리스트 (추론)

| 기법 | 근거 사례 | AGM G 구현 메모 |
|---|---|---|
| 어둠 오버레이 + 플레이어 주변 광원 | Fear & Hunger, Witch's House | CanvasModulate + PointLight2D ([Q7](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/visual_assets.md)). 단, 너무 어두우면 플레이어에게 필요한 정보까지 가린다는 지적이 있음 ([rpgmaker.net 포럼](https://rpgmaker.net/forums/topics/22419), 검색 요약) |
| 실루엣과 전경 레이어 | LIMBO | 스크롤 배율 1.0 초과 전경 Parallax2D |
| 색을 신호로만 사용 | INSIDE, In Stars and Time | 단색 팔레트 + 강조색 1개 (4절 팔레트) |
| 크기 대비 | Little Nightmares | 추격자 스프라이트를 플레이어의 2~3배 크기로 |
| 예측 불가 추격 | Ao Oni, The Coma | 화면 밖 진입, 숨는 지점, 짧은 체크포인트 간격 |
| 점프스케어 프레이밍 | Ib, Witch's House | 카메라 고정 → 정적 → 소리 → 등장. 같은 패턴 반복 금지 |
| 세계 전환 = 화풍 전환 | OMORI, Yume Nikki | 현실/이계 팔레트 교체 셰이더 |
| 사망 연출 | LIMBO, INSIDE | 학습을 돕되 등급(사실적 잔혹 묘사)을 함께 결정 |

---

## 3. 픽셀아트 튜토리얼·학습 자료

| 자료 | 형태·가격 | 이 프로젝트에 쓸 부분 |
|---|---|---|
| [Pedro Medeiros (saint11) 튜토리얼](https://saint11.art/blog/pixel-art-tutorials/) | 이미지 튜토리얼, 무료 (Patreon·itch.io 묶음으로 후원) | 걷기(Walk), 달리기(RunCycleSimple), 점프, 사망, 타일(Tiles), 어둠(Darkness), 조명 기법(IlluminationTechniques), 셰이딩, 1-bit. 제목은 페이지의 이미지 파일명 기준 |
| [Slynyrd Pixelblog](https://www.slynyrd.com/pixelblog-catalogue) (Raymond Schlitter) | 블로그, 무료 | [1 Color Palettes](https://www.slynyrd.com/blog/2018/1/10/pixelblog-1-color-palettes), [6 Light and Shadow](https://www.slynyrd.com/blog/2018/6/15/pixelblog-6-light-and-shadow), 8 Intro to Animation, [23 Parallax Scrolling](https://www.slynyrd.com/blog/2019/11/12/pixelblog-23-parallax-scrolling), 28 Side View Tiles, [50 Human Walk Cycle](https://www.slynyrd.com/blog/2024/5/24/pixelblog-50-human-walk-cycle), [62 Landscape Backgrounds](https://www.slynyrd.com/blog/2026/5/27/pixelblog-62-landscape-backgrounds) |
| [Lospec Pixel Art Tutorials](https://lospec.com/pixel-art-tutorials) | 튜토리얼 디렉터리(확인 시 586개), 무료 | 태그 [character](https://lospec.com/pixel-art-tutorials/tags/character), [walkcycle](https://lospec.com/pixel-art-tutorials/tags/walkcycle), [tileset](https://lospec.com/pixel-art-tutorials/tags/tileset), [shading](https://lospec.com/pixel-art-tutorials/tags/shading), [dithering](https://lospec.com/pixel-art-tutorials/tags/dithering), [palettes](https://lospec.com/pixel-art-tutorials/tags/palettes). 조명·호러 전용 태그는 보이지 않음 |
| [Pixel Joint](https://pixeljoint.com/) | 갤러리·포럼, 무료 | [튜토리얼 모음 페이지](https://pixeljoint.com/pixels/tutorials.asp)(자체·외부·일반 미술). 갤러리에서 저색수 작품 연구 |
| [Derek Yu: Pixel Art Tutorial](https://www.derekyu.com/makegames/pixelart.html) | 텍스트, 무료 | 96x96 스프라이트 한 장을 팔레트 선택 → 외곽선 → 계단 현상(jaggies) 정리 순으로 완성하는 입문 글 |
| [Pixel Logic](https://michafrar.gumroad.com/l/pixel-logic) (Michael Azzi) | **유료** PDF. 242쪽, 가격은 $9~10로 보도됨 ([80.lv](https://80.lv/articles/pixel-logic-a-pixel-art-tutorial-book/)). 공식 페이지에서 현재 가격 확인 실패 → 미확인 | 시각 위주 기법서. 팀 공용 구매 여부는 라이선스 확인 후 결정 |
| [MortMort](https://www.youtube.com/@MortMort) | YouTube, 무료 | 채널 소개문이 비어 있음. 최근 영상은 밀기·던지기·수영 등 플랫포머 캐릭터 애니메이션 작업 공유 |
| [AdamCYounis](https://www.youtube.com/@AdamCYounis) | YouTube, 무료 | 채널 소개: "게임 개발 튜토리얼, 아트 작업, 에세이, 브이로그" |
| [Brandon James Greer](https://www.youtube.com/@bjgpixel) | YouTube, 무료 | 채널 소개: 픽셀아트 구성의 "기술적 측면과 설계 선택"을 다룸 |

**(추론) 학습 순서 제안:** 팔레트 고르기(Slynyrd 1 → 4절) → 걷기·달리기(Slynyrd 50, saint11 Walk) → 횡스크롤 타일(Slynyrd 28) → 어둠·조명(Slynyrd 6, saint11 Darkness·IlluminationTechniques) → 원경(Slynyrd 23·62). 도구는 [`visual_assets.md` Q6](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/visual_assets.md)과 5.3절을 봅니다.

---

## 4. 호러용 팔레트 (Lospec)

확인한 Lospec 팔레트 페이지에는 라이선스 문구가 없어서 색 값(hex)은 싣지 않고 링크만 둡니다. 각 페이지에서 PNG·GPL·ASE 등으로 내려받을 수 있습니다. 색 수와 작성자는 2026-11-17 각 페이지 기준입니다.

| 팔레트 | 작성자 | 색 수 | 메모 (페이지 설명·태그) |
|---|---|---|---|
| [A Blood-Steeped Corridor](https://lospec.com/palette-list/a-blood-steeped-corridor) | Polyducks | 5 | "피로 물든 어두운 공간, 어둠 속 붉은 눈, 흡혈귀 성"용. 태그 horror·haunted·ghost |
| [Look of Horror](https://lospec.com/palette-list/look-of-horror) | ChuchuCasual | 4 | 호러·어두운 장면에 극적인 느낌. 태그 horror·terror·red |
| [Midnight Ablaze](https://lospec.com/palette-list/midnight-ablaze) | Inkpendude | 7 | "아주 불길한 밤하늘"용. 태그 dark·night·fire |
| [BloodMoon21](https://lospec.com/palette-list/bloodmoon21) | Ademack | 9 | 다크 아트 풍. "음산하거나 종말적인" 그림용 |
| [Nyx8](https://lospec.com/palette-list/nyx8) | Javier Guerrero | 8 | 태그 monochrome. 차가운 단색 계열 |
| [SLSO8](https://lospec.com/palette-list/slso8) | Luis Miguel Maldonado | 8 | 태그 monoramp. 한 줄 명암으로 실루엣 위주 장면에 적합 (추론) |
| [Corruption-16](https://lospec.com/palette-list/corruption-16) | Creepy Cute Games | 16 | "탁하고 진흙 같은 색 + 살색 강조". 러브크래프트 로그라이크용으로 제작 |
| [Lovecraftian Lens](https://lospec.com/palette-list/lovecraftian-lens) | Cactus Celery | 24 | 태그 cosmic·horror·muted·mystery |
| [Darkseed 16](https://lospec.com/palette-list/darkseed-16) | Ricardo Juchem | 16 | 게임 Dark Seed와 기거의 Alien에서 영감 |
| [Lost Century](https://lospec.com/palette-list/lost-century) | SurrealEmber | 16 | Aloys Zötl의 동물 도감(1835)에서 영감. 바랜 빈티지 톤. 재해석판 [Fading 16](https://lospec.com/palette-list/fading-16) |

그 밖의 후보: [Grim32](https://lospec.com/palette-list/grim32)(Jake Stinnett, 32색, dark·grim), [1bit Monitor Glow](https://lospec.com/palette-list/1bit-monitor-glow)(Polyducks, 2색, World of Horror식 1비트 실험용), [Blood Crow](https://lospec.com/palette-list/blood-crow)(Groxguy, 4색, "붉고 음산한").

**(추론) 쓰는 법:** 본편 팔레트는 하나로 고정하고, 이계·회상 같은 세계 전환에만 두 번째 팔레트를 씁니다(2.3절 "세계 전환 = 화풍 전환"). 서로 다른 무료 팩을 섞을 때도 한 팔레트로 리컬러하면 통일감이 생깁니다. 다만 리컬러는 "수정"이므로 원본 라이선스를 그대로 따릅니다 ([`assets/README.md`](../assets/README.md)).

---

## 5. 맵 디자인 참고

### 5.1 쯔꾸르 매핑 자료

| 자료 | 요지 | 출처 상태 |
|---|---|---|
| [Parallax Mapping in MZ: Basics and Tips](https://www.rpgmakerweb.com/blog/parallax-mapping-in-mz-basics-and-tips) (공식 블로그, Avery) | 맵 전체를 그림 한 장(parallax) + 캐릭터 위에 덮는 투명 오버레이로 구성. 통행 판정은 임시 X/O 타일셋으로 찍고 투명 타일로 교체. 물·절벽·오토타일 가장자리는 에디터로. MZ는 4레이어·투명 오토타일 덕에 "패럴랙스가 필요한 경우가 많이 줄었다" | 확인 |
| [Parallax Mapping Guide (VX Ace)](https://www.rpgmakerweb.com/a/rpg-maker-vxace-recommend/parallax-mapping-guide) | 검색 요약상 Photoshop으로 맵을 그리는 VX Ace 가이드. 현재 이 주소는 DEGICA 상점 상품 페이지로 리디렉트되며 그 페이지는 열리지 않음 | 내용·유료 여부 미확인 |
| [Upcycling VX Ace Tiles for MV/MZ](https://rpgmakerweb.com/blog/upcycling-vx-ace-tiles-for-mv-mz) (공식 블로그) | 32px 타일 3개 = 48px 타일 2개(96px) 격자로 옛 타일을 재활용 | 확인 |
| [Lighting by Lotus Games](https://rpgmaker.net/tutorials/625) (rpgmaker.net) | 겹친 조명 레이어로 분위기 만들기. 2003은 알파 채널이 없어 색 오버레이 처리에 요령이 필요 | Cloudflare로 직접 열람 실패, 검색 요약 기준 |
| [My Basic Mapping Commandments](https://www.rpgmaker.net/tutorials/895) (rpgmaker.net) | 장식보다 동선 가독성이 먼저 | 같음 |
| [How Gaia Thinks: Horror Games 101](https://rpgmaker.net/articles/158) (rpgmaker.net) | 쯔꾸르 호러 설계 글 | 같음, 내용 미확인 |
| [Graphics Course #1: Backgrounds and Tiles](https://guild.rpgmakerofficial.com/t/topic/27?tl=en) (AGM 공식 튜토리얼) | AGM G에서 타일맵·Terrain·Parallax2D 배경 만드는 순서 (1.3절) | 확인 |
| [Godot 문서: Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html) | Terrain 매칭 모드 3종(Corners and Sides / Corners / Sides). Godot 3의 3x3 비트마스크에 해당하는 것은 Corners and Sides | 확인 |

### 5.2 탑다운 매핑 기법 → 횡스크롤 대응표 (추론)

| 쯔꾸르 기법 | AGM G 횡스크롤에서 |
|---|---|
| 패럴랙스 맵(통그림 바닥) | 충돌용 TileMapLayer 위에 손그림 배경 Sprite2D/Parallax2D |
| 오버레이(캐릭터 위 그림) | 스크롤 배율 1.0 이상 전경 레이어 |
| X/O 통행 타일셋 | TileSet Physics Layer만 있는 투명 충돌 타일 |
| 화면 색조 변경(틴트) | CanvasModulate, 구역별 Light2D |
| 맵 이동 = 장면 전환 | 방(room) 단위 씬 + 카메라 경계 |

### 5.3 도구

| 도구 | 용도 | 라이선스 | 가격 |
|---|---|---|---|
| [Tiled](https://www.mapeditor.org/) | 타일맵 에디터 | 에디터 본체 GPL(저장소 표기 GPL-2.0), libtiled 등은 BSD 2-clause ([COPYING](https://github.com/mapeditor/tiled/blob/master/COPYING)) | 무료. [itch.io](https://thorbjorn.itch.io/tiled)에서 원하는 만큼 후원 |
| [LDtk](https://ldtk.io/) | 레벨 에디터(Deepnight). 그리드배니아 월드 배치 | MIT ([LICENSE](https://github.com/deepnight/ldtk/blob/master/LICENSE)) | 무료, "제한 없이 무료로 사용 가능" |
| [Aseprite](https://www.aseprite.org/) | 스프라이트·애니메이션 | 독점 EULA. 소스 컴파일은 개인 용도·기여 제안용만 허용 ([EULA](https://github.com/aseprite/aseprite/blob/main/EULA.txt)) | $19.99 ([Steam](https://store.steampowered.com/app/431730/)) |
| [Pyxel Edit](https://pyxeledit.com/) | 타일셋 중심 픽셀 에디터 | 독점. 구매자 본인 컴퓨터에서만 실행 | 미확인. 공식 페이지는 "베타 할인가"와 Humble 판매만 언급하고 직접 구매는 일시 중단 ([구매 페이지](https://pyxeledit.com/get.php)) |
| [Pixelorama](https://github.com/Orama-Interactive/Pixelorama) | 스프라이트 에디터, Godot로 제작 | MIT ([LICENSE](https://github.com/Orama-Interactive/Pixelorama/blob/master/LICENSE)) | 무료 |

Tiled·LDtk 맵을 Godot로 가져오는 임포터와, 그 플러그인이 AGM G 에디터에서 돌아가는지(미확인)는 [`visual_assets.md` Q6](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/visual_assets.md)에 정리되어 있습니다.

---

## 6. 재배포 불가 소스 (링크만)

아래는 **게임에 넣어 배포할 수는 있어도 원본 파일을 공개 저장소에 올릴 수 없는** 소스입니다. 쓰기로 하면 파일은 `assets_private/`에 두고 [`SOURCES.md`](../SOURCES.md)에 입수처·약관 요지·확인일을, [`CREDITS.md`](../CREDITS.md)에 크레딧을 적습니다 ([`assets_private/README.md`](../assets_private/README.md)).

### 6.1 RPG Maker DLC (Steam, 호러 그래픽)

모두 **탑다운 48px** 소재라 플랫포머 본편보다는 탑다운 막간, 소품 참고, 그레이박스에 맞습니다. RPG Maker DLC를 AGM G에서 쓸 수 있는지는 공식 답변이 없고, 커뮤니티 답변과 GGG 약관 해석만 있습니다 ([`visual_assets.md` Q1](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/visual_assets.md)). 대부분 MV판도 따로 있습니다.

| 팩 (MZ판) | 제작 | 가격 | 메모 |
|---|---|---|---|
| [POP! Horror City](https://store.steampowered.com/app/1441970) | Vexed Enigma | $14.99 | "펄프 픽션풍" 타일 + 캐릭터. 후속 [POP: Slasher Forest](https://store.steampowered.com/app/1468850) $24.99, Character Pack [1](https://store.steampowered.com/app/1523080)·[2](https://store.steampowered.com/app/1523070) |
| [Haunted School Tiles](https://store.steampowered.com/app/1450940) | Sherman3D | $9.99 | 귀신 들린 학교 |
| [KR Horror Kit Tileset](https://store.steampowered.com/app/2185630) | Kokoro Reflections | $8.99 | 같은 제작사 [KR Haunted House Tileset](https://store.steampowered.com/app/3308090) $19.99(2024) |
| [Haunted Residences Assets](https://store.steampowered.com/app/2474872) | ESQUADRA, GGG | $10.99 | 폐허 전/후 건물, 실내 소품 91종, 얼굴·걷기 캐릭터 남녀 1명씩, 48x48. "RPG Maker 시리즈 또는 원하는 엔진에서 사용" 가능, 수정본 재배포 금지, ©ESQUADRA,inc. ©Gotcha Gotcha Games Inc. 표기 필수 |
| [Haunted Forest Tileset](https://store.steampowered.com/app/3773230) | White Cat, GGG | $14.99 | 어두운 숲, 묘지, 옛길 (2025) |
| [NEONPIXEL - Mega Spooky set](https://store.steampowered.com/app/2565810) | Neonpixel, GGG | $16.99 | 여러 팩 묶음 |
| [Weird and Creepy Monsters Pack](https://store.steampowered.com/app/2945520) | enski.art, GGG | $9.99 | 기괴한 몬스터 배틀러 |
| [Dark Fantasy Resource Pack](https://store.steampowered.com/app/1351030) | GGG, KADOKAWA | $19.99 | 타일셋·캐릭터·음악 |
| [Visustella School Horror Vol 1](https://store.steampowered.com/app/1764360) | VisuStella | $19.99 | 학교 호러 타일, 걷기 캐릭터, 문 애니메이션 ([검색 요약](https://www.dekudeals.com/items/rpg-maker-mz-visustella-school-horror-vol-1)) |
| [TinyRPG - Creepy Catacomb Tileset](https://store.steampowered.com/app/5416530) | tiopalada, GGG | $5.99 | 묘지·지하묘지 (2026-10) |

Steam에서 RPG Maker 호러 DLC를 직접 찾으려면 [DLC 검색 "horror"](https://store.steampowered.com/search/?term=horror&category1=21)를 씁니다.

### 6.2 itch.io 호러 팩

- [itch.io: Horror + Side Scroller 에셋 목록](https://itch.io/game-assets/tag-horror/tag-side-scroller) — 확인 시 96개. 횡스크롤 호러 팩을 찾는 출발점입니다. "무료" 표시는 원본 재배포 허용과 별개이므로 각 페이지 약관을 따로 봅니다.
- [Horror Apartment Side-scroller Assets](https://zodee.itch.io/horror-apartment-assets) (RAINPROXY) — £3.99 이상, 16x16 횡스크롤, Lone Survivor에서 영감. "수정·상업 이용 자유"라고만 적혀 있고 재배포 조항이 없음 → `assets_private/`.
- [Spooky Graveyard Builder](https://penzilla.itch.io/spooky-graveyard-builder) (Penzilla) — $5 이상, 32x32(소품 16x16) 횡스크롤, "로열티 프리·상업 이용". 전체 라이선스 문서는 페이지에 없음 → `assets_private/`.

### 6.3 일본 BOOTH·ツクール素材

- [BOOTH: Pixel Material Studio「ホラー・悪夢30点」](https://booth.pm/ja/items/8034214) — ¥500(체험판 무료). 상업 이용·수정 가능, 소재 자체와 수정본의 재배포·전매 금지, 크레딧 선택. **제작 일부에 생성 AI 사용**을 명시하므로, 쓰면 Steam AI 콘텐츠 공개 대상이 될 수 있습니다 ([`visual_assets.md` Q6](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/visual_assets.md)).
- BOOTH의 호러 소재는 대체로 "작품 내 사용 OK, 소재 재배포 금지" 구조였습니다 (위 예시 외에는 검색 요약 수준).
- **호러 전문 무료 ツクール素材 사이트는 이번 조사에서 이름과 약관을 확인한 곳이 없습니다 (미확인).** 확인된 일본 소재 사이트(ぴぽや倉庫 등)는 [`visual_assets.md` Q3](../research_notes/쯔꾸르%20리소스와%20스토리%20자원%20분석/visual_assets.md)를 봅니다.

### 6.4 들이기 전 체크

1. 약관 페이지에서 **원본 재배포 허용이 명시**되어 있는가? 아니면 `assets_private/`.
2. AGM G(비-RPG Maker 툴)에서 써도 되는가? (RPG Maker 전용 소재 여부)
3. 크레딧 문구, AI 사용 여부, 연령 등급 제한을 [`SOURCES.md`](../SOURCES.md) 표에 기록했는가?
4. `git status`로 `assets_private/` 파일이 추적되지 않는지 확인했는가?

---

## 7. 미확인 항목 요약

- RPG Maker XP 규격 대부분(타일 32x32, 타일셋 가로 256px, 오토타일 96x128, 캐릭터 4x4 배치, 얼굴 그래픽 유무, 배틀러 크기). 확인된 것은 화면 640x480과 "시트 크기 규정 없음"뿐입니다.
- VX/VX Ace 시트·얼굴 크기는 공식 문서가 아니라 커뮤니티 값입니다(MV 공식값의 2/3와 일치). RPG Maker 2000 얼굴 크기는 48x48과 42x42로 출처가 충돌합니다.
- MZ 기본 화면 816x624는 커뮤니티 출처입니다(공식 도움말에 기본값 없음).
- AGM G의 기본 해상도, 권장 스프라이트 크기.
- Ib 원작 엔진(2000/2003 출처 충돌), Paranoiac·The Crooked Man 원작 공개 연도, FAITH의 시점.
- Pixel Logic 현재 가격, Pyxel Edit 가격.
- rpgmaker.net 튜토리얼 3건의 본문(Cloudflare 차단으로 검색 요약만 확인), VX Ace 패럴랙스 가이드 본문.
- 호러 전문 일본 무료 ツクール素材 사이트.
- Lospec 팔레트의 이용 조건(확인한 페이지에 라이선스 문구 없음).

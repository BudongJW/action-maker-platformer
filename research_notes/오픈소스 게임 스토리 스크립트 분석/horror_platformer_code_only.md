# 오픈소스 호러·플랫포머·액션 게임의 스토리/대사 스크립트 공개 여부 검증 (+ "엔진만 공개" 사례)

> 조사일: 2026-11-17. 원칙: 공개 웹페이지/raw 파일만 열람(클론·GitHub API·gh 미사용). 인용은 구조 파악용 최소 분량.
> 분류 기준: **(A)** 코드+스토리 모두 자유 라이선스로 공개 / **(B)** 스토리는 읽을 수 있으나 제한적 라이선스(NC, 프리웨어, 소스 공개형 비상업 등) / **(C)** 코드만 공개, 스토리·데이터는 독점.

---

## Q1. 분류 총괄: "오픈소스 코드 = 오픈 스토리"인가?

### Takeaway
아니다. 검증한 17개 사례 중 대사/스토리 텍스트까지 자유 라이선스(BY-SA/BY 등)로 열린 것은 SuperTux·Lugaru·SCP–CB(+소규모 Godot 잼작 1개) 정도이고, 유명 상업작 소스 공개(Amnesia, Penumbra, System Shock, Arx Fatalis, FreeSpace 2, RTCW, Doom)는 거의 전부 "코드만" 공개다. 예외적으로 **대사가 코드 안에 하드코딩된 경우(Doom의 엔딩 텍스트, VVVVVV 컷신)에는 스토리 텍스트가 코드 라이선스를 따라 함께 공개**되었다.

### Cited Findings

#### 분류표 (상세 근거는 Q2~Q4)
| 작품 | 장르 | 분류 | 코드 라이선스 | 스토리/대사 위치·라이선스 | 캐릭터 대사 포함 |
|---|---|---|---|---|---|
| SuperTux | 플랫포머 | **A** | GPL-3.0 | 레벨 파일 `(license "GPL 2+ / CC-by-sa 3.0")` + Squirrel `.nut`, gettext `.po` | Partial(내레이션 캡션 위주, 화자 표기 없음) |
| Lugaru (OSS Lugaru HD) | 3D 액션 | **A** | GPL-2.0+ | `Data/` 전체 CC BY-SA 3.0/4.0 (캠페인 txt·맵 포함) | 미검증(캠페인 txt·맵 데이터가 BY-SA로 포함됨은 확인, 대화 포맷은 미열람) |
| SCP – Containment Breach | 호러 | **A**(주의사항 多) | CC BY-SA 3.0 (게임+소스) | 문서=JPG 이미지, NPC 대사=OGG 음성, 힌트=하드코딩 문자열 | Partial(텍스트 대사는 거의 없음, 음성 위주) |
| SCP-001: When Day Breaks (Godot 잼작) | 호러 | A(추정) | MIT | 에셋 CC BY 4.0(스토리 텍스트 포함 여부 불명) | 미검증 |
| Frogatto & Friends | 플랫포머 | **B** | Zlib(src/ C++만) | 기본 CC-BY 3.0, 단 `data/levels`·스토리·캐릭터는 CC BY-NC-SA | 미검증(스토리가 NC-SA로 명시됨, 대사 파일 위치 미확인) |
| VVVVVV | 플랫포머 | **B** | VVVVVV Source Code License v1.0(비상업) | 컷신 대사가 `Scripts.cpp`에 하드코딩 + `lang/en/cutscenes.xml` | Yes(화자=색상) |
| Cave Story (원작 프리웨어) / NXEngine-evo / CSE2 | 플랫포머 | **B** | NXEngine-evo GPL-3.0, CSE2는 대부분 독점(Pixel 소유)+수정분 MIT | 프리웨어 데이터의 `Stage/*.tsc`(난독화) | Yes(TSC, 얼굴 초상화 `<FAC`) |
| OpenTyrian | 슈팅(액션) | **B** | GPL-2.0+ | 프리웨어 Tyrian 2.1 데이터 `tyrian.hdt`(XOR 암호화) | Partial(이벤트/도움말 텍스트) |
| Iji | 액션 플랫포머 | **B** | 명시적 라이선스 없음(프리웨어+소스 다운로드) | GameMaker 소스 내(세부 미검증) | 미검증 |
| Celeste Classic (PICO-8) | 플랫포머 | B(라이선스 불명) | 불명 | 카트 코드 내(대사 거의 없음) | 사실상 No |
| Amnesia: TDD / AMFP | 호러 | **C** | GPL-3.0 | `english.lang` XML(게임 데이터, 미포함) | No |
| Penumbra: Overture | 호러 | **C** | GPL-3.0 | 게임 데이터(미포함) | No |
| Doom | FPS | **C**(텍스트 예외) | GPL-2.0(저장소 표기) | 에피소드 엔딩 텍스트가 `d_englsh.h`에 하드코딩 → 코드와 함께 공개 | 대사 없음(내레이션만) |
| System Shock | 호러 FPS/RPG | **C** | GPL-3.0 | 데이터(원 EULA) | No |
| Arx Fatalis | RPG | **C** | GPL-3.0+ (추가조항) | `.asl` 스크립트·현지화·음성 모두 데이터 | No |
| FreeSpace 2 | 우주 슈팅 | **C**(코드도 비상업) | Volition 비상업 라이선스 | 미션 데이터(독점) | No |
| Return to Castle Wolfenstein | FPS | **C** | GPL-3.0 + 추가조항 | "does not contain any game data" | No |

- Amnesia: README는 "All code is under the GPL Version 3 license"라고만 하며, 언론은 "the game assets have not been made available under any free license" / "only the code and not all the other media assets"라고 정리 — [GitHub README](https://github.com/FrictionalGames/AmnesiaTheDarkDescent); [LinuxReviews](https://linuxreviews.org/Frictional_Games_Has_Released_Source_Code_For_Two_Amnesia_Games_As_FOSS_Under_The_GNU_GPLv3); [GamingOnLinux](https://www.gamingonlinux.com/2020/09/amnesia-the-dark-descent-and-amnesia-a-machine-for-pigs-go-open-source/page=1/)
- RTCW README: "This source release does not contain any game data", 데이터는 "covered by the original EULA" — [id-Software/RTCW-SP](https://github.com/id-Software/RTCW-SP)
- Doom README: "You still need real DOOM data to work with this code." 그러나 `d_englsh.h`에 `E1TEXT`~`E4TEXT`, `C1TEXT`~`C6TEXT` 등 엔딩 스토리 텍스트가 매크로로 들어 있음 — [id-Software/DOOM](https://github.com/id-Software/DOOM); [d_englsh.h raw](https://raw.githubusercontent.com/id-Software/DOOM/master/linuxdoom-1.10/d_englsh.h)
- VVVVVV: 저장소는 "does not, however, contain any of the icons, art, graphics or music for the game"이지만, 컷신 대사는 `Scripts.cpp`에 `static const char* lines[]` 배열로 하드코딩되어 있음 — [LICENSE.md](https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/LICENSE.md); [Scripts.cpp](https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/desktop_version/src/Scripts.cpp)

### Inferences
- "어디에 텍스트를 두었는가"가 공개 범위를 결정한다: 데이터 파일(lang XML, TSC, WAD, .asl)에 두면 코드 공개와 무관하게 독점으로 남고, 소스 코드 안에 하드코딩하면 코드 라이선스로 함께 풀린다(Doom, VVVVVV).
- 사용자의 저장소(GPL-3.0 + section 7 예외, 오리지널 콘텐츠 All Rights Reserved)에서는 **대사를 `.gd` 스크립트 문자열로 하드코딩하지 말고 별도 데이터 파일(CSV/JSON/.tres 등)로 분리하고 파일/디렉터리 단위로 ARR 표기**하는 것이 라이선스 경계를 명확히 하는 핵심 교훈이다(법률 자문 아님, 구조적 추론).

### Gaps
- 각 저장소의 전체 트리를 클론하지 않고 웹 페이지 목록만 확인했으므로, 일부 하위 폴더(예: Amnesia `amnesia/src` 내부)에 소량의 텍스트 리소스가 섞여 있을 가능성은 완전히 배제하지 못함.

---

## Q2. 호러 계열: 실제로 무엇이 공개되었고 대사/문서는 어디에 있는가?

### Takeaway
SCP–CB는 게임 전체가 CC BY-SA 3.0이라 "열린 스토리"에 가장 가깝지만, 대사는 음성(OGG), 문서는 이미지(JPG), 힌트는 하드코딩 문자열이라 "텍스트 스크립트"로서의 대사 파일은 사실상 없다. Amnesia/Penumbra는 GPL-3.0 코드만 공개되었고 노트·대사는 데이터(`.lang` XML)에 남아 독점이다.

### Cited Findings

#### 1) SCP – Containment Breach (SCP–CB)
- **기본 정보**: Blitz3D(v1.108) 기반, 저장소 [Regalis11/scpcb](https://github.com/Regalis11/scpcb). 1.3.11 변경로그(2018년 8월) — [Softpedia changelog](https://games.softpedia.com/progChangelog/SCP-Containment-Breach-Changelog-119482.html)
- **라이선스(README 원문)**: "This game and the source code are licensed under Creative Commons Attribution-ShareAlike 3.0 License." / "The game is based on the works of the SCP Foundation community" — 코드·아트·사운드·텍스트를 구분하지 않고 일괄 CC BY-SA 3.0. 별도 LICENSE 파일은 페이지상 보이지 않음. 서드파티 DLL(FMod, FreeImage, BlitzMovie 등)의 라이선스는 명시 없음 — [README](https://github.com/Regalis11/scpcb)
- **대사/문서 위치**:
  - 문서(Documents): `GFX/items/doc008.jpg`, `doc035.jpg`, `doc1048.jpg` … 등 **JPG 이미지로 저장** — [GFX/items](https://github.com/Regalis11/scpcb/tree/master/GFX/items)
  - NPC 대사: 음성 파일로만 존재. 예: `LoadSound_Strict("SFX\Room\Intro\Guard\Ulgrin\ExitCell.ogg")`; 자막 렌더링 코드는 확인된 범위에서 없음 — [UpdateEvents.bb](https://raw.githubusercontent.com/Regalis11/scpcb/master/UpdateEvents.bb) (40만자 중 첫 10만자만 확인)
  - 화면 메시지: `.bb` 소스에 하드코딩. 예: `Msg = "Pick up the paper on the desk."` + `MsgTimer=70*7`(70fps 기준 프레임) — 같은 출처
  - 방송(PA): 파일명 조각을 파이프로 이어 순차 재생(`"1\attention"+Rand(1,2)+".ogg"`) — 같은 출처
  - `Data/`에는 `events.ini`, `rooms.ini`, `NPCs.ini`, `achievementstrings.ini`, `SCP-294.ini` 등 INI 데이터 — [Data/](https://github.com/Regalis11/scpcb/tree/master/Data)
- **대사 포함 판정**: Partial — 텍스트 대사 스크립트 없음(음성), 문서는 이미지, 힌트/시스템 메시지만 텍스트. 화자 표기·초상화·분기 대화 시스템 없음, 현지화 구조 없음(하드코딩 영어).
- **SCP 라이선스 주의**: SCP 위키 콘텐츠는 CC BY-SA 3.0, 파생물은 "MUST release your work under CC-BY-SA 3.0", 원 출처(SCP Foundation wiki) 표기 필요. "You can also choose to license your game under GPLv3, which is compatible with our license." 판매도 허용("You can sell the remixes"). 단 SCP-173의 옛 이미지(가토 이즈미 조각 *Untitled 2004*)는 "barred from use in any commercial endeavor", "you cannot use the sculpture, or its likeness, for commercial purposes" — [SCP Wiki Licensing Guide](https://scp-wiki.wikidot.com/licensing-guide); 위키는 이 이미지를 CC 비호환 유일 이미지로 보고 자발적 삭제 — [SCP Wiki 공지](https://scp-wiki.wikidot.com/forum/t-14469202/announcement-regarding-the-removal-of-scp-173-s-image)
- SCP–CB의 173 디자인은 Untitled 2004를 모델로 했다는 서술이 타 프로젝트(SCP: Unity) 데브로그에 있음; 해당 데브로그는 Kato가 이후 SCP 관련 사용을 허락하지 않게 되었다고 언급 — [SCP: Unity Alpha 6 Devlog](https://kaliditzy.itch.io/xk/devlog/1113308/alpha-6-devlog-scp-173s-appearance). TCRF는 173이 v0.6~v1.3.11까지 존재한다고 기록 — [TCRF](https://tcrf.net/SCP_-_Containment_Breach)
- **스토리/긴장 전달**: 시설 탈출형 오픈 구조(무작위 맵 생성 — `MapSystem.bb`, `rooms.ini` 존재로 추정), 공포는 PA 방송·무전/경비 음성·현장 문서(이미지)·깜박임(blink) 메커니즘으로 전달. (구조 유형은 파일 구성 기반 추론)

#### 2) SCP-001: When Day Breaks (Godot 잼작, 추가 후보)
- Godot Wild Jam #66, 2024-02-18 공개, 코드 "MIT License", 에셋 "Creative Commons Attribution v4.0 International", SCP-001 제안문(Shaggydredlocks 저) 각색, 상태 "In development" — [itch.io 페이지](https://parallaxrat.itch.io/scp-001-when-day-breaks)
- 소스 저장소 URL은 페이지에 없음; 스토리 텍스트가 CC BY 4.0 에셋 범위에 포함되는지 명시 없음 — 같은 출처

#### 3) Amnesia: The Dark Descent (2010) / A Machine for Pigs (2013) — 소스 공개 2020년 9월
- **저장소**: [FrictionalGames/AmnesiaTheDarkDescent](https://github.com/FrictionalGames/AmnesiaTheDarkDescent) 최상위 `HPL2/`, `amnesia/src/`, `LICENSE`, `README.md`. README: "here is almost everything you need to build Amnesia: The Dark Descent", "All code is under the GPL Version 3 license", FBX SDK 2012 미제공으로 "the engine wont compile" — 같은 출처
- **공개 범위**: TDD·AMFP 게임 코드와 에디터 코드 전체가 GPLv3; 에셋은 공개되지 않아 게임 자체는 독점 유지 — [LinuxReviews](https://linuxreviews.org/Frictional_Games_Has_Released_Source_Code_For_Two_Amnesia_Games_As_FOSS_Under_The_GNU_GPLv3); [GamingOnLinux](https://www.gamingonlinux.com/2020/09/amnesia-the-dark-descent-and-amnesia-a-machine-for-pigs-go-open-source/page=1/)
- **스토리 텍스트 위치(데이터, 미포함)**: 노트·일지는 `.lang` XML의 `<CATEGORY Name="Journal">` 안에 `Note_<이름>_Name` / `Note_<이름>_Text` 쌍으로 저장, `<LANGUAGE>` / `<RESOURCES>`로 감쌈. 본편은 Config 폴더 `lang_main`의 `english.lang`, 커스텀 스토리는 루트에 `extra_english.lang`(공식 측은 원본 파일 수정 대신 별도 파일 권장) — [Frictional 포럼 튜토리얼 스레드](https://forum.frictionalgames.com/printthread.php?tid=4407)
- **판정**: C. 캐릭터 대사 스크립트: No(공개분에 없음). 포맷: lang XML(키-값, 카테고리 분류, 언어별 파일로 현지화).
- **긴장 전달**: 노트/일지(Journal) 중심의 문서형 서사 — 같은 포럼 출처(구조), 그 외 연출은 미검증.

#### 4) Penumbra: Overture (2007) — 소스 공개 2010년 5월
- Humble Indie Bundle 100만 달러 돌파 직후 공개, Frictional 블로그: "the executable's source code is now released under the GPL version 3 licence" — [Frictional 블로그](https://frictionalgames.blogspot.it/2010/05/penumbra-overture-goes-open-source.html); [Slashdot](https://games.slashdot.org/story/10/05/15/167204/Penumbra-Overture-Goes-Open-Source)(댓글: 엔진 일부 외 에셋은 기존 저작권 유지)
- 저장소 [FrictionalGames/PenumbraOverture](https://github.com/FrictionalGames/PenumbraOverture): README "All code is under the GPL Version 3 license." 파일 목록에 `IntroStory.cpp`, `Notebook.cpp`, `DemoEndText.cpp`, `MapLoadText.cpp`, `Credits.cpp` 등 존재, `.lang`/`.xml` 텍스트 파일은 목록에 없음 — 같은 출처
- **판정**: C. 노트북(Notebook)·인트로 스토리 "시스템" 코드는 공개, 텍스트 자체는 데이터 측(미포함으로 보임).

### Inferences
- SCP–CB는 "라이선스상 완전 개방"이지만 "텍스트 스크립트로서 분석 가능한 대사"는 거의 없다(음성·이미지). 대사 구조 분석 자료로는 빈약하고, 음향/환경 연출 분석 자료로 가치가 있다.
- SCP–CB의 문서를 이미지로 굽는 방식은 현지화·접근성(자막/텍스트 검색) 측면에서 반면교사다. Amnesia의 "키-값 lang XML + Journal 카테고리"는 Godot의 CSV/PO 번역 시스템으로 그대로 옮길 수 있는 구조다.
- Penumbra의 `IntroStory.cpp`처럼 "스토리 연출 로직"과 "스토리 텍스트"를 분리한 구조가 상업 호러의 표준으로 보인다(파일명 기반 추론).

### Gaps
- `IntroStory.cpp`, `DemoEndText.cpp` 내부에 하드코딩 텍스트가 있는지 미확인(파일 미열람).
- SCP–CB 저장소에 자막 시스템이 전혀 없는지(UpdateEvents.bb 후반부, NPCs.bb) 전부 확인하지 못함.
- SCP–CB 내 173 모델이 실제로 Kato 조각의 "likeness"인지에 대한 1차 출처(개발자 공식 언급) 미발견.
- Frictional의 2020년 공식 블로그 원문은 직접 열람하지 못함(2차 보도로 대체).

---

## Q3. 플랫포머/액션 계열: 대사 스크립트 포함 여부와 포맷

### Takeaway
SuperTux(Squirrel + gettext)와 Lugaru(CC BY-SA 데이터)는 스토리까지 자유 라이선스다. Frogatto는 스토리·캐릭터를 명시적으로 CC BY-NC-SA로 묶었고, VVVVVV·Cave Story·Tyrian·Iji는 대사를 "읽을 수는 있지만" 비상업/프리웨어라 재사용 불가다. 대사 포맷 연구 가치는 Cave Story의 TSC(초상화·플래그·분기·스킵플래그)와 VVVVVV(색상=화자, 번역 XML)가 가장 높다.

### Cited Findings

#### 1) SuperTux — (A)
- 코드: 루트 `LICENSE.txt`는 GPL v3 전문만 수록(데이터 라이선스 언급 없음) — [LICENSE.txt](https://raw.githubusercontent.com/SuperTux/supertux/master/LICENSE.txt)
- 데이터: 레벨 파일이 개별 라이선스 필드를 가짐. 예: `intro.stl`의 `(license "GPL 2+ / CC-by-sa 3.0")`, `(author "SuperTux Team")` — [intro.stl](https://raw.githubusercontent.com/SuperTux/supertux/master/data/levels/world1/intro.stl)
- 파일 위치: `data/levels/world1/`에 `intro.stl/.nut`, `castle_cutscene`, `yeti_cutscene`, `yetiwin_cutscene`(.stl/.nut), `worldmap.stwm`, `messages.pot` 및 언어별 `.po`(ko 포함) — [world1 트리](https://github.com/SuperTux/supertux/tree/master/data/levels/world1)
- 포맷: S-expression 레벨 파일의 `(init-script "import(\"levels/world1/intro.nut\"); ...")`로 Squirrel 임베드 — [intro.stl](https://raw.githubusercontent.com/SuperTux/supertux/master/data/levels/world1/intro.stl). 화면 텍스트는 `Text.set_text(_("Somewhere at the shores of Antarctica..."));` → `Text.fade_in(1)` → `wait()` → `Text.fade_out(1)`; 연출은 `Tux.walk(200)`, `Camera.scroll_to(...)`, `play_sound("speech/tux_hello.ogg")` — [intro.nut](https://raw.githubusercontent.com/SuperTux/supertux/master/data/levels/world1/intro.nut)
- 화자 표기·초상화 없음; 음성 대사는 `speech/penny_runt_01.ogg`처럼 파일명으로만 화자 식별; 모든 문자열은 `_()`(gettext)로 감싸 번역 — 같은 출처
- 스토리: 펭귄 Tux가 친구 Penny와 피크닉 중 Nolok에게 납치당한 Penny를 구하러 감("You don't have a chance of saving her! Signed, Nolok.") — 같은 출처
- 대사 포함 판정: Partial(내레이션 캡션 + 음성, 대화창형 다자 대화는 확인 안 됨)

#### 2) Frogatto & Friends — (B)
- LICENSE 요지: 기본 "everything is licensed under the CC-BY 3.0 LICENSE", 예외로 `data/levels`, `images/characters`, `images/tiles`, `sounds`, `music` 등은 "all of their contents are licensed under CC-BY-NC-SA", 게임의 **스토리와 "all visual designs of characters (in any representation)"·캐릭터 이름도 CC-BY-NC-SA**, 엔진 C++ 코드는 "limited to the C++ source code files found in the "src" directory"에 한해 Zlib — [LICENSE](https://raw.githubusercontent.com/frogatto/frogatto/master/LICENSE) (NC-SA 버전은 두 번 조회에서 4.0으로 한 번 요약됨 — 버전 표기 재확인 필요)
- 저장소 최상위: `data`, `images`, `locale`, `music`, `po`, `sounds` 등; README: "The game's source code license can be found in the LICENSE file" — [frogatto/frogatto](https://github.com/frogatto/frogatto)
- 판정: B (스토리는 열람 가능하나 NC → 상업 프로젝트 재사용 불가). `po`/`locale` 폴더로 번역 구조 존재.

#### 3) Lugaru (OSS Lugaru HD) — (A)
- README: 코드 "GNU General Public License version 2" "or (at your option) any later version (GPLv2+)", `Data` 폴더 에셋은 "Creative Commons Attribution - Share Alike" 3.0 또는 4.0(`CONTENT-LICENSE.txt` 참조), "open sourced in 2010" — [README](https://raw.githubusercontent.com/osslugaru/lugaru/master/README.md)
- `CONTENT-LICENSE.txt`: "All assets from the original Lugaru game (including Lugaru HD assets)" = CC BY-SA 3.0; 커뮤니티 캠페인(`Data/Campaigns/empire.txt` + `Data/Maps/jendraz*`, Seven Tasks `seventasks.txt` + `Data/Maps/task*` 등)은 CC BY-SA 4.0; 저작자 표기 "Attribution to Wolfire Games" — [CONTENT-LICENSE.txt](https://raw.githubusercontent.com/osslugaru/lugaru/master/CONTENT-LICENSE.txt)
- 재라이선스 시점: 커밋 "Relicensing all Wolfire Lugaru assets to CC-BY-SA 3.0"(2016-11-30), LWN은 2016년 12월로 기술, 언론 보도는 2017년 1월 — [GitLab 커밋](https://gitlab.com/osslugaru/lugaru/commit/51203b531b2054a8a7c40356e2108a5ec7b9f366); [LWN](https://lwn.net/Articles/715362/); [GamingOnLinux 2017-01](https://www.gamingonlinux.com/2017/01/lugaru-campaign-now-fully-playable-in-overgrowth-lugaru-hd-now-fully-open-source-including-the-data/page=1/)
- 판정: A. 캠페인 텍스트(`Data/Campaigns/*.txt`)와 맵(`Data/Maps/*`) 포함. ※ 사용자가 제시한 "2017년 CC BY-SA"는 실제로는 2016년 말 커밋/2017년 초 보도.

#### 4) OpenTyrian — (B)
- 코드 GPL-2.0(저장소 표기, 소스 헤더 "GNU General Public License… version 2 or later"); 릴리스 빌드에는 "the freeware Tyrian 2.1 data files are included" — [opentyrian/opentyrian](https://github.com/opentyrian/opentyrian); [helptext.c](https://raw.githubusercontent.com/opentyrian/opentyrian/master/src/helptext.c)
- 텍스트 위치: `helptext.c`는 `"tyrian.hdt"`에서 도움말·행성명·이벤트 텍스트·에피소드명 등을 읽고, 각 문자열은 `readEncryptedString()`으로 XOR 복호화 — [helptext.c](https://raw.githubusercontent.com/opentyrian/opentyrian/master/src/helptext.c)
- 판정: B (코드 GPL, 스토리 텍스트는 프리웨어 데이터 — 재배포는 허용되나 자유 라이선스 아님).

#### 5) Cave Story(洞窟物語) / NXEngine-evo / CSE2 — (B)
- 원작: Daisuke "Pixel" Amaya, 2004-12-20 Windows 프리웨어 공개; Nicalis가 WiiWare(2010)·Cave Story+(2011)·Switch(2017) 등 상업판 출시; CSE2(프리웨어 기반 디컴파일)는 Nicalis가 2020년 말 내리게 함 — [Wikipedia: Cave Story](https://en.wikipedia.org/wiki/Cave_Story)
- CSE2(포크) README: "CSE2 is a decompilation of Cave Story." / "the majority of the code in this project is proprietary and belongs to Daisuke "Pixel" Amaya." / 수정·자체 코드는 MIT — [gameblabla/CSE2](https://github.com/gameblabla/CSE2)
- NXEngine-evo: GPL-3.0, "A somewhat upgraded/refactored version of NXEngine", "Removed built-in data extractor" — [nxengine/nxengine-evo](https://github.com/nxengine/nxengine-evo)
- **TSC(Text SCripts) 포맷**: 이벤트는 `#` + 4자리 번호, 명령은 `<` + 3글자, 파라미터는 4자리 0패딩·`:` 구분, 모든 스테이지가 공용 `data/Head.tsc` 로드 — [modcavestory guide](https://modcavestory.github.io/guide/tsc). 예시: `#0100 <KEY<MSGHello World<NOD<CLO<END` — [modcavestory api](https://modcavestory.github.io/api/tsc). 문 이벤트 예: `#0700` / `<KEY<SOU0011<DNP0700<FAO0004<TRA0006:0092:0011:0012` — [TSC 튜토리얼](https://archive.cavestory.one/basicmodding/guide/tsc.html)
- 명령 정의(TSC Notes): `<MSG` "Open normal text box (text follows)", `<FAC` "Show face X in text box"(초상화), `<NOD` 버튼 대기, `<CLR`/`<CLO` 지우기/닫기, `<FL+` "Set flag X", `<FLJ` "Jump to event Y if flag X is set", `<YNJ` "Ask yes or no, jump to event X if No", `<ITJ` 아이템 보유 분기, `<SK+` "Set skipflag X (remains set until program exits, to avoid repeating cutscenes/dialogue after retrying)", `<MS2`/`<MS3` 화면 상단 텍스트박스 — [TSC Notes](https://archive.cavestory.one/basicmodding/guide/tsc.txt)
- 난독화: `.tsc`는 파일 중간 바이트를 키로 나머지 바이트에 더하는 방식(복호화 = 키를 뺌), `Stage/*.tsc` 일괄 복호화 도구 존재 — [tsc_decrypt gist](https://gist.github.com/slice/aae504ca921421bf26d077e07136ed22); [go-chie](https://github.com/jozsefsallai/go-chie)
- 화자 표기: 이름 태그 대신 `<FAC`의 얼굴 번호로 화자 표시(위 TSC Notes 정의 기반). 현지화: 원작 일본어, 영어는 팬 번역(Aeon Genesis — 출처 미확인, Gaps 참조).
- 판정: B (대사 Yes·형식 상세, 단 프리웨어/독점 — 재사용 불가, 포맷 아이디어만 참고).

#### 6) VVVVVV (2010, 소스 공개 2020-01) — (B)
- 라이선스: "VVVVVV Source Code License v1.0" — "Permission is granted to anyone to use this software and to alter it and redistribute it freely" 단 "primarily intended for or directed toward commercial advantage or private monetary compensation"인 용도 금지, 제품 사용 시 Terry Cavanagh 저작권 표기 의무; 아이콘·아트·그래픽·음악은 미포함·독점 — [LICENSE.md](https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/LICENSE.md); 10주년 기념 공개 — [GamingOnLinux 2020-01](https://www.gamingonlinux.com/2020/01/vvvvvv-from-terry-cavanagh-has-the-source-code-opened-up-to-celebrate-the-10-year-anniversary/page=1/)
- **대사 위치 1 (하드코딩)**: `desktop_version/src/Scripts.cpp`의 `scriptclass::load()` 내 `static const char* lines[]` 배열. 구조 예: `"squeak(cry)",` `"text(blue,0,0,1)",` `"Waaaa!",` `"position(blue,above)",` `"speak_active",` … `endtext` — [Scripts.cpp](https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/desktop_version/src/Scripts.cpp)
- **대사 위치 2 (번역용 XML)**: `desktop_version/lang/en/cutscenes.xml` — `<cutscene id="intro" explanation="">` 안에 `<dialogue speaker="cyan" english="Uh oh..." translation=""/>`; 선택 속성 `case`, `tt`(터미널 텍스트), `pad_right`, `padtowidth` 등; 터미널 로그 예 `speaker="gray" english="-= PERSONAL LOG =-"` — [cutscenes.xml](https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/desktop_version/lang/en/cutscenes.xml)
- 화자 표기: 캐릭터 색상(cyan/blue/yellow/purple/gray)이 곧 화자 ID; 초상화 없음, `squeak()` 효과음으로 감정 표현 — 같은 출처들
- 판정: B (대사 텍스트 완전 열람 가능, 비상업 라이선스로 재사용 불가).

#### 7) Iji (2008) — (B)
- GameMaker로 4년간 개발(5.3a) — [Wikipedia: Iji](https://www.wikipedia.org/wiki/Iji); 소스는 "Around 2013" 공개(위키) vs 2012년 포럼 인용 이메일 "you can find the source code on my homepage on the Resources page"(시점 불일치) — [Cave Story 포럼](https://forum.cavestory.org/threads/iji-ports-permission-granted-by-remar.4532/)
- 공식 리소스 페이지: "These downloads also include the source codes."(Iji, Hero Core 등), 명시적 라이선스 문구 없음 — [remargames.se resources](https://www.remargames.se/daniel/resources.php)
- 판정: B (프리웨어 + 소스 열람 가능, 라이선스 부재 → 기본적으로 저작권 유보). 대사 저장 형식은 미검증.

#### 8) Celeste Classic (PICO-8, 2015) — B(불명)
- Maddy Thorson·Noel Berry가 4일 게임잼에서 PICO-8로 제작했다는 2차 기술; 원 카트의 라이선스 문구는 찾지 못함; 후속작 Celeste Classic 2(2021-01)는 PICO-8 BBS에 CC4-BY-NC-SA로 게시되었다는 검색 결과 — [Nintendo Life (Celeste 2 공개)](https://www.nintendolife.com/news/2021/01/celeste_devs_release_retro_celeste_mini-sequel_to_celebrate_the_games_third_anniversary); [ccleste C 포트](https://github.com/lemon32767/ccleste)
- 판정: 대사가 거의 없는 작품이라 스크립트 분석 가치 낮음.

### Inferences
- 플랫포머 컷신 스크립트의 공통 패턴은 "명령 배열/명령 토큰 + 대기(wait/NOD) + 캐릭터 액션 + 텍스트"의 선형 시퀀스이며, 분기는 플래그 점프(TSC `<FLJ`, `<ITJ`, `<YNJ`)로 처리한다. 이는 AGM/Godot에서 JSON/CSV 이벤트 테이블 + 플래그 딕셔너리로 재현 가능하다.
- TSC의 `<SK+`(재시도 시 컷신 반복 방지 스킵플래그)는 타임루프 게임에서 "이번 루프에 이미 본 대사 vs 영구 기억" 플래그를 분리하는 설계에 직접 대응된다(세션 플래그 / 세이브 플래그 / 메타(파일 간) 플래그 3층).
- VVVVVV가 하드코딩 대사를 나중에 번역용 XML로 추출하며 `explanation`(번역가용 맥락) 속성을 둔 것은, 처음부터 대사를 키 기반 데이터로 분리해야 한다는 반증 사례다.
- SuperTux·Frogatto·VVVVVV 모두 대화 초상화 없이 "색상/스프라이트/효과음"으로 화자를 표시 — 소규모 2D 팀이 초상화 비용을 줄이는 현실적 선택.

### Gaps
- Frogatto 대사가 `data/levels/*.cfg`의 FFL 이벤트 안에 있는지 실제 파일로 확인하지 못함.
- Lugaru 맵 내 대화(dialogue) 포맷(바이너리 맵 내 저장 여부)과 캠페인 txt 구조를 직접 열람하지 못함.
- OpenTyrian의 "데이터큐브" 스토리 텍스트 파일명(tyrian.hdt 외)을 확인하지 못함.
- Cave Story 영어 팬 번역(Aeon Genesis) 연도·주체는 이번 조사에서 1차 출처 미확인.
- Celeste Classic 원 카트의 라이선스 문구, Iji 대사 저장 방식 미확인.
- SuperTux의 전체 데이터 라이선스 정책 문서(레벨별 license 필드 외)는 확인하지 못함.

---

## Q4. 코드만 공개(C) 사례: 대사는 어디에 있었나 (간략)

### Takeaway
대형 게임사의 소스 공개는 거의 예외 없이 "엔진/게임 코드 + 원 EULA로 묶인 데이터" 구조이며, 대사·텍스트는 데이터 측 스크립트/현지화 파일(Arx `.asl` + `speech/<언어>/`, FreeSpace 미션 파일, Amnesia `.lang`)에 있다. Doom처럼 텍스트를 코드에 넣은 경우만 텍스트가 같이 풀렸다.

### Cited Findings
- **Doom (1993, 소스 1997)**: README(1997-12-23, John Carmack) "The DOOM source code is released for your non-profit use." / "You still need real DOOM data"; 저장소는 GPL-2.0 표기 — [id-Software/DOOM](https://github.com/id-Software/DOOM). `d_englsh.h`에 `E1TEXT`("Once you beat the big badasses and…") 등 엔딩 텍스트 하드코딩, 파일 헤더는 여전히 "DOOM Source Code License" 문구 — [d_englsh.h](https://raw.githubusercontent.com/id-Software/DOOM/master/linuxdoom-1.10/d_englsh.h) (헤더 문구 vs 저장소 GPL-2.0 표기 불일치 주의)
- **System Shock (1994, 소스 2018-04)**: Nightdive가 Power Mac판 소스("shockmac")를 GPL로 공개, 게임 데이터는 원 EULA 적용 — [GamingOnLinux](https://www.gamingonlinux.com/2018/04/nightdive-studios-has-released-the-source-code-for-system-shock/page=2); OtherSide가 발견해 Nightdive에 공유 — [Game Developer](https://gamedeveloper.com/programming/nightdive-shares-source-code-for-i-system-shock-i-on-mac)
- **Arx Fatalis (2002, 소스 2011-01-14)**: Arkane가 1.21 패치와 함께 GPL로 소스 공개, 에셋은 독점 — [Wikipedia: Arx Fatalis](https://EN.wikipedia.com/wiki/Arx_Fatalis); "art"는 미공개 — [LinuxFr](https://linuxfr.org/users/apostle/journaux/code-source-de-arx-fatalis-lib%C3%A9r%C3%A9). 대사 구조: 스크립트 명령 `speak [-tuphao] <speech*> <command...>`에서 `<speech>`는 현지화 키, 음성은 `speech/<language>/<speech><variant>.wav`에서 로드 — [Arx Libertatis Wiki: speak](https://wiki.arx-libertatis.org/Script:speak)
- **FreeSpace 2 (1999, 소스 2002-04-25)**: "You may not sell or otherwise commercially exploit the source or things you created based on the source." → 오픈소스 정의 불충족; 아트 등 권리는 Interplay/Volition 유지 — [Wikipedia: FreeSpace 2 Source Code Project](https://en.wikipedia.org/wiki/FreeSpace_2_Source_Code_Project)
- **Return to Castle Wolfenstein (2001, 소스 2010-08)**: GPL + "certain additional terms", "does not contain any game data" — [id-Software/RTCW-SP](https://github.com/id-Software/RTCW-SP)
- **Amnesia / Penumbra**: Q2 참조.

### Inferences
- Arx의 "키 하나로 텍스트+음성 파일을 동시에 찾는" 방식(`speech/<lang>/<key>.wav`)은 음성 더빙 없는 2D 게임에서도 "대사 키 → 텍스트/효과음/초상화"를 묶는 설계로 차용할 만하다.
- 코드 공개 + 데이터 독점 모델은 사용자 프로젝트(GPL 코드 + ARR 콘텐츠)와 동일한 구조이며, 업계에서 오래 검증된 분리 방식이라는 근거로 보고서에 인용 가능.

### Gaps
- System Shock의 텍스트 리소스 파일명(CYBSTRNG.RES 등)과 FreeSpace 2 미션 파일(.fs2) 내 메시지 구조는 이번 조사에서 1차 출처로 확인하지 못함.
- Quake는 시간 관계상 조사하지 않음.

---

## Q5. 사용자 프로젝트(상업, GPL-3.0 + section 7 예외, 오리지널 콘텐츠 ARR) 재사용 가능성

### Takeaway
코드·텍스트를 직접 가져다 쓸 수 있는 후보는 사실상 없다. BY-SA(SCP, Lugaru, SuperTux 레벨) 텍스트를 섞으면 해당 부분은 SA로 공개해야 해 ARR 정책과 충돌하고, NC(Frogatto 스토리, VVVVVV, Celeste 계열)·프리웨어(Cave Story, Tyrian, Iji)는 상업 사용 불가다. 분석·영감(구조, 포맷 아이디어)용으로만 쓰는 것이 안전하다.

### Cited Findings
- SCP 콘텐츠 파생물은 CC BY-SA 3.0 의무, GPLv3 선택 가능, 판매 허용; SCP-173 옛 이미지/조각 likeness는 상업 사용 금지 — [SCP Licensing Guide](https://scp-wiki.wikidot.com/licensing-guide)
- SCP–CB는 게임·소스 전체가 CC BY-SA 3.0 — [README](https://github.com/Regalis11/scpcb)
- Frogatto 스토리·캐릭터 디자인·이름은 CC-BY-NC-SA — [LICENSE](https://raw.githubusercontent.com/frogatto/frogatto/master/LICENSE)
- VVVVVV 소스는 상업적 목적의 변경·재배포 금지 — [LICENSE.md](https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/LICENSE.md)
- CSE2 코드 대부분은 Pixel 소유 독점, Nicalis가 CSE2를 2020년 말 내림 — [CSE2 README](https://github.com/gameblabla/CSE2); [Wikipedia](https://en.wikipedia.org/wiki/Cave_Story)
- Amnesia 코드는 GPLv3, 에셋·IP는 Frictional 소유 — [GamingOnLinux](https://www.gamingonlinux.com/2020/09/amnesia-the-dark-descent-and-amnesia-a-machine-for-pigs-go-open-source/page=1/)

### Inferences (법률 자문 아님)
- **GPL-3.0 코드 차용(Amnesia/Penumbra/SuperTux 등)**: 사용자 저장소의 section 7 "추가 허가(독점 AGM 런타임 결합 허용)"는 사용자 자신이 저작권을 가진 코드에만 부여할 수 있다. 제3자 GPL-3.0 코드는 그 예외를 부여받지 않았으므로, 독점 런타임과 결합되는 빌드에 포함하면 충돌 소지가 크다 → 제3자 GPL 코드 차용은 피하는 것이 안전.
- **CC BY-SA 텍스트(SCP/Lugaru/SuperTux 레벨)**: 차용·각색 시 그 부분은 BY-SA로 공개해야 하므로 "오리지널 콘텐츠 ARR" 정책과 양립 불가. SCP 소재를 쓰려면 해당 콘텐츠만 BY-SA로 분리·표기하고 SCP-173 옛 이미지 계열 디자인은 배제해야 함.
- **NC / 프리웨어 / 무라이선스(Frogatto 스토리, VVVVVV, Cave Story, Tyrian, Iji, Celeste Classic)**: 텍스트·캐릭터 재사용 불가. 다만 "명령 토큰식 스크립트", "플래그 분기", "색상 화자 표시" 같은 일반적 기법 아이디어를 참고해 자체 구현하는 것은 표현 복제와 구분된다.
- **MIT/CC BY 4.0(SCP-001 WDB)**: 라이선스상 가장 관대하지만 원 SCP 제안문 자체는 BY-SA라는 점, 소스 위치 미확인이라는 점에서 실사용 가치는 낮음.

### Gaps
- CC BY-SA 3.0 → GPLv3 호환 경로(3.0→4.0 업그레이드 후 GPLv3)에 대한 Creative Commons 공식 문서는 이번 조사에서 직접 확인하지 않음(SCP 가이드의 "compatible" 문구만 확인).

---

## Q6. 호러/미스터리 플랫포머(타임루프·멀티엔딩·메타픽션) 스크립트 설계 교훈

### Takeaway
공개 사례들은 "대사보다 문서·로그·환경 텍스트로 공포를 전달"(SCP–CB 문서/PA, Amnesia Journal, VVVVVV PERSONAL LOG)하고, "텍스트는 키 기반 데이터로 분리, 진행은 플래그로 분기"(TSC, Arx speak, Amnesia lang)하는 구조를 공유한다. 사용자 프로젝트는 이 두 축을 AGM/Godot 위에 데이터 주도형으로 구현하는 것이 바람직하다.

### Cited Findings
- 문서형 서사: Amnesia 노트는 `Journal` 카테고리의 Name/Text 쌍으로 관리 — [Frictional 포럼](https://forum.frictionalgames.com/printthread.php?tid=4407); SCP–CB 문서는 `GFX/items/doc*.jpg` 이미지 — [GFX/items](https://github.com/Regalis11/scpcb/tree/master/GFX/items)
- 음향/방송형 긴장: SCP–CB PA 방송을 클립 조각 조합으로 생성 — [UpdateEvents.bb](https://raw.githubusercontent.com/Regalis11/scpcb/master/UpdateEvents.bb)
- 환경 로그: VVVVVV `speaker="gray"` 터미널 텍스트 `-= PERSONAL LOG =-` — [cutscenes.xml](https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/desktop_version/lang/en/cutscenes.xml)
- 플래그·분기·스킵: TSC `<FL+`/`<FLJ`/`<YNJ`/`<ITJ`/`<SK+` — [TSC Notes](https://archive.cavestory.one/basicmodding/guide/tsc.txt)
- 키 기반 텍스트+음성: Arx `speak` + `speech/<language>/<key>.wav` — [Arx Wiki](https://wiki.arx-libertatis.org/Script:speak)
- 번역 맥락 메타데이터: VVVVVV `explanation` 속성 — [cutscenes.xml](https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/desktop_version/lang/en/cutscenes.xml); SuperTux `_()` + 월드별 `.po` — [world1 트리](https://github.com/SuperTux/supertux/tree/master/data/levels/world1)
- 코드 내 텍스트의 라이선스 귀속: Doom 엔딩 텍스트(`d_englsh.h`), VVVVVV 대사(`Scripts.cpp`) — Q1 출처 참조

### Inferences (설계 제안)
1. **대사·문서 데이터 분리 + ARR 표기**: `content/dialogue/*.json|csv`, `content/docs/*.json`처럼 코드와 분리하고 디렉터리별 LICENSE(ARR) 명시. `.gd`/AGM 스크립트에는 키만(`"loop2.memo_07"`) 둔다(Doom/VVVVVV 반면교사).
2. **메모 픽업 시스템**: Amnesia식 `Name/Text` 쌍 + 읽은 메모를 다시 볼 수 있는 저널. SCP–CB처럼 이미지에 텍스트를 굽지 말고 "종이 텍스처 + 런타임 텍스트"로 렌더(현지화·접근성).
3. **3층 플래그(타임루프)**: TSC의 일반 플래그(`<FL+`)와 스킵플래그(`<SK+`, 프로그램 종료 시 소멸) 구분을 확장해 ① 루프 내 플래그(루프 리셋 시 초기화) ② 영구 플래그(세이브) ③ 메타 플래그(세이브 슬롯/회차 간, 메타픽션용)로 설계. 이미 본 컷신 스킵·"기시감" 대사 변형에 사용.
4. **화자 표시 최소화**: 초상화 대신 색상/이름 태그(VVVVVV), 얼굴 번호(`<FAC`)식 표정 ID 필드(`speaker`, `face`)를 데이터에 두고, 초상화는 후순위.
5. **대사보다 환경 텍스트**: 호러의 긴장은 PA 방송·로그·터미널·메모(SCP–CB, VVVVVV, Amnesia)로 전달하고, 캐릭터 대화는 짧게. 음성 없는 2D에서는 SCP–CB의 "자막 없는 음성" 문제를 피하려면 모든 음향 대사에 텍스트를 병기.
6. **번역 맥락 필드**: 각 대사 엔트리에 `context`(VVVVVV `explanation`) 필드를 두어 한국어 원문→타 언어 번역 시 루프 회차·화자 의도를 전달.
7. **명령 토큰식 컷신**: TSC/VVVVVV처럼 `[wait 0.5][move npc 3][text …][flag+ X]`의 선형 명령열 + 플래그 점프로 분기·멀티엔딩을 데이터에서 제어(엔딩 판정 로직을 코드에서 분리).

### Gaps
- ACTION GAME MAKER(Godot 4.7 기반)의 내장 대화/텍스트 시스템이 위 데이터 분리 구조(CSV 번역, 외부 JSON 로드)를 어떻게 지원하는지는 본 조사 범위 밖이라 검증하지 않음.
- 오픈소스 Godot 호러/내러티브 플랫포머 중 "코드+스토리 모두 자유 라이선스이며 대사 파일이 공개된" 검증 가능한 사례는 SCP-001 WDB(소스 위치 미확인) 외에 찾지 못함(GitHub 토픽 `horror` + GDScript 목록 존재만 확인: [GitHub topics/horror?l=gdscript](https://github.com/topics/horror?l=gdscript)).

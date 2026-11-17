# 공개 비주얼노벨·IF·내러티브 툴 샘플의 캐릭터 대사 스크립트 검증 (조사일 2026-11-17)

> 조사 방법: WebSearch/WebFetch로 공개 웹페이지와 raw 파일 URL만 읽었다. git clone, gh CLI, GitHub MCP는 쓰지 않았고 아카이브도 내려받지 않았다. 인용은 구조를 보여 주는 짧은 줄로만 제한했다.
> 용어: **source-visible**은 스크립트를 읽을 수 있다는 뜻일 뿐이다. **openly licensed**는 텍스트의 재사용·개작 조건이 라이선스로 명시되어 있다는 뜻이다. 둘을 구분해서 적는다.

## Q1. 어떤 공개 작품·샘플이 캐릭터 대사 스크립트를 포함하는가 (식별 정보, 경로, 규모, 구조)

### Takeaway
화자가 표시된 대사, 표정, 선택지를 모두 갖추고 텍스트까지 상업적으로 재사용할 수 있는 확실한 예는 적다. **Ren'Py "The Question"**(Ren'Py 저장소에 포함, MIT로 추정)이 가장 깔끔한 예다. **inkle "The Intercept"**는 MIT가 명시되어 있지만 화자 태그 없이 산문 속에 대사를 쓴다. **Counterfeit Monkey**는 CC BY-SA 4.0이며 quip 기반 대화를 쓴다. **Katawa Shoujo**와 **Twofold(Work in Progress)**는 스크립트를 볼 수 있지만 NC/ND 조건이 붙어 분석용으로만 쓸 수 있다. **Depression Quest**는 소스가 공개되어 있지 않다.

### Cited Findings

#### A. Ren'Py: "The Question" (Ren'Py 저장소 포함 샘플)
- 경로: `renpy/renpy` 저장소 `the_question/game/script.rpy`. 저장소 루트에 `the_question`, `tutorial` 폴더가 있다. — [renpy/renpy](https://github.com/renpy/renpy), [raw script.rpy](https://raw.githubusercontent.com/renpy/renpy/master/the_question/game/script.rpy)
- 캐릭터 정의: `define s = Character(_("Sylvie"), color="#c8ffc8")`. 주인공은 `m`("Me")이다. `_()`는 번역 대상 표시다. — [raw script.rpy](https://raw.githubusercontent.com/renpy/renpy/master/the_question/game/script.rpy)
- 표정/스프라이트: `show sylvie green smile` 형식으로 이미지 태그(sylvie) + 의상/색(green) + 표정(smile)을 쓴다. `scene`, `with fade/dissolve`, `play music`도 쓰인다. — [raw script.rpy](https://raw.githubusercontent.com/renpy/renpy/master/the_question/game/script.rpy)
- 대사: `s "Hi there! How was class?"`, `m "Will you be my artist for a visual novel?"`. 화자가 없는 줄은 내레이션이다. — 같은 출처
- 선택지/플래그: `menu:`가 2개 있다(예: "To ask her right away." / 나중에). 플래그는 `default book = False`로 선언하고 `book` 라벨에서 True로 바꾼 뒤 `marry`에서 `if book:`으로 대사를 분기한다. — 같은 출처
- 규모/구조: 약 230줄, 대사·내레이션 약 90줄, 라벨 6개(start, rightaway, game, book, marry, later), 엔딩 2개("Good Ending" / "Bad Ending"). 파일에 라이선스 헤더는 없다. — 같은 출처
- 성격: renai.us 목록은 Ren'Py 사용법을 가르치려고 만든 "very small game"으로 소개한다(검색 스니펫 기준, 페이지 직접 미확인). — [renai.us: Question, The](https://renai.us/game/question)
- 전제(스포일러 최소): 소꿉친구 Sylvie에게 '질문'을 할지, 언제 할지를 고르는 짧은 연애 VN이다. — [raw script.rpy](https://raw.githubusercontent.com/renpy/renpy/master/the_question/game/script.rpy)

#### B. Ren'Py 튜토리얼 게임
- 경로: `tutorial/game/script.rpy`. `define e = Character(_('Eileen'), color="#c8ffc8")`로 정의하고 `show eileen happy at left`로 표정을 바꾼다. 라벨은 start, tutorials, end이며 각 튜토리얼은 `call expression`으로 `tutorial_playing`, `tutorial_dialogue` 등을 호출한다. 상단 주석은 Ren'Py 스타일의 예로는 The Question이 더 낫다고 적고 있다. — [raw tutorial script.rpy](https://raw.githubusercontent.com/renpy/renpy/master/tutorial/game/script.rpy)
- 성격: 이야기가 아니라 기능 설명용 메타 튜토리얼이다(위 파일의 구조 기준).

#### C. Katawa Shoujo (Four Leaf Studios, Ren'Py) / Katawa Shoujo: Re-Engineered
- 원작 라이선스: 공식 FAQ의 포럼 사본에 따르면 Creative Commons BY-NC-ND이고 FAQ는 3.0 버전에 링크한다. "You may not alter the game, nor make your own derivative work that builds on it." "You may not use Katawa Shoujo for any commercial purposes, including ... any fanworks." — [ks.renai.us FAQ 사본](https://ks.renai.us/viewtopic.php?p=63539) (2차 사본이며, 공식 사이트는 429 오류로 직접 확인 실패)
- 스크립트 공개: Wikipedia 계열 미러에 따르면 개발진이 팬 번역용으로 "English script files in full"을 공개했다. 2차 출처다. — [Wikipedia 미러](https://ipfs.aleph.im/ipfs/QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco/wiki/Katawa_Shoujo.html)
- KS:RE(Fleeting Heartbeat Studios): "The code is licensed under the Mozilla Public License 2.0", "the assets are under by their original CC-BY-NC-ND license", "This project is not affiliated with Four Leaf Studios." — [codeberg.org/fhs/katawa-shoujo-re-engineered](https://codeberg.org/fhs/katawa-shoujo-re-engineered)
- 2022년에 라이선스가 갱신되어 KS:RE 같은 프로젝트를 "두 가지 조건"으로 허용했다는 인터뷰 보도가 웹검색 요약에 등장했다. 그러나 정확히 어느 페이지인지와 조건 내용은 확인하지 못했다. 후보 결과 중 하나는 [fuwanovel 기사](https://fuwanovel.moe/?p=52872)다. 신뢰도가 낮으니 보고서에는 "미확인"으로 표기한다.

#### D. inkle "The Intercept" (ink + Unity, 2016)
- 경로: `Assets/Ink/TheIntercept.ink`. README: "a small demo game written in ink and Unity". — [inkle/the-intercept](https://github.com/inkle/the-intercept)
- 라이선스: "**The Intercept** and **ink** are released under the MIT license.", "Copyright (c) 2016 inkle Ltd.", "we don't require attribution". — [inkle/the-intercept README](https://github.com/inkle/the-intercept)
- 구조: 1,000줄 이상, top-level knot 약 45개(`=== start ===`, `harris_demands_component`, `night_falls` 등), stitch 약 25개. 함수 `lower(ref x)`/`raise(ref x)`, 변수 `VAR forceful = 0`, `evasive`, 인벤토리·플래그(`teacup`, `drugged`, `hooperConfessed`), `CONST STRAIGHT = 1`이 있다. 선택지 `* (think) [Think]`, gather `-`, 터널 `->->`, 인라인 조건 `{ forceful > 3:sweating slightly|wasting no time}`을 쓰고 `-> END`가 최소 3개 보인다. — [raw TheIntercept.ink](https://raw.githubusercontent.com/inkle/the-intercept/master/Assets/Ink/TheIntercept.ink)
- 화자 표기: **speaker 태그가 없다.** 1인칭 산문 안에서 따옴표로 대사를 쓰고 "Harris replies" 같은 서술로 화자를 밝힌다. 보이는 범위에는 `#` 태그도 없다. — 같은 출처
- 전제(스포일러 최소): Harris라는 인물이 주인공에게 '부품(component)'의 행방을 추궁하는 심문극이다(knot 이름 기준).

#### E. ink 공식 문서의 태그 규칙
- "ink provides a simple system for tagging lines of content, with hashtags." 예: `A line of normal game-text. # colour it blue`. 태그는 "don't show up in the main text flow, but can be read off by the game". — [WritingWithInk.md](https://github.com/inkle/ink/blob/master/Documentation/WritingWithInk.md)

#### F. Yarn Spinner 예제
- ExampleProjects 저장소의 폴더는 GhostyLads, SpaceJourney, UtilityScripts이며 Yarn Spinner 2.0 데모 게임의 소스다. "MIT license" 라벨(LICENSE.md)이 있다. 크레딧: Story Paris Buttfield-Addison / Art "Kenney.nl, with modifications and additional art by Jon Manning" / Code Jon Manning, Mars Buttfield-Addison. 2025-10-16에 아카이브(읽기 전용)되었다. — [YarnSpinnerTool/ExampleProjects](https://github.com/YarnSpinnerTool/ExampleProjects)
- Unity 샘플은 별도 저장소(YarnSpinner-Unity-Samples)와 에셋 스토어 무료 에셋으로 배포된다. 해당 저장소의 라이선스는 찾지 못했다. — [검색 결과 요약: Yarn Spinner Unity Samples docs](https://docs.yarnspinner.dev/yarn-spinner-for-unity/samples)
- YarnSpinner-Godot(C#판)은 "MIT license" 라벨이 있고 루트에 `Samples` 폴더가 있다. GDScript 사용자는 별도 저장소를 쓰라고 안내한다. — [YarnSpinnerTool/YarnSpinner-Godot](https://github.com/YarnSpinnerTool/YarnSpinner-Godot)
- 라이선스 FAQ: "Most of Yarn Spinner, including the core library and Yarn Spinner for Unity, is released under the MIT License." "Yarn Spinner for Godot (GDScript) and Yarn Spinner for Unreal are released under the Yarn Spinner Public License (YSPL)." — [yarnspinner.dev/license](https://yarnspinner.dev/license/)

#### G. Godot: Dialogue Manager 예제 프로젝트
- 본체 저장소에는 `examples` 폴더가 없다(루트: `addons/dialogue_manager`, `docs`, `tests`). 예제는 itch.io 5종(Portraits/emotes/tags, Visual novel, Voices & translations, Speech balloons, Endless scroll)이다. "Dialogue Manager 4 for Godot 4.6+", MIT. — [nathanhoad/godot_dialogue_manager](https://github.com/nathanhoad/godot_dialogue_manager)
- Portraits 예제: Code "MIT License", Asset "Creative Commons Attribution v4.0 International"이며 최소 **$5 USD**를 내야 받을 수 있다. 파일은 `gdscript_project-4.1.0.zip`, `dotnet_project-4.1.0.zip`이다. 설명은 "Showing character portraits alongside dialogue.", "Animating those portraits by using tags in the dialogue.", "Talking beeps"다. — [itch.io 예제 페이지](https://nathanhoad.itch.io/godot-dialogue-example-project-portraits)

#### H. Godot: Dialogic 2 / GDQuest Godot Open RPG
- Dialogic 타임라인은 `.dtl` 확장자를 쓴다: "For Dialogic to register your timeline file, it has to use the `.dtl` extension!" — [Dialogic docs: Timeline Text Syntax](https://docs.dialogic.pro/timeline-text-syntax.html)
- Godot Open RPG: 코드 MIT. "You need to use Godot 4.7.2, or newer"이고 "currently a work-in-progress"다. `addons/dialogic`을 포함하며 목표 목록에 "dialogues"가 있다. — [gdquest-demos/godot-open-rpg](https://github.com/gdquest-demos/godot-open-rpg)
- CREDITS: 아트(Kenney Emotes/Tiny Town/Tiny Dungeon, food_please 파생)와 오디오(Zane Little Music, Kenney)가 모두 CC0다. **글/대사 크레딧은 없다.** — [CREDITS.md](https://raw.githubusercontent.com/gdquest-demos/godot-open-rpg/main/CREDITS.md)
- 트리 일부에서 `addons/dialogic/Example Assets/Fonts/LICENSE.txt`, `LICENSE`, `CREDITS.md`는 확인했다. 실제 `.dtl` 타임라인 파일은 응답이 잘린 범위에서 찾지 못했다. — [GitHub API tree](https://api.github.com/repos/gdquest-demos/godot-open-rpg/git/trees/main?recursive=1)

#### I. Godot: Escoria 데모 게임 (포인트앤클릭)
- "a general showcase of its features". Godot 4.6.x와 4.7.x를 지원한다. 코드는 MIT 라벨이다. 아트(Marco Giorgini 캐릭터 시트, Kenney 아이템, 커서)는 CC0, 오디오는 CC0와 CC-BY 4.0(Eric Matyas 곡 포함)이 섞여 있다. 폰트 Onesize는 "free for personal use"이고 README는 "Please mind checking the licence before redistributing"이라고 경고한다. — [godot-escoria/escoria-demo-game](https://github.com/godot-escoria/escoria-demo-game)
- 대사는 ASHES 언어로 쓴다: `say($player, "Hello!")`, 세 번째 인자는 번역 키(`"worker_hello"`)다. 선택지 블록은 `?!` … `!?`, 옵션은 `- "I sell fine leather jackets."`, 조건은 `[!knows_way]`이다. — [Escoria docs: Writing dialogs](https://docs.escoria-framework.org/en/devel/getting_started/dialogs.html)

#### J. Godot: Bow (Arrow 런타임 SDK + 예제)
- Godot 4 기반 내러티브 SDK이고 Arrow 런타임을 포함한다. 코드는 MIT이고, 미디어는 CC 계열을 쓰며 특히 CC0를 선호한다. 루트 폴더는 `chapters`, `scenes`, `assets`, `addons`, `internals`이고 데모는 온라인에서 플레이할 수 있다. 예제 제목·전제·스토리 텍스트 라이선스는 페이지에 없다. — [mhgolkar/Bow](https://github.com/mhgolkar/Bow)

#### K. Inform 7: Counterfeit Monkey (Emily Short 외)
- "Counterfeit Monkey is licensed under the Creative Commons Attribution-ShareAlike 4.0 license." feelies(포스터)는 제외되며 "only the images which are complied into the gamefile are licensed." "Copyright © 2012-2023 by Emily Short and others", Inform 7 6M62, 커밋 2,079개. — [i7/counterfeit-monkey](https://github.com/i7/counterfeit-monkey), [README raw](https://raw.githubusercontent.com/i7/counterfeit-monkey/master/README.md)
- 소스 구조: `Counterfeit Monkey.materials/Extensions/Counterfeit Monkey/` 아래 `.i7x`가 최소 51개다. 막별 파일(`Act I Among Sightseers.i7x` … `Act V Atlantida Herself.i7x`)과 대화 관련 파일(`Animal Actions and Human Conversation.i7x`, `Hard-coded Quip Cache.i7x`, `Initial Quip Positions.i7x`, `Conversation Speedups.i7x`, `Character Models.i7x`)이 있다. — [Extensions 폴더](https://github.com/i7/counterfeit-monkey/tree/master/Counterfeit%20Monkey.materials/Extensions/Counterfeit%20Monkey)
- 대화 인코딩(quip): `barker-advertisement is an NPC-directed quip.` / `The reply is "[one of]...` / `add barker-advertisement to the planned conversation of the barker.` / `queue hang-on-there.` — [Act I raw](https://raw.githubusercontent.com/i7/counterfeit-monkey/master/Counterfeit%20Monkey.materials/Extensions/Counterfeit%20Monkey/Act%20I%20Among%20Sightseers.i7x)

#### L. Twine: Depression Quest / Twine Cookbook
- Depression Quest: 저자 Zoe Quinn, Patrick Lindsey, Isaac Schankler. 2013-02-14, Twine. IFWiki의 라이선스 필드는 **"n/a"**이고 소스 링크 없이 플레이 링크만 있다. — [IFWiki](https://ifwiki.org/Depression_Quest)
- itch.io에서 무료·PWYW로 배포한다(검색 스니펫 기준). — [itch.io](https://the-quinnspiracy.itch.io/depressionquest)
- Twine Cookbook: "This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License." — [iftechfoundation/twine-cookbook](https://github.com/iftechfoundation/twine-cookbook)
- Twine 도구 자체는 GPL이다(Wikipedia 검색 스니펫 기준). 게임별 라이선스는 별개이며, itch.io는 Twine 태그 게임에 프로젝트별 코드 라이선스(MIT, BSD-3 등) 필터를 둔다. — [Wikipedia: Twine](https://en.wikipedia.org/wiki/Twine_(software)), [itch.io code-mit twine](https://itch.io/games/newest/code-mit/tag-twine)

#### M. 일본: TyranoScript 샘플 / 吉里吉里(KAG3)
- TyranoScript(ShikemokuMK, "Ver6.00"): `data/scenario/`에 `cg.ks, config.ks, first.ks, make.ks, replay.ks, scene1.ks, title.ks, tyrano.ks`가 있다. — [tyranoscript/data/scenario](https://github.com/ShikemokuMK/tyranoscript/tree/master/data/scenario), [repo](https://github.com/ShikemokuMK/tyranoscript)
- `scene1.ks`(헤더 `;ティラノスクリプトサンプルゲーム`, 약 300~350줄)는 캐릭터 akane(あかね)와 yamato(やまと)가 기능을 설명하는 튜토리얼형 샘플이다. — [raw scene1.ks](https://raw.githubusercontent.com/ShikemokuMK/tyranoscript/master/data/scenario/scene1.ks)
- 吉里吉里/KAG3: 2차 출처끼리 충돌한다. 吉里吉里Z는 "修正BSDライセンス"라는 해설과 [pedia.3rd-in](https://pedia.3rd-in.co.jp/wiki/%E5%90%89%E9%87%8C%E5%90%89%E9%87%8CZ), 吉里吉里(구판) 본체는 GPL이라는 설명이 있다([萌娘百科](https://zh.moegirl.org.cn/Kirikiri)). SDL2 포트의 `src`는 MIT다([krkrsdl2](https://github.com/krkrsdl2/krkrsdl2)). KAG3 샘플의 개별 라이선스는 찾지 못했다.

#### N. 추가 발견: 소스가 공개된 Ren'Py VN
- **Unscripted**(UnscriptedVN/core): "A visual novel about software development". Ren'Py 7.3.5이며 루트에 `script.rpy`, `options.rpy`가 있다. "The source code and assets in this repository are licensed under the Mozilla Public License v2.0." — [UnscriptedVN/core](https://github.com/UnscriptedVN/core)
- **Twofold / "Work in Progress" demo**(Salty Salty Studios): 커뮤니티 칼리지 청년의 이야기다. Ren'Py 6.17.6 위에 자체 스크립트 시스템 RABBL을 쓴다. 언어별 디렉터리는 `game/scripts/en`, 언어별 `init.rpy`에서 scenes/characters/tracks를 등록하고 선택지는 `choice_<name>_<language>` 라벨로 만든다. 2020-07-15에 아카이브되었다. — [salty-salty-studios/twofold](https://github.com/salty-salty-studios/twofold)

### Inferences
- **캐릭터 스크립트 포함 여부 요약**
  - Yes(화자·표정·선택지 모두): The Question, Katawa Shoujo, TyranoScript scene1.ks, Twofold. Dialogue Manager/Dialogic/Yarn/Escoria 샘플은 문법상 지원하지만 실제 예제 파일을 직접 열어 확인하지는 못했다.
  - Partial: The Intercept(대사는 있으나 화자를 산문으로 표기), Counterfeit Monkey(quip 객체로 NPC 대사를 구성하고 표정 개념은 없음), Ren'Py tutorial(이야기가 아닌 설명형).
  - No(소스 비공개): Depression Quest.
- **구조 유형(추정)**
  - The Question: 짧은 분기 2엔딩에 플래그 1개로 대사가 변하는 미니 branch-and-bottleneck/time-cave형.
  - The Intercept: 상태 변수(forceful/evasive)로 뉘앙스가 달라지는 branch-and-bottleneck과 다중 엔딩.
  - Counterfeit Monkey: 5막 구조의 퍼즐 IF로, NPC별 "planned conversation" 큐를 쓰는 대화가 storylet/quality-based에 가깝다.
  - Katawa Shoujo: 루트 분기형 다중 엔딩(일반 지식이며 이번 세션에서 미검증).
- AGM이 Godot 4.7 기반이라는 점에서 Godot Open RPG(4.7.2+)와 Escoria(4.6/4.7)는 엔진 버전이 맞는 참고 프로젝트다. 다만 AGM 런타임에서 이 애드온들이 돌아가는지는 별개 문제다.

### Gaps
- The Question과 튜토리얼의 **텍스트·아트 라이선스가 파일 단위로 명시된 곳을 찾지 못했다**(Q2 참조).
- Katawa Shoujo 공식 사이트 FAQ와 2022년 갱신 조건은 429 오류로 직접 확인하지 못했다. KS의 스크립트 파일명, 단어 수, 루트 수도 이번 세션에서 확인하지 못했다.
- Yarn ExampleProjects의 `.yarn` 파일 경로(GitHub API 403)와 아트 수정본 라이선스는 미확인이다.
- Godot Open RPG에 실제 Dialogic 타임라인(대사 내용)이 들어 있는지는 미확인이다.
- Dialogue Manager 예제(유료)의 `.dialogue` 파일 내용은 미확인이다.
- **한국어 오픈소스 VN**: 한·영 검색에서 명시적 라이선스가 붙은 공개 스크립트를 찾지 못했다.
- The Intercept, Counterfeit Monkey, KS의 정확한 단어 수는 찾지 못했다.

## Q2. 코드·텍스트·아트·오디오 라이선스를 분리하면 어떻게 되는가 (source-visible vs openly licensed)

### Takeaway
텍스트까지 **명시적으로 열린 라이선스**인 것은 The Intercept(MIT), Counterfeit Monkey(CC BY-SA 4.0), Unscripted(MPL-2.0, "source code and assets")다. Ren'Py 샘플은 저장소 전체가 MIT 기여 원칙을 따르지만 샘플 텍스트에 대한 개별 문구는 없다. Katawa Shoujo는 BY-NC-ND, Twofold는 NC 계열이라 볼 수만 있다. 툴 샘플은 대부분 코드는 MIT, 에셋은 CC0/CC BY다.

### Cited Findings
| 항목 | 코드 | 스크립트/텍스트 | 아트 | 오디오 | 구분 | 출처 |
|---|---|---|---|---|---|---|
| Ren'Py 엔진 | "Most of Ren'Py is covered by the terms of the following (MIT) license" + LGPL 일부 | 새 프로젝트 템플릿(`game/script.rpy` 등)만 CC0 1.0. "allow you to license your game scripts the way you want" | 데모 아트: "released by various copyright holders, under the same terms."(지시 대상 모호) | — | 엔진 open | [license.rst](https://raw.githubusercontent.com/renpy/renpy/master/sphinx/source/license.rst), [renpy.org license](https://www.renpy.org/doc/html/license.html) |
| The Question / tutorial | 저장소 기여는 MIT: "By contributing to Ren'Py, you agree to license your contributions under the MIT license." | 파일 헤더 없음. 별도 문구 없음 | 위 "same terms" 문장 외 없음 | — | source-visible, MIT 추정 | [renpy/renpy README](https://github.com/renpy/renpy), [script.rpy](https://raw.githubusercontent.com/renpy/renpy/master/the_question/game/script.rpy) |
| The Question(단독 배포판, 2차) | "Code: MIT" | — | "Artwork: MIT & (GPL-2+, LGPL, Bitstream, Arev Fonts)" | — | 2차 출처 | [Le Bottin des Jeux Linux](https://lebottinlinux.vps.a-lec.org/Bottin_T-Z_files/The_question-13160.html) |
| Katawa Shoujo | KS:RE 코드 MPL 2.0 | 원작 CC BY-NC-ND(3.0) | 원작 CC BY-NC-ND | 원작 CC BY-NC-ND | visible, NC-ND | [FAQ 사본](https://ks.renai.us/viewtopic.php?p=63539), [KS:RE](https://codeberg.org/fhs/katawa-shoujo-re-engineered) |
| The Intercept | MIT(ink, Json.NET도 MIT) | MIT: "The Intercept and ink are released under the MIT license." | README에 별도 언급 없음(MIT로 추정) | 동일 | **open** | [the-intercept](https://github.com/inkle/the-intercept) |
| Yarn ExampleProjects | MIT 라벨 | 별도 문구 없음(MIT 라벨이 저장소 전체 대상인지 불명) | Kenney.nl + Jon Manning 수정. 조건 미기재 | 미기재 | 부분 open | [ExampleProjects](https://github.com/YarnSpinnerTool/ExampleProjects) |
| Dialogue Manager 예제 | MIT | (에셋 CC BY 4.0에 포함되는지 불명) | CC BY 4.0 | — | **유료 다운로드** | [itch.io](https://nathanhoad.itch.io/godot-dialogue-example-project-portraits) |
| Godot Open RPG | MIT | 글 크레딧 없음 | CC0(Kenney 등) | CC0 | open | [repo](https://github.com/gdquest-demos/godot-open-rpg), [CREDITS](https://raw.githubusercontent.com/gdquest-demos/godot-open-rpg/main/CREDITS.md) |
| Escoria demo | MIT | (별도 문구 없음) | CC0 | CC0 + CC-BY 4.0 | open(폰트 주의) | [escoria-demo-game](https://github.com/godot-escoria/escoria-demo-game) |
| Bow | MIT | 미기재 | CC/CC0 선호(폴더별 readme) | 동일 | open(텍스트 불명) | [Bow](https://github.com/mhgolkar/Bow) |
| Counterfeit Monkey | CC BY-SA 4.0(소스 전체) | CC BY-SA 4.0 | 게임 내 이미지만 BY-SA. feelies는 "freely redistributed, but not modified" | — | **open(copyleft)** | [counterfeit-monkey](https://github.com/i7/counterfeit-monkey) |
| Depression Quest | 비공개 | "n/a" | — | — | 비공개 | [IFWiki](https://ifwiki.org/Depression_Quest) |
| Twine Cookbook | (CC BY-SA 4.0) | CC BY-SA 4.0 | — | — | open(copyleft) | [twine-cookbook](https://github.com/iftechfoundation/twine-cookbook) |
| TyranoScript | 무료, "商用利用にも制限はありません。", "作品の製作が目的であれば、改造に制限はありません。", 본체 재배포 금지 | 샘플 시나리오 조건 미기재 | 샘플 캐릭터 이미지 조건 미기재 | — | visible, 샘플 조건 불명 | [LICENCE.txt](https://raw.githubusercontent.com/ShikemokuMK/tyranoscript/master/LICENCE.txt) |
| Unscripted | MPL-2.0 | MPL-2.0("source code and assets") | MPL-2.0 | MPL-2.0 | open(file-level copyleft) | [UnscriptedVN/core](https://github.com/UnscriptedVN/core) |
| Twofold(WIP demo) | BY-NC-ND 4.0 또는 BSD-3 | "Writing ... BY-NC-ND 4.0 or ... BY-NC-SA 4.0" | BY-NC-ND 4.0 | 음악 BY-NC-ND 4.0, SFX BY-NC-ND/BY-NC | visible, NC | [twofold](https://github.com/salty-salty-studios/twofold) |

- CC 공식: GPLv3와 BY-SA 4.0의 호환은 "compatibility with the GPLv3 is one-way only"이다. 즉 BY-SA 4.0 개작물은 GPLv3로 낼 수 있지만 반대는 안 된다. "Currently, no non-CC licenses have been designated as compatible with BY-NC-SA 4.0." — [CC Compatible Licenses](https://creativecommons.org/share-your-work/licensing-considerations/compatible-licenses/)

### Inferences
- Ren'Py 쪽 근거는 두 가지다. 저장소 README의 "contributions under the MIT license" 원칙과, 2차 출처(Le Bottin)의 "Code: MIT / Artwork: MIT"다. 이를 합치면 The Question의 스크립트 텍스트도 MIT일 가능성이 높다. 다만 공식 문서에 샘플 텍스트를 지칭한 명시 문구가 없으므로 "강한 추정"으로 표기해야 한다.
- Katawa Shoujo의 공개 스크립트는 가장 큰 공개 VN 스크립트 중 하나로 분석 가치가 크다. 그러나 NC-ND라 텍스트·구조 인용을 넘어서는 개작은 할 수 없다.

### Gaps
- The Question과 튜토리얼 아트·음악의 정확한 저작자와 라이선스 파일은 찾지 못했다(Debian copyright 페이지 404).
- Yarn ExampleProjects LICENSE.md 본문과 아트 수정본 조건은 미확인이다.
- Escoria demo의 대사 텍스트가 MIT 범위인지 명시 문구는 없다.
- TyranoScript 샘플 캐릭터(あかね/やまと) 이미지·시나리오의 이용 조건 문서를 찾지 못했다.

## Q3. 포맷별로 캐릭터·표정·선택지·변수·로컬라이즈를 어떻게 인코딩하는가

### Takeaway
현대 툴(Yarn, Dialogue Manager, Dialogic)은 모두 **`Name: line` 화자 접두사**로 수렴한다. 표정은 세 갈래다. Dialogic은 괄호(`Name (portrait):`), Dialogue Manager와 Yarn은 태그(`[#mood=happy]`, `#tone:x`), Ren'Py와 TyranoScript는 별도 이미지 명령(`show sylvie green smile`, `[chara_mod face=]`)을 쓴다. 로컬라이즈는 **줄 단위 고유 ID**(Yarn `#line:`, Escoria 키 인자, Ren'Py `_()`)가 핵심이다.

### Cited Findings
| 포맷 | 화자 | 표정/초상 | 선택지 | 변수/조건 | 로컬라이즈 | 짧은 예시(출처) |
|---|---|---|---|---|---|---|
| Ren'Py `.rpy` | `define s = Character(_("Sylvie"), color=...)` 후 `s "..."` | `show sylvie green smile` (이미지 태그 + 속성) | `menu:` + `"text":` 블록 → `jump` | `default book = False`, `if book:` | `_()` 래퍼 | [The Question script.rpy](https://raw.githubusercontent.com/renpy/renpy/master/the_question/game/script.rpy) |
| ink `.ink` | 규칙 없음. The Intercept는 산문 서술 | 기본 없음. `# tag`를 게임이 해석 | `* [Think]`, `+`(sticky), gather `-` | `VAR`, `{cond: a\|b}`, `~` | 내장 규칙 없음 | [TheIntercept.ink](https://raw.githubusercontent.com/inkle/the-intercept/master/Assets/Ink/TheIntercept.ink), [WritingWithInk](https://github.com/inkle/ink/blob/master/Documentation/WritingWithInk.md) |
| Yarn `.yarn` | "a run of characters with no spaces before a colon"를 화자로 인식: `Narrator: Hi...` | 줄 태그 `#tone:sarcastic` | `-> Captain: ...` (중첩 가능) | `<<set>>`/`<<if>>` (이번에는 미확인) | `#line:4c49c5`(고유, 없으면 자동 추가) | [Lines/Nodes](https://docs.yarnspinner.dev/write-yarn-scripts/scripting-fundamentals/lines-nodes-and-options), [Options](https://docs.yarnspinner.dev/write-yarn-scripts/scripting-fundamentals/options), [Tags](https://docs.yarnspinner.dev/write-yarn-scripts/advanced-scripting/tags-metadata) |
| Dialogue Manager `.dialogue` | `Nathan: This is me talking.` | `[#mood=happy]` 태그(`get_tag_value`) | `- Start again => start` | `[if SomeGlobal.some_property == true /]` | Translations 문서 별도(미확인) | [Basic_Dialogue.md](https://github.com/nathanhoad/godot_dialogue_manager/blob/main/docs/Basic_Dialogue.md) |
| Dialogic `.dtl` | `Emilio: Hello and welcome!` | `Emilio (excited): ...`, 인라인 `[portrait=confused]`, `join Emilio (happy) center [animation="Bounce In"]` | `- No \| [if {John.Relationship} > 23]` | `set {MyVariable} += 10`, `if/elif/else:` | (미확인) | [Timeline Text Syntax](https://docs.dialogic.pro/timeline-text-syntax.html) |
| Escoria ASHES | `say($player, "Hello!")` | 문서에 초상 언급 없음 | `?!` … `- "option"` … `!?` | `[!knows_way]` | `say(..., "worker_hello")` 키 | [Writing dialogs](https://docs.escoria-framework.org/en/devel/getting_started/dialogs.html) |
| Inform 7 (CM) | quip 객체: `... is an NPC-directed quip.` | 없음 | quip 선택(대화 시스템) | `planned conversation`, `queue` | — | [Act I .i7x](https://raw.githubusercontent.com/i7/counterfeit-monkey/master/Counterfeit%20Monkey.materials/Extensions/Counterfeit%20Monkey/Act%20I%20Among%20Sightseers.i7x) |
| TyranoScript `.ks` | `[chara_new name="akane" ... jname="あかね"]` 후 `#あかね` 줄 | `[chara_face name="akane" face="doki" storage=...]` 등록 → `[chara_mod name="akane" face="happy"]` | `[glink ... target=...]`, `[link target=*playmusic]…[endlink]` | `[eval]`/`[if]`(scene1에는 없음) | — | [scene1.ks](https://raw.githubusercontent.com/ShikemokuMK/tyranoscript/master/data/scenario/scene1.ks) |
| RABBL(Twofold) | 언어별 `init.rpy`에서 characters 등록 | — | `choice` 문, `choice_<name>_<language>` 라벨 | — | 언어별 디렉터리 `game/scripts/en` | [twofold README](https://github.com/salty-salty-studios/twofold) |

- Dialogue Manager의 부가 문법: 무작위 줄 `%3 Nathan: ...`, 인라인 랜덤 `[[A|B|C]]`, 동시 발화 `| Coco: ...`, `=> END`, `=>< cue`(점프 후 복귀). — [Basic_Dialogue.md](https://github.com/nathanhoad/godot_dialogue_manager/blob/main/docs/Basic_Dialogue.md)
- Yarn 노드 구조: `title: Start` / `---` / 본문 / `===`. 노드 태그는 헤더의 `tags:`에 쓰고 `GetTagsForNode`로 읽는다. — [Yarn docs](https://docs.yarnspinner.dev/write-yarn-scripts/scripting-fundamentals/lines-nodes-and-options), [Tags](https://docs.yarnspinner.dev/write-yarn-scripts/advanced-scripting/tags-metadata)
- Dialogic의 위치 이름은 alpha 15부터 숫자 대신 leftmost/left/center/right/rightmost이다. 이벤트명은 소문자로 바뀌었다(join/leave/update). — [Dialogic 릴리스 노트(검색 스니펫)](https://newreleases.io/project/github/dialogic-godot/dialogic/release/2.0-alpha-15)

### Inferences
- 표정 표기 비교
  - Dialogic `Name (expr): text`는 화자·표정·대사가 한 줄에 있어 작가가 읽기 쉽다.
  - 태그 방식(`[#mood=x]`, `#tone:x`)은 파서가 단순하고 확장(음성·카메라 등)이 쉽다.
  - Ren'Py/Tyrano의 별도 명령 방식은 연출(위치·트랜지션)까지 다루지만 대사 줄과 상태가 분리되어 실수가 생기기 쉽다.
- ink는 화자 규칙이 없다. 따라서 ink를 쓰면 프로젝트에서 `# speaker:` 같은 태그 규칙이나 `Name:` 접두사 파싱 규칙을 따로 정해야 한다. The Intercept는 산문형이라 초상화 UI에는 맞지 않는다.

### Gaps
- Dialogic 캐릭터 리소스 파일(일반적으로 `.dch`로 알려져 있음)의 확장자와 portrait 정의 방식은 docs 페이지 404로 이번 세션에서 확인하지 못했다.
- Dialogue Manager의 `[ID:xxx]` 번역 키 문법, Yarn의 `<<set>>/<<if>>`는 이번 세션에서 원문을 확인하지 못했다(일반 지식 수준).

## Q4. 사용자 프로젝트(GPL-3.0 + 7조 추가 허가, 상업, 원작 콘텐츠 All Rights Reserved)에서 재사용할 수 있는가

### Takeaway
**포맷·구조는 모두 참고할 수 있다.** 텍스트 재사용은 사실상 MIT인 The Intercept와 (추정 MIT인) The Question만 부담이 적고, 이 경우에도 저작권 고지를 지켜야 한다. CC BY-SA(Counterfeit Monkey, Twine Cookbook)와 MPL(Unscripted) 텍스트를 섞으면 그 부분은 원작 콘텐츠의 ARR 방침과 충돌한다. NC/ND(KS, Twofold)는 상업 프로젝트에 텍스트를 쓸 수 없다.

### Cited Findings
- The Intercept: MIT이고 "we don't require attribution"이라 적혀 있지만, MIT 본문 조건상 저작권·허가 고지는 포함해야 한다. — [the-intercept README](https://github.com/inkle/the-intercept)
- Counterfeit Monkey: CC BY-SA 4.0. BY-SA 4.0 → GPLv3는 단방향 호환이다. — [README](https://github.com/i7/counterfeit-monkey), [CC compatible licenses](https://creativecommons.org/share-your-work/licensing-considerations/compatible-licenses/)
- Katawa Shoujo: "You may not alter the game, nor make your own derivative work...", 상업 이용 금지. — [FAQ 사본](https://ks.renai.us/viewtopic.php?p=63539)
- Twofold 글: BY-NC-ND 4.0 또는 BY-NC-SA 4.0. BY-NC-SA 4.0은 비CC 라이선스와 호환 지정이 없다. — [twofold](https://github.com/salty-salty-studios/twofold), [CC](https://creativecommons.org/share-your-work/licensing-considerations/compatible-licenses/)
- Ren'Py는 생성 템플릿 파일만 CC0로 풀어 "license your game scripts the way you want"를 보장한다. 이는 **엔진이 게임 스크립트 라이선스를 강제하지 않는다**는 선례다. — [license.rst](https://raw.githubusercontent.com/renpy/renpy/master/sphinx/source/license.rst)
- Yarn Spinner for Godot(GDScript)는 YSPL이고 C#판은 MIT 라벨이다. 툴 선택 시 확인이 필요하다. — [yarnspinner.dev/license](https://yarnspinner.dev/license/), [YarnSpinner-Godot](https://github.com/YarnSpinnerTool/YarnSpinner-Godot)
- Escoria demo의 폰트 Onesize는 "free for personal use"라 재배포할 때 주의해야 한다. — [escoria-demo-game](https://github.com/godot-escoria/escoria-demo-game)

### Inferences
- **재사용 권고 매트릭스**
  - 포맷·문법 차용(아이디어·구조)은 모든 항목에서 문제없다. 문법 자체는 저작권 보호 대상이 아니라는 일반 원칙에 따른 것이며 법률 자문은 아니다.
  - 텍스트·스크립트를 직접 가져오는 것은 MIT(The Intercept, The Question 추정)만 권장한다. 이때도 `THIRD_PARTY_NOTICES`에 고지하고 원작 ARR 텍스트와 디렉터리를 분리해야 한다.
  - BY-SA(CM, Twine Cookbook)와 MPL-2.0(Unscripted)은 GPLv3 저장소에 넣는 것 자체는 가능하다. BY-SA는 단방향 호환이고, MPL은 파일 단위 copyleft에 Secondary License 조항이 있다(일반 지식, 이번 세션 미검증). 다만 그 텍스트로 만든 개작물은 ARR로 묶을 수 없으므로, 원작 스토리를 ARR로 유지한다는 방침이면 **텍스트는 차용하지 말고 분석만** 하는 편이 안전하다.
  - NC/ND(KS, Twofold)는 분석·학습용으로만 쓴다. 구조 관찰 내용을 보고서에 요약하는 정도로 한정한다.
- GPL-3.0 저장소에서 스토리 텍스트를 ARR로 두려면, Twofold README처럼 **카테고리별(코드/글/아트/음악/SFX) 라이선스 표**를 README에 명시하는 방식이 좋은 선례다.

### Gaps
- MPL-2.0과 GPL-3.0의 결합 조건, 7조 추가 허가와 CC BY-SA의 상호작용은 법률 검토가 필요하다(이번 조사 범위 밖).

## Q5. Godot/AGM용 캐릭터 대사 스크립트 포맷 설계 교훈

### Takeaway
권장안은 **"캐릭터 정의 리소스(표시명·색·초상 맵) + `화자ID (표정): 대사 [#태그] #line:ID` 형식의 줄"**이다. 즉 Dialogic의 괄호 표정, Dialogue Manager·Yarn의 태그, Yarn의 줄 ID, Ren'Py의 `define Character`를 합친 하이브리드 구조다. 선택지는 `- 텍스트 [if 조건] => 대상`, 상태는 명시적 변수/플래그로 둔다. 플랫포머용으로는 무작위·동시 발화(bark) 문법과 NPC 대화 큐(CM의 planned conversation)를 추가로 고려한다.

### Cited Findings
- 캐릭터 정의와 대사 분리: Ren'Py `define s = Character(_("Sylvie"), color="#c8ffc8")`([The Question](https://raw.githubusercontent.com/renpy/renpy/master/the_question/game/script.rpy)), TyranoScript `[chara_new]`+`[chara_face]`로 표정 이미지를 미리 등록([scene1.ks](https://raw.githubusercontent.com/ShikemokuMK/tyranoscript/master/data/scenario/scene1.ks)), Twofold는 언어별 `init.rpy`에서 characters를 등록([twofold](https://github.com/salty-salty-studios/twofold)).
- 한 줄 표정 지정: Dialogic `Emilio (excited): ...` + 인라인 `[portrait=confused]`. — [Dialogic](https://docs.dialogic.pro/timeline-text-syntax.html)
- 태그 기반 메타데이터: Dialogue Manager `Nathan: [#mood=happy] Oh, Hello!`([DM docs](https://github.com/nathanhoad/godot_dialogue_manager/blob/main/docs/Basic_Dialogue.md)), Yarn `#tone:sarcastic`([Yarn tags](https://docs.yarnspinner.dev/write-yarn-scripts/advanced-scripting/tags-metadata)), ink `# colour it blue`([ink](https://github.com/inkle/ink/blob/master/Documentation/WritingWithInk.md)).
- 줄 고유 ID와 번역: Yarn `#line:` "uniquely identifies a line ... for localisation", 없으면 자동 추가([Yarn](https://docs.yarnspinner.dev/write-yarn-scripts/advanced-scripting/tags-metadata)). Escoria 키 "Once you add a key ... the text in quotes will be ignored."([Escoria](https://docs.escoria-framework.org/en/devel/getting_started/dialogs.html)).
- 조건부 선택지: DM `[if ... /]`, Dialogic `| [if ...]`, Escoria `[!knows_way]`. — 위 각 출처
- 바크(bark)형 대사: DM 무작위 가중치 `%3`, 동시 발화 `| Coco:`. — [DM docs](https://github.com/nathanhoad/godot_dialogue_manager/blob/main/docs/Basic_Dialogue.md)
- NPC 대화 큐: CM `add ... to the planned conversation of the barker.` / `queue ...`. — [CM Act I](https://raw.githubusercontent.com/i7/counterfeit-monkey/master/Counterfeit%20Monkey.materials/Extensions/Counterfeit%20Monkey/Act%20I%20Among%20Sightseers.i7x)
- 상태 변수가 대사 톤을 바꾸는 방식: The Intercept `VAR forceful`, `{ forceful > 3:...|...}`. — [TheIntercept.ink](https://raw.githubusercontent.com/inkle/the-intercept/master/Assets/Ink/TheIntercept.ink)

### Inferences
1. **화자 ID와 표시명을 분리한다.** 스크립트에는 짧은 ID(`hero`, `rival`)만 쓰고 표시명·색·초상 맵은 리소스(Godot `.tres`/JSON)에 둔다. 로컬라이즈할 때 표시명만 번역하면 되고, Ren'Py `_()`와 같은 효과를 얻는다.
2. **표정은 화자 바로 뒤 괄호 + 기본값 폴백**으로 한다(`hero (angry): ...`, 생략하면 이전 표정 유지 또는 default). 태그는 음성, 카메라 흔들림 같은 확장용으로 쓴다(`[#voice=...]`). Dialogic과 DM 문법을 모두 받아들일 수 있게 파서를 설계하면 툴을 바꿔도 이전 비용이 낮다.
3. **줄 ID를 필수로 둔다**(Yarn처럼 툴이 자동 생성). 한국어 원문을 기준으로 영어·일본어 CSV를 내보낼 때 ID가 기준 키가 된다.
4. **선택지·조건·플래그 문법은 DM/Dialogic 스타일**(`- text [if flag] => label`)로 하고, 플래그는 AGM의 게임 변수(스위치)와 이름을 1:1로 맞춘다.
5. **산문형(ink The Intercept) 대신 화자 접두형을 쓴다.** 초상화와 말풍선 UI가 화자 정보를 필요로 하기 때문이다.
6. **플랫포머 특화 요소**: 전투 중·이동 중 짧은 바크(무작위/가중치), 동시 발화, NPC 대화 큐(만날 때마다 다음 대사로 진행)를 지원한다. 분기 구조는 The Question 같은 소규모 branch-and-bottleneck을 챕터 단위로 반복하는 것이 관리하기 쉽다.
7. **언어별 디렉터리와 라이선스 표를 둔다**(Twofold 선례). `story/ko/`, `story/en/`처럼 나누고 README에 "코드 GPL-3.0 / 스토리 텍스트·캐릭터 All Rights Reserved" 표를 명시한다.

### Gaps
- AGM(ACTION GAME MAKER) 런타임에서 Dialogic, Dialogue Manager, Escoria 같은 GDScript 애드온이 동작하는지, AGM 이벤트 시스템과 연동할 수 있는지는 이번 조사 범위에서 검증하지 못했다.

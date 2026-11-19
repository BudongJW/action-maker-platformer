# 캐릭터 스크립트 포맷 명세 (v1 초안)

이 문서는 게임의 대사·바크·문서·자막을 작성하는 텍스트 포맷(`.dlg`)과, 그것을 컴파일한 데이터, 그리고 런타임이 지켜야 할 계약을 정의합니다. 설계 근거는 [`reports/오픈소스 게임 스토리 스크립트 분석.md`](../reports/오픈소스%20게임%20스토리%20스크립트%20분석.md)의 "캐릭터 스크립트는 레지스트리·줄 ID·3층 플래그로 설계하라" 절입니다.

상태: **초안**. 컴파일러·린터는 [`tools/storyc.py`](../tools/storyc.py)(12절), 런타임은 [`scripts/story/`](../scripts/story/)(11절)에 구현되어 있습니다. 런타임은 Godot 4.7 헤드리스에서 테스트했지만, ACTION GAME MAKER G 안에서의 동작은 아직 확인하지 않았습니다.

---

## 1. 설계 목표와 제약

| 목표 | 이 포맷에서의 결정 |
|---|---|
| 대사 텍스트를 GPL 코드와 분리 | 원문은 `assets/original/`(All Rights Reserved)에만 둡니다. 코드는 줄 ID로만 참조합니다. 조건·효과는 선언형으로만 쓰고 임의 코드 실행을 허용하지 않습니다. |
| ACTION GAME MAKER G 의존 최소화 | AGM G에서 Godot 애드온(`addons/`)이 동작하는지 아직 확인되지 않았습니다. 그래서 특정 대화 애드온에 묶이지 않도록, 저장소 안의 오프라인 컴파일러가 JSON을 만들고 작은 GDScript 런타임이 읽는 구조로 갑니다. |
| 타임루프·멀티 엔딩·메타 연출 | 플래그를 `loop` / `save` / `meta` 세 층으로 나누고, 본 대화 기록(`seen`)을 층마다 자동으로 남깁니다. 메타 연출은 대사의 출력 대상(`to=`)으로 표현하고, 런타임은 반드시 게임 내 대체 연출을 갖춥니다. |
| 한국어 1차 작성, 번역 대비 | 모든 표시 텍스트에 고정 줄 ID(`#line:`)를 붙입니다. 번역 표에는 화자·표정·맥락·원문 해시를 함께 싣습니다. |
| 작가가 읽고 쓰기 쉬움 | 화자 접두형(`화자 (표정): 대사`)을 씁니다. Dialogic·Dialogue Manager 문법과 비슷하게 만들었지만 **호환되지는 않습니다.** |

**설계 출처.** 화자 접두사와 괄호 표정은 Dialogic, 줄 끝 `#line:` ID는 Yarn Spinner, 조건부 선택지와 `=>` 점프는 Dialogue Manager에서 왔습니다. `@requires`/`@forbids`는 Flare와 Naev, 이름 덮어쓰기는 Wesnoth `caption`과 Naev `rename()`을 따랐습니다. 번역 맥락은 VVVVVV `explanation`, 원문 해시는 Ryzom, 플래그 층 구분은 Cave Story의 일반/스킵 플래그에서 가져왔습니다. 문법과 구조만 참고했고, 외부 텍스트는 가져오지 않았습니다.

---

## 2. 파일 배치

```
assets/original/                      # All Rights Reserved
├── characters/
│   └── <character_id>/
│       ├── character.json            # 캐릭터 레지스트리 (3절)
│       └── portraits/<expression>.png
├── voice/<locale>/<line_id>.ogg      # 선택. 줄 ID와 같은 이름이면 자동 연결
└── story/
    ├── project.json                  # 원문 언어, 번역 언어, 길이 제한 (8절)
    ├── src/*.dlg                     # 원문 스크립트 (4~7절)
    ├── l10n/strings.csv              # 번역 표 (9절)
    ├── l10n/.gdignore                # Godot이 CSV를 번역 리소스로 가져오지 않게 함 (컴파일러가 만듦)
    └── compiled/                     # 컴파일 결과, 커밋함 (10절)
        ├── story.json
        └── strings.<locale>.json

scripts/story/*.gd                    # 런타임 (GPL, 11절)
tools/storyc.py                       # 컴파일러·린터 (GPL, 12절)
tools/run_godot_tests.py              # 런타임 테스트 실행기 (Godot 헤드리스)
```

- `compiled/`는 컴파일러가 만드는 파일이지만 **커밋합니다.** AGM G 에디터와 내보내기 빌드가 Python 없이도 바로 읽을 수 있어야 하기 때문입니다. CI는 `compiled/`가 `src/`와 일치하는지 검사합니다.
- 확장자를 `.dialogue`가 아니라 `.dlg`로 정한 이유가 있습니다. 나중에 Dialogue Manager 애드온을 설치하면 `.dialogue` 파일을 자기 문법으로 가져오려다 오류를 냅니다. 그 충돌을 피하려는 것입니다.
- 원문 언어 폴더(`ko/`)를 따로 두지 않습니다. 원문 언어는 `project.json`의 `source_locale`로 정하고, 번역은 모두 `l10n/strings.csv`에 둡니다.

---

## 3. 캐릭터 레지스트리 (`character.json`)

```json
{
  "id": "hongryeon",
  "name": "홍련",
  "aliases": { "unknown": "???", "girl": "연못가의 소녀" },
  "color": "#9fc5e8",
  "style": "bubble",
  "expressions": ["neutral", "sad", "surprised", "angry"],
  "default_expression": "neutral",
  "portraits": {
    "neutral": "portraits/neutral.png",
    "sad": "portraits/sad.png"
  },
  "blip": "sfx/blip_soft",
  "bio": {
    "personality": "체념한 듯 차분하지만 진실 앞에서는 단호하다.",
    "purpose": "자신의 죽음에 얽힌 거짓을 바로잡는 것.",
    "backstory": "작성 중",
    "relations": { "hero": "매 루프 처음 만나지만 기억은 쌓인다." }
  },
  "notes": "존댓말. 감정이 격해지면 문장이 짧아진다."
}
```

| 필드 | 필수 | 설명 |
|---|---|---|
| `id` | 예 | 폴더 이름과 같아야 합니다. `[a-z][a-z0-9_]*` |
| `name` | 예 | 원문 언어 표시명. 번역은 `strings.csv`의 `name.<id>` 키로 들어갑니다. |
| `aliases` | 아니오 | 정체를 숨기거나 호칭이 바뀔 때 쓰는 대체 이름입니다. 대사에서 `[name=unknown]`으로 고르고, 번역 키는 `name.<id>.<alias>`입니다. |
| `color` | 아니오 | 이름표·말풍선 테두리 색. 초상화 없이 화자를 구분할 때 씁니다(VVVVVV 방식). |
| `style` | 아니오 | 이 화자의 기본 출력 방식: `window`(초상화 대화창) / `bubble`(머리 위 말풍선) / `caption`(화면 하단 자막). 기본값은 `window`입니다. |
| `expressions` | 예 | 대사에서 쓸 수 있는 표정 이름 목록. 초상화가 없어도 표정 이름은 정의합니다(말풍선 색조·이모트 기본값에 씁니다). |
| `default_expression` | 예 | 대화가 시작될 때의 표정. `expressions` 안에 있어야 합니다. |
| `portraits` | 아니오 | 표정 → 초상화 이미지. 일부 표정만 있어도 됩니다. 없는 표정은 `default_expression`의 초상화로 대체합니다. |
| `blip` | 아니오 | 글자 출력음 ID. |
| `bio`, `notes` | 아니오 | 작가용 설정 메모입니다. **컴파일 결과에 포함되지 않습니다.** |

**예약 화자.** 다음 두 화자는 레지스트리 없이 쓸 수 있습니다. 레지스트리 파일을 두면 스타일을 덮어쓸 수 있습니다.

- `narrator`: 이름표 없는 서술. 기본 `style`은 `caption`입니다.
- `system`: 게임·OS의 시스템 메시지처럼 보이는 메타 연출용 화자입니다. 기본 `style`은 출력 대상 `os_dialog`입니다(6.3절).

예약 화자의 레지스트리 파일에서는 `name`과 `expressions`를 생략할 수 있고, `style`에 6.3절의 출력 대상 이름도 쓸 수 있습니다. 컴파일 결과에는 레지스트리 파일이 없어도 두 예약 화자의 항목이 항상 들어갑니다.

`title`과 `p`는 문서 블록 전용 표기(7.2절)라서 캐릭터 ID로 쓸 수 없습니다.

---

## 4. `.dlg` 파일 기본 규칙

- 인코딩은 UTF-8, 줄 단위로 해석합니다.
- 빈 줄은 무시합니다.
- `//`로 **시작하는** 줄은 주석입니다. 줄 중간의 `//`는 대사 텍스트로 취급합니다.
- 들여쓰기는 선택지와 `if` 블록의 본문에만 씁니다. 한 파일 안에서는 탭이나 4칸 공백 중 하나로 통일합니다.
- 식별자(블록 ID, 라벨, 화자, 표정, 플래그 이름 조각)는 `[a-z][a-z0-9_]*`입니다.
- 블록 ID와 줄 ID는 **프로젝트 전체에서** 유일해야 합니다(파일이 달라도 겹치면 안 됩니다).

한 파일에는 여러 블록이 들어갈 수 있습니다. 블록은 `~`로 시작하는 머리줄로 열고, 다음 머리줄이나 파일 끝에서 닫힙니다.

| 머리줄 | 블록 종류 | 용도 |
|---|---|---|
| `~ <id>` | 대화(dialogue) | 입력을 막고 진행하는 대화. 선택지·분기·효과 사용 가능 |
| `~bark <id>` | 바크 풀(bark pool) | 이동·전투를 멈추지 않는 무작위 혼잣말 |
| `~doc <id>` | 문서(document) | 줍고 저널에서 다시 읽는 메모·일지 |
| `~cue <id>` | 자막 큐(cue) | 컷신·연출 중 시간에 맞춰 나오는 자막 |

머리줄 바로 아래에는 `@`로 시작하는 블록 속성을 둘 수 있습니다(5.1절).

---

## 5. 대화 블록

### 5.1 블록 속성

```
~ ch01_pond_ghost
@requires loop.night
@forbids loop.pond_sealed
@once save
@priority 10
@style bubble
```

| 속성 | 값 | 의미 |
|---|---|---|
| `@requires <식>` | 조건식 | 참일 때만 이 대화를 시작할 수 있습니다. 여러 줄이면 모두 참이어야 합니다(AND). |
| `@forbids <식>` | 조건식 | 참이면 시작할 수 없습니다. 여러 줄이면 하나라도 참이면 막힙니다. |
| `@once [loop\|save\|meta]` | 층 | 해당 층에서 이미 본 대화(`seen.<층>.<id>`)면 시작할 수 없습니다. 층을 생략하면 `save`입니다. |
| `@priority <정수>` | 기본 0 | 한 트리거에 후보 대화가 여럿일 때 높은 값부터 고릅니다(11절 `pick`). |
| `@style <window\|bubble\|caption\|notice>` | 스타일 | 이 대화 안 모든 줄의 기본 출력 방식. 화자 레지스트리의 `style`보다 우선합니다. |

### 5.2 대사 줄

```
<화자> [(<표정>)] [<속성>]... : <텍스트>  [#<태그>:<값>]...
```

```
hongryeon (sad) [name=unknown]: 또 오셨네요. 이번이 몇 번째 밤인지 기억하세요?  #line:ch01_pg_002 #ctx:정체를 숨긴 화자, 체념한 존댓말
```

- **화자**는 레지스트리의 `id` 또는 예약 화자입니다.
- **표정**은 괄호 안에 씁니다. 생략하면 이 대화 안에서 그 화자가 마지막으로 쓴 표정을 유지하고, 대화 첫 줄이면 `default_expression`을 씁니다.
- **속성**은 대괄호로 하나씩 씁니다. 순서는 자유입니다.

| 속성 | 값 | 의미 |
|---|---|---|
| `[name=<alias>]` | 레지스트리 `aliases`의 키 | 이 줄의 이름표를 대체 이름으로 표시 |
| `[to=<대상>]` | 6.3절 | 이 줄을 출력할 곳 |
| `[emote=<id>]` | 8절의 이모트 목록 | 머리 위 감정 아이콘(초상화가 없을 때 감정 전달) |
| `[voice=<clip>]` | 클립 ID | 음성 지정. 생략하면 `voice/<locale>/<line_id>.ogg`가 있으면 자동 재생 |
| `[side=left\|right]` | | 대화창 초상화 위치 |

- **텍스트**는 첫 번째 `: `(콜론 뒤 공백) 다음부터, 공백 뒤에 `#<소문자 키>:`가 처음 나오는 지점 앞까지입니다. 앞뒤 공백은 지웁니다.
- **태그**는 텍스트 뒤에 `#키:값` 형식으로 붙입니다.
  - `#line:<id>`: **필수.** 번역·음성·기록의 기준이 되는 줄 ID입니다. 형식은 `[a-z0-9_]+`입니다.
  - `#ctx:<자유 텍스트>`: 번역가와 성우를 위한 맥락 메모. 줄 끝까지 읽으므로 항상 마지막에 둡니다.
  - 그 밖의 `#키:값`은 예약되어 있으며, v1 컴파일러는 경고를 냅니다.

**텍스트 안에서 쓸 수 있는 것**

| 표기 | 의미 |
|---|---|
| `{save.ibang_trust}` 등 플래그 이름 | 플래그 값으로 치환 |
| `{@player_name}` / `{@loop_count}` / `{@os_user}` | 런타임 토큰. `{@os_user}`는 메타 연출에 동의한 경우에만 OS 사용자명이고, 아니면 `{@player_name}`과 같습니다. |
| `[b]`, `[i]`, `[color=#hex]`, `[shake]`, `[wave]` | Godot RichTextLabel BBCode 일부 |
| `[wait=<초>]` | 글자 출력 중 멈춤(런타임이 처리하고 화면에서는 지움) |
| `\n` | 강제 줄바꿈 |
| `\#`, `\{`, `\\` | 문자 그대로의 `#`, `{`, `\` |
| `\=>` | 선택지 텍스트 안의 문자 그대로의 `=>` (점프 표기와 구분) |

### 5.3 선택지

```
- [if <식>] [enable_if <식>] [once] <텍스트>  [=> <대상>]  #line:<id> [#ctx:...]
    <본문 문장들>
```

- 연속된 `-` 줄이 하나의 선택지 묶음입니다.
- `[if <식>]`: 거짓이면 **보이지 않습니다.**
- `[enable_if <식>]`: 거짓이면 **보이지만 고를 수 없습니다**(회색 처리). 아직 모르는 정보를 암시할 때 씁니다. Endless Sky의 `to display` / `to activate` 구분을 따랐습니다.
- `[once]`: 이 세이브에서 한 번 고르면 다시 보이지 않습니다.
- `=> <대상>`을 쓰면 고른 즉시 그곳으로 이동합니다. 대신 들여쓴 본문을 둘 수 있습니다.
- 본문이 점프로 끝나지 않으면 **선택지 묶음 다음 줄로 이어집니다**(분기 후 다시 합류하는 branch-and-bottleneck 구조).
- 보이는 선택지가 하나도 없거나, 보이는 선택지가 모두 `[enable_if]`로 막혀 고를 수 있는 것이 없으면 묶음 전체를 건너뜁니다(막다른 화면 방지).

### 5.4 라벨과 점프

```
:: truth
=> truth          // 같은 대화 안의 라벨로 이동
=> ~ch01_aftermath  // 다른 대화로 전환 (그 대화의 @requires는 무시)
=> END            // 대화 종료
```

- 라벨은 `:: <이름>`이며 블록 안에서만 유효합니다.
- 블록 끝에 도달하면 `=> END`와 같습니다.

### 5.5 조건 분기

```
if seen.meta.ch01_pond_ghost
    hero (uneasy): 이 연못… 처음이 아닌 것 같다.  #line:ch01_pg_010
elif sys.loop_count >= 2
    hero: 또 같은 밤이다.  #line:ch01_pg_011
else
    hero: 물소리가 이상하다.  #line:ch01_pg_012
```

- `if <식>` / `elif <식>` / `else` 다음 줄부터 들여쓴 부분이 본문입니다. 콜론을 붙이지 않습니다.
- 같은 장면의 '기시감 변형'(처음 본 밤과 반복된 밤의 대사 차이)을 이 구문으로 씁니다.

### 5.6 효과와 명령

```
set save.asked_about_previous = true
set save.ibang_trust += 1
set loop.ibang_suspicious = true
do sfx drum_far
do shake 0.4 0.6
do emit open_east_gate
```

- `set <플래그> = <값>` / `+= <정수>` / `-= <정수>`. `sys.*`와 `seen.*`는 읽기 전용이라 쓸 수 없습니다.
- `do <명령> [인자...]`는 런타임이 구현한 **허용 목록** 안의 명령만 쓸 수 있습니다. 인자는 숫자나 식별자만 받습니다. **화면에 보이는 텍스트는 명령 인자로 넘기지 않고**, 항상 대사 줄(`#line:`)로 씁니다.

| 명령 | 인자 | 동작 |
|---|---|---|
| `wait` | 초 | 진행 정지 |
| `sfx` | 효과음 ID | 효과음 재생 |
| `music` | 곡 ID 또는 `stop` | 배경음 전환 |
| `shake` | 세기, 초 | 카메라 흔들기 |
| `fade` | `in`/`out`, 초 | 화면 페이드 |
| `emit` | 이벤트 ID | AGM 게임 오브젝트로 이벤트 전달(문 열기, 컷신 시작 등) |
| `loop_reset` | 없음 | 루프 리셋 요청(`loop.*`와 `seen.loop.*` 초기화) |
| `window_shake` | 세기, 초 | **메타.** 실제 OS 창 흔들기(동의하지 않았으면 `shake`로 대체) |

- 런타임은 모든 명령을 `command` 시그널로 게임에 넘깁니다. `loop_reset`은 런타임이 직접 루프를 리셋한 뒤에 알립니다. `window_shake`는 동의가 없거나 창을 움직일 수 없는 환경(Wayland, 웹, 모바일)이면 `shake`로 바꿔서 알립니다.
- `wait`와 `fade`는 대화를 멈춥니다. 런타임이 씬 트리 안에 있으면 지정한 시간 뒤에 스스로 이어 가고, 게임이 그 전에 `resume()`을 불러도 됩니다.

---

## 6. 조건식, 플래그, 출력 대상

### 6.1 조건식

```
식      := or_식
or_식   := and_식 ( "or" and_식 )*
and_식  := not_식 ( "and" not_식 )*
not_식  := "not" not_식 | 비교
비교    := 항 ( ("==" | "!=" | "<" | "<=" | ">" | ">=") 항 )?
항      := 플래그 | 정수 | 실수 | "true" | "false" | "\"식별자\"" | "(" 식 ")"
```

- 비교 연산자 없이 플래그만 쓰면 참/거짓으로 판단합니다(`0`, `false`, 미설정은 거짓).
- 한 번도 설정되지 않은 플래그는 `false`(숫자로 쓰면 `0`)입니다.
- 문자열 리터럴은 `save.route == "east"`처럼 **식별자 값 비교에만** 씁니다. 화면에 보이는 텍스트가 아닙니다.
- 사칙연산과 함수 호출은 v1에서 지원하지 않습니다. 대사 데이터에 로직이 쌓이는 것을 막기 위해서입니다.

### 6.2 플래그 층

플래그 이름은 `<층>.<이름>[.<이름>]...`입니다.

| 층 | 수명 | 쓰기 | 예 |
|---|---|---|---|
| `loop.*` | 현재 루프. 루프 리셋 때 초기화 | 가능 | `loop.night`, `loop.pond_sealed` |
| `save.*` | 세이브 파일 하나 | 가능 | `save.has_seal`, `save.ibang_trust` |
| `meta.*` | 세이브 슬롯과 새 게임을 넘어 유지(`user://meta.dat`) | 가능 | `meta.knows_name`, `meta.endings.true` |
| `seen.loop.*` / `seen.save.*` / `seen.meta.*` | 각 층의 수명 | 런타임 자동 | `seen.meta.ch01_pond_ghost` |
| `sys.*` | 런타임 제공 | 읽기 전용 | `sys.loop_count`, `sys.playthrough`, `sys.meta_os`, `sys.locale` |

- **본 기록(`seen`).** 대화가 **끝날 때**(`=> END`, 블록 끝, 다른 대화로 전환, `stop()` 모두 포함), 그리고 문서를 주울 때 런타임이 `seen.loop.<id>`, `seen.save.<id>`, `seen.meta.<id>`를 함께 참으로 만듭니다. 그래서 "이번 루프에서 봤나", "이 세이브에서 봤나", "어떤 세이브에서든 봤나"를 구분해 쓸 수 있습니다. 시작이 아니라 끝에 기록하므로, 대화 안에서 `seen.<층>.<자기 ID>`는 **이전에** 본 적이 있는지를 뜻합니다(13절 예시의 기시감 분기).
- **`sys.meta_os`.** 플레이어가 실제 OS를 건드리는 메타 연출에 동의했는지를 나타냅니다. 기본값은 거짓입니다.

### 6.3 출력 대상 (`[to=...]`)

| 대상 | 설명 | 동의하지 않았을 때 대체 |
|---|---|---|
| `window` | 초상화 대화창 | — |
| `bubble` | 화자 노드 머리 위 말풍선 | — |
| `caption` | 화면 하단 자막 | — |
| `notice` | 화면 오른쪽 위 알림 한 줄. 대화창에 띄우지 않고 대화는 바로 다음 줄로 간다(프로토타입) | — |
| `os_dialog` | **메타.** OS 알림창(`OS.alert` 등) | 게임 화면 안에 그린 가짜 시스템 창 (`fake_os_dialog`) |
| `window_title` | **메타.** 게임 창 제목 | 화면 상단 캡션 (`caption`) |
| `desktop_file` | **메타.** 바탕화면에 텍스트 파일 생성 | 게임 안 저널에 쪽지로 추가 (`journal_note`) |

괄호 안은 런타임이 대체할 때 `line_started`의 `attrs.target`에 넣는 값입니다. 원래 요청한 대상은 `attrs.requested_target`에 남습니다.

- 우선순위: 줄의 `[to=]` > 블록의 `@style` > 화자 레지스트리의 `style` > `window`.
- 메타 대상은 `sys.meta_os`가 참일 때만 실제 OS에 출력합니다. 런타임은 **모든 메타 대상에 대체 연출을 반드시 구현**해야 합니다. 웹·모바일·Linux Wayland처럼 OS 조작이 막힌 환경에서도 같은 이야기가 진행되어야 하기 때문입니다.
- 런타임은 플레이어의 기존 파일을 수정하거나 지우지 않습니다. `desktop_file`은 게임이 만든 새 파일에만 씁니다.

---

## 7. 바크·문서·자막 블록

### 7.1 바크 풀

```
~bark ch01_night_watch
@requires loop.night
@cooldown 12

watchman [w=3]: 삼경이오— 불조심하시오—  #line:ch01_bk_001
watchman: 연못 쪽으로는 가지 마시오.  #line:ch01_bk_002
watchman (fear) [w=1]: …방금 물소리 들었소?  #line:ch01_bk_003
```

- 속성: `@requires`, `@forbids`, `@cooldown <초>`(같은 풀이 다시 말하기까지의 최소 간격).
- 대사 줄만 쓸 수 있습니다(선택지·점프·`set`·`do`는 오류).
- `[w=<정수>]`는 뽑힐 가중치(기본 1)입니다. 바크는 기본적으로 `bubble`로 출력하고 입력을 막지 않습니다.
- 직전에 나온 줄은 연속으로 다시 뽑지 않습니다.

### 7.2 문서

```
~doc ch01_prev_diary
@category journal

title: 전임 사또의 일지  #line:ch01_dc_001
p: 사흘째 밤, 연못에서 우는 소리가 들렸다. 아전들은 바람 소리라 했다.  #line:ch01_dc_002
p: 그 소리는 내 이름을 알고 있었다.  #line:ch01_dc_003
```

- 문서 블록 안에서는 화자 대신 `title`(제목, 하나만)과 `p`(문단, 여러 개)를 씁니다.
- 텍스트를 이미지에 굽지 않고 런타임이 종이 텍스처 위에 그립니다. 번역과 접근성(글자 크기 조절) 때문입니다.
- 문서를 주우면 `seen.*.<doc_id>`가 참이 되고 저널의 `@category` 탭에 들어갑니다.

### 7.3 자막 큐

```
~cue ch01_opening
watchman [at=0.0] [dur=3.0]: 초경이오—  #line:ch01_cu_001
narrator [at=3.5] [dur=4.0]: 그날 밤, 새 사또가 부임했다.  #line:ch01_cu_002
```

- `[at=<초>]`는 큐 시작 기준 표시 시각, `[dur=<초>]`는 표시 시간입니다. 둘 다 필수입니다.
- 음성·효과음으로만 전달되는 대사도 모두 자막 큐로 텍스트를 남깁니다.

---

## 8. 프로젝트 설정 (`story/project.json`)

```json
{
  "format": 1,
  "source_locale": "ko",
  "locales": ["ko", "en", "ja"],
  "emotes": ["exclaim", "question", "sweat", "heart", "anger", "silence"],
  "max_chars": { "bubble": 40, "caption": 60, "window": 120 },
  "external_flags": ["loop.night", "loop.pond_sealed", "save.has_seal"]
}
```

- `emotes`는 런타임이 그릴 수 있는 이모트 ID 목록입니다.
- `external_flags`는 `.dlg`가 아니라 게임 쪽(AGM 오브젝트, 런타임 API)에서 설정하는 플래그 목록입니다. 여기 적힌 플래그는 W101 경고에서 빠집니다.
- `max_chars`는 스타일별 권장 최대 글자 수입니다. 넘으면 컴파일러가 경고를 냅니다(원문 언어 기준).

---

## 9. 번역 표 (`l10n/strings.csv`)

```csv
id,kind,speaker,expression,context,source_hash,ko,en,en_src_hash,ja,ja_src_hash
name.hongryeon,name,hongryeon,,,1289bd3a,홍련,Hongryeon,1289bd3a,,
ch01_pg_002,line,hongryeon,sad,"정체를 숨긴 화자, 체념한 존댓말",6797deb8,또 오셨네요. 이번이 몇 번째 밤인지 기억하세요?,You came again. Do you remember which night this is?,6797deb8,,
```

- **컴파일러가 만들고 갱신하는** 열: `id`, `kind`(`line`/`choice`/`bark`/`doc`/`cue`/`name`), `speaker`, `expression`, `context`, `source_hash`, 원문 언어 열(`ko`). 이 열들은 손으로 고치지 않습니다. 원문은 `.dlg`와 `character.json`에서 고칩니다.
- 행 순서는 캐릭터 이름(`name.*`, 캐릭터 ID 순) 다음에 `.dlg` 파일 순서·작성 순서입니다. 원문에서 지운 줄의 행은 다음 컴파일 때 빠집니다.
- **번역가가 채우는** 열: 언어별 텍스트(`en`, `ja`)와, 번역할 때의 원문 해시(`en_src_hash` 등).
- `source_hash`는 원문 텍스트의 SHA-1 앞 8자리입니다. 원문이 바뀌면 `<locale>_src_hash`와 달라지므로 컴파일러가 해당 번역을 "원문 변경됨"으로 보고합니다(Ryzom 방식).
- 번역이 비어 있거나 원문이 바뀐 줄은 런타임에서 원문 언어로 대체 표시합니다.
- 번역에서 `{...}` 자리표시자와 BBCode 태그 집합이 원문과 다르면 컴파일러가 경고합니다.

---

## 10. 컴파일 결과

### 10.1 `compiled/story.json`

언어와 무관한 구조만 담습니다. **텍스트는 없습니다.**

```json
{
  "format": 1,
  "source_locale": "ko",
  "locales": ["ko", "en", "ja"],
  "characters": {
    "hongryeon": {
      "color": "#9fc5e8", "style": "bubble",
      "expressions": ["neutral", "sad", "surprised", "angry"],
      "default_expression": "neutral",
      "portraits": {
        "neutral": "res://assets/original/characters/hongryeon/portraits/neutral.png",
        "sad": "res://assets/original/characters/hongryeon/portraits/sad.png"
      },
      "aliases": ["unknown", "girl"],
      "blip": "sfx/blip_soft"
    }
  },
  "dialogues": {
    "ch01_pond_ghost": {
      "requires": { "and": [ { "var": "loop.night" }, { "not": { "var": "loop.pond_sealed" } } ] },
      "once": null, "priority": 0, "style": "bubble",
      "code": [
        { "op": "line", "id": "ch01_pg_001", "speaker": "narrator" },
        { "op": "line", "id": "ch01_pg_002", "speaker": "hongryeon", "expression": "sad", "name": "unknown" },
        { "op": "choice", "options": [
            { "id": "ch01_pg_003", "pc": 3 },
            { "id": "ch01_pg_005", "if": { "cmp": ">=", "a": { "var": "sys.loop_count" }, "b": 2 }, "pc": 5 }
        ], "skip_pc": 8 },
        { "op": "line", "id": "ch01_pg_004", "speaker": "hongryeon", "name": "unknown" },
        { "op": "goto", "pc": 8 },
        { "op": "set", "var": "save.told_ghost_loop", "mode": "=", "value": true },
        { "op": "line", "id": "ch01_pg_006", "speaker": "hongryeon", "expression": "surprised" },
        { "op": "goto", "pc": 10 },
        { "op": "line", "id": "ch01_pg_007", "speaker": "hongryeon" },
        { "op": "end" },
        { "op": "line", "id": "ch01_pg_008", "speaker": "hongryeon" },
        { "op": "set", "var": "meta.knows_name", "mode": "=", "value": true },
        { "op": "line", "id": "ch01_pg_009", "speaker": "system", "to": "window_title" },
        { "op": "end" }
      ]
    }
  },
  "barks": {},
  "docs": {},
  "cues": {}
}
```

- 대화 본문은 **평평한 명령 배열**(`code`)과 배열 인덱스 점프(`pc`)로 컴파일됩니다. 런타임은 프로그램 카운터 하나로 진행하므로 구현이 단순합니다.
- `op` 종류: `line`, `choice`(`options`, 보이는 선택지가 없을 때 이동할 `skip_pc`), `branch`(`if`, `else_pc`), `goto`, `set`, `do`(`cmd`, `args`), `switch`(`dialogue`, 다른 대화로 전환), `end`.
- 선택지 항목: `id`, 선택 사항 `if`·`enable_if`·`once`, 고른 뒤 이동할 `pc`.
- 바크는 `{"requires", "cooldown", "lines": [...]}`, 문서는 `{"category", "title", "paragraphs": [...]}`, 자막 큐는 `{"lines": [...]}`로 컴파일됩니다. 바크 줄에는 `w`, 자막 줄에는 `at`·`dur`가 붙습니다.
- `characters`에는 레지스트리의 모든 캐릭터와 예약 화자 `narrator`, `system`이 들어갑니다. `bio`, `notes`, `name`은 빠집니다(이름은 문자열 표의 `name.<id>`).
- `@requires`와 `@forbids`는 하나의 `requires` 식으로 합쳐집니다(`@forbids X`는 `not X`).
- 표정을 생략한 줄은 `expression` 필드가 없고, 런타임이 직전 표정을 유지합니다.
- 조건식은 문자열이 아니라 **미리 파싱한 트리**로 저장합니다. `{"var": ...}`, `{"cmp": op, "a": ..., "b": ...}`, `{"and": [...]}`, `{"or": [...]}`, `{"not": ...}`. 런타임에는 식 파서가 필요 없습니다.
- 위 예시는 13절 예시 스크립트의 `ch01_pond_ghost` 블록을 컴파일한 모습입니다.

### 10.2 `compiled/strings.<locale>.json`

```json
{
  "ch01_pg_002": "또 오셨네요. 이번이 몇 번째 밤인지 기억하세요?",
  "name.hongryeon": "홍련",
  "name.hongryeon.unknown": "???"
}
```

- 원문 언어 파일은 `.dlg`와 레지스트리에서 만들고, 번역 언어 파일은 `strings.csv`에서 만듭니다. 원문이 바뀐 번역은 넣지 않습니다(런타임이 원문으로 대체).
- 컴파일된 문자열에서 `\n`은 실제 줄바꿈으로, `\#`과 `\=>`는 `#`과 `=>`로 바뀝니다. `\{`와 `\\`는 런타임의 자리표시자 처리를 위해 그대로 남깁니다.

---

## 11. 런타임 계약 (GDScript, GPL)

런타임은 GPL 코드이며 **대사 원문을 한 글자도 담지 않습니다**(CI의 `tools/check_dialogue_in_code.py`가 검사). 구현은 [`scripts/story/`](../scripts/story/)에 있습니다.

| 파일 | 클래스 | 역할 |
|---|---|---|
| `story_runner.gd` | `StoryRunner` (Node) | 대화 진행, 바크·문서·자막, 언어, 메타 대체 처리. 오토로드로 쓰는 것을 전제로 함 |
| `story_flags.gd` | `StoryFlags` (RefCounted) | 플래그 층, `seen`·`[once]` 기록, 세이브 직렬화, 메타 파일 |
| `story_condition.gd` | `StoryCondition` | 컴파일된 조건 트리 평가 |
| `story_text.gd` | `StoryText` | 자리표시자 치환, `[wait=]` 위치 계산 |

| API (`StoryRunner`) | 설명 |
|---|---|
| `load_story(story_json, strings_dir) -> Error` | 컴파일 결과와 원문 언어 문자열을 읽고, 메타 파일도 읽음 |
| `set_locale(locale) -> bool` / `get_locale()` | 표시 언어 변경. 번역이 없거나 원문이 바뀐 줄은 원문 언어로 대체 |
| `is_available(id) -> bool` | `@requires`/`@forbids`/`@once` 판정 |
| `pick(ids) -> String` | 후보 중 시작 가능한 것을 `@priority` 높은 순, 같으면 나열 순으로 고름. 없으면 빈 문자열 |
| `start(id)` / `advance()` / `choose(index)` / `resume()` / `stop()` | 대화 진행. `start`는 시작 조건을 검사하지 않음(트리거는 `pick` 또는 `is_available`을 먼저 호출) |
| `bark(pool_id, speaker_node) -> Dictionary` | 바크 한 줄 출력(조건·쿨다운·가중치·직전 줄 제외). 못 말하면 빈 딕셔너리 |
| `collect_doc(id)` / `get_doc(id)` / `collected_docs(category)` | 문서 줍기, 표시용 텍스트, 저널 목록 |
| `play_cue(cue_id) -> Array` | 자막 줄 목록(`attrs.at`, `attrs.dur`) |
| `get_flag(name)` / `set_flag(name, value)` | 플래그 읽기·쓰기 |
| `new_game()` / `reset_loop()` | 새 게임(`loop.*`·`save.*` 초기화, 회차 증가) / 루프 리셋(`loop.*`·`seen.loop.*` 초기화, `sys.loop_count` 증가) |
| `serialize_save()` / `restore_save(data)` | `loop.*`, `save.*`, `seen.loop.*`, `seen.save.*`, `[once]` 기록, 루프 회차. 진행 중인 대화 위치는 저장하지 않음 |
| `flags.set_meta_os(enabled)` | 실제 OS를 건드리는 메타 연출에 대한 플레이어 동의(`sys.meta_os`) |

| 시그널 | 인자 |
|---|---|
| `dialogue_started` | `dialogue_id` |
| `line_started` | `line_id`, `speaker`, `expression`, `attrs`, `text`(치환·번역 완료, `[wait=]` 제거) |
| `choices_presented` | `[{line_id, text, enabled}]` |
| `command` | `cmd`, `args` |
| `dialogue_finished` | `dialogue_id` |
| `bark_started` | `pool_id`, `line_id`, `speaker`, `expression`, `attrs`, `text` |
| `doc_collected` | `doc_id` |
| `cue_started` | `cue_id`, `lines` |

`line_started`의 `attrs`에는 `display_name`(이름 덮어쓰기 반영), `portrait`, `color`, `blip`, `target`(대체 반영), `requested_target`, `emote`, `voice`, `voice_path`(`assets/original/voice/<언어>/<줄 ID>.ogg`가 있으면 그 경로), `side`, `waits`(`[{at, seconds}]`, `at`은 BBCode를 뺀 글자 위치), `dialogue_id`가 들어갑니다.

- 표정을 생략한 줄은 같은 대화 안에서 그 화자가 마지막으로 쓴 표정을 이어받고, 처음이면 `default_expression`을 씁니다.
- `meta.*`, `seen.meta.*`, 회차, 메타 동의는 값이 바뀔 때마다 `user://meta.dat`(JSON)에 바로 저장합니다. 세이브를 지우거나 새 게임을 시작해도 남습니다.
- 신호 처리기 안에서 `advance()`·`choose()`·`resume()`·`start()`·`stop()`을 바로 불러도 됩니다.
- **ACTION GAME MAKER G 연동(미검증).** AGM G의 Custom Action Plugin(`AGMPluginAction` / `AGMPluginCondition`)으로 "대화 시작(id 또는 후보 목록)", "대화 시작 가능?", "플래그 비교" 액션·조건을 만드는 것을 1안으로 합니다. AGM 안에서 이 플러그인 경로와 오토로드가 실제로 동작하는지, 내보내기 빌드에 `compiled/*.json`이 포함되는지는 AGM G가 설치된 PC에서 확인해야 합니다.

---

## 12. 컴파일러와 검사 규칙 (`tools/storyc.py`)

```bash
python3 tools/storyc.py            # 검사 후 오류가 없으면 compiled/와 l10n/strings.csv 갱신
python3 tools/storyc.py --fix      # 빠진 #line: ID를 .dlg에 먼저 써 넣고 컴파일
python3 tools/storyc.py --check    # 검사하고 compiled/·strings.csv가 최신인지 확인만 함 (CI용)
python3 tools/storyc.py --strict   # 경고도 실패로 처리
```

- 오류가 하나라도 있으면 아무 파일도 쓰지 않고 종료 코드 1로 끝납니다.
- `assets/original/story/project.json`이 없으면 할 일이 없다고 알리고 종료 코드 0으로 끝납니다.
- `.dlg`는 `story/src/` 아래를 하위 폴더까지 읽습니다.

| 코드 | 수준 | 내용 |
|---|---|---|
| E001 | 오류 | 문법 오류(해석할 수 없는 줄, 들여쓰기 혼용 등) |
| E002 | 오류 | 등록되지 않은 화자 |
| E003 | 오류 | 화자의 `expressions`에 없는 표정, 또는 `aliases`에 없는 `[name=]` |
| E004 | 오류 | `#line:` 누락(`--fix`로 자동 부여 가능), 줄 ID 또는 블록 ID 중복 |
| E005 | 오류 | 없는 라벨·대화로 점프 |
| E006 | 오류 | 알 수 없는 층의 플래그, `sys.*`·`seen.*`에 `set` |
| E007 | 오류 | 허용 목록에 없는 `do` 명령이나 잘못된 인자 |
| E008 | 오류 | 블록 종류에 맞지 않는 문장(바크의 선택지, 문서의 일반 화자 등), 자막 큐의 `at`/`dur` 누락, 빈 블록 |
| E009 | 오류 | `project.json` 또는 `character.json`이 잘못됨(필수 필드 누락, `default_expression`이 목록에 없음, 예약어 ID 등) |
| E010 | 오류 | `--check`에서 `compiled/`, `strings.csv`, `l10n/.gdignore`가 원문과 맞지 않거나 없음 |
| W101 | 경고 | 읽기만 하고 `.dlg` 어디서도 `set`하지 않는 플래그(`sys.*`, `seen.*`, `project.json`의 `external_flags` 제외) |
| W102 | 경고 | 도달할 수 없는 라벨이나 문장 |
| W103 | 경고 | 스타일별 `max_chars` 초과 |
| W104 | 경고 | 원문이 바뀐 번역(stale), 원문과 다른 자리표시자·BBCode. 번역 누락 개수는 경고가 아니라 요약으로만 출력 |
| W105 | 경고 | 예약되었지만 v1에서 쓰지 않는 `#키:` 태그 |
| W106 | 경고 | 레지스트리의 `portraits`에 적힌 이미지 파일이 없음 |

`--fix`로 자동 부여하는 줄 ID는 `<블록 ID>_<3자리 순번>`이며, 원문 파일에 다시 써 넣어 이후로 고정됩니다.

---

## 13. 전체 예시

형식을 보이기 위해 새로 쓴 견본입니다(줄거리는 보고서의 스토리 시드 1 "홍련의 연못"을 바탕으로 함). 등장 화자 `hero`, `hongryeon`, `ibang`, `watchman`은 모두 레지스트리에 있다고 가정합니다.

```
// ch01.dlg — 1장: 부임 첫날 밤

~ ch01_ibang_greeting
@priority 10
@style window

if seen.meta.ch01_ibang_greeting
    hero (uneasy): 이 사람… 어디서 본 것 같은데.  #line:ch01_ib_001 #ctx:기시감. 혼잣말
ibang (bow): 새 사또 나리, 먼 길 오셨습니다.  #line:ch01_ib_002
ibang: 전임 사또들은 모두 부임 첫날 밤을 넘기지 못하셨지요.  #line:ch01_ib_003 #ctx:담담하게. 겁주려는 의도는 없음
- 무슨 일이 있었나?  #line:ch01_ib_004
    set save.asked_about_previous = true
    ibang (fear): 소인은… 연못 쪽엔 가지 마십시오, 그 말씀밖엔.  #line:ch01_ib_005
- [enable_if save.has_seal] 관인을 꺼내 보인다.  => show_seal  #line:ch01_ib_006
- [if sys.loop_count >= 2] 오늘 밤 연못에 소녀가 나타나지?  => knows_ghost  #line:ch01_ib_007 #ctx:루프 지식을 쓰는 선택지
ibang: 방은 동헌 뒤편에 마련해 두었습니다.  #line:ch01_ib_008
=> END

:: show_seal
ibang (surprised): 이, 이건 감영의 관인이 아닙니까!  #line:ch01_ib_009
set save.ibang_trust += 1
=> END

:: knows_ghost
ibang (fear) [emote=sweat]: 나리께서 그걸 어떻게…  #line:ch01_ib_010
set loop.ibang_suspicious = true
do sfx drum_far
=> END


~ ch01_pond_ghost
@requires loop.night
@forbids loop.pond_sealed
@style bubble

narrator: 연못 위로 물이 거꾸로 떨어진다.  #line:ch01_pg_001
hongryeon (sad) [name=unknown]: 또 오셨네요. 이번이 몇 번째 밤인지 기억하세요?  #line:ch01_pg_002 #ctx:정체를 숨긴 화자, 체념한 존댓말
- 처음 왔다.  #line:ch01_pg_003
    hongryeon [name=unknown]: 다들 그렇게 말해요.  #line:ch01_pg_004
- [if sys.loop_count >= 2] {@loop_count}번째다.  #line:ch01_pg_005 #ctx:숫자는 루프 회차로 치환됨
    set save.told_ghost_loop = true
    hongryeon (surprised): 기억하시는군요. 그럼 이번엔 끝까지 들어 주세요.  #line:ch01_pg_006
    => truth
hongryeon: 날이 밝기 전에 연못을 떠나세요.  #line:ch01_pg_007
=> END

:: truth
hongryeon: 제 이름은 홍련이에요.  #line:ch01_pg_008
set meta.knows_name = true
system [to=window_title]: 홍련  #line:ch01_pg_009 #ctx:창 제목이 바뀌는 메타 연출. 동의하지 않았으면 상단 캡션
=> END


~bark ch01_night_watch
@requires loop.night
@cooldown 12

watchman [w=3]: 삼경이오— 불조심하시오—  #line:ch01_bk_001
watchman: 연못 쪽으로는 가지 마시오.  #line:ch01_bk_002
watchman (fear) [w=1]: …방금 물소리 들었소?  #line:ch01_bk_003


~doc ch01_prev_diary
@category journal

title: 전임 사또의 일지  #line:ch01_dc_001
p: 사흘째 밤, 연못에서 우는 소리가 들렸다. 아전들은 바람 소리라 했다.  #line:ch01_dc_002
p: 그 소리는 내 이름을 알고 있었다.  #line:ch01_dc_003


~cue ch01_opening
watchman [at=0.0] [dur=3.0]: 초경이오—  #line:ch01_cu_001
narrator [at=3.5] [dur=4.0]: 그날 밤, 새 사또가 부임했다.  #line:ch01_cu_002
```

---

## 14. 열린 결정 사항

1. **자체 컴파일러·런타임 vs Dialogue Manager 채택.** 이 명세는 애드온에 의존하지 않는 자체 구현을 전제로 합니다. AGM G에서 `addons/`와 autoload가 동작한다고 확인되면, Dialogue Manager(MIT)를 쓰고 이 명세의 규칙(줄 ID 필수, 플래그 층, 선언형 조건)을 린트로 강제하는 쪽도 다시 검토할 수 있습니다.
2. **`save.*` 저장 위치.** AGM의 `SaveGameData`에 함께 넣을지, 별도 파일로 둘지는 AGM 세이브 형식을 확인한 뒤 정합니다.
3. **번역 언어.** `project.json`의 `locales`는 예시입니다. 실제 지원 언어는 출시 계획에 맞춰 정합니다.
4. **씬 파일의 텍스트.** AGM 비주얼 스크립트가 텍스트 표시 액션의 문자열을 `.tscn`/`.tres`에 저장한다면, 그 액션 대신 이 포맷의 대화를 호출하도록 작업 규칙을 정해야 합니다.

## 변경 이력

- v1 초안 (2026-11-17): 최초 작성.
- v1 초안 (2026-11-17): 컴파일러(`tools/storyc.py`) 구현에 맞춰 `skip_pc`, E009·E010, W106 추가.
- v1 초안 (2026-11-17): 런타임(`scripts/story/`) 구현. `seen` 기록 시점을 대화 시작에서 **끝**으로 변경(대화 안에서 자기 ID의 `seen`이 이전 기록을 뜻하도록), 고를 수 있는 선택지가 없으면 묶음을 건너뜀, 메타 대체 값(`fake_os_dialog`·`caption`·`journal_note`) 명시, 세이브에 루프 상태 포함, 컴파일러가 `l10n/.gdignore`를 만듦.

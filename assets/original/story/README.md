# 이야기 스크립트

대사·바크·문서·자막의 원문 폴더입니다. 형식은 [`docs/script-format.md`](../../../docs/script-format.md), 도구는 [`tools/storyc.py`](../../../tools/storyc.py)입니다.

## 현재 상태 (2026-11-17)

- `project.json`과 주인공 레지스트리([`../characters/protagonist/character.json`](../characters/protagonist/character.json))만 있습니다. **대사는 아직 없습니다.** 이야기와 인물(D1)이 정해지지 않았기 때문입니다([`docs/decisions.md`](../../../docs/decisions.md)).
- 주인공 이름 "주인공"과 영어 "Protagonist"는 자리표시입니다.
- `project.json`의 값:
  - `locales`: 한국어 원문 + 영어(D8).
  - `emotes`: 지금 그려 둔 표시 두 가지. `exclaim`은 `ui_icons`의 `mark_alert`, `silence`는 `mark_talk`.
  - `max_chars`: Galmuri11 Condensed 12 px(한글 8 px, 줄 높이 14 px)와 대화창 목업 크기로 계산한 값. 대화창은 글 영역 232 px x 3줄(29자 x 3), 말풍선은 148 px x 2줄(18자 x 2), 자막은 300 px x 2줄(37자 x 2)에서 줄바꿈 여유를 뺐습니다.

## 시작하는 법

1. `src/`에 `.dlg` 파일을 만듭니다(예: `src/prologue.dlg`).
2. `python3 tools/storyc.py --fix`로 줄 ID를 붙이고, `python3 tools/storyc.py`로 컴파일합니다.
3. `.dlg`, `compiled/`, `l10n/strings.csv`를 함께 커밋합니다. CI가 일치 여부를 검사합니다.

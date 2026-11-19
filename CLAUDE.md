# CLAUDE.md

작업 상태와 로컬 준비는 `docs/handoff.md`, 스토리 쪽 상태는 `private/인수인계_비공개.md`(비공개 팩을 푼 경우)에 있습니다. 새 작업 전에 둘 다 읽습니다.

## 규칙

- 줄거리·대사·인물·엔딩·콘티 같은 스토리 자료는 `private/`에만 두고 커밋하지 않는다. `git ls-files private`는 비어 있어야 한다(CI 검사).
- `assets/original/story/`, `assets/original/characters/`는 공개 자리표시 프로젝트다. 비공개 팩을 여기에 풀지 않는다.
- `.gd`에 한국어 문자열을 쓰지 않는다(`tools/check_dialogue_in_code.py`). UI 문구는 `assets/original/ui/strings.csv`, 이야기 글은 `.dlg`.
- README 파일은 영어. `docs/`와 사용자 보고는 한국어.
- 공개 데모(`prototype/demo/`)는 영어 자리표시 문장만. 새 레벨 기능은 데모에도 넣어 CI가 거치게 한다.
- 무가 사설은 창작만, 굿 장면 본문은 무속 자문 뒤 고정(그 전에는 임시본 표시).
- 작업 브랜치 `claude/inspiring-galileo-f9ez1u`. PR #4 병합과 새 PR은 사용자가 요청할 때만.

## 검사

푸시 전: `docs/handoff.md` 4절의 명령. 비공개 팩을 고쳤으면 `python3 tools/storyc.py --root private`와 `python3 tools/build_prototype.py --story private --smoke --require-godot`도. Godot 4.7-stable 경로는 `GODOT_BIN`.

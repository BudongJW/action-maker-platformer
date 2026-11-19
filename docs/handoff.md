# 작업 인수인계: 로컬에서 이어 하기

> 2026-11-19 기준. 클라우드 세션에서 하던 작업을 로컬 PC에서 이어 가기 위한 문서입니다.
> 이 파일은 공개 저장소에 있으므로 **줄거리·대사·엔딩 내용은 쓰지 않습니다.** 스토리 쪽 상태와 다음 일은 비공개 스토리 팩의 `private/인수인계_비공개.md`에 있습니다.

## 1. 지금 상태

| 항목 | 상태 |
|---|---|
| 작업 브랜치 | `claude/inspiring-galileo-f9ez1u` (main에 없는 커밋은 `git log --oneline origin/main..HEAD`로 확인) |
| PR | [BudongJW/action-maker-platformer#4](https://github.com/BudongJW/action-maker-platformer/pull/4) 열림. main과 충돌 없음, CI 모두 통과. **병합은 직접 요청할 때만** |
| 스토리 런타임 | `scripts/story/` 완성, Godot 4.7 헤드리스 테스트 246개 통과 |
| 프로토타입 | 비공개 팩으로 시작부터 진엔딩까지 봇이 끝까지 진행(약 77,000프레임, 오류 0). 공개 데모 콘텐츠로는 CI가 같은 기능을 검사 |
| 비공개 스토리 팩 | v0.22 (`미방송분_스토리팩_v0.22.zip`). 원고·설계·레벨·릴·콘티·자문 자료·조사 노트 전부 |
| 데모 영상 | `미방송분_프로토타입_데모_v2.mp4`(9:43, 프롤로그~엔딩). 비공개 자료라 저장소에 없음 |
| ACTION GAME MAKER G | 아직 연결하지 않음(8절) |

## 2. 로컬 준비

### 2.1 저장소

```bash
git clone https://github.com/BudongJW/action-maker-platformer.git
```

```bash
cd action-maker-platformer
```

```bash
git checkout claude/inspiring-galileo-f9ez1u
```

### 2.2 비공개 스토리 팩

받은 `미방송분_스토리팩_v0.22.zip`을(또는 더 새 판을) 저장소의 `private/` 폴더에 풉니다. `private/`는 통째로 git에서 빠져 있고, 여기에 추적 파일이 생기면 CI(`Private story files are not tracked`)가 실패합니다.

```bash
unzip -o 미방송분_스토리팩_v0.22.zip -d private
```

팩이 없으면 프로토타입은 공개 데모 콘텐츠(`prototype/demo/`)로 돌아갑니다.

### 2.3 도구

| 도구 | 버전 | 쓰는 곳 |
|---|---|---|
| Python | 3.11 이상(3.13에서 확인) | 모든 `tools/*.py`. 표준 라이브러리만 씀. `tools/asset_previews.py`만 Pillow 필요 |
| Godot | **4.7-stable**(AGM G와 같은 엔진) | 런타임 테스트, 프로토타입 실행·봇·릴. [릴리스 페이지](https://github.com/godotengine/godot/releases/tag/4.7-stable)에서 OS에 맞는 파일을 받고, 경로를 환경 변수 `GODOT_BIN`에 넣거나 `--godot`로 넘김 |
| ffmpeg | 아무 최신판 | 데모 영상을 mp4로 바꿀 때만(`--movie x.mp4`) |
| xvfb-run | — | 화면 없는 Linux 서버에서 영상을 녹화할 때만. 데스크톱에서는 필요 없음 |
| Node + Playwright | — | 비공개 콘티를 PDF로 뽑을 때만(`private/콘티/src/pdf.js`) |

Windows PowerShell 예:

```powershell
$env:GODOT_BIN = "C:\tools\Godot_v4.7-stable_win64.exe"
```

macOS 예:

```bash
export GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
```

## 3. 자주 쓰는 명령

모두 저장소 루트에서 실행합니다.

| 하는 일 | 명령 |
|---|---|
| 프로토타입 창 열기(비공개 팩이 있으면 그것으로) | `python3 tools/build_prototype.py --run` |
| 공개 데모로 열기 | `python3 tools/build_prototype.py --story demo --run` |
| 봇 플레이(헤드리스) | `python3 tools/build_prototype.py --story private --smoke --require-godot` |
| 봇 플레이 추적(트리거·대화·스케어를 테이프 시각과 함께) | 위 명령으로 한 번 빌드한 뒤 `"$GODOT_BIN" --headless --fixed-fps 60 --path build/prototype --quit-after 300000 -- --bot --trace` |
| 데모 영상 녹화 | `python3 tools/build_prototype.py --story private --reel private/reels/endings_v1.json --movie out.mp4` |
| 비공개 원고 컴파일 | `python3 tools/storyc.py --root private` (줄 ID가 없으면 `--fix`로 채움) |
| 스케어 설정 검사 | `python3 tools/scare_lint.py private/assets/original/story/scares.json --table` |

## 4. 푸시 전에 돌릴 검사 (CI와 같은 것)

```bash
python3 -m unittest discover -s tools/tests
```

```bash
python3 tools/check_dialogue_in_code.py
```

```bash
python3 tools/storyc.py --check
```

```bash
python3 tools/run_godot_tests.py --require-godot
```

```bash
python3 tools/build_prototype.py --story demo --smoke --require-godot
```

```bash
python3 tools/build_prototype.py --story demo --reel prototype/demo/reel.json --require-godot
```

```bash
python3 tools/pixelart.py --check && python3 tools/pixelart.py --check --root assets/original/mibangsong/art/src
```

```bash
python3 tools/sfxsynth.py --check && python3 tools/sfxsynth.py --check --root assets/original/mibangsong/audio/src
```

```bash
git ls-files private
```

마지막 명령은 아무것도 출력하지 않아야 합니다. 비공개 팩을 고쳤다면 `--story private --smoke`도 함께 돌립니다(CI는 비공개 팩을 볼 수 없습니다).

## 5. 지켜야 할 규칙

- **스토리 자료는 커밋하지 않는다.** 줄거리·대사·인물·엔딩·콘티·스토리가 담긴 릴은 `private/`에만 둡니다. 공유는 파일로만 합니다.
- `assets/original/story/`와 `assets/original/characters/`는 **공개 자리표시 프로젝트**입니다. 비공개 팩을 여기에 풀지 않습니다(git이 병합·체크아웃 때 무시된 파일을 덮어씀).
- 디자인 팩 `assets/original/mibangsong/`(그림·소리)은 공개입니다.
- **`.gd` 파일에 한국어 문자열을 쓰지 않는다**(CI 검사). UI 문구는 `assets/original/ui/strings.csv`, 이야기 글은 `.dlg`에 씁니다.
- README 파일은 영어로 씁니다. `docs/`의 설계 문서와 이 문서는 한국어입니다.
- 공개 데모 콘텐츠(`prototype/demo/`)는 게임 스토리가 아닌 영어 자리표시 문장만 씁니다. 새 레벨 기능을 넣으면 데모에도 넣어 CI가 거치게 합니다.
- 무가 사설은 창작만 합니다(차용은 받는소리 한 구절뿐). 굿 장면 본문은 무속 자문 뒤에 고정하고, 그 전에는 원고에 "임시본"으로 표시합니다.
- 새 PR은 꼭 필요할 때만 엽니다. PR #4 병합은 직접 결정합니다.

## 6. 저장소에서 볼 곳

| 위치 | 내용 |
|---|---|
| `README.md` | 저장소 구조, 라이선스(코드 GPL-3.0, 콘텐츠 All rights reserved), Story runtime 절 |
| `docs/script-format.md` | `.dlg` 원고 형식과 `storyc` 명세 |
| `docs/scare-director.md` | 스케어 디렉터·트랙 믹서·스케어 검사 |
| `docs/resource-needs.md` | 게임에 아직 필요한 것(그림·소리·글·엔진) |
| `prototype/README.md` | 프로토타입 키, 레벨 파일 형식(트리거·허브·보드·동행·장면 그림·끝 문서 등), 릴, 봇 |
| `scripts/story/` | 스토리 런타임(`StoryRunner` 등) |
| `scripts/scare/`, `scripts/tracks/` | 스케어 디렉터, 트랙 믹서 |
| `scripts/proto/` | 프로토타입: `proto_game.gd`(진행·트리거·봇), `proto_ui.gd`, `proto_board.gd`(추리 보드), `proto_reel.gd`(데모 영상), `proto_level.gd`, `proto_art.gd`, `proto_audio.gd`, `proto_fx.gd`, `proto_settings.gd`, `proto_player.gd` |
| `tools/` | `storyc.py`, `build_prototype.py`, `run_godot_tests.py`, `scare_lint.py`, `pixelart.py`, `sfxsynth.py`, `check_dialogue_in_code.py` |
| `.claude/skills/` | 픽셀 아트용 슬래시 명령(main에서 병합) |

## 7. 알아 둘 것

- **Godot을 직접 돌릴 때:** 새로 빌드한 `build/prototype`은 먼저 가져오기를 해야 `class_name`이 등록됩니다. `--smoke`나 `--reel`은 알아서 하고, 직접 돌릴 때는 `"$GODOT_BIN" --headless --path build/prototype --import`를 한 번 실행합니다.
- **봇을 직접 돌릴 때는 `--fixed-fps 60`을 붙입니다.** 없으면 실제 시간으로 돌아 매우 느립니다.
- **메타 플래그(본 엔딩, 2회차):** 평소 플레이는 `user://meta.dat`에 저장합니다. 봇과 릴은 메모리에만 둡니다. 2회차 상태를 지우려면 Godot 사용자 폴더의 `app_userdata/Story prototype/meta.dat`을 지웁니다(Windows `%APPDATA%\Godot\`, macOS `~/Library/Application Support/Godot/`, Linux `~/.local/share/godot/`).
- **스케어 지연은 무작위**라 데모 봇 결과(보드 카드 수 등)가 실행마다 조금 다를 수 있습니다. 판정은 끝까지 갔는지와 오류 0건입니다.
- **영상 녹화**는 고정 프레임이라 실제 시간과 관계없이 같은 결과가 나옵니다. 1~4장 릴은 약 10분 걸립니다.

## 8. 다음 작업 (추천 순서)

1. **플레이테스트(직접).** `python3 tools/build_prototype.py --run`으로 처음부터 엔딩까지. 스케어 로그(`ScareDirector.log_path`)를 남기면 강도 모델 보정에 씁니다.
2. **저장과 불러오기:** 프로토타입에는 아직 저장이 없습니다. 타이틀 화면(이어하기·처음부터, UI 문구는 `strings.csv`에 이미 있음), 루프 사이 자동 저장, 엔딩 선택 직전 저장. 런타임에는 세이브 직렬화(`StoryFlags`)가 이미 있습니다. (크레딧, 메타 연출의 게임 안 화면, 장면 그림 위 글자는 끝났습니다.)
3. **카메라를 끈 뒤 VHS 질감 끄기**(셰이더), **MIX 두 레이어 겹침 셰이더.**
4. **ACTION GAME MAKER G 연결 확인:** 오토로드로 `StoryRunner`·`ScareDirector`·`TrackMixer` 등록, Custom Action Plugin(`AGMPluginAction`/`AGMPluginCondition`)으로 대화 시작·조건 연결, 내보내기 빌드에 `compiled/*.json`과 스케어·레벨 설정이 들어가는지.
5. **소리 듣기와 라우드니스:** 사운드는 아직 아무도 들어 보지 않았습니다. 게임 안 녹화로 LUFS를 잽니다.

스토리 쪽 다음 일(원고 다음 판, 무속 자문, 방언 감수 등)은 `private/인수인계_비공개.md`에 있습니다.

## 9. 결정을 기다리는 것

| 항목 | 지금 |
|---|---|
| 비공개 콘티를 어디에 둘지(비공개 저장소 / 비공개 페이지) | 미정. 지금은 스토리 팩 안(`private/콘티/`) |
| 각 장 설계의 '정할 것' | 추천안으로 진행 중. 목록은 비공개 인수인계 문서 |
| 음성 녹음 범위 | 미정 |
| AGM G 기본 해상도(320x180 4배 / 640x360 2배) | 미정. 프로토타입은 320x180 그림을 4배로 씀 |

## 10. 로컬 Claude Code로 이어 갈 때

저장소 루트의 `CLAUDE.md`가 규칙과 이 문서를 가리킵니다. 첫 요청에서 "docs/handoff.md와 private/인수인계_비공개.md를 읽고 이어서 진행"이라고 하면 됩니다.

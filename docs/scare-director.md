# 스케어 디렉터·트랙 믹서·스케어 검사 도구

이 문서는 `scripts/scare/scare_director.gd`(`ScareDirector`), `scripts/tracks/track_mixer.gd`(`TrackMixer`), `tools/scare_lint.py`의 동작과 근거를 설명합니다. 세 가지 모두 GPL-3.0 코드이며 대사·줄거리를 담지 않습니다. 게임별 설정 파일(예: 비공개 스토리 팩의 `private/assets/original/story/scares.json`)은 원작 콘텐츠로서 비공개로 둡니다.

## 1. 왜 따로 두는가

점프스케어의 효과는 대사보다 **타이밍**에 달려 있습니다. 놀람 반사 연구에서 다음이 확인됩니다.

| 조건 | 수치 | 이 코드에서 하는 일 |
|---|---|---|
| 선행 자극 억제(PPI) | 놀람 자극 30~500 ms 앞의 약한 소리가 반사를 평균 약 32%, 최적 조건(60~120 ms 앞, 배경 +15~20 dB)에서 거의 다 억제 | 시작 0.5 s 전부터 `is_quiet()`가 참. UI 버스를 음소거하고 `quiet_window_started`를 보냄 |
| 그림이 먼저 바뀐 경우 | 화면 시작 300 ms 뒤의 소리는 반사가 약하고 800 ms 이상이면 정서 조절이 일어남 | `scare_onset` 한 번에 그림과 소리를 같은 프레임에 시작하게 함 |
| 상승 시간 | 피크까지 10~12 ms 이하일 때 반응이 큼 | 설정 `rise_ms`. 검사 도구가 10 ms 초과를 오류로 봄 |
| 길이 | 심장 방어 반응은 500 ms 이상 이어지는 소리에서만 | 설정 `body_ms` |
| 예측 가능성 | 해저드 H(t) = f(t)/(1−F(t)). 균일 분포는 1/(b−t)로 끝에 갈수록 확실해지고, 지수 분포는 1/τ로 일정 | 지연을 절단된 지수 분포에서 뽑음(`sample_delay`) |
| 반복 | 같은 자극은 첫 몇 회에 가장 크게 줄고 전신 반응과 심장 방어는 1회 뒤 급감. 다양한 스케어는 습관화가 작음 | `repeat_step_db`, `repeat_floor_lu`, `replace_after`, `min_repeat_interval_s` |
| 이완 | 스케어마다 공포와 즐거움은 역U자. Left 4 Dead AI 디렉터는 정점 3~5 s 유지 뒤 30~45 s 이완 | `sustain_s`, `relax_s`. 이완 중 진짜 스케어는 미룸(짝으로 선언된 경우만 허용) |
| 입력 직후 | 선택지 확인음·발소리도 선행 자극이 됨 | 입력으로 시작된 스케어는 최소 0.6 s 기다림(`min_input_delay`) |

## 2. ScareDirector

### 2.1 설정 파일

```json
{
  "format": 1,
  "settings": {"soft_gain_db": -10, "off_rise_ms": 1500, "min_input_delay": 0.6,
               "bed_bus": "Ambience", "ui_bus": "UI"},
  "scares": {
    "door": {
      "kind": "real", "family": "house",
      "delay": {"mean": 1.2, "min": 0.6, "max": 4.0}, "input": true,
      "level_lu": 16, "rise_ms": 2, "body_ms": 600,
      "lead_s": 1.8, "duck_db": -20, "sustain_s": 4, "relax_s": 36,
      "visual": {"flash": false, "area": 0.2, "shake": 0.4},
      "cue": "door_sting", "after_dialogue": ""
    }
  }
}
```

| 키 | 뜻 | 기본값 |
|---|---|---|
| `kind` | `real`(진짜) / `false`(가짜: 원인이 바로 보임) / `fail`(잡힘처럼 반복) | `real` |
| `family` | 습관화 계산용 분류. 같은 분류끼리 강하게 습관화 | `""` |
| `delay` | 지연 분포 `{mean, min, max}`(초). 생략하면 `{1.5, 0.6, 6.0}` | |
| `immediate` | 지연 없이 바로 시작(잡힘 등) | `false` |
| `input` | 플레이어 입력으로 시작됨(검사 도구용. 실행 시에는 `trigger(id, true)`) | `false` |
| `level_lu` | 스팅어 단기 라우드니스 − 대사 기준 레벨(LU). 상한 +20 | 12 |
| `rise_ms`, `body_ms` | 피크까지 상승 시간, 스팅어 몸통 길이 | 2, 500 |
| `lead_s`, `duck_db` | 시작 몇 초 전부터 배경을 얼마나 낮출지 | 1.5, −20 |
| `sustain_s`, `relax_s` | 유지, 이완 | 4, 36(가짜는 10) |
| `repeat_step_db`, `repeat_floor_lu`, `replace_after`, `min_repeat_interval_s` | 반복 감쇠, 하한, 몇 번째부터 다른 연출(`variant: "replacement"`), 재발동 최소 간격 | 0, 2, 0, 0 |
| `allow_during_relax_of` | 이 ID의 이완 중에도 바로 시작(가짜→진짜 짝) | `""` |
| `visual` | `flash`, `area`(화면 비율), `shake` | |
| `cue` | 시작 프레임에 재생할 자막 큐 ID(`~cue`) | `""` |
| `after_dialogue` | 끝난 뒤 시작할 대화 ID | `""` |
| `design` | 검사 도구 전용(5절). 실행 시 무시 | |

### 2.2 시그널과 게임 쪽 할 일

| 시그널 | 게임이 할 일 |
|---|---|
| `scare_scheduled(id, delay)` | 디버그 표시 |
| `lead_started(id, duck_db)` | `bed_bus`를 쓰지 않으면 직접 배경을 낮춤 |
| `quiet_window_started(id)` | UI 효과음, 글자 출력음, 발소리, UI 애니메이션을 멈춤. 그 밖의 시점에도 `is_quiet()`를 확인 |
| `prepulse(id)` | '약하게' 모드: 짧고 약한 소리 하나(배경 +15~20 dB) |
| `scare_onset(id, info)` | **같은 프레임에** 그림, 스팅어(`info.level_lu`), 흔들림, 자막 큐(`info.cue`)를 시작. `info.variant == "replacement"`면 대체 연출 |
| `scare_finished(id)` | 추격 시작 등 |
| `dialogue_requested(id, dialogue_id)` | `bind_story()`로 연결했다면 디렉터가 직접 시작 |

`bind_story(runner)`로 `StoryRunner`에 연결하면, 대사 원고의 `do emit scare_<id>`가 그 스케어를 시작합니다. 대사 블록은 이 명령으로 끝내고, 스케어 뒤의 대사는 `after_dialogue`로 이어 줍니다(스타일 가이드의 '점프스케어 주변의 대사' 규칙).

### 2.3 설정(접근성)

| `mode` / 속성 | 동작 |
|---|---|
| `Mode.DEFAULT` | 설정값 그대로 |
| `Mode.SOFT` | 스팅어 −10 dB, 시작 90 ms 전 `prepulse`(PPI를 일부러 사용), 번쩍임·흔들림 끔 |
| `Mode.OFF` | 상승 시간을 1.5 s 이상으로 바꿔 반사가 일어나지 않게 함, 번쩍임·흔들림 끔 |
| `photosafe = true` | 번쩍임 끔, 그림 면적 ≤ 10% |

### 2.4 플레이테스트 기록

`log_path`(예: `user://scare_log.csv`)를 지정하면 스케어마다 한 줄을 남깁니다(시각, ID, 종류, 반복 횟수, 모드, 지연, 레벨, 상승 시간, 번쩍임). 테스터의 '움찔했는가'와 심박을 같은 시각으로 맞춰 5절 모델의 계수를 보정합니다.

## 3. TrackMixer

VHS Hi-Fi 데크에서 오디오 더빙은 리니어 트랙만 덮어쓰고 Hi-Fi 트랙은 남깁니다. 그래서 두 트랙은 덧녹음 구간에서만 다릅니다.

| 기능 | API |
|---|---|
| 듣는 트랙 | `set_track(Track.HIFI / LINEAR / MIX)`. `bind_story()`로 연결하면 `loop.track_hifi`·`loop.track_mix` 플래그를 씀(그 트랙일 때만 참). `set_track()`은 트랙이 바뀔 때만 쓰므로, 새 루프에서 `loop.*` 플래그를 지운 뒤에는 `sync_flags()`로 다시 씀 |
| 크로스페이드 | `gains()`(hifi, linear 진폭). MIX는 등전력(√0.5). `hifi_bus`/`linear_bus`를 지정하면 버스 볼륨에 바로 적용 |
| 한쪽 트랙에만 있는 노드 | 그룹 `track_hifi_only`, `track_linear_only`. `apply_layers(root)`가 보이기·투명도·처리 모드를 맞춤. MIX에서는 둘 다 반투명(`mix_alpha`, 기본 0.5)으로 보이고 어느 쪽도 충돌하지 않음. 프로토타입은 MIX를 두 화면으로 그릴 때(`scripts/proto/proto_screen.gd`) 각 트랙 노드를 자기 화면에만 두고 `mix_alpha`를 1로 둠 |
| 테이프 시계 | `tick(dt)`, `time_scale`(기본 10: 두 시간 테이프를 12분에), `seek()`, `rewind()`, `paused` |
| 덧녹음 구간 | `set_segments([[시작, 끝], ...])`(테이프 초). `divergence(t)`는 구간 밖 0, 안 1, 앞뒤 `divergence_ramp` 초 동안 선형으로 변함. `segment_entered/exited` |
| 타임라인 사건 | `add_event(테이프 초, 이름, 플래그)`. 한 바퀴에 한 번 `timeline_event`, 플래그를 참으로. `rewind()`하면 다시 무장, `seek()`로 건너뛴 사건은 발생하지 않음 |

## 4. 대사 원고와의 연결

```
~ door_scene
narrator: The hallway goes quiet.
do emit scare_door
=> END

~cue door_sting
dub [at=0.0] [dur=1.4]: Did you hear that—
```

- 스케어 시점은 대사가 정하지 않습니다. `do emit scare_<id>`로 알리고, 지연과 스팅어는 디렉터가 맡습니다.
- 스팅어에 실리는 목소리는 `~cue`로 두고, 설정의 `cue`에 그 ID를 적습니다.

## 5. 검사 도구 `tools/scare_lint.py`

```bash
python3 tools/scare_lint.py private/assets/original/story/scares.json --table
```

### 5.1 규칙

| 코드 | 뜻 |
|---|---|
| E201 | 스팅어가 대사 +20 LU 초과(통합 −24 LUFS에서 트루 피크 −1 dBTP 여유 없음) |
| E202 | 진짜·잡힘 스케어의 상승 시간 10 ms 초과 |
| E203 / W216 | 그림 면적 25% 초과(광과민 기준) / 20% 초과(Xbox 접근성 지침) |
| E204 | 채도 높은 빨강 번쩍임(R/(R+G+B) ≥ 0.8) |
| E205 | 한 스케어에 번쩍임 3회 초과 |
| E206 | 알 수 없는 `kind` |
| W211 | 지연 최대값이 평균의 3배 미만(창 끝에서 예측이 쌓임) |
| W212 | 입력으로 시작되는데 최소 지연이 0.6 s 미만 |
| W213 | 반복되는 잡힘 스케어에 감쇠가 없음 |
| W214 | 진짜 스케어 두 개가 3분 안에 붙음(짝으로 선언되지 않음) |
| W215 | 예측 강도 J가 등급 목표 범위를 벗어남 |

### 5.2 예측 모델

스케어끼리 비교하고 목표에 맞추기 위한 설계 근사입니다. 계수는 플레이테스트로 보정합니다.

- L = L_ref + min(level_lu, 20), L_ref = 70 dB(A) 가정
- 깜박임 확률 p(L) = 1 / (1 + e^(−(L − 80)/8)) — 80 dB(A)에서 50%, 102 dB(A)에서 94%
- 크기 g(L) = 1.15^((L − 95)/5) · R(상승) · D(길이)
- 증강 Π = 1 + 0.40·위협 + 0.20·어둠(정지 중) + 0.15·예고 + 0.10·조용한 바탕 + 0.10·시청각 동시
- 습관화 H = 0.71 + 0.29·e^(−0.6·n), n = Σ w·e^(−Δt/15분) (같은 분류 w = 1, 다른 분류 0.25)
- **J = p(L) · g(L) · Π · H** (실험실 표준 자극 95 dB, 맥락 없음 ≈ 0.87)
- 등급 목표: large 0.85–1.20, medium 0.45–0.85, small 0.15–0.50

`design` 칸에 `tier`, `minute`, `threat`, `dark`, `anticip`, `quiet`, `av`, `pair_with`를 적으면 계산에 쓰입니다.

## 6. 근거 자료

- 놀람 반사 강도·확률: Lissek 외 2005, Dahmen & Corr 2004, Maslovat 외 2015 — https://pmc.ncbi.nlm.nih.gov/articles/PMC4393208/
- 강도–크기, 위협 증강, 습관화: Bradford 외 2015 — https://pmc.ncbi.nlm.nih.gov/articles/PMC4715694/ · Quednow 2009 — https://pmc.ncbi.nlm.nih.gov/articles/PMC3184478/
- 선행 자극 억제: Swerdlow 외 2007 — https://pmc.ncbi.nlm.nih.gov/articles/PMC1992603/
- 상승 시간·길이와 심장 방어: Ramírez 외 2005 — https://pubmed.ncbi.nlm.nih.gov/16364069/
- 그림 뒤의 소리 시점: Bradley 외 1993 — https://pubmed.ncbi.nlm.nih.gov/8416082/
- 어둠: Kamkwalala 외 2012 — https://pmc.ncbi.nlm.nih.gov/articles/PMC3674026/
- 시간 기대와 해저드: Herbst 외 2018 — https://pmc.ncbi.nlm.nih.gov/articles/PMC5938715/
- 공포와 즐거움의 역U자: Andersen 외 2020 — https://pmc.ncbi.nlm.nih.gov/articles/PMC7734554/
- 예측 못 한 스케어와 습관화: Tashjian 외 2022 — https://pmc.ncbi.nlm.nih.gov/articles/PMC9096462
- 긴장 리듬: Booth 2009, *The AI Systems of Left 4 Dead* (GDC/AIIDE 발표 자료)
- 게임 라우드니스(−24 LUFS, −1 dBTP), 광과민(WCAG 2.3.1, ITU-R BT.1702), Xbox Accessibility Guideline 118

실험실 수치는 교정된 헤드폰과 조용한 환경 기준입니다. 플레이어의 볼륨과 스피커는 제어할 수 없으므로 모든 레벨은 대사 기준 상대값으로 다룹니다.

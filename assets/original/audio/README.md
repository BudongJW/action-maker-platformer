# 오리지널 오디오 (1차, 프로토타입용)

첫 플레이어블([`docs/decisions.md`](../../../docs/decisions.md))에 필요한 효과음과 환경음입니다.

- 라이선스: [`../LICENSE.md`](../LICENSE.md) (All rights reserved).
- **AI 생성물입니다.** AI(Anthropic Claude, Claude Code)가 합성 레시피(`src/*.sfx`)를 작성했고, [`tools/sfxsynth.py`](../../../tools/sfxsynth.py)가 그 레시피로 WAV를 만듭니다. 녹음이나 다른 음원은 쓰지 않았습니다. 기록: [`../AI_CONTENT.md`](../AI_CONTENT.md)
- 제작 중에 사람이 들어 보지 않았습니다. 파형과 스펙트로그램으로 길이, 음량, 잘림, 루프 이음매만 확인했습니다. **AGM G에 넣기 전에 반드시 들어 보고** 레시피를 고칩니다.
- 음악과 UI 효과음은 수집한 CC0 팩의 것을 임시로 씁니다(아래 표).

## 이벤트별 파일 (첫 플레이어블)

| 이벤트 | 파일 | 메모 |
|---|---|---|
| 걷기 발소리 | `sfx/footstep_wood_a.wav`, `_b`, `_c` | 걸음마다 셋 중 무작위. `c`는 마루 삐걱 |
| 점프 / 착지 | `sfx/jump.wav` / `sfx/land.wav` | |
| 미닫이문 열기 / 닫기 | `sfx/door_slide_open.wav` / `sfx/door_slide_close.wav` | |
| 사물함 열기 / 닫기 | `sfx/locker_open.wav` / `sfx/locker_close.wav` | 숨을 때 닫기, 나올 때 열기 |
| 손전등 켜기·끄기 | `sfx/flashlight_click.wav` | |
| 쪽지 줍기 | `sfx/paper_pickup.wav` | |
| 체크포인트(촛불) | `sfx/checkpoint.wav` | |
| 형광등 꺼짐 (위협 등장 이벤트) | `sfx/lamp_flicker.wav` | |
| 그림자 손님 발소리 | `sfx/enemy_step.wav` | 화면 밖에서도 들리게. 거리로 음량 조절 |
| 그림자 손님 숨소리 | `sfx/enemy_breath_loop.wav` | 3초 루프. 가까울 때만 |
| 그림자 손님이 눈치챔 | `sfx/enemy_notice.wav` | `mark_alert` 표시와 함께 |
| 잡힘 (피격) | `sfx/hurt.wav` | |
| 실패 직전 | `sfx/death_sting.wav` | 이어서 암전 |
| 복도 환경음 | `ambience/corridor_loop.wav` | 8초 루프, 형광등 웅웅거림 + 공기 소리. 항상 깔림 |
| 탐색 BGM (임시) | `assets/third_party/pixel-boy-ninja-adventure/Audio/Musics/40 - Crypt.ogg` | CC0. 가장 조용한 후보 |
| 추격 BGM (임시) | `assets/third_party/pixel-boy-ninja-adventure/Audio/Musics/28 - Tension.ogg` | CC0 |
| UI 이동 / 확인 / 취소 (임시) | `assets/third_party/pixel-boy-ninja-adventure/Audio/Sounds/Menu/Move1.wav`, `Accept.wav`, `Cancel.wav` | CC0 |

임시 음악은 판타지 어드벤처 팩의 곡이라 호러 톤과 맞지 않을 수 있습니다. 탐색 구간은 음악 없이 환경음만 두는 안도 플레이 테스트로 비교합니다([`resource-needs.md` 3절](../../../docs/resource-needs.md)).

## 믹싱 기준 (시작값)

모든 효과음은 피크 -1 dBFS로 정규화되어 있고, 환경음 루프만 -12 dBFS입니다. 실제 크기는 AGM G의 오디오 버스에서 맞춥니다.

| 버스 | 시작 음량 | 내용 |
|---|---|---|
| 환경음 | -6 dB | `corridor_loop` |
| 효과음 | 0 dB | 발소리는 -6 dB 정도로 낮춤 |
| 적 신호 | 0 dB | 발소리·숨소리는 거리 감쇠, 눈치챔은 감쇠 없음 |
| 음악 | -10 dB | 추격 때만 올림 |

## 수정하는 법

```bash
python3 tools/sfxsynth.py            # src/의 모든 레시피를 WAV로 렌더링
python3 tools/sfxsynth.py --check    # WAV가 레시피와 같은지 확인
```

레시피 형식은 `tools/sfxsynth.py` 맨 위에 있습니다. 한 줄이 한 층(layer)이고, 사인·삼각·사각·톱니파와 백색·갈색 잡음에 엔벨로프, 필터, 트레몰로, 반복, 메아리를 걸 수 있습니다. 루프는 `@loop`로 이음매를 크로스페이드합니다.

`--check`는 CI에 넣지 않았습니다. 부동소수점 연산 결과가 플랫폼에 따라 마지막 자리에서 달라질 수 있어서입니다. 레시피를 고치면 같은 커밋에 WAV도 같이 넣습니다.

## 다음 단계

- 사람이 들어 보고 레시피 조정 (특히 문·사물함·숨소리)
- 오리지널 음악 (탐색, 추격, 안전 구역), P1 효과음([`resource-needs.md` 3절](../../../docs/resource-needs.md))
- 사람 사운드 디자이너가 맡게 되면 녹음·DAW 원본으로 교체하고 [`AI_CONTENT.md`](../AI_CONTENT.md)의 "Replaced" 표에 기록

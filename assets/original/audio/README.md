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

## 추가 소리 (P1, 이야기와 무관하게 미리 만든 것)

| 용도 | 파일 | 메모 |
|---|---|---|
| 창밖 바람 / 비 | `ambience/wind_loop.wav` / `ambience/rain_loop.wav` | 6초 루프, 피크 -10 dBFS |
| 먼 천둥 | `sfx/thunder_far.wav` | 이계 전환이나 폭풍 연출 |
| 심장 박동 (보통 / 빠름) | `sfx/heartbeat_loop.wav` / `sfx/heartbeat_fast_loop.wav` | 약 75 / 125 bpm. 숨어 있을 때, 쫓길 때 |
| 소복 귀신 등장 / 소멸 | `sfx/ghost_appear.wav` / `sfx/ghost_vanish.wav` | `fx_ghost_swirl`과 함께 |
| 말 없는 속삭임 | `sfx/ghost_whisper_loop.wav` | 4초 루프. 귀신 근처에서 거리 감쇠 |
| 도깨비불 타닥거림 | `sfx/wisp_crackle_loop.wav` | 2초 루프 |
| 점프스케어 | `sfx/jumpscare.wav` | `fx_static`과 함께. 남용 금지 |
| 책장 넘김 / 저널 열기 | `sfx/page_turn.wav` | |
| 열쇠 줍기 | `sfx/key_pickup.wav` | |
| 전등 스위치 | `sfx/switch_click.wav` | |
| 창문 열기 | `sfx/window_open.wav` | |
| TV 지지직 | `sfx/tv_static_loop.wav` | 2초 루프. 교실 TV 타일과 짝 |
| 이계로 넘어감 | `sfx/otherworld_shift.wav` | 팔레트 교체 셰이더의 `amount`를 올리는 동안 |

## 음악 스케치 (오리지널, 루프)

음표 목록을 레시피로 바꾼 짧은 스케치입니다. 22.05 kHz로 렌더링해 용량을 줄였습니다. 방향 확인용이며, 실제 음악은 작곡가가 맡거나 이 스케치를 바탕으로 다듬는 것을 전제로 합니다.

| 파일 | 길이 | 내용 |
|---|---|---|
| `music/title_loop.wav` | 32초 | 타이틀. A 단조 60 bpm, 패드(Am F Dm E) 위의 오르골 선율, 이끎음 G#에서 끝나 반복 |
| `music/safe_loop.wav` | 24초 | 안전 구역(촛불). C 장조, 따뜻한 패드와 느린 아르페지오 |
| `music/otherworld_loop.wav` | 24초 | 이계. A1·Bb1 저음이 맥놀이하고 6초마다 부풀고 12초마다 낮게 울림 |
| `music/chase_loop.wav` | 16초 | 추격. 120 bpm, 반음 긴장의 저음 반복, 박마다 심장 박동 킥, 마디마다 불협 스탭 |

첫 플레이어블의 임시 음악(CC0 `Crypt`, `Tension`)을 이 스케치로 바꿀지는 들어 보고 정합니다.

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
- 탐색 구간 음악, 엔딩 음악, 사람이 다듬은 음악([`resource-needs.md` 3절](../../../docs/resource-needs.md))
- 사람 사운드 디자이너가 맡게 되면 녹음·DAW 원본으로 교체하고 [`AI_CONTENT.md`](../AI_CONTENT.md)의 "Replaced" 표에 기록

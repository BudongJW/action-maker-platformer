# 《미방송분》 1장 사운드 1차안 v0.1

> 디자인 팩([`../README.md`](../README.md))과 같은 성격의 공개 소스입니다. 라이선스는 [`../../LICENSE.md`](../../LICENSE.md)(All rights reserved)이고 저장소의 GPL은 적용되지 않습니다.
> **AI 생성물입니다.** AI(Anthropic Claude, Claude Code)가 합성 레시피(`src/*.sfx`)를 쓰고 [`tools/sfxsynth.py`](../../../../tools/sfxsynth.py)로 렌더링했습니다. 녹음이나 다른 사람의 소리는 쓰지 않았습니다. 기록: [`../../AI_CONTENT.md`](../../AI_CONTENT.md)
> **아직 사람이 들어 보지 않았습니다.** 프로토타입과 플레이테스트용 자리표시이며, 최종 소리는 녹음·사운드 디자이너 작업으로 바꾸는 전제입니다. 목소리(확성기 공지, 자동 응답 음성, 무가, 받는소리)는 넣지 않았습니다.

```bash
python3 tools/sfxsynth.py --root assets/original/mibangsong/audio/src          # 렌더링
python3 tools/sfxsynth.py --check --root assets/original/mibangsong/audio/src  # CI가 하는 검사
```

## 규칙 (스케어 디렉터 문서와 같음)

- 스팅어는 시작 뒤 최고 레벨까지 설정의 `rise_ms` 안(2~10 ms), 길이는 `body_ms`에 맞춤. 파일은 피크 −1 dBFS로 정규화하고, 게임에서 `level_lu`(대사 기준 상대값)로 낮춰 틉니다(+20 LU = 파일 그대로).
- 스팅어 앞 30~500 ms에는 어떤 소리도 두지 않음: 발소리는 디렉터의 조용한 구간에서 멈춤.
- LINEAR와 HI-FI 바탕 소리는 RMS를 맞춰 트랙 전환(크로스페이드) 때 레벨이 튀지 않게 함.

## 파일

| 파일 | 큐 시트 ID | 내용 | 측정 |
|---|---|---|---|
| `ambience/amb_linear_loop.wav` | AMB-02 | LINEAR 밤: 저역이 얇은 바람, 테이프 히스, 먼 물소리, 풀벌레. 12 s 루프 | RMS −25.5 dBFS |
| `ambience/amb_hifi_loop.wav` | AMB-03 | HI-FI 밤: 넓은 바람, 가까운 물소리, 풀벌레. 12 s 루프 | RMS −25.5 dBFS |
| `ambience/amb_workroom_loop.wav` | AMB-05 | 2026 작업실: 형광등 험(120 Hz), 데크 모터. 6 s 루프 | RMS −24 dBFS |
| `ambience/generator_loop.wav` | AMB-04 | 중계 발전기. 4 s 루프 | |
| `ambience/generator_stop.wav` | AMB-04 | 발전기 멎음(딸깍 → 엔진이 잦아듦). 뒤는 침묵(JS2 전 1 s 이상) | 1.6 s |
| `gut/janggu_loop_temp.wav` | GUT-01 | **임시본.** 12/8 굿거리 느낌의 장구 한 장단(점4분음표 = 70). 장단은 무속 자문 뒤 확정, 최종은 실연 녹음 | 3.43 s 루프 |
| `stingers/st_f1_dog.wav` | ST-F1 | 담 너머 개가 두 번 짖음(가짜 스케어) | 상승 4 ms, 350 ms |
| `stingers/st_js1_first_answer.wav` | ST-JS1 | 안내음 조각이 테이프처럼 늘어짐 | 상승 2 ms, 약 600 ms |
| `stingers/st_js2_blackout.wav` | ST-JS2 | 암전 침묵 뒤 귀 옆의 거친 목소리 같은 소리(녹음 음성 자리표시) | 상승 2 ms, 800 ms |
| `stingers/st_js3_caught.wav` | ST-JS3 | 잡힘: 노이즈 버스트와 트래킹 울림 | 상승 2 ms, 500 ms |
| `stingers/st_f2_phone.wav` | ST-F2 | 책상 위 휴대폰 진동(가짜 스케어, 작게) | 상승 10 ms, 400 ms |
| `stingers/st_js4_tape_chew.wav` | ST-JS4 | 데크가 테이프를 씹음: 모터 비명 + 짧은 역재생 | 상승 2 ms, 700 ms |
| `sfx/prepulse.wav` | — | '약하게' 설정의 선행음(스팅어 약 90 ms 앞의 짧은 틱) | 30 ms |
| `sfx/rec_on.wav`, `sfx/rec_off.wav` | SFX-02 | 캠코더 REC 켬(두 번 올라가는 삐) / 끔 | |
| `sfx/step_dirt_a.wav`, `_b` | SFX-01 | 물가 흙·자갈 발소리 두 가지 | |
| `sfx/deck_play.wav`, `sfx/deck_rewind.wav` | SFX-04 | S-VHS 데크 재생(딸깍 + 모터) / 되감기 | |
| `sfx/tone_1k.wav` | SFX-05 | 테이프 머리의 1 kHz 기준음 | 1 s |

측정은 2 ms 창 RMS 포락선 기준(상승 = 최고값의 10%→90%, 길이 = 최고값 −20 dB 위 구간)입니다. 통합 라우드니스(LUFS)는 게임 안에서 녹화로 따로 재야 합니다.

## 아직 없는 것 (큐 시트 기준)

- 목소리: SFX-03 확성기 공지, VO 전부, GUT-03~06 받는소리·축원·공수·당부(자문과 녹음 뒤)
- GUT-02 젓대, GUT-07 징, SFX-06 데크 뒷면 스위치, SFX-07 메신저 알림, SFX-08~11
- 2장 이후 스팅어(ST-JS5~JS9, F3, F4)

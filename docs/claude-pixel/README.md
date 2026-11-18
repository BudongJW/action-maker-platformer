# Claude 픽셀 디자인 레퍼런스·프롬프트 모음

Claude로 픽셀 아트를 더 잘 만들기 위해 모은 자료입니다. 다른 사람들이 Claude(와 다른 LLM)로 픽셀 아트를 만든 방식, 그때 쓴 프롬프트, 이 저장소에서 직접 겪은 실패와 고친 방법을 함께 정리합니다. 2026-11-18에 처음 모았고, 앞으로도 같은 형식으로 덧붙입니다.

| 문서 | 내용 |
|---|---|
| [`references.md`](references.md) | 방식별 정리(텍스트 격자, 도형·코드, 에디터 도구, 이미지 모델), 출처 목록, 공통 교훈, 이 저장소에서 겪은 실패와 규칙 |
| [`prompts.md`](prompts.md) | 수집한 프롬프트(출처 포함), 이 저장소의 `.pix`·`.scene` 파이프라인에 맞춘 프롬프트 템플릿, 셀프 리뷰 프롬프트 |
| [`../pixel-technique.md`](../pixel-technique.md) | 손·얼굴·머리카락·외곽선 같은 픽셀 기법 자체의 레퍼런스(사람 아티스트의 글) |

## 슬래시 명령

[`prompts.md`](prompts.md)의 템플릿은 Claude Code 슬래시 명령(프로젝트 스킬, [`.claude/skills/`](../../.claude/skills/))으로도 들어 있습니다. 이 저장소에서 Claude Code를 열고 `/pixel-`까지 치면 목록이 나옵니다. 명령 뒤에 자유롭게 설명을 붙이면 되고, 빠진 항목은 Claude가 저장소 기본값으로 채운 뒤 정한 값을 먼저 표로 보여 줍니다.

| 명령 | 템플릿 | 하는 일 | 예 |
|---|---|---|---|
| `/pixel-rules` | T0 | 공통 규칙. 픽셀 아트 작업을 하면 Claude가 스스로 불러 읽음 | `/pixel-rules` |
| `/pixel-sprite` | T1 | 스프라이트 시트 | `/pixel-sprite 2026년 기태(51), 서기·걷기 4·전화 받기` |
| `/pixel-tiles` | T2 | 타일셋 + 시험 장면으로 이음매 확인 | `/pixel-tiles 학교 옥상: 바닥, 난간, 물탱크 2x2` |
| `/pixel-scene` | T3 | `.scene` 장면 | `/pixel-scene 미방송분 3-04 다른 구도, 등불 셋` |
| `/pixel-closeup` | T4 | 얼굴·손 클로즈업, 표정 항목 지정 | `/pixel-closeup 4-10 미정 CU, 3/4로 순례 쪽, 울며 외침` |
| `/pixel-bg` | T5 | 배경·원경·부감 | `/pixel-bg 새벽 저수지, 안개, 부감` |
| `/pixel-palette` | T6 | 같은 키의 새 팔레트로 트랙·시간대 변형 | `/pixel-palette 학교 복도의 새벽 버전` |
| `/pixel-imageprompt` | T7 | 외부 이미지 도구용 프롬프트와 후처리 절차(저장소에 넣지 않음) | `/pixel-imageprompt 해골 병사, 옆모습, 64x64` |
| `/pixel-review` | R1 | 렌더 결과를 체크리스트로 검수하고 고침 | `/pixel-review assets/original/mibangsong/art/src/cut_e402.scene` |
| `/pixel-feedback` | R2 | 피드백 → 원인 → 레퍼런스 → 그리는 방법 고치기 → 규칙 기록 | `/pixel-feedback "손이 막대를 안 잡고 있는 것 같다" 2-10` |
| `/pixel-options` | R3 | 여러 안을 나란히 비교하고 추천 | `/pixel-options 덧녹음된 것의 마지막 모습 4` |

`/pixel-rules`만 Claude가 필요할 때 스스로 불러올 수 있고, 나머지는 직접 입력할 때만 실행됩니다. 명령을 고치려면 해당 폴더의 `SKILL.md`를 고치고, 이 표와 [`prompts.md`](prompts.md)의 템플릿도 함께 맞춥니다.

## 수집 규칙

1. **링크와 요약만 둡니다.** 다른 사람의 그림은 저장소에 복사하지 않습니다. 프롬프트는 짧은 부분만 인용하고 출처를 붙입니다.
2. **확인한 것과 주장만 있는 것을 나눕니다.** 출처가 스스로 주장한 수치(예: "12x12를 넘으면 정확도가 떨어진다")는 "출처 주장"이라고 적습니다.
3. **모델 버전 대신 날짜를 적습니다.** 결과는 모델이 바뀌면 달라집니다. 언제 나온 자료인지 적어 두면 오래된 결론을 가려낼 수 있습니다.
4. **이 저장소에 쓸 수 있는지 적습니다.** 외부 이미지 생성 도구의 결과물은 라이선스와 AI 고지([`assets/original/AI_CONTENT.md`](../../assets/original/AI_CONTENT.md))를 확인하기 전에는 `assets/original/`에 넣지 않습니다.

## 덧붙이는 형식

레퍼런스는 [`references.md`](references.md) 2절의 표에 한 줄을 더합니다.

```markdown
| [제목](URL) (YYYY-MM) | 방식(A~D) | 무엇을 했나 | 배울 점 / 주의할 점 |
```

프롬프트는 [`prompts.md`](prompts.md) 1절에 아래 형식으로 더합니다.

```markdown
### 출처 이름 (YYYY-MM)
- 출처: [제목](URL)
- 프롬프트: "짧은 인용"
- 결과·배울 점: 한두 줄
```

이 저장소에서 직접 써서 효과가 있었던 프롬프트는 [`prompts.md`](prompts.md) 2절의 템플릿을 고치거나 새 템플릿으로 더합니다. 실패한 경우는 [`references.md`](references.md) 4절의 표에 "증상 → 원인 → 프롬프트에 넣을 규칙"으로 남깁니다.

# Claude 픽셀 아트 프롬프트 모음

2026-11-18 수집. 1절은 다른 사람들이 쓴 프롬프트를 출처와 함께 짧게 인용한 것입니다. 2절은 이 저장소의 `.pix`·`.scene` 파이프라인에 맞춘 템플릿이고, 3절은 렌더 뒤에 Claude가 스스로 검수하게 하는 프롬프트입니다. 2·3절은 [`references.md`](references.md)의 교훈과 4절 실패 사례를 반영했습니다. `[ ]` 안을 채워서 그대로 붙여 넣으면 됩니다.

## 1. 수집한 프롬프트

### Lj Miranda, "Draw me a swordsman" (2025-07)
- 출처: [Draw me a swordsman: Can tool-calling LLMs draw pixel art?](https://ljvmiranda921.github.io/notebook/2025/07/20/draw-me-a-swordsman/)
- 프롬프트(정지): "Draw me a pixel art of a swordsman."
- 프롬프트(애니메이션): "Draw a 4-frame spritesheet showing a swordsman performing a sword slash attack sequence", 그리고 "each frame capturing a different stage of the slashing motion from windup to follow-through"
- 시스템 프롬프트 요지: 창의적이고 예술적인 도구 호출 에이전트로 행동하고, 오류가 나면 다른 도구로 복구할 것. 핵심 제약은 "Your output must always be saved as an image file in the PNG format."
- 배울 점:
  - 짧은 프롬프트라도 애니메이션은 "준비 → 베기 → 마무리"처럼 단계를 적어야 프레임이 나뉩니다.
  - 결과물을 반드시 파일로 남기게 해야 확인할 수 있습니다.

### Pixelsrc (형식 규칙형 시스템 프롬프트)
- 출처: [System Prompts](https://scbrown.github.io/pixelsrc/book/ai-generation/system-prompts.html), [Best Practices](https://scbrown.github.io/pixelsrc/book/ai-generation/best-practices.html)
- 시스템 프롬프트 규칙(발췌):
  - "Sprites use structured regions that define shapes, not pixel grids"
  - "Limit palette to 4-16 colors for retro aesthetic"
  - 애니메이션: "All frames must use the SAME shared palette"
- 사용자 프롬프트 예: "Create a 16x16 pixel art sword with a silver blade and golden hilt"
- 좋은 예와 나쁜 예:
  - 좋음: "Create a 16x16 pixel art treasure chest in pixelsrc format. Use a warm brown wood color, gold trim, and a dark shadow..."
  - 나쁨: "Make me a chest"
- 색을 지정하는 문구: "use exactly 6 colors", "Use a complementary color scheme with blue and orange."
- 배울 점:
  - 크기, 형식, 재질별 색, 그림자 유무를 한 문장에 넣습니다.
  - 고칠 때는 "칼날을 2픽셀 길게"처럼 수치로 말합니다.

### Pixel Art Bench (격자 JSON형)
- 출처: [Pixel Art Bench](https://www.emergentmind.com/pixel-art-bench)
- 프롬프트 구조(요약):
  - 24x24 격자, 2~10색 팔레트(# 없는 hex)를 씁니다.
  - "palette"와 "grid"(24자리 숫자 문자열 24개) 두 키만 담은 JSON으로 냅니다.
  - 모든 칸을 채우고, 글자를 그리지 않고, 팔레트는 적게 씁니다.
  - "희망" 같은 추상 주제는 구체적인 장면을 먼저 떠올리게 합니다.
  - 출력은 "Output ONLY the JSON object"입니다.
- 배울 점: 출력 형식을 하나로 못 박고, 추상 주제는 장면으로 바꾸게 합니다.

### pixel-plugin (Aseprite, Claude Code)
- 출처: [pixel-plugin README](https://cdn.jsdelivr.net/gh/willibrandon/pixel-plugin@main/README.md)
- 프롬프트 예: "Make a 16x16 tile with NES palette", "Add 4 frames for a walk cycle", "Reduce to 16 colors", "Export as PNG at 4x scale"
- 배울 점: 한 번에 다 시키지 않습니다. 크기·팔레트 → 그림 → 프레임 → 내보내기를 대화로 나눠 시킵니다.

### aseprite-mcp 권장 작업 순서
- 출처: [diivi/aseprite-mcp README](https://cdn.jsdelivr.net/gh/diivi/aseprite-mcp@main/README.md)
- 요지(번역):
  1. 팔레트를 먼저 정합니다.
  2. 레이어로 나눠 그립니다.
  3. 실루엣에서 디테일로 갑니다.
  4. 매 단계 미리보기로 확인합니다.
  5. 의도를 갖고 음영을 넣습니다.
  6. 애니메이션 뒤에는 프레임 비교와 경계 상자로 검증합니다.
- 배울 점: 그대로 시스템 프롬프트로 써도 되는 순서입니다. 이 저장소 템플릿의 기본 순서도 같습니다.

### claude-pxl (스킬형 작업 순서)
- 출처: [claude-pxl wiki](https://github.com/crsolver/claude-pxl/wiki)
- 요지: 스킬 문서가 Claude에게 "쓰기 → 빌드 → 미리보기 확인 → 고치기"를 반복하게 합니다. 좌표 눈금이 붙은 ASCII 출력으로 위치를 다시 확인합니다.
- 배울 점: 작업 순서를 프롬프트가 아니라 스킬(반복 지침)로 두면 매번 다시 말할 필요가 없습니다.

### SVG 벤치마크 (짧은 장면형)
- 출처: [Simon Willison: LLM SVG Generation Benchmark](https://simonwillison.net/2025/Nov/25/llm-svg-generation-benchmark/) (2025-11)
- 프롬프트 형식: "Generate an SVG of [A] [doing] [B]"(예: 파이프오르간을 연주하는 문어)
- 배울 점: 같은 형식으로 여러 번 돌려서 가장 나은 것을 고르는 방식이 비교·선택에 편합니다.

### 이미지 모델 쪽 (참고)
- [SpriteCook](https://www.spritecook.ai/blog/creating-pixel-art-assets):
  - "skeleton warrior, side view"처럼 짧게 쓰되 시점은 꼭 적습니다.
  - 게임 해상도로 생성합니다.
  - 일관성은 프롬프트보다 참조 이미지로 맞춥니다.
- [Rangy](https://rangy.ai/blog/ai-pixel-art):
  - 정확한 크기, 안티에일리어싱 없음, 엄격한 팔레트를 프롬프트에 적어도 이미지 모델은 지키지 않았습니다.
  - 대신 "굵고 단순한 실루엣, 내부 디테일 적게"를 요청하는 편이 후처리가 잘 됩니다.

## 2. 이 저장소용 템플릿

### T0. 공통 머리말 (모든 요청 앞에)

```text
이 저장소의 픽셀 아트 규칙을 따라 줘.
- 원본은 텍스트다: .pix(스프라이트·타일), .scene(장면). 렌더러는 tools/pixelart.py이고 형식은 그 파일 첫머리 설명을 따른다.
- 팔레트는 assets/original/art/palette/night-school.pal의 20개 키만 쓴다. 트랙·시간대 색은 같은 키의 다른 .pal로 @swap 한다.
- 기본값: 횡스크롤 옆모습, 오른쪽을 봄. 캐릭터 셀 32x40, 타일 16x16, 장면·인서트 320x180.
- 광원은 하나(기본 왼쪽 위 앞). 외곽선은 셀아웃(빛 쪽은 그 물체의 가장 어두운 색, 그림자 쪽만 K). 외톨이 픽셀 없음. 디더는 하늘·안개·비네트에만.
- 손·얼굴·머리카락은 docs/pixel-technique.md의 규칙을 따른다.
- 24x24보다 큰 그림은 행을 직접 쓰지 말고 도형·구성 함수로 만든 뒤 렌더러로 찍는다. 작은 아이콘·타일만 행을 직접 쓴다.
- 작품 규칙: [예: 그리면 안 되는 인물, 금지 색, 스케어 면적 상한]
- 끝나면 렌더하고, 확대 미리보기를 직접 보고 고친 뒤 python3 tools/pixelart.py --check 로 확인한다. 전후 비교 이미지를 보여 준다.
```

### T1. 스프라이트 시트

```text
[인물·물건] 스프라이트 시트를 만들어 줘.
- 파일: [src 경로]/[이름].pix → 출력 [characters/…png]
- 셀: 32x40. 프레임: idle_0, idle_1, walk_0~3, [동작 이름들]
- 생김새: [나이, 체형, 머리 모양, 옷(팔레트 키), 들고 있는 것]
- 1배 실루엣에서 읽혀야 하는 것: [예: 어깨에 멘 카메라, 손에 든 등불]
- 동작: [동작마다 무엇이 바뀌는지. 예: 베기 = 준비(칼 뒤로) → 베기(팔 뻗음) → 마무리(몸이 돈 채)]
- 애니메이션은 같은 팔레트를 쓰고, 바뀌는 부위만 바꾼다. 키·어깨·머리 높이는 프레임 사이에서 정해진 만큼만 움직인다.
- 확인: 프레임을 나란히 놓은 4배 미리보기에서 비율이 흐트러진 프레임이 없는지 본다.
```

### T2. 타일셋

```text
[장소] 타일셋(16x16)을 만들어 줘.
- 타일: [윗면, 속, 벽, 장식(2x2·1x3 같은 큰 것은 _x_y로 나눔)]
- 윗면은 0행, 가장자리는 옆 타일과 이어지게
- 낮·밤, 트랙별 색은 그림을 바꾸지 말고 팔레트로
- 확인: 이 타일로 320x180 시험 장면을 깔아 반복 무늬가 튀지 않는지, 이음매가 보이지 않는지 본다.
```

### T3. 장면 (.scene)

```text
컷 [번호] 장면을 .scene으로 만들어 줘.
- 콘티: [한 줄 설명]. 트랙: [2026 / linear / hifi / 1979] → @swap
- 레이어: @layer는 매번 0행부터 깔린다. 하늘·벽·바닥은 한 레이어 안에서 위에서 아래로 쓴다(바닥은 10~11행).
- 인물: 발이 바닥 줄(y=160)에 닿게 놓는다(32x40 셀이면 y=121). 대상을 보도록 flip.
- 소품: 바닥·책상·벽에 닿게 놓는다. 손에 든 것은 손 위치에 맞춘다.
- 조명: 어두운 장면만 @darkness + @light. 밝은 실내와 낮 장면에는 둥근 조명을 넣지 않는다.
- UI(뷰파인더, 배지, 자막 자리)는 over로 맨 위에.
- 확인: 2배 미리보기 전체와, 손·소품이 닿는 곳을 잘라 확대한 것을 함께 본다.
```

### T4. 클로즈업·인서트 (큰 그림)

```text
컷 [번호] 클로즈업을 만들어 줘. 320x180, [트랙] 팔레트.
- 구도: [CU / MCU / ECU], [정면 / 옆얼굴 / 3/4], 고개 돌림 [-1..1, +는 화면 오른쪽]
- 표정(항목마다 지정):
  눈썹 안쪽 [올림·내림], 눈썹 바깥쪽 [올림·내림], 미간 [찌푸림 여부]
  위 눈꺼풀 [내림 정도], 아래 눈꺼풀 [올림 여부], 시선 [방향]
  입 [닫음 / 살짝 벌림 / 말함 / 노래 / 외침 / 허밍 / 꾹 다묾], 입꼬리 [올림·내림]
  광대 [올림 여부], 주름 [미간 / 이마 / 눈가], 눈물 [있음·없음]
- 빛: [예: 모니터 빛이 정면 아래에서]
- 얼굴은 행으로 찍지 말고, 두개골과 턱 실루엣에 면(눈두덩·코·광대·턱끝)으로 음영을 낸 뒤 이목구비를 그린다.
- 옆얼굴의 헤어라인은 이마 → 관자놀이 → 귀 앞 → 귀 뒤 → 뒷목. 벌린 입은 얼굴 안쪽 쐐기로.
- 손이 나오면 손바닥·마디·엄지 구조로. 쥔 손은 주먹 중심을 쥔 물건의 좌표에 맞춘다.
- 확인: 얼굴만 3배로 잘라 보고, 보이는 표정을 한 줄로 말한 뒤 지시와 다르면 고친다.
```

### T5. 배경·멀리 보이는 것

```text
[장소] 배경을 320x180으로 만들어 줘.
- 원근: 먼 것은 작고 흐리게(배경색으로 섞음), 가까운 것은 크고 선명하게.
- 반복 무늬를 피한다: 돌담은 돌을 하나씩, 무너진 틈과 흩어진 돌, 안쪽 내용물(기단·주춧돌·기와)을 넣는다.
- 식물은 실제 구조대로: 대나무 잎은 마디마다 2~3장, 바깥으로 뻗고 아래로 처지게. 한 점에서 방사형으로 뻗지 않는다.
- 하늘·물의 그라데이션만 디더를 쓰고 나머지는 단색 덩어리로.
- 확인: 썸네일 크기(1배)에서 무엇인지 읽히는지 먼저 본다.
```

### T6. 팔레트·트랙 변형

```text
[그림]의 [트랙·시간대] 버전을 만들어 줘.
- 그림은 고치지 말고 같은 키의 새 .pal을 만들어 @swap 한다.
- 이 팔레트의 금지 사항: [예: LINEAR에는 채도 높은 빨강 없음, C 키는 덧녹음된 것의 자홍]
- 트랙이 바뀌어도 색이 변하면 안 되는 UI(예: 목소리 파형)는 ui.pal로 따로 그린다.
- 확인: 원래 판과 나란히 놓고 명암 단계 순서가 뒤집힌 곳이 없는지 본다.
```

### T7. 이미지 모델을 쓸 때 (방식 D, 참고용)

```text
[대상], [side view / front view / top-down], [32x32 또는 64x64] sprite,
bold simple silhouette, few internal details, flat colors, [N]-color palette,
no anti-aliasing, no dithering, transparent background
```

결과는 최근접 축소 → 프로젝트 팔레트로 양자화 → 디더 없이 → 손으로 정리하는 순서로 다듬습니다. `assets/original/`에 넣기 전에 도구의 라이선스와 AI 고지([`AI_CONTENT.md`](../../assets/original/AI_CONTENT.md))를 확인합니다.

## 3. 셀프 리뷰·피드백 프롬프트

### R1. 렌더 뒤 스스로 검수

```text
방금 렌더한 [파일]을 직접 보고 아래를 하나씩 확인해 줘. 문제를 "위치 / 증상 / 고칠 방법" 표로 적고, 고친 뒤 전후 비교를 보여 줘.
1. 1배 크기에서 실루엣만으로 무엇인지 읽히나
2. 광원이 한 방향인가, 명암 경계가 뚜렷한가
3. 외톨이 픽셀, 지글거리는 디더, 외곽을 따라 같은 폭의 띠(필로우 셰이딩)
4. 손: 손가락 넷과 엄지가 보이나, 쥔 손이 물건에 실제로 닿았나
5. 얼굴: 표정이 지시와 맞나, 이목구비가 면 위에 놓였나
6. 머리카락: 덩어리인가, 빗살·공·가시·새 모양이 아닌가
7. 물건·인물이 떠 있지 않나(바닥·책상·벽에 닿음)
8. 장면: 바닥 줄 위치, 조명 띠, 낮·밤 타일 혼용, 작품 금지 사항
```

### R2. "어색하다"는 피드백을 받았을 때

```text
"[피드백 그대로]"라는 피드백을 받았어.
1. 해당 그림들에서 원인을 찾아 "증상 / 원인 / 있는 곳" 표로 정리해 줘.
2. 사람 아티스트의 레퍼런스(링크와 요약만)에서 고칠 원리를 찾아 줘.
3. 한 장만 고치지 말고, 그리는 방법(구성 도구나 템플릿)을 고쳐 같은 문제가 있는 그림을 모두 다시 그려 줘.
4. 전후 비교를 보여 주고, docs/claude-pixel/references.md 4절에 규칙 한 줄을 남겨 줘.
```

### R3. 여러 안 중에서 고르기

```text
[대상]을 [N]가지 안으로 그려서 나란히 보여 줘. 안마다 다른 점(실루엣, 자세, 색 비중)을 한 줄씩 적고, 1배 크기에서 가장 잘 읽히는 안을 추천해 줘.
```

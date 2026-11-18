# Claude 픽셀 아트 레퍼런스

2026-11-18 수집. 다른 사람들이 Claude와 다른 LLM으로 픽셀 아트를 만든 방식을 정리했습니다. 여기에 이 저장소에서 직접 겪은 실패를 더해 규칙으로 묶었습니다. 그림은 가져오지 않고 링크와 요약만 둡니다. 외부 도구와 저장소는 확인한 날짜 기준이며, 이후 바뀌었을 수 있습니다.

## 1. 네 가지 방식

LLM이 픽셀 아트를 만드는 방법은 크게 넷입니다. 이 저장소는 B를 주로 쓰고(저작용 스크립트가 도형·입체 음영으로 `.pix` 텍스트를 만듦), 작은 아이콘과 타일은 A로 씁니다(`.pix`의 행을 직접 씀).

| 방식 | 어떻게 | 잘 되는 것 | 잘 안 되는 것 | 예 |
|---|---|---|---|---|
| **A. 텍스트 격자를 직접 쓰기** | 팔레트 키 한 글자 = 픽셀 하나. 행을 그대로 씀 | 16x16~24x24 아이콘, 타일, 작은 스프라이트. 결과가 정확히 격자에 맞음 | 크면 모양이 어긋나고 조각남. 대칭·곡선·비율이 흔들림 | pixlrt, claude-pxl, PIXL 작은 타일, Pixel Art Bench, 이 저장소의 `.pix` 직접 작성 |
| **B. 도형·코드로 쓰고 렌더러가 찍기** | 사각형·원·다각형·선, 또는 그리는 함수를 쓰면 프로그램이 격자로 바꿈 | 큰 그림, 장면, 반복과 변형, 일관된 팔레트 | 도형을 이어 붙인 느낌이 나기 쉬움. 손·얼굴·머리카락은 따로 구조를 짜야 함 | Pixelsrc, AM-Bench, SVG 생성, 이 저장소의 저작용 스크립트 |
| **C. 에디터 도구 호출** | MCP로 Aseprite 같은 에디터의 그리기 도구를 호출 | 사람이 이어서 손보기 좋음. 애니메이션·내보내기·팔레트 변환 | 결과가 도구 설계에 좌우됨. 미리보기 도구가 없으면 눈 감고 그리는 셈 | Aseprite MCP 여러 종, pixel-plugin |
| **D. 이미지 모델 + 후처리** | Claude는 프롬프트를 쓰고, 이미지 모델이 그린 뒤 축소·양자화 | 빠름, 그림 같은 디테일 | "픽셀 아트처럼 보이는 그림"이 나옴. 격자가 어긋나고 색이 수만 개. 후처리와 손질 필수. 라이선스·AI 고지 확인 필요 | PixelLab MCP, SpriteCook, pixelwright |

## 2. 출처

### A·B. 텍스트 포맷과 렌더러

| 출처 | 방식 | 무엇을 했나 | 배울 점 / 주의할 점 |
|---|---|---|---|
| [Pixelsrc: System Prompts](https://scbrown.github.io/pixelsrc/book/ai-generation/system-prompts.html), [Best Practices](https://scbrown.github.io/pixelsrc/book/ai-generation/best-practices.html) | B | JSON5로 팔레트·스프라이트·애니메이션·변형·합성을 씀. 스프라이트는 픽셀 격자가 아니라 영역(rect, circle, polygon 등과 합·차·교집합)으로 정의 | 크기·색 수·스타일·형식을 명시. 색 이름은 `{c1}`이 아니라 `{skin}`, `{shadow}`처럼 의미로. 색 수는 스타일에 맞춤(GB 4, NES 8, SNES 16). 실루엣은 도형 3개로 먼저 잡고, 안 되면 디테일이 아니라 비율 문제. 애니메이션은 같은 팔레트를 쓰고 바뀌는 부위만 지정. 32x32보다 크면 타일로 나눠 합침. `render --strict`로 검증. Claude가 복잡한 형식 규칙을 잘 따른다고 적음 |
| [pixlrt](https://kacheo.github.io/pixlrt/) | A | 한 글자 = 한 픽셀인 텍스트 격자 스프라이트 → PNG·GIF·스프라이트 시트 | LLM이 직접 쓰는 격자는 24x24 이하로(출처 주장: 그보다 크면 공간 정확도가 떨어짐). `.`은 투명, 모든 행은 같은 폭 |
| [PIXL](https://pixl-site.vercel.app/docs/Introduction) | A+B | TOML 기반 `.pax`: 팔레트(기호→색)와 타일 격자를 한 파일에, 타일을 조합해 큰 그림. 검증·렌더·비평(critique) CLI와 MCP | 출처 주장: LLM은 12x12를 넘는 원시 픽셀 추론에 약하고 기호적 조합에 강함. 그래서 작은 타일은 격자로, 큰 그림은 조합으로. 원래 GitHub 주소는 2026-11-18 현재 404 |
| [claude-pxl](https://github.com/crsolver/claude-pxl/wiki) | A | `.px.js`에 팔레트(한 글자 키)와 텍스트 격자를 쓰고 빌드. Claude Code 스킬로 배포 | 작업 순서를 스킬에 명시: 쓰기 → 빌드 → 미리보기 확인 → 고치기. `ascii` 명령이 좌표 눈금과 함께 다시 보여 줌. 좌우 대칭(`mx`), 자동 외곽선, 색 바꾸기(`swap`)를 도구가 맡음 |
| [Pixel Art Bench](https://www.emergentmind.com/pixel-art-bench) | A | 24x24, 2~10색 팔레트, 각 행 24자리 색 번호의 JSON만 출력하게 해서 모델을 비교 | 추상 주제("희망")는 상징 하나가 아니라 구체적인 장면을 먼저 떠올리게 함. 글자를 쓰지 않게 함. 출력은 JSON만 |
| [Autoregressive Mosaics / AM-Bench](https://ashwin-ned.github.io/autoregressive-mosaics/) | A→B | 처음엔 ASCII 격자로 칠하게 했다가, 도형 6종으로 그리는 짧은 Python 함수로 바꿈(24x24, 이름 붙은 30색) | ASCII 버전은 "모양이 흘러내리고 조각남", 코드 버전이 훨씬 나음. 완전히 정해진 도형을 코드로 옮기는 건 쉽고, 열린 주제로 배치를 짜는 건 모델마다 차이가 큼. SVG로 쓰면 배치 점수가 더 오름 |
| [Simon Willison: LLM SVG Generation Benchmark](https://simonwillison.net/2025/Nov/25/llm-svg-generation-benchmark/) (2025-11) | B | "Generate an SVG of [A] [doing] [B]" 형식 프롬프트 30개로 여러 모델의 SVG 그림을 비교 | 같은 형식으로 여러 모델·여러 번 돌려 고르는 방식. 기계류는 잘 그리고 동물은 덩어리처럼 되는 경향 |
| [pixel-art skill (wanshuiyin)](https://skills.sh/wanshuiyin/auto-claude-code-research-in-sleep/pixel-art) | A(SVG) | 픽셀 하나를 SVG `<rect>` 하나(7px)로, 캐릭터는 가로 8~10px. 그룹으로 위치·재사용 | 아주 작은 캐릭터는 이 정도 크기가 다루기 쉬움 |
| [agi-stylist (Hacker News)](https://news.ycombinator.com/item?id=50172003) | B | EGA 시대 어드벤처 게임처럼 그리기 명령(선·채우기)으로 장면을 만들고 Sierra PIC 형식으로 컴파일 | 비결정적인 생성을 결정적인 명령열로 바꾸면 다루기 쉬움. 애니메이션 스프라이트는 아직 "조금 달래야" 한다는 작성자 답변 |

### C. 에디터 도구 (MCP)

| 출처 | 방식 | 무엇을 했나 | 배울 점 / 주의할 점 |
|---|---|---|---|
| [Lj Miranda: Draw me a swordsman](https://ljvmiranda921.github.io/notebook/2025/07/20/draw-me-a-swordsman/) (2025-07) | C | Aseprite MCP에 저수준 도구 10개(캔버스, 레이어, 프레임, 점·선·사각형·채우기·원, 내보내기, 미리보기)를 주고 "검사" 정지 그림과 4프레임 베기 시트를 그리게 함. 모델별 세 번 중 가장 나은 것으로 채점 | Claude 상위 모델이 창의성·정확성 모두 가장 높았고, 같은 모델의 중간급은 애니메이션에서 몸 비율이 흐트러짐. 모든 결과가 사람 그림보다 투박했는데, 저자는 도구가 너무 원시적인 탓으로 봄. 결론: 도구를 어떤 단위(픽셀 대 도형)로 줄지가 핵심. 그림 자체보다 스프라이트 시트 내보내기, 팔레트 바꾸기, 크기 맞추기 같은 일이 에이전트에 더 맞을 수 있음 |
| [diivi/aseprite-mcp](https://github.com/diivi/aseprite-mcp) ([README](https://cdn.jsdelivr.net/gh/diivi/aseprite-mcp@main/README.md)) | C | 위 실험의 기반 서버. 지금은 도구 123개(그리기, 레이어, 애니메이션, 팔레트, 타일맵, 검사, 미리보기, Lua) | `draw_rows`: ASCII 행 + 색 범례로 손으로 고른 디테일을 찍고, `read_rows`로 같은 형식으로 다시 읽어 고침(A와 C를 섞음). 권장 순서: 팔레트 먼저 → 레이어로 나눠 → 실루엣에서 디테일로 → 매 단계 `view_sprite`로 확인 → 의도를 갖고 음영 → 애니메이션 → `compare_frames`, `get_bounds`로 검증. README에 최신 Claude 모델로 "검사" 실험을 다시 한 결과와 비평 후 다시 그린 예시가 있음(직접 확인하지 않음) |
| [willibrandon/pixel-plugin](https://cdn.jsdelivr.net/gh/willibrandon/pixel-plugin@main/README.md) | C | Claude Code 플러그인. `/pixel-new`, `/pixel-palette`, `/pixel-export` 같은 명령과 자연어로 Aseprite 조작 | 처음에 크기와 팔레트를 정하고 → 단계별로 디테일·음영 → 프레임과 타이밍 → 엔진에 맞는 시트 형식으로 내보내기. 레트로 팔레트(NES, GB, PICO-8, DB16/32), 디더, 팔레트 축소 |
| [ZeroTian/aseprite-mcp](https://glama.ai/mcp/servers/ZeroTian/aseprite-mcp), [MalloyTheDev/aseprite-mcp](https://glama.ai/mcp/servers/MalloyTheDev/aseprite-mcp) | C | 다른 Aseprite MCP 구현 | 어니언 스킨 렌더(`render_onion_skin`)로 프레임 사이 움직임이 이어지는지 그림으로 확인 |

### D. 이미지 모델과 후처리

| 출처 | 방식 | 무엇을 했나 | 배울 점 / 주의할 점 |
|---|---|---|---|
| [Rangy: AI Pixel Art: Why It Isn't Really Pixel Art](https://rangy.ai/blog/ai-pixel-art) | D | 32x32·12색으로 요청한 결과를 분석: 고유 색 44,725개, 색이 바뀌는 곳의 2%만 32x32 격자에 맞음 | 이미지 모델은 "픽셀 아트의 그림"을 그림. 프롬프트로 격자·색 수를 강제할 수 없음. 후처리: 최근접 축소 → 팔레트 양자화(순서 중요) → 디더 끔 → 손으로 정리. 단순한 실루엣을 요청할수록 변환이 잘 됨. 글쓴이가 이미지 생성 도구를 파는 회사라는 점은 감안 |
| [SpriteCook: Creating Pixel Art Assets](https://www.spritecook.ai/blog/creating-pixel-art-assets) (2026-03) | D | 이미지 생성 서비스의 사용 안내 | 짧고 구체적인 프롬프트에 시점(옆·앞·탑다운)을 꼭 적음. 게임 해상도로 생성. 팔레트 고정·재사용. 일관성은 프롬프트보다 참조 이미지로 |
| [PixelLab MCP](https://www.pixellab.ai/mcp) | D | Claude Code에 붙는 MCP. 스프라이트, 회전, 애니메이션, 타일셋, 맵 생성 | 유료 API 키 필요. 결과물 라이선스 확인 필요 |
| [pixelwright](https://github.com/m4bwav/pixelwright/wiki) | D | 이미지 모델 결과를 블록당 한 픽셀, 고정 팔레트, 딱 떨어지는 알파로 정리하는 Claude Code 플러그인 | D 방식이라면 후처리를 도구로 고정하는 것이 핵심 |

## 3. 공통 교훈

1. **크기·팔레트·시점·투명 키를 먼저 못 박습니다.** 모든 출처가 같은 말을 합니다(Pixelsrc, pixel-plugin, SpriteCook, Pixel Art Bench). 이 저장소에서는 팔레트 파일의 20개 키, 32x40 셀, 오른쪽을 보는 옆모습이 기본값입니다.
2. **실루엣 → 색 덩어리 → 디테일 순서로 그립니다.** 실루엣이 안 읽히면 디테일로 고칠 수 없습니다(Pixelsrc, aseprite-mcp, [`../pixel-technique.md`](../pixel-technique.md)).
3. **LLM이 직접 찍는 격자는 작게 둡니다.** 출처마다 기준이 12x12, 16x16, 24x24로 다르지만 결론은 같습니다. 그보다 큰 그림은 도형, 타일 조합, 구성 함수로 만들고 렌더러가 찍게 합니다(PIXL, pixlrt, AM-Bench).
4. **색에는 의미 있는 이름을 붙입니다.** `{skin}`, `{shadow}`처럼 이름이 있으면 LLM이 명암 단계를 덜 헷갈립니다. 이 저장소의 팔레트 키(`s` 피부, `h` 피부 그림자, `K` 외곽선 등)가 같은 역할입니다.
5. **렌더 → 보기 → 고치기 루프를 돌립니다.** 미리보기가 없으면 결과가 크게 나빠집니다. claude-pxl, aseprite-mcp, Miranda 실험 모두 미리보기 도구를 둡니다. Claude는 PNG를 직접 볼 수 있으니 확대본을 만들어 보고, 실루엣·손·얼굴을 따로 크게 잘라 봅니다.
6. **애니메이션은 비교해서 확인합니다.** 같은 팔레트를 쓰고, 바뀌는 부위만 지정하고, 프레임을 겹치거나 나란히 놓고 비율이 흐트러지지 않았는지 봅니다(Pixelsrc, aseprite-mcp, Miranda 실험의 비율 흐트러짐 사례).
7. **검증기를 둡니다.** 형식 오류는 렌더러가 잡게 하고(Pixelsrc `--strict`, 이 저장소의 `pixelart.py --check`), 사람의 눈은 그림 판단에만 씁니다.
8. **이미지 모델 결과는 후처리 순서를 지킵니다.** 최근접 축소 → 양자화 → 디더 없이 → 손 정리(Rangy). 이 저장소에서는 쓰기 전에 라이선스와 AI 고지를 먼저 확인합니다.
9. **도구 단위가 결과를 정합니다.** 점·선만 주면 투박해지고, 손·얼굴·머리카락을 구조로 그리는 도구를 주면 나아집니다(Miranda 결론, 이 저장소의 손·얼굴 구성 도구).

## 4. 이 저장소에서 겪은 실패와 규칙

《미방송분》 팩과 그 이전 작업에서 사용자 피드백이나 검수로 발견한 문제입니다. 오른쪽 열의 규칙은 [`prompts.md`](prompts.md)의 템플릿에 반영했습니다.

| 증상 | 원인 | 프롬프트에 넣을 규칙 |
|---|---|---|
| 손이 "도형을 이어 붙인" 모양 | 원 + 직선 손가락 | 손은 손바닥 상자 + 손가락 3마디 + 엄지 구조로 그림([`../pixel-technique.md`](../pixel-technique.md)) |
| 막대·그릇을 쥔 손이 대상 옆에 떠 있음 | 손목 위치만 보고 놓음. 주먹은 손목에서 손 크기의 약 0.6배 앞에 생김 | 쥔 손은 주먹 중심을 대상 좌표에 맞추고, 확대해서 겹쳤는지 확인 |
| 장면 위쪽에 바닥 줄이 깔림 | `.scene`의 `@layer`는 매번 0행부터 시작하는데 바닥을 별도 레이어로 씀 | 벽과 바닥은 한 레이어 안에서 위에서 아래로(바닥은 10~11행) |
| 대나무 잎이 야자수처럼 | 한 점에서 잎을 방사형으로 뻗음 | 잎은 마디마다 2~3장, 바깥으로 뻗고 아래로 처지게. 앞 잎과 뒤 잎의 명암을 다르게 |
| 곱슬머리가 공을 늘어놓은 모양, 컬 표시가 새 모양 | 원을 하나하나 셰이딩 / 컬 아래쪽에 어두운 호 | 머리 덩어리 실루엣을 먼저(가장자리만 울퉁불퉁), 컬은 밝은 짧은 호 몇 개만 |
| 물 밑 돌담이 만화 구름처럼 | 둥근 고리 모양을 한 줄로 늘어놓음 | 원근(먼 것은 작고 흐리게), 돌을 하나씩, 무너진 틈, 집터 안에 기단·주춧돌·기와 같은 내용물 |
| 얼굴이 무표정한 가면 | 눈·입이 표정과 상관없이 고정 | 표정을 눈썹 안쪽·바깥쪽 높이, 미간, 위아래 눈꺼풀, 입꼬리, 광대, 주름, 눈물로 지정. 시선 방향과 고개 돌림(3/4) 지정 |
| 옆얼굴 머리가 헬멧처럼 | 머리카락 경계를 수직선으로 자름 | 헤어라인은 이마 → 관자놀이 → 귀 앞(구레나룻) → 귀 뒤 → 뒷목으로 |
| 노래하는 입이 얼굴 밖으로 튀어나온 검은 공 | 입을 타원으로 그리고 얼굴 실루엣으로 자르지 않음 | 벌린 입은 얼굴 안쪽 쐐기로, 입술 경계를 따라 |
| 밝은 실내에 동심원 띠 | 둥근 조명을 밝은 장면에 씀 | 밝은 실내·낮 장면에는 둥근 조명을 넣지 않음 |
| 낮 장면에 밤 물 타일이 검은 띠로 | 밤용 타일을 그대로 씀 | 낮 장면의 물은 배경 그림으로, 바닥 줄은 투명으로 남김 |
| 곳곳이 지글거림 | 규칙 디더를 모든 그라데이션에 씀 | 디더는 하늘·안개·비네트처럼 일부러 거칠게 둘 곳에만 |
| 작품 규칙 위반 위험(예: 그리면 안 되는 인물, 금지 색) | 규칙이 프롬프트 뒤쪽에 묻힘 | 작품 규칙은 프롬프트 맨 앞에, 그림으로 어떻게 지킬지까지 적음 |

# action-maker-platformer

ACTION GAME MAKER G(구 ACTION GAME MAKER, Gotcha Gotcha Games)로 만드는 2D 플랫포머 프로젝트입니다.
현재는 개발 준비 단계로, 리소스·스토리 자원 조사 결과는 [`reports/`](reports/)와 [`research_notes/`](research_notes/)에 있습니다.

## 라이선스 개요

이 저장소는 **코드와 콘텐츠의 라이선스를 경로별로 분리**합니다. 저장소 루트의 `LICENSE`(GPL-3.0)는 **코드에만** 적용되며, 아트·오디오·시나리오에는 적용되지 않습니다.

| 경로 | 대상 | 라이선스 |
|---|---|---|
| 아래 표에 없는 모든 파일 | GDScript, 씬(`.tscn`), 프로젝트 설정, 문서 | [GPL-3.0](LICENSE) + [ACTION GAME MAKER G 결합 추가 허가](LICENSE-EXCEPTION.md) |
| `assets/original/` | 이 프로젝트가 직접 만든 아트·오디오·시나리오 텍스트 | [All rights reserved](assets/original/LICENSE.md) (변경 예정 시 해당 파일 수정) |
| `assets/third_party/<출처>/` | 재배포가 허용된 외부 에셋 (CC0, CC BY, CC BY-SA 4.0, GPL 호환 등) | 각 폴더의 `LICENSE` 파일 |
| `addons/<이름>/` | 외부 Godot 애드온 (MIT 등) | 각 애드온 폴더의 `LICENSE` 파일 |
| `assets_private/` | 재배포 금지 에셋 (GGG RTP·DLC, 일본 무료 BGM·효과음, 유료 팩 등) | **커밋하지 않음** (`.gitignore`), 입수 방법만 [`SOURCES.md`](SOURCES.md)에 기록 |

### 왜 이렇게 나누는가

- **재배포 금지 에셋은 공개 저장소에 올릴 수 없습니다.** GGG 제품 약관은 소재를 "다른 정식 사용자에게 무상으로"만 넘길 수 있게 하고, GGG 제품의 전부 또는 일부를 서면 동의 없이 배포하는 것을 금지합니다([GGG Terms](https://rpgmakerofficial.com/en/support/rule/), 2026-06-22 개정). 일본 무료 음원 사이트 대부분도 게임 내장은 허용하지만 원본 재배포는 금지합니다.
- **GPL은 독점 런타임과의 결합을 스스로 허용하지 않습니다.** 내보낸 게임은 이 저장소의 코드와 GGG의 독점 런타임이 결합된 형태이므로, 제3자가 포크해서 빌드·배포할 수 있도록 [`LICENSE-EXCEPTION.md`](LICENSE-EXCEPTION.md)에 GPL-3.0 제7조 추가 허가를 둡니다. Godot Engine 자체는 MIT이므로 별도 예외가 필요 없습니다.
- **콘텐츠는 코드와 다른 결정이 필요합니다.** 오리지널 아트·시나리오는 우선 가장 보수적인 All rights reserved로 두었습니다. 나중에 CC BY-SA 4.0 등으로 여는 것은 쉽지만, 한 번 연 라이선스를 되돌릴 수는 없기 때문입니다.

## 빌드에 필요한 것

1. **ACTION GAME MAKER G 정식 구매본** (Steam). GGG 약관상 배포하는 게임은 정식 구매한 사용자가 만든 것이어야 합니다.
2. [`SOURCES.md`](SOURCES.md)에 적힌 재배포 금지 에셋을 직접 입수해 `assets_private/` 아래 지정된 경로에 배치.

`assets_private/`가 비어 있으면 해당 에셋을 참조하는 씬에서 리소스 누락 경고가 납니다. 이는 의도된 동작입니다.

## 저장소 구조

```
.
├── LICENSE                  # GPL-3.0 전문 (코드 전용)
├── LICENSE-EXCEPTION.md     # GPL-3.0 제7조 추가 허가 (ACTION GAME MAKER G 런타임 결합)
├── CREDITS.md               # 게임 내 크레딧 원본 (필수 표기 + 외부 에셋·애드온)
├── SOURCES.md               # 커밋하지 않는 에셋의 입수처·약관 기록
├── assets/
│   ├── README.md            # 에셋 분류 기준과 추가 절차
│   ├── original/            # 오리지널 콘텐츠 (All rights reserved)
│   └── third_party/         # 재배포 허용 외부 에셋 (출처별 폴더 + LICENSE)
├── assets_private/          # 재배포 금지 에셋 (git 무시, README만 추적)
├── reports/                 # 조사 보고서
└── research_notes/          # 조사 노트
```

ACTION GAME MAKER G 프로젝트(`project.godot`)는 저장소 루트에 만드는 것을 전제로 합니다. Godot은 프로젝트 폴더(`res://`) 밖의 파일을 읽을 수 없으므로 `assets/`와 `assets_private/`가 프로젝트 안에 있어야 합니다.

## 첫 프로젝트 커밋 전 체크리스트

ACTION GAME MAKER G가 새 프로젝트에 어떤 GGG 독점 파일(런타임 스크립트, 애드온, 내장 에셋)을 넣는지는 아직 확인되지 않았습니다. 프로젝트를 처음 커밋하기 전에:

- [ ] 빈 프로젝트를 만들고 생성된 파일 목록을 확인한다 (`git status --ignored`).
- [ ] GGG가 제공한 파일·폴더를 식별해 `.gitignore`의 "GGG 독점 파일" 구역에 추가한다.
- [ ] 내장 에셋(1,000여 종)을 씬에서 쓸 경우 그 파일도 커밋되지 않는지 확인한다.
- [ ] 사용하는 AGM G 버전을 이 README에 기록한다 (예: `2.0.x`, Godot 4.7.0).

## 에셋·애드온 추가 방법

[`assets/README.md`](assets/README.md)의 분류 기준을 따릅니다. 요약하면:

1. 직접 만든 것 → `assets/original/`
2. 원본 재배포를 **명시적으로** 허용하는 라이선스 → `assets/third_party/<출처>/` + `LICENSE` + `SOURCE.md` + `CREDITS.md` 항목
3. 그 밖의 모든 것 → `assets_private/` + `SOURCES.md` 항목

외부 코드는 **MIT·BSD·CC0 등 GPL-3.0과 호환되고 독점 런타임과의 결합을 막지 않는 라이선스만** 받습니다. 제3자의 GPL 코드는 우리가 대신 추가 허가를 줄 수 없으므로 넣지 않습니다(같은 추가 허가가 붙은 경우 제외).

**외부 게임의 대사·시나리오 텍스트는 오픈소스라도 들이지 않습니다.** 형식과 구조만 참고합니다. 자세한 규칙은 [`assets/README.md`](assets/README.md)의 "대사·시나리오 텍스트 규칙"을 따릅니다.

## 대사와 코드 분리 검사

대사 원문은 `assets/original/`의 데이터 파일(All Rights Reserved)에만 두고, GDScript 코드(GPL)는 줄 ID나 번역 키로만 참조합니다. 코드에 적은 텍스트는 코드 라이선스로 함께 배포되기 때문입니다.

이 규칙은 CI([`.github/workflows/content-license-checks.yml`](.github/workflows/content-license-checks.yml))가 PR과 `main` 푸시마다 검사합니다. `.gd` 파일의 문자열 리터럴에 한글이 있으면 실패합니다. 로컬에서는 다음으로 실행합니다.

```bash
python3 tools/check_dialogue_in_code.py
```

- 한글 주석(`#`, `##`)은 허용됩니다.
- 콘텐츠가 아닌 문자열은 같은 줄에 `# dialogue-lint: allow` 주석을 달면 통과합니다.
- `addons/`, `test/`, `tests/`, `.godot/`, `assets_private/`는 검사하지 않습니다.
- **알려진 한계:** 씬·리소스 파일(`.tscn`, `.tres`)은 아직 검사하지 않습니다. ACTION GAME MAKER G의 비주얼 스크립트가 텍스트 표시 액션의 문자열을 씬 파일에 저장하는지 확인한 뒤 검사 대상에 추가할지 정합니다. 영어 등 한글이 아닌 대사도 잡지 못하므로, 리뷰에서 함께 확인합니다.

## 기여

이 저장소에 기여하는 코드는 GPL-3.0과 [`LICENSE-EXCEPTION.md`](LICENSE-EXCEPTION.md)의 추가 허가 조건으로 제공되는 것으로 간주합니다. `assets/original/`에 기여하는 콘텐츠는 [`assets/original/LICENSE.md`](assets/original/LICENSE.md)의 조건을 따릅니다.

---

이 문서의 라이선스 구조는 조사에 근거한 실무적 정리이며 법률 자문이 아닙니다. 상업 출시 전에는 각 약관 원문과 전문가 검토를 거치는 것을 권장합니다.

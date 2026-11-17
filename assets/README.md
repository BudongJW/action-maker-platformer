# assets: 에셋 분류 기준과 추가 절차

에셋을 추가하기 전에 아래 순서대로 판단합니다. **기준은 하나, "원본 파일의 재배포를 명시적으로 허용하는가"입니다.** 게임에 넣어 배포할 수 있는지(대부분 가능)와 공개 저장소에 올릴 수 있는지(대부분 불가)는 다른 문제입니다.

## 분류 순서

```
직접 만들었나? ──예──▶ assets/original/
      │
     아니오
      ▼
약관이 원본 파일 재배포를 명시적으로 허용하나?
(CC0, CC BY, CC BY-SA 4.0, GPL 호환, ぴぽや 무료 소재 등)
      │
   ┌──┴──┐
  예     아니오 / 불명확
   ▼      ▼
assets/third_party/<출처>/    assets_private/  (커밋 안 됨)
 + LICENSE                    + SOURCES.md 항목
 + SOURCE.md                  + CREDITS.md 항목
 + CREDITS.md 항목
```

불명확하면 **항상 `assets_private/`** 로 보냅니다. 나중에 재배포 허용이 확인되면 옮기면 됩니다. 반대로 한 번 공개 저장소에 올린 파일은 커밋 기록에서 완전히 지우기 어렵습니다.

## 1. `original/`: 직접 만든 콘텐츠

- 아트, 오디오, 시나리오·대사 텍스트(`.dialogue`, `.ink` 등) 원본과 작업 파일(`.aseprite`, `.kra`, `.psd`)을 둡니다.
- 라이선스: [`original/LICENSE.md`](original/LICENSE.md)
- AI 생성 콘텐츠를 쓴 경우 파일 경로와 도구를 기록합니다(Steam 출시 시 AI 콘텐츠 신고에 필요).
- **GGG 에셋, 외부 에셋을 개변한 결과물은 여기에 두지 않습니다.** 개변물도 원본 라이선스를 따르므로 원본과 같은 위치(`third_party/` 또는 `assets_private/`)에 둡니다.

## 2. `third_party/<출처>/`: 재배포 허용 외부 에셋

출처(작가·팩) 하나당 폴더 하나를 만듭니다. 폴더 이름은 `작가-팩이름` 형식의 소문자·하이픈(예: `pixelfrog-pixel-adventure-1`)으로 합니다. 폴더마다 다음 두 파일이 반드시 있어야 합니다.

- `LICENSE`: 원본에 동봉된 라이선스 파일 그대로, 없으면 약관 페이지 전문 또는 라이선스 원문
- `SOURCE.md`: 아래 템플릿

```markdown
# <팩 이름>

- 작가: 
- 출처 URL: 
- 라이선스: (예: CC0 1.0 / CC BY 4.0 / GPL-3.0 (LPC 이중 라이선스 중 선택))
- 다운로드 날짜 / 버전: 
- 크레딧 필수: 예 / 아니오 (필수 문구: )
- 개변 사항: (없음 / 색 변경, 크기 조정 등)
```

그리고 [`CREDITS.md`](../CREDITS.md)의 "외부 에셋" 표에 한 줄을 추가합니다.

### 커밋해도 되는 것으로 확인된 소스 (2026-11 조사 기준)

| 소스 | 라이선스 | 메모 |
|---|---|---|
| Kenney | CC0 | 비주얼·오디오 모두 |
| Pixel Frog Pixel Adventure 1·2 | CC0 | 횡스크롤 플랫포머용 |
| Ansimuz Sunny Land | CC0 | 횡스크롤. 같은 작가의 다른 유료 팩은 팩별로 확인 |
| 0x72 DungeonTileset II, Ninja Adventure | CC0 | 탑다운 16x16 |
| LPC (OpenGameArt) | GPL-3.0 / CC BY-SA 3.0 이중 | **GPL-3.0 쪽을 선택**해 기록. 에셋별 CREDITS 필수 |
| ぴぽや倉庫 무료 소재 | 자체 약관 | 약관 전문을 `LICENSE`로 동봉할 때만 무상 재배포 가능. 유료·후원 소재는 불가 |
| Freesound 개별 파일 | 파일별 CC0 / CC BY | 파일마다 라이선스 확인. **CC BY-NC는 상업 이용 불가라 사용 금지** |
| Incompetech (Kevin MacLeod) | CC BY 4.0 | 정해진 크레딧 형식 필수 |
| Bfxr·jfxr로 직접 만든 효과음 | 제작자 소유 | `original/`에 둬도 됨 |

### 공유 라이선스 주의점

- **CC BY-SA 3.0은 GPL-3.0과 호환되지 않습니다.** CC가 공식 선언한 GPL-3.0 단방향 호환은 CC BY-SA 4.0뿐입니다.
- **CC 4.0 라이선스는 DRM을 금지합니다.** CC BY·BY-SA 에셋을 Steam 빌드에 넣는다면 DRM-free로 배포하거나, DRM 조항을 면제한 작가의 에셋만 고릅니다.
- **SCP 재단 콘텐츠(CC BY-SA 3.0)는 쓰지 않습니다.** GPL-3.0과 호환되지 않고, 게임 전체에 ShareAlike가 미치는지 불명확합니다.

## 3. `assets_private/`: 재배포 금지 에셋 (저장소 루트, 커밋 안 됨)

다음은 게임에 넣어 배포할 수는 있지만 **원본을 공개 저장소에 올릴 수 없는** 대표적인 소스입니다.

- GGG RTP·DLC, ACTION GAME MAKER G 내장 에셋 (GGG 약관: 정식 사용자 간 무상 양도만 허용, 추출 금지)
- 일본 무료 BGM·효과음: 魔王魂, 甘茶の音楽工房, OpenTracks(구 DOVA-SYNDROME), 効果音ラボ, ポケットサウンド, On-Jin, ユーフルカ
- 유료·무료 상업 팩: CraftPix, Szadi Art, Time Fantasy, ぴぽや 유료·후원 소재, DOTOWN
- Pixabay 오디오, Sonniss GDC 번들

배치 방법은 [`../assets_private/README.md`](../assets_private/README.md), 입수처 기록은 [`../SOURCES.md`](../SOURCES.md)를 따릅니다.

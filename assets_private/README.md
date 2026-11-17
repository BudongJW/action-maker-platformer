# assets_private (커밋하지 않음)

이 폴더의 파일은 `.gitignore`로 제외되며, 이 README만 저장소에 추적됩니다.

**재배포가 금지된 에셋**(GGG RTP·DLC·내장 에셋, 일본 무료 BGM·효과음, 유료 팩 등)을 여기에 둡니다. 게임 빌드에는 포함되지만 공개 저장소에는 올라가지 않습니다.

## 규칙

1. 에셋을 넣을 때마다 저장소 루트의 [`SOURCES.md`](../SOURCES.md)에 입수처·배치 경로·약관 요지·확인일을, [`CREDITS.md`](../CREDITS.md)에 크레딧을 추가합니다.
2. 하위 폴더는 `assets/`와 같은 분류로 나눕니다.

```
assets_private/
├── audio/
│   ├── bgm/
│   └── se/
├── graphics/
│   ├── tilesets/
│   ├── characters/
│   └── portraits/
└── ggg_dlc/<팩 이름>/      # GGG 공식 DLC (팩 readme 조건 확인)
```

3. 커밋 전에 `git status`로 이 폴더의 파일이 추적되지 않는지 확인합니다. 실수로 커밋했다면 푸시하기 전에 되돌리고, 이미 푸시했다면 기록에서 제거해야 합니다.

## 새로 받은 저장소에서

`SOURCES.md`의 목록대로 파일을 입수해 지정 경로에 두면 빌드할 수 있습니다. 파일이 없으면 해당 리소스를 참조하는 씬에서 누락 경고가 납니다.

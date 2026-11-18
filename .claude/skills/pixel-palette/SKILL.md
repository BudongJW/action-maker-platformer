---
name: pixel-palette
description: 같은 키로 새 팔레트(.pal)를 만들어 그림을 바꾸지 않고 트랙·시간대·다른 세계 버전을 만든다(@swap).
argument-hint: "[대상 그림과 만들 버전]"
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash(python3 tools/pixelart.py *)
---

# 팔레트·트랙 변형 (T6)

먼저 `.claude/skills/pixel-rules/SKILL.md`를 읽고 그 규칙을 따른다.

요청: $ARGUMENTS

1. 원래 팔레트 파일을 읽고 키마다 역할(외곽선, 피부, 피부 그림자, 강조색 등)을 표로 정리한다.
2. 새 `.pal`은 같은 키를 모두 갖게 만든다. 키마다 이름(역할)을 주석으로 단다.
3. 명암 순서를 지킨다. 원래 팔레트에서 어두운 키가 새 팔레트에서도 어둡게 한다.
4. 이 버전의 금지 사항을 먼저 적고 지킨다(예: LINEAR에는 채도 높은 빨강 없음, `C`는 덧녹음된 것의 자홍).
5. 트랙이 바뀌어도 색이 변하면 안 되는 것(예: 목소리 파형 UI)은 `ui.pal`로 따로 그리거나 `keep`으로 둔다.
6. 그림은 고치지 않고 `.scene`의 `@swap`으로 적용한다. 원래 판과 새 판을 나란히 렌더해 명암이 뒤집힌 곳, 색이 뭉개진 곳을 확인한다.
7. `--check`로 확인하고 비교 이미지를 보여 준다.

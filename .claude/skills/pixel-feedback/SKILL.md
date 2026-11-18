---
name: pixel-feedback
description: 그림이 어색하다는 식의 피드백을 받았을 때 원인 진단 → 레퍼런스 → 그리는 방법 고치기 → 같은 문제가 있는 그림 모두 다시 그리기 → 규칙 기록까지 한다.
argument-hint: "[받은 피드백 그대로, 대상 그림]"
disable-model-invocation: true
allowed-tools: Read Grep Glob WebSearch WebFetch Bash(python3 tools/pixelart.py *)
---

# 피드백 반영 (R2)

먼저 `.claude/skills/pixel-rules/SKILL.md`, `docs/pixel-technique.md`, `docs/claude-pixel/references.md`를 읽는다.

피드백: $ARGUMENTS

1. 피드백이 가리키는 그림을 찾아 직접 보고, 같은 증상이 있는 다른 그림도 찾는다. "증상 / 원인 / 있는 곳" 표로 정리한다.
2. 고칠 원리를 사람 아티스트의 레퍼런스에서 찾는다. 이미 정리된 문서에 있으면 그것을 쓰고, 없으면 웹에서 찾아 링크와 요약만 남긴다(그림은 복사하지 않음).
3. 한 장만 손보지 않는다. 그리는 방법(구성 함수, 템플릿, 규칙)을 고쳐 같은 문제가 있는 그림을 모두 다시 그린다.
4. 전후 비교 이미지를 만들어 보여 준다.
5. `docs/claude-pixel/references.md` 4절 표에 "증상 / 원인 / 프롬프트에 넣을 규칙" 한 줄을 더한다. 일반 기법이면 `docs/pixel-technique.md`에도 반영한다.
6. `--check`와 저장소 검사를 돌린다.

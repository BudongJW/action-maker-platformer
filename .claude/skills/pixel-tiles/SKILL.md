---
name: pixel-tiles
description: 장소 타일셋(.pix, 16x16)을 이 저장소 규칙으로 만들고, 시험 장면에 깔아 이음매와 반복 무늬를 확인한다.
argument-hint: "[장소와 필요한 타일]"
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash(python3 tools/pixelart.py *)
---

# 타일셋 (T2)

먼저 `.claude/skills/pixel-rules/SKILL.md`를 읽고 그 규칙을 따른다.

요청: $ARGUMENTS

1. 필요한 타일 목록을 정해 표로 보여 준다: 윗면, 속, 벽, 장식. 2x2·1x3처럼 큰 것은 `이름_x_y` 프레임으로 나눈다.
2. 윗면은 0행에 두고, 가장자리는 옆 타일과 이어지게 한다. 같은 재질의 명암 단계는 같은 키 묶음으로 쓴다.
3. 낮·밤과 트랙별 색은 그림을 바꾸지 않고 팔레트(`@swap`)로 처리한다. 밤 전용 타일(예: 검은 물)은 이름에 밝힌다.
4. 렌더한 뒤, 이 타일로 320x180 시험 장면(`.scene`)을 스크래치 폴더에 깔아 본다. 반복 무늬가 튀는지, 이음매가 보이는지, 1배에서 재질이 읽히는지 확인하고 고친다.
5. `--check`로 확인하고 타일 목록, 미리보기, 시험 장면을 보여 준다. 시험 장면은 요청이 없으면 커밋하지 않는다.

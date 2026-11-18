---
name: pixel-options
description: 같은 대상을 여러 안으로 그려 나란히 비교하고, 1배 크기에서 가장 잘 읽히는 안을 추천한다.
argument-hint: "[대상] [안 개수, 기본 3]"
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash(python3 tools/pixelart.py *)
---

# 여러 안 비교 (R3)

먼저 `.claude/skills/pixel-rules/SKILL.md`를 읽고 그 규칙을 따른다.

요청: $ARGUMENTS

1. 안의 개수를 정한다(요청에 없으면 3). 안마다 다르게 할 축을 하나씩 정한다: 실루엣, 자세, 색 비중, 구도 중에서.
2. 안들은 같은 크기·팔레트로 스크래치 폴더에 그린다. 고른 안만 저장소에 넣는다.
3. 1배와 4배로 나란히 놓은 비교 이미지를 만든다. 안마다 다른 점을 한 줄씩 적는다.
4. 1배 크기에서 가장 잘 읽히는 안을 이유와 함께 추천하고, 어느 안을 쓸지 묻는다.

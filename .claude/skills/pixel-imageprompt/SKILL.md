---
name: pixel-imageprompt
description: 외부 이미지 생성 도구에 넣을 픽셀 아트 프롬프트와 후처리 순서를 쓴다. 저장소에 그림을 넣지는 않는다.
argument-hint: "[대상, 시점, 크기]"
disable-model-invocation: true
allowed-tools: Read Grep Glob
---

# 이미지 모델용 프롬프트 (T7, 참고용)

`docs/claude-pixel/references.md`의 방식 D 항목을 읽고 따른다.

요청: $ARGUMENTS

1. 아래 형식으로 영어 프롬프트를 쓴다. 시점과 크기는 꼭 넣는다. 복잡한 디테일보다 굵고 단순한 실루엣을 요청한다.

   ```text
   [대상], [side view / front view / top-down], [32x32 또는 64x64] sprite,
   bold simple silhouette, few internal details, flat colors, [N]-color palette,
   no anti-aliasing, no dithering, transparent background
   ```

2. 이미지 모델은 격자·색 수·안티에일리어싱 지시를 잘 지키지 않는다는 점을 알린다. 후처리 순서를 함께 준다: 최근접 축소 → 프로젝트 팔레트(`night-school.pal` 또는 해당 팩 팔레트)로 양자화 → 디더 없음 → 손으로 외톨이 픽셀·끊긴 외곽선 정리.
3. 결과물을 `assets/original/`에 넣기 전에 해야 할 일을 적는다: 도구의 이용 약관과 라이선스 확인, `assets/original/AI_CONTENT.md`에 기록.
4. 이 명령은 프롬프트와 절차만 쓴다. 이미지를 받거나 저장소에 넣지 않는다.

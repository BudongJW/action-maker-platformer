# 오디오 리소스 · 플러그인/확장 · 시스템 구현 가능성 (RPG Maker 계열 & ACTION GAME MAKER)

> 조사일: 2026-11-16. 대상 저장소: 공개 GitHub 저장소 `action-maker-platformer` (GPL-3.0).
> 모든 라이선스 요약은 각 사이트의 약관 페이지를 직접 읽고 정리한 것이다(법률 자문 아님). 약관은 예고 없이 바뀔 수 있으므로, 실제로 쓰기 전에 다운로드 시점의 약관을 다시 확인하고 스크린샷이나 PDF로 보관할 것.
> **⚠ 공개 저장소 경고**: 아래 표에서 "원본 파일 재배포 금지"로 표시된 소스의 음원(.ogg/.wav/.mp3)은 공개 GitHub 저장소에 커밋하면 안 된다. 해당 파일은 `.gitignore` 처리하고 비공개 저장소, 로컬 다운로드 스크립트, 비공개 빌드 아티팩트 등 별도 경로로 관리해야 한다.

---

## Q1. 오디오: RPG Maker 개발자와 인디 개발자가 많이 쓰는 무료·상용 BGM/SFX 소스와 라이선스 (특히 공개 저장소 재배포 가능 여부)

### Takeaway
일본 무료 BGM·SFX 사이트(마왕혼, 甘茶, DOVA-SYNDROME→OpenTracks, 効果音ラボ, ポケットサウンド, On-Jin, ユーフルカ)는 모두 게임 안에 넣어 쓰는 것은 허용하지만 **원본 파일 단독 재배포는 금지**한다. 따라서 GPL-3.0 공개 저장소에 원본 음원을 커밋할 수 없다. 공개 저장소에 그대로 넣어도 되는 것은 CC0(Kenney, Freesound의 CC0 파일, Bfxr/jfxr로 직접 만든 효과음)와 재배포를 허용하는 CC-BY/CC-BY-SA 계열(Incompetech, Freesound의 CC-BY 파일, OpenGameArt의 개별 파일)뿐이다. 공식 Maker DLC와 Sonniss GDC 번들도 원본 재배포를 금지한다.

### Cited Findings

#### A. 일본 무료 BGM/SFX 사이트

- **魔王魂 (Maou-damashii, maou.audio)**
  - 음악은 CC BY 4.0으로 제공되지만 사이트 자체 이용 규칙이 따로 붙는다. 저작권은 작곡가 森田交一에게 남고, 사이트는 "魔王魂は著作権フリーではありません。"라고 명시한다. — [魔王魂 利用規約](https://maou.audio/rule/)
  - 개인·상업 용도 모두 무료이고 신고나 등록이 필요 없다("商用でも制限無く無料で使えます。"). — [魔王魂 利用規約](https://maou.audio/rule/)
  - **크레딧 필수**: "魔王魂の音楽を使用された場合は著作表記が必要です。" (예: "音楽：魔王魂"). — [魔王魂 利用規約](https://maou.audio/rule/)
  - **원본 재배포 금지**: 곡 단품을 다시 배포하는 행위("曲単品を再配布するのはNG!"), 다른 소재 배포·판매 사이트 등록, mp3/wav 직링크, 스트리밍 서비스(Spotify 등)나 NFT 등록이 모두 금지된다. — [魔王魂 利用規約](https://maou.audio/rule/)
  - **게임 암호화 허용**: CC 라이선스는 원칙상 기술적 보호조치를 금지하지만, 사이트는 "RPGツクールシリーズやウディタ、Unityなどのゲーム制作用途における暗号化は許可します。"라고 예외를 둔다. — [魔王魂 利用規約](https://maou.audio/rule/)
  - 생성형 AI 학습에 쓰는 것은 전면 금지다. — [魔王魂 利用規約](https://maou.audio/rule/)
  - ⚠ 모순점: CC BY 4.0은 원래 재배포를 허용하는데, 사이트 규칙은 곡 단품 재배포를 금지한다. 보수적으로 "원본은 공개 저장소에 넣지 않는다"로 해석해야 한다.

- **甘茶の音楽工房 (Amacha, amachamusic.chagasi.com)**
  - 상업·개인 이용이 모두 가능하고, 게임 BGM 용도가 명시돼 있다("ウェブ、映像、ゲーム、ラジオなど"). — [甘茶 利用規約](https://amachamusic.chagasi.com/terms.html)
  - 크레딧은 선택 사항이다. 단 편곡판을 쓸 때는 저작권 표시가 필요하다. — [甘茶 利用規約](https://amachamusic.chagasi.com/terms.html)
  - **재배포 금지**: "音楽だけを販売したり、2次配布することは禁止です。" 직링크도 금지된다. — [甘茶 利用規約](https://amachamusic.chagasi.com/terms.html)
  - 이 음원을 쓴 작품은 JASRAC 같은 관리단체나 YouTube Content ID에 등록할 수 없고, 음악 스트리밍 플랫폼으로 배포할 수도 없다. 사이트는 MP3(128kbps)만 제공한다. — [甘茶 利用規約](https://amachamusic.chagasi.com/terms.html)

- **DOVA-SYNDROME → OpenTracks (2026-09-15 명칭 변경)**
  - 기존 dova-s.jp 라이선스 URL은 opentracks.com으로 301 리다이렉트된다. 약관 페이지에는 "DOVA-SYNDROMEは2026年9月15日付でOpenTracksに名称が変更になりました"라고 적혀 있다. — [OpenTracks 音源利用ライセンス](https://opentracks.com/help/articles/license/)
  - 이용료가 없고 **크레딧도 불필요**하다("著作権表示・提供等の表示は不要です。"). 개인과 법인 모두 상업 이용이 가능하지만 "배경음악(従)"으로 쓰는 경우에 한한다. 게임과 DVD는 허용 예시에 들어 있다. — [OpenTracks License](https://opentracks.com/help/articles/license/)
  - **재배포 금지**: 음원 자체를 배포·판매하는 것(온라인 공개 포함)이 금지된다. 또 "최종 사용자가 변환 없이 음원 파일에 쉽게 접근·복사할 수 있는 형태"도 금지된다. 공개 저장소나 압축되지 않은 게임 데이터에 원본을 두면 여기에 해당할 수 있다. — [OpenTracks License](https://opentracks.com/help/articles/license/)
  - 작곡가별 개별 규약이 사이트 규약보다 우선한다. 단 무료·크레딧 불필요 조항과 금지사항은 사이트 규약을 따른다. AI 학습 이용, JASRAC 신탁, YouTube Content ID 등록은 금지된다. — [OpenTracks License](https://opentracks.com/help/articles/license/)

- **効果音ラボ (soundeffect-lab.info)**
  - 크레딧·신고·링크가 모두 필요 없다(선택). 개인·법인·공공기관 모두 상업 이용이 무료다. "RPGツクール作品、WOLF RPGエディター作品"이 이용 예시로 나온다. — [効果音ラボ 利用規約](https://soundeffect-lab.info/agreement/)
  - **재배포 금지**: "再配布禁止※許可できる場合あり（企業様限定）". 효과음을 가공해 쓰는 것은 괜찮지만 "改変したものを再配布することは禁止"다. 효과음을 넣은 무료 소재나 템플릿을 만드는 것도 재배포로 본다. 앱 조작음으로 내장하는 것은 재배포가 아니다. — [効果音ラボ 利用規約](https://soundeffect-lab.info/agreement/)
  - AI 학습, 성인·공서양속 위반 작품, 음 상표 등록은 금지된다. — [効果音ラボ 利用規約](https://soundeffect-lab.info/agreement/)

- **ポケットサウンド (pocket-se.info)**
  - **크레딧을 표기하면 무료**다. 크레딧 없이 쓰려면 유료다(효과음 550엔~, BGM 1,100엔~, 구독 개인 1,650엔·법인 10,000엔). 판매용 게임과 YouTube 수익화에 쓸 수 있다. — [ポケットサウンド](https://pocket-se.info/), [規約](https://pocket-se.info/rules/)
  - **재배포·재판매 금지**("素材を再配布したり販売しないでください。"), 소재 단품을 YouTube 등에 올리는 것도 금지다. — [ポケットサウンド](https://pocket-se.info/)

- **On-Jin ～音人～ (on-jin.com)**
  - "フリー"는 "자유"가 아니라 "무료"라는 뜻이라고 사이트가 정의한다. 개인·서클·학교·자원봉사자는 상업·비상업 모두 자유롭게 쓸 수 있다. **기업·영리사업·관공서가 상업적으로 쓰려면 사전 연락이 필요**하다. — [On-Jin 利用規約](https://on-jin.com/kiyaku.php)
  - 크레딧은 강제가 아니다. 다만 **RPG 쯔꾸르 게임처럼 최종 제품 안에 음원 파일이 그대로 노출되는 경우**에는 작품에 출처 표기와 "재배포·무단 사용 금지" 문구를 함께 넣어야 한다. — [On-Jin 利用規約](https://on-jin.com/kiyaku.php)
  - "素材をそのまま、または加工やコンバートしただけの状態などで、素材として販売や公開、配信するなど、第三者が取得できる状態にする事はできません。" 원본뿐 아니라 가공·변환만 한 파일도 공개할 수 없다. 니코니코 커먼즈 고음질판은 상업 이용이 불가능하다. — [On-Jin 利用規約](https://on-jin.com/kiyaku.php)

- **ユーフルカ (YouFulca, youfulca.com)**
  - **크레딧은 가능한 경우 필수**("表記できる場合は作品内やYouTubeの概要欄などに"音楽：ユーフルカ"などと記載"). 저작권은 ユーフルカ에 귀속된다. 상업·18금·TV·영화 등에 쓸 수 있다. — [ユーフルカ 利用規約](https://youfulca.com/kiyaku_jp/)
  - **툴 잠금 소재가 있다**: 파일명에 "RPGmaker"가 들어간 RPG Maker 전용 소재는 RPG Maker로 만든 게임에서만 쓸 수 있다("ウディタやUnity、RPG Developer Bakinなどで作られたゲームでは使用できません。"). ACTION GAME MAKER는 명시돼 있지 않다. — [ユーフルカ 利用規約](https://youfulca.com/kiyaku_jp/)
  - 소재 자체를 CD나 데이터로 재배포·판매하는 것은 금지된다. NFT와 스트리밍 배포도 전면 금지다. 게임용 루프 ZIP을 제공한다. — [ユーフルカ 利用規約](https://youfulca.com/kiyaku_jp/), [ユーフルカ](https://youfulca.com/)

- **Senses Circuit (senses-circuit.com)**
  - 비상업 용도는 링크와 저작권 표기(예: "BGM: hitoshi by Senses Circuit")를 조건으로 무료다. 법인 이용(유·무료 불문)과 TV·사이니지 광고는 사전 연락이 필요하다. 약관 페이지가 403을 반환해 직접 확인하지 못했고, 검색 스니펫으로만 확인했다. — [Senses Circuit non-commercial terms](https://senses-circuit.com/terms/non-commercial-terms-and-conditions-of-use)

#### B. 서양권 소스

- **Kenney (kenney.nl)**: "all game assets on the asset pages are public domain licensed (CC0)". 상업적으로 쓸 수 있고 크레딧은 필요 없다("Attribution is not required."). — [Kenney Support](https://kenney.nl/support). CC0이므로 공개 저장소에 커밋해도 된다.
- **Freesound**: 업로더가 파일마다 CC0, CC BY 4.0, CC BY-NC 4.0 중 하나를 고른다. 구형 Sampling+ 1.0은 CC가 폐기했지만 아직 남아 있는 파일이 있다. CC BY는 원저작자 표기가 필수다. CC BY-NC는 "you can't earn any money with the piece of work you create!" — [Freesound FAQ](https://freesound.org/help/faq/)
- **Incompetech / Kevin MacLeod**: CC BY 4.0이다. 표기 형식은 "Title Kevin MacLeod (incompetech.com) / Licensed under Creative Commons: By Attribution 4.0 / [라이선스 URL]"이다. 게임은 설정 메뉴의 크레딧 화면에 넣는 것이 일반적이다. 스트리밍이 예상되면 화이트리스트 등록을 메일로 요청하라고 안내한다. 크레딧을 넣기 어려우면 유료 Standard License를 쓸 수 있다(가격은 이 페이지에 없음). — [Incompetech FAQ](https://incompetech.com/music/royalty-free/faq.html)
- **Pixabay (음악·효과음 포함)**: 크레딧 없이 무료로 쓸 수 있고 가공도 할 수 있다. 다만 "standalone"(창작적 가공 없이 그대로) 판매·배포는 금지된다. 상표가 포함된 콘텐츠는 상업 이용에 제한이 있고, 기만적 이용도 금지된다. 요약 페이지는 법적 구속력이 없다고 밝힌다. — [Pixabay License Summary](https://pixabay.com/service/license-summary/)
- **Sonniss GDC Game Audio Bundle (라이선스 v2.0, 2026-08-27 시행)**: 무제한 프로젝트에 상업적으로 쓸 수 있고 크레딧도 필요 없다. 하지만 "distribute, publish, sub-license or otherwise supply the sound effects as sound effects"는 사전 서면 허락이 필요하다. 가공·재디자인한 경우도 마찬가지다. AI 학습은 금지되고, 팀 내부 공유는 허용된다. 다운로드 시점의 라이선스 버전이 적용된다. — [Sonniss GDC Bundle License](https://sonniss.com/gdc-bundle-license/)
- **OpenGameArt**: 파일마다 라이선스가 다르다(CC0, CC-BY 3.0/4.0, CC-BY-SA 3.0/4.0, OGA-BY 3.0, GPL 등). 상업적으로 쓸 수 있다. CC-BY-SA와 GPL은 같은 조건의 공유를 요구한다. 여러 라이선스가 걸린 파일은 그중 하나를 골라 따르면 된다. OGA-BY 3.0은 CC-BY 3.0에서 기술적 보호조치(DRM) 금지 조항을 뺀 것이다. LPC 커뮤니티 페이지는 "CC-BY-SA 4.0 is compatible with the GPL v3"라고 안내한다. 공식 FAQ 페이지는 403이라 검색 결과로 확인했다. — [OpenGameArt FAQ (검색 경유)](https://opengameart.org/content/faq), [LPC FAQ 업데이트](https://lpc.opengameart.org/node/51649), [Wikipedia: Open Game Art](https://www.wikipedia.org/wiki/Open_Game_Art)

#### C. 직접 생성하는 SFX 도구

- **Bfxr**: bfxr.net에 따르면 사용자는 bfxr로 만든 모든 사운드에 대한 전권을 갖고, 상업용을 포함한 모든 용도로 쓸 수 있다. — [bfxr.net](https://www.bfxr.net)
- **jfxr**: 만든 사운드는 제작자의 것이고 상업적으로 쓸 수 있다. 코드는 BSD-3이다. — [jfxr GitHub](https://github.com/ttencate/jfxr)
- **jsfxr / ChipTone**: 1차 출처에서 출력물 라이선스를 확인하지 못했다. jsfxr npm 패키지는 2022년 소유자가 바뀌었다는 HN 댓글이 있다. — [HN 스레드](https://hn.svelte.dev/item/44721932)

#### D. 공식 Maker 오디오 DLC와 툴 잠금

- ACTION GAME MAKER의 Steam DLC 24종은 대부분 음악·효과음 팩이다(Small Sounds 시리즈, Dusk of the Elves, Nightwalker 등). — [Steam: ACTION GAME MAKER](https://store.steampowered.com/app/2987180/ACTION_GAME_MAKER/)
- **GGG Products 이용규약** (AGM 포함):
  - 정식 구매자만 소재("Our Material")를 쓸 수 있다.
  - 소재를 넘기거나 배포하는 것은 **"only to other Users free of charge"**만 허용된다.
  - 게임에서 소재를 추출해 배포하는 것은 금지되고, Official Add-Ons를 단독으로 배포하는 것도 금지된다.
  - 같은 규약 안에 "다른 회사 게임 툴로 만든 작품에서도 쓸 수 있다"는 취지의 조항이 있다.
  - — [GGG Products Terms](https://rpgmakerofficial.com/en/?p=1248)
- **RPG Maker MZ/MV EULA (rpgmakerweb.com)**: "Company Assets may be used only in User Games produced with This Software." 제3자 툴에서 쓰려면 사전 서면 동의가 필요하다. 개별 소재를 단독으로 배포하는 것도 금지된다. — [RPG Maker EULA](https://www.rpgmakerweb.com/eula)
  - ⚠ **상충**: 구형 rpgmakerweb EULA는 MZ 소재를 MZ 게임에만 쓰도록 한정한다. 신형 GGG Products Terms는 Maker 시리즈 간 교차 사용과 타사 툴 사용을 허용하는 것처럼 읽힌다. 어느 쪽이 우선하는지는 원문을 대조해 확인해야 한다.
- RPG Maker DLC를 AGM에서 쓸 수 있느냐는 질문(2026-05-21)에, Baz가 "GGG Products Terms에 MZ/MV와 함께 열거되어 있으므로 괜찮을 것"이라고 답했다. 조건은 팩 소유, 게임 제작·홍보 용도 한정, 작가 크레딧 표기다. 이 답변은 공식 판정이 아닌 커뮤니티 해석으로 분류된다. — [GUILD topic 1316](https://guild.rpgmakerofficial.com/t/topic/1316?tl=en)

### Inferences
- **공개 GPL 저장소 운영 원칙**
  - (a) 음원 원본은 기본적으로 커밋하지 않는다. 저장소에는 `assets/audio/SOURCES.md`(출처 URL, 다운로드일, 라이선스, 크레딧 문구)와 다운로드 스크립트나 체크섬만 둔다.
  - (b) 공개 저장소에 넣을 수 있는 음원은 CC0(Kenney, Freesound의 CC0, Bfxr/jfxr 자작)와, 크레딧 파일을 함께 넣은 CC-BY 4.0(Incompetech, Freesound의 CC-BY)으로 한정한다.
  - (c) GPL-3.0은 코드 라이선스다. 에셋 라이선스는 README와 `LICENSES/` 폴더에 따로 명시하는 것이 안전하다. CC-BY-SA 4.0만 GPLv3와 단방향 호환이다(OGA/LPC 안내).
- **Godot 계열 게임의 패키징 문제**: OpenTracks는 "최종 사용자가 쉽게 복사할 수 있는 형태"를 금지한다. 마왕혼은 게임 암호화를 허용한다. On-Jin은 파일이 노출되면 재배포 금지 문구를 넣으라고 요구한다. Godot 내보내기 파일은 기본적으로 .pck 묶음이어서 RPG Maker MV의 www/audio 노출과는 상황이 다르다. 그러나 .pck는 추출 도구로 풀 수 있으므로 "쉽게 복사 불가"라고 단정하기는 어렵다. AGM에서 PCK 암호화를 쓸 수 있는지는 확인하지 못했다(Gaps 참조).
- **크레딧 필수 소스(마왕혼, ユーフルカ, ポケットサウンド 무료판, Incompetech, Freesound CC-BY)를 쓸 때**: 게임 내 크레딧 화면과 저장소의 CREDITS 파일을 함께 관리해야 한다.
- **ユーフルカ의 "RPGmaker" 전용 파일**은 AGM 게임에 쓰지 않는 것이 안전하다. 규약이 "RPG Maker로 만든 게임"만 명시하기 때문이다.
- **AI 학습 금지 조항**(마왕혼, 効果音ラボ, OpenTracks, Sonniss)은 게임 제작 자체와는 무관하다. 다만 음원으로 AI 리믹스를 만드는 등의 2차 활용은 피해야 한다.

### Gaps
- **くらげ工匠**: 두 번 검색했지만 사이트 존재와 약관을 확인하지 못했다. 이름 오기이거나 소규모 사이트일 수 있으며, 리스트에서 보류해야 한다.
- **Senses Circuit**: 상업 이용 조건(유료 라이선스 가격 등)과 게임 이용 조항은 약관 페이지가 403이라 확인하지 못했다.
- **Pixabay 음악**: Content ID 관련 문제와 게임 이용 조항은 요약 페이지에 없다. 전문(Content License)을 확인해야 한다.
- **ChipTone, jsfxr**: 출력물 라이선스의 1차 출처를 찾지 못했다.
- **itch.io 오디오 팩**: 팩마다 라이선스가 달라 개별 확인이 필요하다(이번에는 조사하지 않음).
- **AGM PCK 암호화**: AGM이 Godot의 PCK 암호화(커스텀 export template 필요)를 지원하는지 확인하지 못했다.
- **GGG Products Terms와 rpgmakerweb EULA의 우선순위**: 확인하지 못했다.

---

## Q2. RPG Maker MZ/MV 플러그인 생태계: 라이선스와 비용

### Takeaway
VisuStella MZ는 상업 이용이 가능하다. 하지만 **재배포가 금지**되고, 유료 플러그인은 팀원 각자가 구매해야 하므로 공개 GPL 저장소와 맞지 않는다. 반대로 트리아콘탄(triacontane)의 플러그인과 Community Lighting은 **MIT**라서 공개 저장소에 포함하거나 참고하기 쉽다. MZ에는 공식 무료 "ARPG plug-in set" DLC도 있다.

### Cited Findings
- **VisuStella MZ 이용약관**
  - 제1조: 정식 경로로 입수하면 무료·상업 게임 모두에 쓸 수 있다.
  - 제2조: 크레딧이 필수다(코더 개별 표기 또는 "VisuStella" 일괄 표기).
  - 제3조: 코드 수정은 허용되지만 자기 것이라고 주장하면 안 된다.
  - 제4조: **"You may NOT redistribute these plugins nor take code from this plugin to use as your own."**
  - 제7조: 유료 플러그인은 "all project team members must purchase their own individual copies".
  - — [VisuStella MZ Terms of Use](https://yanfly.moe/wiki/Template:VisuStella_MZ_Terms_of_Use)
- 학습용 "게임 템플릿"은 게임 프로젝트로 인정되지 않으므로 VisuStella 플러그인을 넣어 재배포할 수 없다. — [VisuStella ToU 해설 (검색 경유)](https://www.yanfly.moe/wiki/VisuStella_MZ_Terms_of_Use_Article_4)
- VisuStella 개별 툴 중 최소 $15 USD에 판매되는 사례가 있다(가격은 변동될 수 있음). Wave 단위 Access Key 번들도 판매된다. — [visustellamz.itch.io (검색 결과)](https://visustellamz.itch.io/item-crafting-system), [Wave 2 Bundle](https://visustellamz.itch.io/wave-2-bundle)
- **트리아콘탄 플러그인**: 본인이 작성한 플러그인은 MIT이며 상업·비상업 모두 신고 없이 쓸 수 있다. 다른 사람이 만든 것을 수정해 재배포한 플러그인은 원작자의 약관을 따른다. MV 플러그인은 `master`, MZ 플러그인은 `mz_master` 브랜치에 있다. — [triacontane/RPGMakerMV](https://github.com/triacontane/RPGMakerMV)
  - 개별 파일 헤더에서 직접 확인한 내용: `PictureCallCommon.js`(ピクチャのボタン化, MZ·MV), `MessageWindowPopup.js`(Balloon Window, MZ v1.2.1 2022/06/12), `SceneCustomMenu.js`(カスタムメニュー作成, MZ) 모두 "This software is released under the MIT License." — [raw: mz_master/PictureCallCommon.js](https://raw.githubusercontent.com/triacontane/RPGMakerMV/mz_master/PictureCallCommon.js), [raw: MessageWindowPopup.js](https://raw.githubusercontent.com/triacontane/RPGMakerMV/mz_master/MessageWindowPopup.js)
  - `StandPictureEC.js`는 이 저장소의 mz_master에서 찾지 못했다. 다른 작가의 플러그인일 가능성이 있다.
- **Community Lighting (MV/MZ)**: MIT 라이선스이고, 저작권자는 "Terrax, ImaginaryVillain, Aesica, Eliaquim, Alexandre, Nekohime1989"다. Terrax Lighting 문법을 옵션으로 지원한다. 광원 개수 제한(Terrax는 4개)이 없다. — [community_lights LICENSE](https://raw.githubusercontent.com/ImaginaryVillain/community_lights/master/LICENSE), [GitHub](https://github.com/ImaginaryVillain/community_lights)
- **공식 "RPG Maker MZ - ARPG plug-in set"**: Steam 무료 DLC로, RPG Maker Festival 2023 기념으로 배포됐다. ARPG 플러그인과 그래픽 에셋이 들어 있다. 라이선스 세부는 이번에 확인하지 못했다. — [Steam app 2287820](https://store.steampowered.com/app/2287820)
- **RPG Maker 공식 가이드라인**: 개별 플러그인 파일 안의 라이선스 표기가 일반 약관보다 우선한다("the license notice for each individual plugin takes precedence"). — [GUILD: Official plugins – terms of use?](https://guild.rpgmakerofficial.com/t/topic/2049?tl=en)
- **NW.js 창 API (MV/MZ 데스크톱 런타임)**: `nw.Window.get()`, `win.moveTo(x,y)`, `win.moveBy`, `win.resizeTo(w,h)`, `win.resizeBy`, `win.title`, `win.setAlwaysOnTop(true)`, `win.enterFullscreen()`. — [NW.js Window API](https://docs.nwjs.io/References/Window/)

### Inferences
- **MZ/MV 메타픽션의 일반 구현 방식**: 데스크톱 MV/MZ 게임은 NW.js 위에서 돌기 때문에 플러그인 JS에서 NW.js 창 API(위)와 Node 모듈(`fs`, `os` 등)을 호출해 창 이동·크기 변경·파일 입출력을 구현하는 것이 일반적이다. 다만 Node 모듈 접근을 1차 문서로 확인하지는 못했다(Gaps).
- **GPL 저장소에 RPG Maker 쪽 코드를 참고하거나 포팅할 때**: MIT(트리아콘탄, Community Lighting)는 출처와 저작권 고지를 남기면 문제없다. VisuStella 코드는 **복사·이식 금지**(제4조)이므로 메커니즘을 처음부터 다시 구현해야 한다.
- **AGM은 RPG Maker JS 플러그인을 쓸 수 없다**: 엔진 자체가 다르다. RPG Maker 생태계는 구현 아이디어와 UX 레퍼런스로만 활용 가치가 있다.

### Gaps
- Yanfly(MV 레거시), Galv, SRD, Moghunter(Chrono Engine 포함), Ultra Mode 7, Alpha ABS Z, Quasi ABS의 현재 약관과 가격은 이번 세션에서 1차 확인하지 못했다.
- "ARPG_Core"(うなぎおおとろ 등) 플러그인의 존재와 라이선스를 확인하지 못했다. 검색 결과에는 공식 ARPG plug-in set만 나왔다.
- MZ가 NW.js에서 Node `require('fs')`/`require('os')`에 접근할 수 있다는 점은 1차 문서로 인용하지 못했다.
- StandPictureEC, 일반 "Tachie" 플러그인의 작가와 라이선스를 확인하지 못했다.

---

## Q3. ACTION GAME MAKER(AGM)의 확장성: GDScript, Godot 애드온, 비주얼 스크립트, 저장/대화 시스템

### Takeaway
AGM은 Godot 기반 Maker 툴이다(2025-06-16 Steam 출시, $99.99). **1.4.0(2026-08-31 패치노트)에서 엔진 베이스가 Godot 4.4에서 4.7로 올라갔다.** GDScript를 쓰는 공식 확장 경로는 세 가지다.
- (1) InvokeScript / ScriptConditionEvaluator: 게임 오브젝트 아래 Node2D에 GDScript를 붙여 액션이나 조건으로 호출한다.
- (2) 1.3.0의 **Custom Action Plugin**: `.gd` 파일을 프로젝트에 넣으면 자동 등록된다.
- (3) 플러그인에서 "Godot Engine 기본 기능"을 쓸 수 있다.

반면 GDScript에서 AGM 내장 액션을 직접 호출하는 기능은 로드맵에 없다(2026-02). Godot Asset Library나 애드온 호환성에 대한 공식 문서도 찾지 못했다. 저장/로드는 공식 액션으로 있지만, 대화 시스템과 스탠딩 일러스트(입식) 관련 공식 문서는 확인하지 못했다.

### Cited Findings
- **제품 개요 (Steam)**
  - 출시 2025-06-16, 개발·배급 Gotcha Gotcha Games, 가격 $99.99, 무료 데모 제공.
  - 상태를 박스로 놓고 화살표로 전이를 연결하는 비주얼 스크립팅 방식이다.
  - "Godot Engine 4.7.0 기반"이며 GDScript로 커스텀 Action/Condition을 작성할 수 있다.
  - 내보내기 대상은 Windows, macOS, Linux, Web, Android, iOS다.
  - 데이터베이스, 저장/로드, 탄막 도구, 로컬 멀티 8인, 2.5D(3D 배경)를 지원하고 내장 에셋이 1,000종 이상이다.
  - 로열티는 없다. 조회 시점 리뷰는 Mixed(72개 중 63% 긍정)다.
  - — [Steam: ACTION GAME MAKER](https://store.steampowered.com/app/2987180/ACTION_GAME_MAKER/)
- Godot 공식 쇼케이스 페이지는 AGM을 "Built using Godot Engine"으로 소개한다. Pixel Game Maker MV의 노드 기반 비주얼 스크립트를 계승했고 "RPG Maker의 이벤트 커맨드" 같은 Action을 연결하는 방식이라고 설명한다. — [Godot Showcase: ACTION GAME MAKER](https://godotengine.org/showcase/action-game-maker/)
- **GDScript 첨부 (InvokeScript / ScriptConditionEvaluator)**
  - 게임 오브젝트의 자식으로 Node2D를 만들고 GDScript를 붙인다. 그 스크립트의 메서드를 액션(InvokeScript)이나 전이 조건(ScriptConditionEvaluator)으로 호출한다.
  - 실행 타이밍은 OnStateEnter, OnStateUpdate(매 프레임이라 비용이 큼), OnStateExit 중에서 고른다.
  - 예제는 플레이어와의 X 거리 100px 판정으로 낙하 함정을 만드는 것이다.
  - 2025-10-30, 작성자 Moonling.
  - — [GUILD 매뉴얼: InvokeScript/ScriptConditionEvaluator](https://guild.rpgmakerofficial.com/t/topic/958)
- **Custom Action Plugin (1.3.0, 2026-06-17)**: GDScript로 커스텀 액션과 조건을 만들어 비주얼 스크립트 에디터에서 쓸 수 있다. 공식 플러그인 6종이 함께 나왔다(이동 방향 자동 회전, 사인 곡선 이동, RigidBody 밀기, 광량 조건, 변수 범위 조건, 두 변수 연산 조건). 3D 배경 기능과 Shader & HDR 샘플도 이때 추가됐다. — [AGM 1.3.0 패치노트](https://guild.rpgmakerofficial.com/t/topic/1776?tl=en)
- **Custom Action Plugin 매뉴얼**
  - 파일 형식은 `@tool` + `class_name`을 가진 `.gd`이며 GDScript만 지원한다.
  - 액션은 `AGMPluginAction`, 조건은 `AGMPluginCondition`을 상속한다. 콜백은 다음과 같다:
    - 액션: `on_state_enter(p_owner)`, `on_state_update(p_owner, p_delta)`, `on_state_exit(p_owner)`
    - 조건: `on_judge_condition(p_owner, p_delta_time) -> bool`
    - 메타데이터: `get_plugin_tab_name()`, `get_group_name()`, `get_description()`
  - owner 객체는 `GameObject`(CharacterBody2D 기반) 또는 `Area2DGameObject`다.
  - 파라미터는 `@export`로 노출한다.
  - 이동 액션은 `is_release_move_control = true`로 내장 이동을 끄고 써야 한다.
  - 파일을 프로젝트 아무 곳에 두면 자동으로 로드된다. 업데이트할 때는 파일을 교체해야 하며, 복사본이 남으면 class_name 충돌이 난다.
  - "Godot Engine の基本機能を利用できます"라고 명시돼 있다. 공식 배포 규칙이나 라이선스 표기는 없다.
  - — [GUILD 매뉴얼: カスタムアクションプラグイン](https://guild.rpgmakerofficial.com/t/topic/1503)
- **로드맵**
  - 2026-02-19 질의응답(GDScript에서 AGM 실행 액션에 접근할 수 있느냐)에 대한 답변: "로드맵에 없으나 불가능하다는 뜻은 아님". 같은 글에서 오브젝트 풀링, Godot 4.6 업데이트, Linux/Mac 버전 지연이 언급됐다. — [GUILD topic 1162](https://guild.rpgmakerofficial.com/t/topic/1162?tl=en)
  - ⚠ 답변자 Baz의 역할은 출처마다 다르다. 이 글 요약에서는 팀원처럼 보이지만, topic 1316 요약에서는 "community member"로 분류된다.
- **프로듀서 레터 #19 (2026-06-17)**: Godot 4.4→4.6.3 업데이트(노드 UID, 새 UI)를 가을에 하겠다는 계획을 밝혔다. Ver.2.0에서는 "Godot UI를 바꾸지 않는다"는 기존 방침을 철회하고 UX를 개선하겠다고 했다. 표준 UI와 새 UI는 전환할 수 있게 하고, 단점으로 사용 가능한 기능 제한과 Godot 업데이트 추종의 어려움을 꼽았다. — [프로듀서 레터 #19](https://guild.rpgmakerofficial.com/t/topic/1778)
- **1.4.0 패치노트 (2026-08-31)**: Godot 베이스를 **4.4에서 4.7로** 업그레이드했다. 처리 구조를 "processor-based model"로 전면 변경해 대형 비주얼 스크립트의 성능 문제를 해결했다. 노드 UID 지원은 아직 구현되지 않았다. 문제가 생기면 Steam 베타에서 1.3.5로 롤백할 수 있다. — [AGM 1.4.0 패치노트](https://guild.rpgmakerofficial.com/t/topic/2751?tl=en)
  - ⚠ 레터는 4.6.3을 예고했는데 실제 1.4.0은 4.7이다. Steam 페이지도 4.7.0으로 표기한다.
- **저장/로드 (공식 매뉴얼)**
  - 런타임 액션 `SaveGameData` / `LoadGameData`를 쓴다.
  - 오브젝트 위치와 상태는 GameObject의 `is_savable`, 변수와 스위치는 VariableSettings/SwitchSettings의 `is_savable`로 저장 대상을 정한다. 플래그가 없는 변수는 로드할 때 초기값으로 돌아간다.
  - 세이브 슬롯은 액션 옵션으로 지정하며, 슬롯 번호 자체도 DB 변수로 저장된다.
  - 체크포인트 퀵 리스타트 예제가 있다.
  - — [GUILD 매뉴얼: Saving and Loading](https://guild.rpgmakerofficial.com/t/topic/1248?tl=en)
- **약관**
  - Godot Engine에는 GGG 약관이 적용되지 않고 MIT가 적용된다.
  - 법인의 비즈니스·상업 이용은 이 약관 적용 대상이 아니다(개인 상업 이용은 가능).
  - 사용자 소프트웨어에서 GGG의 프로그램이나 소재를 추출해 배포하는 것은 금지된다.
  - 오프닝 크레딧에 GGG 로고와 지정 표기를 가능한 한 넣고, 동봉 문서에 "GGG 제품으로 제작"했다고 명시해야 한다. AGM 표기는 "©2025 Gotcha Gotcha Games Inc."다.
  - — [GGG Products Terms](https://rpgmakerofficial.com/en/?p=1248)

### Inferences
- **확장 가능성 평가**: 플러그인 매뉴얼이 "Godot 기본 기능 이용 가능"이라고 하고, InvokeScript가 일반 GDScript Node2D를 호출한다. 그러므로 `DisplayServer`, `FileAccess`, `OS` 같은 Godot 코어 싱글턴을 AGM 게임 안에서 호출하는 것은 **기술적으로 가능할 가능성이 높다**. 다만 이것을 명시한 공식 문서는 없으므로, 프로토타입으로 반드시 검증해야 한다.
- **Godot 애드온(`addons/` + EditorPlugin) 사용**: AGM이 Godot 에디터를 커스텀한 빌드이므로 이론적으로 가능할 수 있다. 하지만 공식 지원 표명이 없다. Ver.2.0의 UI 변경 이후에는 호환성이 줄어들 수 있다(레터에 "사용 가능한 기능 제한" 언급). 런타임 GDScript 라이브러리(대화 엔진 코어 등)가 에디터 플러그인보다 이식 위험이 낮다.
- **대화·입식·분기·변수·컷신**
  - 변수와 스위치는 AGM DB 기능으로 확인됐다.
  - 대화창, 입식, 분기 선택지, 컷신 타임라인은 다음 중 하나로 만들어야 할 가능성이 높다: (a) AGM 기본 UI와 오브젝트 상태머신 조합, (b) InvokeScript로 GDScript 대화 엔진(Dialogic 등) 호출, (c) Godot `AnimationPlayer` 기반 컷신.
  - 컷신 타임라인 공식 기능은 확인하지 못했다.
- **GPL-3.0 저장소와의 충돌 가능성**
  - AGM 런타임은 GGG의 독점 "Our Program"이고, 추출·배포가 금지된다.
  - 프로젝트 폴더에 AGM이 생성하거나 복사한 스크립트·노드·샘플 에셋이 섞이면 공개 저장소에 올리는 것이 약관 위반이 될 수 있다.
  - 자기 코드를 GPL로 내는 것은 저작권자 본인이 결정할 수 있다. 하지만 **제3자 GPLv3 코드(예: godotshaders의 GPLv3 셰이더)를 독점 AGM 런타임과 결합해 배포하는 것은 GPL 조건과 충돌할 소지가 있다**. 제3자 코드는 MIT나 CC0을 우선 고르는 것이 안전하다.
- **1.4.0의 대규모 구조 변경과 Ver.2.0 UI 개편 예고**를 고려하면, 프로젝트 초기에 AGM 버전을 고정하고(Steam 베타 브랜치) 업그레이드 전에 백업하는 정책이 필요하다.

### Gaps
- AGM 공식 대화/메시지 창, 입식, 선택지 분기, 컷신 타임라인 기능의 매뉴얼 문서를 찾지 못했다.
- Godot Asset Library와 `addons/` 에디터 플러그인, GDExtension(LimboAI 등)의 AGM 호환성에 대한 공식·커뮤니티 검증 사례를 찾지 못했다.
- AGM이 C#/.NET을 지원하는지 확인하지 못했다(지원하지 않으면 Yarn Spinner C#판과 godot-ink는 쓸 수 없다).
- AGM 공식 Discord나 템플릿 저장소의 존재는 확인하지 못했다. GUILD 포럼(guild.rpgmakerofficial.com)에 모듈·플러그인 공유 카테고리가 있다는 언급만 있다(매뉴얼 1503).
- AGM 프로젝트 폴더에 어떤 GGG 독점 파일이 포함되는지(공개 저장소에 올릴 수 있는 범위)는 확인하지 못했다.
- AGM의 PCK 암호화 지원과 커스텀 export template 지원 여부를 확인하지 못했다.

---

## Q4. AGM에서 재사용할 수 있는 Godot 측 리소스와 라이선스

### Takeaway
주요 Godot 4 애드온(Dialogic 2, inkgd, Phantom Camera, SmartShape2D, Beehave, LimboAI)은 모두 **MIT**라서 GPL-3.0 저장소에 포함해도 라이선스 충돌이 없다. 다만 **C# 전용 애드온(Yarn Spinner for Godot C#판, godot-ink)은 .NET판 Godot이 필요**해 AGM에서는 쓰기 어려울 것으로 보인다. LimboAI는 GDExtension 또는 모듈 방식이라 AGM 커스텀 빌드와의 호환성이 불확실하다. godotshaders.com은 셰이더마다 CC0, MIT, GPLv3 중 하나다.

### Cited Findings
- **Dialogic 2**: MIT("Copyright (c) 2020 - present Emilio Coppola"). README에 "Dialogic 2 **requires at least Godot 4.5**"라고 되어 있다. 알파·베타 단계라 버전 간 API가 바뀔 수 있다고 경고한다. 예제 폰트(Roboto)는 Apache 2.0이다. — [dialogic LICENSE](https://raw.githubusercontent.com/dialogic-godot/dialogic/main/LICENSE), [README](https://github.com/dialogic-godot/dialogic)
- **Yarn Spinner for Godot**: MIT로 표기되어 있다. "Godot Engine 4.x (C#)" 통합이고, GDScript 사용자에게는 별도 프로젝트 "Yarn Spinner for Godot (GDScript)"를 안내한다. — [YarnSpinner-Godot GitHub](https://github.com/YarnSpinnerTool/YarnSpinner-Godot)
- **godot-ink**: MIT(Copyright 2018-2024 Paul Joannon). 설치 안내가 ".NET installation"과 C# 솔루션을 전제로 한다. — [godot-ink LICENSE](https://raw.githubusercontent.com/paulloz/godot-ink/main/LICENSE), [README](https://github.com/paulloz/godot-ink)
- **inkgd** (순수 GDScript ink 런타임): MIT(inkle Ltd. + Paul Joannon). "inkgd is compatible with Godot 4.2+, but has no official releases yet", 즉 `godot4` 브랜치를 써야 한다. — [inkgd LICENSE](https://raw.githubusercontent.com/ephread/inkgd/main/LICENSE), [README](https://github.com/ephread/inkgd)
- **Phantom Camera**: MIT(© 2022 Marcus Skov). — [phantom-camera LICENSE](https://raw.githubusercontent.com/ramokz/phantom-camera/main/LICENSE)
- **SmartShape2D**: MIT(© 2018 Robert Morse). — [SmartShape2D LICENSE](https://raw.githubusercontent.com/SirRamEsq/SmartShape2D/master/LICENSE)
- **Beehave** (행동 트리): MIT(© 2023 bitbrain). — [beehave LICENSE](https://raw.githubusercontent.com/bitbrain/beehave/godot-4.x/LICENSE)
- **LimboAI** (행동 트리 + 상태 머신): MIT 문구(© 2023-2025 Serhii Snitsaruk and contributors). 버전 대응표: 1.8.x는 GDExtension으로 Godot 4.6 이상, 모듈로 Godot 4.7. 1.7.x는 GDExtension 4.6 이상, 모듈 4.6. — [limboai LICENSE.md](https://raw.githubusercontent.com/limbonaut/limboai/master/LICENSE.md), [README](https://github.com/limbonaut/limboai)
- **godotshaders.com**: 게시자가 CC0, MIT, GNU GPL v3 중 하나를 고른다. "Anyone will be able to use the shaders posted to the site freely, both in personal and commercial products." 라이선스는 코드에만 적용되고 미리보기 이미지와 에셋에는 적용되지 않는다. — [godotshaders.com/license](https://godotshaders.com/license/)
- **Godot Engine 자체**: MIT이며 GGG 약관 적용 대상이 아니다. — [GGG Products Terms](https://rpgmakerofficial.com/en/?p=1248)

### Inferences
- **우선순위 (AGM 1.4 = Godot 4.7 기준)**
  - 순수 GDScript 런타임: Dialogic 2(4.5 이상 요구 → 4.7이면 충족), inkgd(`godot4` 브랜치), Beehave. 이들이 AGM에서 작동할 가능성이 가장 높다.
  - Phantom Camera와 SmartShape2D는 에디터 플러그인 의존도가 높아 AGM 자체 카메라·타일 시스템과 충돌할 수 있다. 검증 전까지는 보조 후보로 둔다.
- **대화 엔진 선택 기준**
  - 분기·변수 중심의 내러티브(미스터리, 멀티엔딩)라면 ink(inkgd)나 Dialogic 2가 맞다.
  - Dialogic 2는 입식(Portrait), 타임라인, 선택지 UI를 포함하므로 RPG Maker식 "입식+메시지" 연출을 재현하기 쉽다. 단 알파·베타 API 변동 위험이 있다.
- **GPL 호환**: MIT는 GPL-3.0 저장소에 포함하거나 수정해서 넣을 수 있다(저작권·허가 고지 유지). godotshaders의 GPLv3 셰이더는 Q3에서 지적한 AGM 독점 런타임 결합 문제 때문에 피하고, CC0이나 MIT 셰이더를 고르는 것이 좋다.

### Gaps
- Godot Dialogue Manager(nathan-hoad)의 라이선스는 LICENSE 파일 경로를 찾지 못해 확인하지 못했다.
- Yarn Spinner GDScript판의 저장소, 라이선스, 성숙도를 확인하지 못했다.
- 위 애드온들을 AGM 안에서 실제로 구동한 사례를 찾지 못했다.
- 플랫포머 컨트롤러 템플릿(Godot Asset Library 등)의 라이선스는 이번에 조사하지 않았다. AGM은 자체 이동 상태머신을 제공하므로 우선순위가 낮다.

---

## Q5. 메타픽션 기법의 기술적 가능성 (Godot 기반 내보내기 게임), 선례, 윤리·플랫폼 한계

### Takeaway
Godot 4.7 API로 **창 크기·위치·제목 변경, 멀티 윈도우, 투명·항상 위 창, 네이티브 대화상자, 바탕화면 경로 조회와 파일 생성, 환경변수(사용자명) 읽기, 탐색기 열기, 의도적 크래시**까지 모두 구현할 수 있다. 단 **Linux Wayland에서는 창 위치 지정이 동작하지 않고(no-op)**, Web과 모바일, 샌드박스(macOS, itch 앱)에서는 상당수 기능이 막힌다.

선례(OneShot, DDLC, Undertale, Imscared)는 대부분 "실제 OS를 건드리는" 연출을 쓴다. 그러나 콘솔판(OneShot WME, DDLC Plus)은 **게임 안의 가상 데스크톱**으로 대체했다. 서명되지 않은 Godot exe는 백신 오탐이 잦으므로 코드 서명이 사실상 필수다.

### Cited Findings

#### A. Godot 4.7 API (공식 클래스 레퍼런스)

**창 조작 (DisplayServer)**
- `window_set_position(position: Vector2i, window_id=0)`: 멀티 모니터에서는 가상 데스크톱 좌표 기준이다. 문서 원문은 "**On Linux (Wayland): this method is a no-op.**"이다. — [DisplayServer.xml (godot master)](https://raw.githubusercontent.com/godotengine/godot/master/doc/classes/DisplayServer.xml), [DisplayServer 문서 4.7](https://docs.godotengine.org/en/stable/classes/class_displayserver.html)
- `window_set_size(size, window_id)`: 크기 변경. `window_set_title(title, window_id)`: 제목 변경. 제목은 매 프레임 바꾸지 말라는 경고가 있다(일부 창관리자에서 성능 문제). — [DisplayServer.xml](https://raw.githubusercontent.com/godotengine/godot/master/doc/classes/DisplayServer.xml)
- 창 플래그:
  - `WINDOW_FLAG_ALWAYS_ON_TOP`: Linux X11, macOS, Windows
  - `WINDOW_FLAG_BORDERLESS`: X11/Wayland, macOS, Windows
  - `WINDOW_FLAG_TRANSPARENT`: 드라이버·컴포지터에 따라 다름
  - `WINDOW_FLAG_MOUSE_PASSTHROUGH`
  - — [DisplayServer.xml](https://raw.githubusercontent.com/godotengine/godot/master/doc/classes/DisplayServer.xml)
- 기타 메서드: `screen_get_size`, `screen_get_usable_rect`, `get_screen_count`, `window_request_attention`, `window_move_to_foreground`, `dialog_show(title, description, buttons, callback)`(네이티브 대화상자, Windows와 macOS), `clipboard_set`, `tts_speak`, `create_status_indicator`(트레이 아이콘). — [DisplayServer 문서 4.7](https://docs.godotengine.org/en/stable/classes/class_displayserver.html)

**멀티 윈도우**
- `FEATURE_SUBWINDOWS`(창을 메인 창 밖으로 꺼낼 수 있음)는 Windows, macOS, Linux X11에서 지원된다. — [DisplayServer.xml](https://raw.githubusercontent.com/godotengine/godot/master/doc/classes/DisplayServer.xml)
- 프로젝트 설정 `display/window/subwindows/embed_subwindows=false`로 두면 "multi-window mode"가 되어 `Window` 노드가 별도 OS 창으로 뜬다. `Window`는 닫기 요청 시 자동으로 닫히지 않으므로 `close_requested` 시그널을 직접 처리해야 한다. — [ProjectSettings.xml](https://raw.githubusercontent.com/godotengine/godot/master/doc/classes/ProjectSettings.xml), [Window.xml](https://raw.githubusercontent.com/godotengine/godot/master/doc/classes/Window.xml)
- 투명 창을 쓰려면 `display/window/per_pixel_transparency/allowed`가 필요하다(성능 비용 있음). — [ProjectSettings.xml](https://raw.githubusercontent.com/godotengine/godot/master/doc/classes/ProjectSettings.xml)

**OS·파일 (OS 클래스)**
- `OS.get_environment(variable)`: 환경변수를 읽는다. 예를 들어 Windows `USERNAME`, Unix `USER`로 사용자명을 얻는다. Windows를 제외하면 대소문자를 구분하고, **macOS 앱은 셸 환경변수를 읽지 못한다**. — [OS 문서 4.7](https://docs.godotengine.org/en/stable/classes/class_os.html)
- `OS.get_system_dir(SYSTEM_DIR_DESKTOP / DOCUMENTS ...)`: Android, Linux, macOS, Windows에서 구현되어 있다. — [OS 문서](https://docs.godotengine.org/en/stable/classes/class_os.html)
- `OS.get_user_data_dir()`: `user://`의 절대경로다.
  - 기본 위치: Windows는 AppData\Roaming\Godot\app_userdata\<프로젝트>, macOS는 Application Support, Linux는 ~/.local/share/godot/app_userdata.
  - 모바일은 샌드박스, Web은 브라우저 가상 파일시스템이다.
  - `application/config/use_custom_user_dir`로 경로를 `<OS user data>/<프로젝트명>`으로 바꿀 수 있다(데스크톱만).
  - — [OS 문서](https://docs.godotengine.org/en/stable/classes/class_os.html), [ProjectSettings.xml](https://raw.githubusercontent.com/godotengine/godot/master/doc/classes/ProjectSettings.xml)
- `OS.shell_open(uri)`(폴더나 URL 열기), `OS.shell_show_in_file_manager(path)`(Windows와 macOS에서만 파일 선택 표시, 그 외에는 shell_open으로 대체). — [OS 문서](https://docs.godotengine.org/en/stable/classes/class_os.html)
- `OS.alert(text, title)`: 네이티브 모달창을 띄우고, 닫힐 때까지 엔진이 멈춘다. — [OS 문서](https://docs.godotengine.org/en/stable/classes/class_os.html)
- `OS.crash(message)`: 실제로 엔진을 크래시시킨다. 문서는 "크래시 핸들러 테스트 전용"이라고 명시하고, 대신 assert, push_error, alert를 권장한다. — [OS 문서](https://docs.godotengine.org/en/stable/classes/class_os.html)
- `OS.create_process`, `OS.execute`, `OS.kill`: 외부 프로세스를 실행하거나 종료한다. macOS 샌드박스에는 제한이 있다. `OS.is_sandboxed()`는 macOS와 Linux에서만 동작한다. `OS.get_unique_id()`는 Web에서 빈 문자열을 반환하고, 위조할 수 있다. — [OS 문서](https://docs.godotengine.org/en/stable/classes/class_os.html)

#### B. 선례

- **OneShot** (RPG Maker XP)
  - 창 모드에서 창 가장자리를 화면 밖으로 끌면 창 모양이 바뀌며 코드가 드러나는 퍼즐이 있다.
  - 탑 시퀀스 뒤에는 바탕화면 배경이 Niko와 다시 만나는 방법이 적힌 메모로 바뀐다.
  - 창을 직접 닫거나 종료 후 재실행하면 "Niko는 죽었고 당신이 죽였다"고 알리고 게임이 끝난다(제목의 유래).
  - Switch판 World Machine Edition은 실제 OS 대신 가상 데스크톱 "The World Machine"을 쓴다. 리뷰에서는 원작의 감각이 줄었다는 평가가 있다.
  - 개발자 Velasquez도 "maybe everyone doesn't want a video game uploading files to their computer and changing the wallpaper"라고 인정했다.
  - — [Wikipedia(미러): OneShot](https://www.wikiwand.com/en/articles/OneShot), [PC Gamer](https://www.pcgamer.com/oneshot-is-a-bizarre-adventure-game-full-of-fourth-wall-breaking-moments), [Cubed3 WME 리뷰](https://www.cubed3.com/games/reviews/nintendo-switch/oneshot-world-machine-edition), [Destructoid](https://www.destructoid.com/the-key-to-beating-oneshot-probably-wont-be-in-the-game/)
- **Doki Doki Literature Club** (Ren'Py)
  - 게임 폴더의 `characters/monika.chr` 파일을 지워야 엔딩으로 진행한다.
  - 커뮤니티 분석: 1부에서 다른 캐릭터 파일을 지우면 재생성된다. 게임은 파일의 존재 여부를 boolean 트리거로 확인할 뿐이다(공식 설명은 아님).
  - DDLC Plus(콘솔)는 게임 내 데스크톱의 Files 메뉴로 대체했다.
  - — [Steam 토론](https://steamcommunity.com/app/698780/discussions/0/1519260397786869182), [Twinfinite DDLC Plus 가이드](https://twinfinite.net/guides/ddlc-plus-delete-monika-character-file-console/)
- **Undertale** (GameMaker)
  - True Reset을 해도 undertale.ini의 대부분만 지워지고 일부 기록은 남는다. Genocide 이후 상태는 별도 파일에 저장되어 True Reset의 영향을 받지 않는다.
  - Steam 클라우드 세이브가 리셋을 방해한다는 보고가 있다.
  - — [Undertale Wiki: Reset](https://undertale.wiki/w/Reset), [Steam 토론](https://steamcommunity.com/app/391540/discussions/0/412446292765410030)
- **IMSCARED**: 게임이 바탕화면에 만든 폴더 안의 파일을 플레이어가 편집해야 진행된다. 일부 플레이어는 악성코드를 의심했다. itch.io 데스크톱 앱의 샌드박스 기능 때문에 폴더가 생성되지 않는 사례가 있었다. — [Wikiwand: IMSCARED](https://www.wikiwand.com/en/articles/IMSCARED), [Steam 토론](https://steamcommunity.com/app/429720/discussions/0/1642041106366701241)
- **Pony Island / Inscryption** (Daniel Mullins): Pony Island은 "게임 자체를 부수는" 메타 구성이다. Inscryption은 Ludum Dare 43 출품작에서 시작했고, 메타 서사(파운드 푸티지)를 핵심 카드 게임플레이와 밀착시킨다는 평가를 받는다. — [Game Developer: Inscryption 기원](https://www.gamedeveloper.com/design/how-game-jam-sacrifices-became-inscryption), [Game-Wisdom 분석](https://game-wisdom.com/analysis/inscryption), [Game Rant 인터뷰](https://gamerant.com/inscryption-interview-horror-genre-medium-blending-world-design/)

#### C. 플랫폼·백신 문제

- 서명되지 않은 Godot Windows exe는 Defender에 자주 탐지된다(예: Trojan:Script/Wacatac.B!ml). PCK 내장(embed)이 오탐을 유발한다는 보고가 있다. 가장 많이 권장되는 해결책은 signtool 코드 서명이고, 그다음이 PCK 분리와 Microsoft 오탐 신고다. Steam 배포본은 대체로 탐지되지 않는다는 사용자 보고가 있다. 출처는 대부분 포럼과 itch.io 댓글이다. — [Godot Forum: Antivirus detecting my game](https://forum.godotengine.org/t/antivirus-detecting-my-game-as-malware/132446), [Godot Forum: Viruses in my game](https://forum.godotengine.org/t/viruses-in-my-game/126589), [Godot Forum: 4.6.3 Defender](https://forum.godotengine.org/t/windows-defender-warns-me-that-the-godot-4-6-3-executable-is-dangerous/139517)

### Inferences

**기법별 구현 매핑 (AGM에서는 InvokeScript나 Custom Action Plugin으로 호출)**

| 메타 기법 | Godot API | 주의점 |
|---|---|---|
| 창 흔들기·이동 | `get_window().position` / `DisplayServer.window_set_position` | Wayland에서 no-op → 대체 연출(화면 내 셰이크) 필요 |
| 창 크기·제목 조작 | `window_set_size`, `window_set_title` | 제목은 초당 몇 회 이하로 |
| 두 번째 창 (속삭이는 창) | `Window` 노드 + embed_subwindows=false | X11/Win/mac만. close_requested 처리 |
| 가짜 시스템 메시지 | `OS.alert` 또는 `DisplayServer.dialog_show`, 또는 게임 내 가짜 OS 대화상자 | 네이티브 모달은 엔진 정지 → 연출 타이밍 주의 |
| 사용자명 부르기 | `OS.get_environment("USERNAME"/"USER")` | macOS에서 실패 가능 → 입력 이름으로 대체 |
| 바탕화면 파일 생성 | `OS.get_system_dir(SYSTEM_DIR_DESKTOP)` + `FileAccess` | 동의(옵트인) 필수. 원클릭 삭제 보장. Steam Deck과 샌드박스에서 실패 시 대체 |
| 세이브 조작 감지 | `user://` 세이브에 해시 저장 → 로드 시 대조 | AGM 내장 SaveGameData 파일 형식은 미확인 → 별도 메타 세이브 파일 권장 |
| 영구 기억 (Undertale식) | `user://meta.dat` 같은 별도 파일 | "완전 초기화" 메뉴를 제공해 접근성 확보 |
| 가짜 크래시 | 전체화면 가짜 오류 화면 + 창 제목 변경 | `OS.crash` 실사용은 크래시 리포터와 Steam 오류 보고를 오염시키므로 비권장 |
| 폴더 열어 보여주기 | `OS.shell_open(ProjectSettings.globalize_path("user://..."))` | |

**윤리·안전 가이드라인 (선례에서 도출)**
- (1) **사용자 파일은 절대 지우거나 수정하지 않는다.** 게임이 직접 만든 파일만 다룬다.
- (2) 실제 OS를 건드리는 연출은 옵션(기본 ON/OFF 선택)으로 두고, **가상 데스크톱 대체 모드**를 함께 만든다. 이는 OneShot WME와 DDLC Plus의 해법이고, 콘솔·Web·Steam Deck 대응에도 필요하다.
- (3) 크래시나 파일 손상을 흉내 내는 연출 전에는 "이것은 연출이다"라는 사전 경고나 옵션을 둔다.
- (4) 깜빡임과 창 흔들기에는 광과민성 옵션을 둔다.
- (5) 외부 프로세스 실행(`OS.execute` 등)은 백신 휴리스틱을 자극할 수 있으므로 쓰지 않는다.
- (6) Windows 배포 시 코드 서명을 한다.

**RPG Maker MZ/MV의 메타 구현**: NW.js 창 API(`nw.Window.get().moveTo/resizeTo/title`)로 같은 연출을 한다. OneShot은 RPG Maker XP(Ruby/RGSS) 기반으로 위 연출을 구현했다. 단 OneShot의 구체적인 구현 기술(커스텀 실행파일 등)은 이번에 확인하지 못했다.

### Gaps
- Steam 콘텐츠 정책과 Steamworks 규약 중 "사용자 시스템 변경, 바탕화면 파일 생성"에 관한 명문 조항을 확인하지 못했다.
- 메타 연출의 접근성 가이드라인(공식 문서나 연구)을 찾지 못했다.
- OneShot, DDLC, Inscryption 개발자의 포스트모템과 GDC 강연에서 메타 설계 원칙을 직접 인용하지 못했다(Inscryption 기원 기사만 확인).
- AGM 내보내기 빌드에서 위 Godot API가 실제로 작동하는지 검증하지 못했다.
- AGM의 SaveGameData 파일 위치와 형식(세이브 편집 감지 구현에 필요)을 확인하지 못했다.
- Steam Deck(Gamescope)에서 창 조작이 어떻게 동작하는지 확인하지 못했다.

---

## Q6. 변형 턴제·타이밍 시스템 레퍼런스와 플랫포머·액션 구조로의 번역

### Takeaway
OMORI의 감정 삼각(Happy > Angry > Sad > Happy, 3단계 중첩), Undertale의 "턴제 + 탄막 회피 방어", Paper Mario의 액션 커맨드(타이밍 입력으로 공격 증폭·방어 감쇠), Fear & Hunger의 부위 파괴(다리→넘어짐, 팔→공격 봉인, 머리→즉사·저명중)는 모두 **"상태 + 타이밍 판정"** 구조다. AGM의 상태머신과 변수 조건으로 플랫포머 안에 이식할 수 있다.

### Cited Findings
- **OMORI 감정 시스템**
  - Happy는 Angry에, Angry는 Sad에, Sad는 Happy에 강하다. 유리하면 추가 피해, 불리하면 피해가 감소한다.
  - 효과: Angry는 공격 상승·방어 하락, Sad는 방어 상승·속도 하락에 더해 Heart 피해 일부를 Juice로 전환, Happy는 행운·속도 상승·명중 하락.
  - 감정은 최대 3단계까지 중첩되며 단계마다 효과가 커진다.
  - 정확한 배율은 출처마다 다르다. 팬위키 표에는 Angry 130%/150%, Furious 200%/250% 등이 있으나 신뢰도가 낮다.
  - 예: Final Strike는 감정 단계에 따라 3×ATK−DEF에서 6×ATK−DEF로 커진다.
  - — [OMORI Wiki: Battle system](https://omori.wiki/Battle_system)(조회 시 522 오류, 검색 스니펫 기반), [Destructoid 리뷰](https://destructoid.com/?p=264658), [RPGFan 리뷰](https://www.rpgfan.com/review/omori/)
  - ⚠ shapes.inc 팬 페이지 중 "Angry has no triangle advantages"라는 서술은 다른 출처와 모순된다.
- **Fear & Hunger**
  - Steam 페이지는 "Turn-based Strategic Dismember Combat System"이라고 소개한다. 적과 아군 모두 팔다리를 잃을 수 있다.
  - 다리를 자르면 일부 적이 넘어져 머리가 노출되고, 팔을 자르면 일부 공격이 봉인된다. 머리는 즉사 부위지만 명중률이 낮다. 다리를 먼저 자르지 않으면 머리를 맞히기 어렵다는 것이 커뮤니티 평가다.
  - — [Steam: Fear & Hunger](https://store.steampowered.com/app/1002300/Fear__Hunger/), [Fear & Hunger wiki.gg](https://fearandhunger.wiki.gg/wiki/Fear_%26_Hunger), [TV Tropes](https://www.tvtropes.org/pmwiki/pmwiki.php/VideoGame/FearAndHunger), [RPGFan 리뷰](https://www.rpgfan.com/review/fear-hunger/)
- **Paper Mario 액션 커맨드**: Super Mario RPG의 timed hits를 재해석한 것이다. 공격 타이밍이 맞으면 추가 피해, 방어 타이밍이 맞으면 피해가 감소한다. — [Super Mario Wiki: Action Command](https://www.mariowiki.com/Action_Command), [Dampfkraft: Notes on Combat Systems in Paper Mario](https://www.dampfkraft.com/by-id/80029b7f), [ComicBook.com](https://comicbook.com/gaming/feature/the-30-year-old-rpg-mechanic-that-still-defines-the-best-games-today/)
- **Undertale**: 턴제에 탄막 회피와 대화(ACT) 선택지를 결합했다. 일부 강적의 공격은 사실상 bullet hell이다. 같은 출처는 최근 사례로 Sea of Stars와 Clair Obscur: Expedition 33의 타이밍 입력 확장도 언급한다. — [ComicBook.com](https://comicbook.com/gaming/feature/the-30-year-old-rpg-mechanic-that-still-defines-the-best-games-today/)
- **AGM 기능 근거**: 탄막(bullet-hell) 도구를 내장했고(Steam), 공식 플러그인에 "변수 범위" 조건과 "두 변수 연산" 조건이 있다(1.3.0). — [Steam](https://store.steampowered.com/app/2987180/ACTION_GAME_MAKER/), [1.3.0 패치노트](https://guild.rpgmakerofficial.com/t/topic/1776?tl=en)

### Inferences
**플랫포머·액션으로의 번역 설계안**

- **감정 상태 (OMORI → 플랫포머)**: 플레이어 상태머신에 Emotion 변수(Neutral, Happy 1~3, Sad 1~3, Angry 1~3)를 둔다.
  - Happy: 이동속도·점프 상승, 크리티컬(넉백) 확률 상승, 조준이 흔들림.
  - Sad: 피격 무적 시간 증가, 이동 감소, 피해 일부를 "기력"으로 전환.
  - Angry: 공격력 상승, 방어 하락, 공격 후딜레이 감소.
  - 적에게도 감정을 부여해 상성 배율을 적용한다. AGM 변수 조건과 공식 "변수 범위" 플러그인으로 전이 조건을 구현한다.
- **액션 커맨드 (Paper Mario → 액션)**: 공격 애니메이션의 특정 프레임 윈도우 안에 버튼을 다시 누르면 강화 공격, 피격 직전 윈도우 안에 방어 입력을 하면 "저스트 가드"(피해 감소와 반격)가 된다. 판정 윈도우는 상태 진입 후 경과 프레임을 커스텀 조건(`on_judge_condition`)으로 계산한다.
- **탄막 방어 페이즈 (Undertale → 보스전)**: 보스전을 "대화·행동 페이즈(정지, 선택지)"와 "회피 페이즈(제한된 박스 안 탄막)"로 나눈다. AGM의 탄막 도구와 장면 내 경계 오브젝트로 구현한다. 비폭력 해결(ACT)은 대화 선택과 변수로 처리하고, 멀티엔딩 플래그로 연결한다.
- **부위 파괴 (Fear & Hunger → 액션)**: 적을 여러 히트박스(다리, 팔, 머리)로 구성하고 부위별 HP를 변수로 둔다.
  - 다리 파괴: 적이 넘어지는 상태로 전이 → 머리 히트박스가 노출된다(높이 변경).
  - 팔 파괴: 특정 공격 상태로의 전이를 금지한다.
  - 머리 파괴: 즉사.
  - 플랫포머의 고저차(점프 공격만 머리에 닿음)와 자연스럽게 맞물린다.
- **시간 루프·NG+와 메타 결합**: Q5의 `user://` 영구 메타 파일에 루프 횟수와 선택 기록을 저장하고, 다음 루프의 대사와 상태를 분기한다. AGM의 `is_savable` 변수 세이브(일반 세이브)와 영구 메타 파일(리셋으로도 남는 기록)을 분리하는 것이 Undertale식 "기억하는 게임"의 핵심이다.

### Gaps
- OMORI의 정확한 감정 배율과 공식 수식을 1차 출처로 확인하지 못했다(위키 서버 522).
- OMORI가 RPG Maker MV로 제작되었다는 점, 그리고 OMORI·Fear & Hunger가 쓴 플러그인 구성은 이번 세션에서 인용하지 못했다.
- 시간 루프(예: 이 장르의 쯔꾸르 게임) 시스템 구현 레퍼런스는 이번 범위에서 조사하지 않았다.
- AGM 상태머신에서 프레임 단위 입력 윈도우 판정의 정밀도와 성능(OnStateUpdate 비용)을 검증하지 못했다.

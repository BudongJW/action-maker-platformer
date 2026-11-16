# 쯔꾸르(RPG Maker)·관련 인디 게임의 서사 설계 사례 연구 — 재사용 가능한 구조·모티프·기법 추출

> 조사일: 2026-11-16. 목적: 2D 플랫포머(ACTION GAME MAKER 예정)용 "스토리 자원" 확보.
> 표기 규칙: **[SPOILER]** = 핵심 반전 포함. "(추론)" = 출처 기반 사실이 아닌 분석가 해석.
> Steam 수치 출처: Steam Store API `appdetails`의 `recommendations.total`(=Steam 사용자 리뷰 수, 2026-11-16 조회)과 SteamSpy API(긍정/부정 표본, 소유자 추정 구간). **SteamSpy 값은 일부 타이틀에서 오래되었거나 0으로 나옴**(예: Look Outside는 Steam 14,489건 vs SteamSpy 표본 2,642건) → 긍정률은 참고치로만 사용.
> 각 게임의 Steam 링크는 `https://store.steampowered.com/app/<AppID>`, SteamSpy는 `https://steamspy.com/app/<AppID>` 형식.

---

## Q1. 사례 연구 A — 일본 무료 호러 고전 (2004–2013): 엔진·구조·기법

### Takeaway
일본 프리 호러 고전은 거의 모두 RPG Maker(2000/2003/XP/VX) 또는 WOLF RPG Editor로 만들어졌고, 공통 문법은 "닫힌 공간 + 퍼즐 게이트 + 추격자 + 조건부 멀티엔딩 + 마지막 반전"이다. 그래픽이 단순한 대신 정적·급작스러운 소리·예측 불가한 추격·즉사 함정으로 공포를 만들었으며, 실황 영상(니코니코·YouTube)이 확산 엔진이었다.

### Cited Findings

**① Yume Nikki (ゆめにっき, 2004)**
- 툴/개발: RPG Maker 2003, 익명 개발자 Kikiyama. 2004년 6월 프리웨어, 2007년까지 업데이트, 2018년 Steam 출시 — [Wikipedia: Yume Nikki](https://en.wikipedia.org/wiki/Yume_Nikki); [Wikipedia: List of RPG Maker games](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games)
- 구조: 대화·전투·플롯·게임오버가 없음. 주인공 Madotsuki의 꿈을 탐험하며 24개의 "이펙트"(외형/장비 변화)를 수집. **[SPOILER]** 엔딩은 Madotsuki가 아파트 발코니에서 뛰어내리는 장면 — [Wikipedia: Yume Nikki](https://en.wikipedia.org/wiki/Yume_Nikki)
- 영향: Yume 2kki, .flow 같은 팬게임과 OMORI, Undertale, Doki Doki Literature Club!에 영향. 워킹 시뮬레이터 장르의 선구자로 언급됨. 2018 3D 리부트 *Dream Diary*는 "mixed or average" — [Wikipedia: Yume Nikki](https://en.wikipedia.org/wiki/Yume_Nikki)
- Steam(무료, AppID 650700): SteamSpy 긍정 8,120 / 부정 509(≈94.1%), 소유자 50만–100만 추정 — [SteamSpy](https://steamspy.com/app/650700)
- 교훈(추론): **텍스트 없이 "수집 가능한 능력(이펙트)=해석의 조각"** 구조는 플랫포머의 능력 해금(메트로배니아)과 직결. 능력 하나하나가 심리적 상징이 되도록 설계 가능.

**② Ao Oni (青鬼)**
- 툴/개발: RPG Maker XP, noprops. 출시연도 출처 충돌: Wikipedia 본문은 2004년 첫 공개·2011년 최종판(그 사이 4개 버전, 플롯/맵/퍼즐이 크게 다름), RPG Maker 게임 목록은 2008년으로 기재 — [Wikipedia: Ao Oni](https://en.wikipedia.org/wiki/Ao_Oni); [List of RPG Maker games](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games)
- 기법: 괴물(아오오니)이 **무작위 시점과 스크립트 시점 양쪽**에서 추격 → 플레이어가 위협 시점을 예측할 수 없음 — [Wikipedia: Ao Oni](https://en.wikipedia.org/wiki/Ao_Oni)
- 확산: 니코니코·YouTube 관련 영상 2013년까지 5천만 뷰 이상, PewDiePie·Markiplier가 해외 확산. 라이트노벨·만화·애니·실사영화로 미디어믹스. "RPG Maker로 만든 가장 유명한 호러 게임"으로 기술 — [Wikipedia: Ao Oni](https://en.wikipedia.org/wiki/Ao_Oni)
- 2024 Steam 리마스터 *Aooni*(AppID 2934190, Steam 리뷰 956건) 및 3D 1인칭 스핀오프 *Absolute Fear -AOONI-*(2024, 145건) — [Steam: Aooni](https://store.steampowered.com/app/2934190); [Steam: Absolute Fear -AOONI-](https://store.steampowered.com/app/2889120)
- 교훈(추론): 플랫포머에서 **"언제 올지 모르는 추격자"**는 횡스크롤 도주 시퀀스(화면 밖에서 등장, 문/사다리 숨기)로 직접 이식 가능. 단 무작위성은 리트라이 피로를 낳으므로 체크포인트 설계가 필수.

**③ Ib (イヴ, 2012)**
- 툴/개발: kouri의 데뷔작. 원작 엔진 출처 충돌 — Ib 문서는 RPG Maker 2000, RPG Maker 게임 목록은 "2003, MV". 2012년 2월 프리웨어, 2014년 v1.07까지 업데이트. 2022 리메이크는 RPG Maker MV, Playism 퍼블리싱(유료) — [Wikipedia: Ib](https://en.wikipedia.org/wiki/Ib_(video_game)); [List of RPG Maker games](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games)
- 전제·시스템: 미술관 관람 후 그림 속 세계로 끌려간 소녀 Ib. **체력 = 장미 꽃잎**, 적은 싸우지 않고 회피. Garry·Mary와 동행. 멀티엔딩이며 Garry의 운명, Mary의 그림을 태우는지 여부가 결말을 바꿈 — [Wikipedia: Ib](https://en.wikipedia.org/wiki/Ib_(video_game))
- 공포 기법: 비평가들이 **정적(silence)과 급작스러운 소리**의 사용을 칭찬; Famitsu "귀엽지만 섬뜩함" — 同
- 반응: 원작은 일본에서 100만 다운로드 이상, 영문 번역 후 해외에서도 비슷한 규모로 보도. 스위치 리메이크 Metacritic 82. 마녀의 집·OMORI에 영향 — 同. Steam 리메이크(1901370): 리뷰 5,004건, SteamSpy 긍정률 ≈99.0%, 소유자 20만–50만 — [Steam](https://store.steampowered.com/app/1901370); [SteamSpy](https://steamspy.com/app/1901370)
- 교훈(추론): **HP를 서사적 오브젝트(장미)로 형상화** → 플랫포머에서 체력을 캐릭터가 지닌 상징물(꺼져가는 등불, 꽃, 녹음테이프)로 표현하면 UI가 곧 서사가 됨.

**④ The Witch's House (魔女の家, 2012)**
- 툴/개발: RPG Maker VX, Fummy. 2012-10-03 프리웨어. 2018 *MV* 리메이크(RPG Maker MV, 그래픽 전면 재작화·난이도 2종·신규 이벤트) — [Wikipedia: The Witch's House](https://en.wikipedia.org/wiki/The_Witch%27s_House)
- 구조: 숲 속 저택에 갇힌 13세 Viola, 검은 고양이가 세이브 포인트 겸 동반자. 함정·점프스케어. 여러 엔딩이 선택/행동으로 결정 — 同
- **[SPOILER]** 일부 엔딩에서 플레이어가 조종한 "Viola"는 사실 몸을 빼앗은 마녀 Ellen이며, 내내 쫓아온 "Ellen"이 진짜 Viola였음이 밝혀짐(신체 교환 반전). 고양이는 악마 — 同
- 반응: 2013년 말까지 20만 다운로드 이상. Ao Oni·Yume Nikki·Ib와 함께 RPG Maker 호러 대중화의 주역, Pocket Mirror·Cloé's Requiem에 영향 — 同. Steam *MV*(885810): 리뷰 3,783건, ≈95.6% — [Steam](https://store.steampowered.com/app/885810); [SteamSpy](https://steamspy.com/app/885810)
- 교훈(추론): **"플레이어 아바타의 정체 반전"**은 플레이 내내 쌓인 플레이어의 감정 이입(불쌍한 소녀)을 역이용. 플랫포머에서도 컨트롤하는 캐릭터=가해자 구조로 마지막에 의미를 뒤집을 수 있음.

**⑤ Mad Father (2012) / Misao**
- 툴/개발: WOLF RPG Editor, sen. 2012-12-10 원작, 2016-09-23 Steam(Playism), 2020-11-05 리메이크(PC/Switch) — [Wikipedia: Mad Father](https://en.wikipedia.org/wiki/Mad_Father)
- 구조: 북독일, 11세 Aya가 아버지의 인체실험을 파헤침. **엔딩 3종**: 선택에 따라 Aya가 인형이 되거나 탈출(진엔딩은 Maria를 돕는 경로) — 同
- **[SPOILER]** 아버지 Alfred가 Aya를 인형으로 만들려 했고 어머니 Monika를 죽였음. 리메이크 에필로그는 "Aya는 처음부터 어머니 쪽 악한 성향을 물려받았다"는 재해석을 추가 — 同
- 기법: QTE 도주, 방을 잠그는 퍼즐 게이트, **수집품으로 추가 장면 해금** — 同
- Misao: Mad Father 엔딩이 Misao 사건으로 이어짐 — [Wikipedia: Mad Father](https://en.wikipedia.org/wiki/Mad_Father). Steam *Misao - 2024 HD Remaster*(개발 sen) 리뷰 2,379건 — [Steam](https://store.steampowered.com/app/691450). WOLF RPG Editor 제작 목록에 Mad Father·Misao·Alice Mare·Mermaid Swamp 등이 포함 — [DSOGaming 검색 결과/ModDB 엔진 목록 스니펫](https://www.moddb.com/engines/wolf-rpg-editor/games)
- Mad Father Steam(483980): 리뷰 6,376건, ≈97.2%, 소유자 20만–50만 — [Steam](https://store.steampowered.com/app/483980); [SteamSpy](https://steamspy.com/app/483980)
- 교훈(추론): **수집품 → 추가 컷신 해금**은 플랫포머의 수집 요소(딸기·유물)를 "진실 조각"으로 쓰는 직계 선례. 리메이크에서 에필로그로 캐릭터 해석을 뒤집은 것은 "후속 회차/DLC로 진실을 덧칠하는" 운영 방식의 예.

**⑥ The Crooked Man (Strange Men 시리즈)**
- 개발 Uri Games, Steam 2018-01-16 출시(736570), 리뷰 1,229건 ≈92.5%. 전제: 새 집으로 이사한 David가 겪는 공포 — [Steam](https://store.steampowered.com/app/736570); [SteamSpy](https://steamspy.com/app/736570)
- 엔진: WOLF RPG Editor 목록 맥락에서 언급되나 1차 출처로 확정 못 함(→Gaps).

**⑦ Corpse Party (원작 1996)**
- 원작: 1996-04-22 PC-9801, Makoto Kedōin. RPG Maker 게임 목록은 **RPG Tsukūru Dante 98**(Kenix Soft)로 기재 — 과제 문서의 "RPG Maker 2000 원작"은 부정확. 이후 Team GrisGris가 *Blood Covered*(PC 2007–2011), PSP *Repeated Fear*(2010, 해외명 *Corpse Party*)로 리메이크 — [Wikipedia: Corpse Party](https://en.wikipedia.org/wiki/Corpse_Party); [List of RPG Maker games](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games)
- 전제·기법: 주술 의식으로 이계의 초등학교에 갇힌 학생들, 붉은 원피스 원혼. **더미헤드 마이크로 녹음한 3D 음향** 사용 — [Wikipedia: Corpse Party](https://en.wikipedia.org/wiki/Corpse_Party); [Steam](https://store.steampowered.com/app/251270)
- Steam: *Corpse Party*(251270) 1,276건 ≈88.9%, Metacritic 71; *Corpse Party (2021)*(1273260) 1,452건 ≈92.0% — [Steam](https://store.steampowered.com/app/251270); [Steam 2021](https://store.steampowered.com/app/1273260)
- 교훈(추론): **저해상도 그래픽을 바이노럴 사운드로 보완** — 2D 플랫포머에서도 헤드폰 전제 입체음향(좌우 패닝·거리감)은 저예산 대비 효과가 큼.

**⑧ Wadanohara / The Gray Garden / Alice Mare**
- Wadanohara and the Great Blue Sea(2013, Kaitei Shujin=Mogeko): Wikipedia RPG Maker 목록은 **RPG Maker 2000**으로 기재 — [List of RPG Maker games](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games). (다른 커뮤니티 자료와 충돌 가능성 → Gaps)
- Alice Mare: WOLF RPG Editor 제작 목록 스니펫에 포함 — [ModDB Wolf RPG Editor games](https://www.moddb.com/engines/wolf-rpg-editor/games)
- 세 작품 모두 Steam 미출시(검색 결과 없음).

**참고: WOLF RPG Editor 자체** — SmokingWOLF 제작, 공식 Ver1.00 2008-03-13(테스트판 0.70은 2007-08-28) — [ja.wikipedia: WOLF RPGエディター](https://ja.wikipedia.org/wiki/WOLF_RPGエディター). 2022년 11년 만의 메이저 업데이트 Ver3 — [AUTOMATON](https://automaton-media.com/en/news/20221122-16880/). (일부 영문 DB는 1998년으로 기재 → 충돌)

### Inferences
- 일본 프리 호러의 "탈출형 밀실 호러" 문법(갇힘→탐색→퍼즐 게이트→추격→진실 발견→멀티엔딩)은 엔진 제약(타일맵·이벤트 스크립트)에 최적화된 형식이며, **플랫포머에서는 "한 채의 저택/학교를 횡단면(단면도)으로 보여주는 수직 맵"**으로 번역하기 좋음.
- 반복되는 반전 유형: (a) 아바타 정체 반전(마녀의 집), (b) 보호자=가해자(Mad Father), (c) 동행자의 정체(Ib의 Mary). 모두 "플레이어가 신뢰한 대상"을 뒤집는 구조.
- 확산 측면에서 짧은 플레이타임(1–3시간)·실황 친화성·여러 엔딩(재실황 동기)이 바이럴의 조건이었음(Ao Oni 5천만 뷰, Ib 100만 DL).

### Gaps
- The Crooked Man, The Gray Garden, Alice Mare의 엔진을 1차 출처(개발자 사이트)로 확정하지 못함. Wadanohara는 Wikipedia 목록상 RPG Maker 2000이나 WOLF RPG Editor로 알려진 자료도 있어 확인 필요.
- Ib의 원작 엔진(2000 vs 2003) Wikipedia 내부 충돌 미해결.
- Ib·마녀의 집 엔딩 수와 히든 호감도 변수의 정확한 조건은 Wikipedia에 없음(팬 위키 접근 실패).
- Corpse Party *Blood Covered*(2008)의 엔진 미확인.

---

## Q2. 사례 연구 B — 서구/Steam RPG Maker 히트작: 구조·기법·성과

### Takeaway
Steam 시대 RPG Maker 히트작은 "전투 최소화 서사(To the Moon)", "메타픽션(OneShot, OFF)", "영구적 희생 선택(LISA)", "감정/정신 시스템(OMORI, Fear & Hunger)", "시간 제한 생존(Termina, Look Outside)", "루프(In Stars and Time)"로 갈라지며, 대부분 **1인~소수 팀**이 만들었고 리뷰 수만~8만 건, 판매 100만 장급까지 도달했다. 다수가 게임잼/프리웨어 프로토타입에서 출발했다.

### Cited Findings

**① To the Moon (2011)** — RPG Maker XP(모바일/콘솔은 Unity), Freebird Games(Kan Gao). 두 의사가 죽어가는 노인 Johnny의 기억에 들어가 "달에 가고 싶다"는 소원을 기억 재구성으로 이뤄줌. **노년→유년 역순 진행**, "메멘토"가 기억을 연결. 농담 전투 1회 외 전투·인벤토리·파티 없음. Metacritic 81(PC). GameSpot 2011 "Best Story". 조부의 중병이 계기 — [Wikipedia: To the Moon](https://en.wikipedia.org/wiki/To_the_Moon_(video_game)). Steam(206440) 리뷰 70,521건, ≈95.9%, 소유자 200만–500만 추정 — [Steam](https://store.steampowered.com/app/206440); [SteamSpy](https://steamspy.com/app/206440)
- 교훈(추론): **역순 시간축**은 "왜?"를 먼저 보여주고 "원인"을 마지막에 주는 미스터리 엔진. 플랫포머 스테이지를 과거로 거슬러 올라가는 순서로 배치 가능.

**② OneShot (2014 프리웨어 → 2016 Steam)**
- 2014 프리웨어는 RPG Maker 2003으로 약 한 달 만에 제작(Indie Game Maker Contest 2014 출품, 무수상). 2016 Steam판은 RPG Maker XP, Future Cat(Eliza Velasquez, Nightmargin, Michael Shirt), 약 2.5년 개발. *World Machine Edition*(2022 콘솔, 2024 Steam)은 RPG Maker가 아닌 새 엔진으로 재구축 — [Wikipedia: OneShot](https://en.wikipedia.org/wiki/OneShot)
- 전제: 고양이 같은 아이 Niko가 전구 모양 태양을 탑에 올려 세계를 밝혀야 함. **플레이어는 Niko와 별개의 존재로, OS 사용자명으로 호명됨** — 同. Steam 소개문: "The world knows you exist." — [Steam](https://store.steampowered.com/app/420530)
- 메타 기법: 게임 창을 화면 밖으로 옮겨야 코드가 보이는 퍼즐, 바탕화면 변경, 파일 시스템 속 단서, 필름 현상 흉내, **Niko를 재우면 프로그램이 종료되고 재실행 시 꿈 장면**. 창 모드 권장. 콘솔판은 게임 내 가상 OS로 재현 — [Wikipedia: OneShot](https://en.wikipedia.org/wiki/OneShot)
- 엔딩: 주 엔딩 2개(태양을 탑에 놓기=Niko가 세계에 갇힘 / 태양 파괴=Niko 귀가). 클리어 후 **Documents 폴더의 메모가 'Solstice' 경로를 해금**(2017-03-28 추가) — **[SPOILER]** 세계가 'World Machine'이라는 시뮬레이션임을 드러내고 세계 복원 — 同
- 영향원: Metal Gear Solid의 Psycho Mantis, Irisu Syndrome, Imscared, Eternal Darkness — 同
- 반응: Metacritic PC 80 / Switch 92, 2017 Golden Joystick PC GOTY 후보 — 同. Steam(420530) 60,198건, ≈98.2%, 소유자 100만–200만; WME(2915460) 5,599건 — [Steam](https://store.steampowered.com/app/420530); [SteamSpy](https://steamspy.com/app/420530)
- 교훈(추론): "플레이어=별개의 인격"이라는 **2인칭 관계 설정**이 메타 연출의 정서적 기반. 단순 트릭이 아니라 "너와 Niko의 이별"이라는 감정으로 수렴.

**③ OFF (2008)** — RPG Maker 2003, Unproductive Fun Time(Martin "Mortis Ghost" Georis, Alias Conrad Coldwood, 벨기에). 2008 프랑스어 프리웨어 → 2011 팬 영역 → **2025-08-15 Fangamer 리메이크**(Windows/Switch, Toby Fox 포함 7인 작곡). The Batter가 세계를 "정화"하는 임무; **플레이어를 직접 호명**해 Batter의 행동에 공모시킴. **[SPOILER]** 엔딩: Judge 편(=Batter 처치) vs Batter 편(=Judge 처치, 스위치 내림) + 개그 엔딩. 2013 Tumblr 6번째로 많이 리블로그된 게임 — [Wikipedia: OFF](https://en.wikipedia.org/wiki/Off_(video_game)). Steam(3339880) 3,233건, Metacritic 83 — [Steam](https://store.steampowered.com/app/3339880)
- 교훈(추론): **"주인공 ≠ 플레이어, 마지막에 누구 편에 설지 고르게 함"**은 플랫포머의 최종 보스 선택(누구를 칠 것인가)으로 변환 가능.

**④ LISA: The Painful (2014)** — RPG Maker VX Ace, Dingaling(Austin Jorgensen 1인 각본·디자인·작화·작곡). Kickstarter 목표 $7,000 → $16,492(847명). **2D 횡스크롤 오버월드 + 턴제 전투**. 마약 'Joy'는 공격력↑, 미사용 시 금단. 동료 30명 영입 가능, Brad 외 전원 **영구 사망**. 선택에 따라 **Brad가 한 팔/양팔을 잃음**(스탯↓·금단↑). Metacritic 77. Kotaku Japan: 이겨도 절망감이 남는 드문 게임. 후속 DLC *The Joyful*(2015), Definitive Edition(2023) — [Wikipedia: LISA: The Painful](https://en.wikipedia.org/wiki/Lisa:_The_Painful). Steam(335670) 13,202건, ≈95.6%, 소유자 50만–100만 — [Steam](https://store.steampowered.com/app/335670); [SteamSpy](https://steamspy.com/app/335670)
- 비판: RPGFan "도덕적 선택이 플롯에 항상 유기적으로 통합되진 않음" — [Wikipedia](https://en.wikipedia.org/wiki/Lisa:_The_Painful)
- 교훈(추론): **횡스크롤 + 영구 손실 선택**은 플랫포머에 가장 직접적으로 이식 가능한 RPG Maker 계보. "능력(팔)을 잃는 대가로 동료를 살린다" 같은 선택은 조작감 자체를 바꿔 서사를 몸으로 느끼게 함.

**⑤ OMORI (2020)**
- RPG Maker(인포박스 MV; 개발 중 버전 변경, 목록상 "XP, MV"), OMOCAT LLC. Tumblr 웹코믹 *Omoriboy* 기원, 그래픽노블 구상에서 "플레이어가 선택할 수 있도록" 게임으로 전환. 2014 Kickstarter 하루 만에 달성, 약 6.5년 개발, 2020-12-25 출시 — [Wikipedia: OMORI](https://en.wikipedia.org/wiki/Omori_(video_game)); [List of RPG Maker games](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games)
- 감정 시스템: Neutral 기준, Angry(공↑방↓), Sad(방↑속↓, 피해 일부를 Juice로), Happy(운·속↑ 명중↓). **Happy > Angry > Sad > Happy 상성** + 고강도 단계 — [Wikipedia: OMORI](https://en.wikipedia.org/wiki/Omori_(video_game))
- 구조: 꿈의 세계 Headspace ↔ 현실 Faraway Town 이중 구조. 선택이 결말을 결정 — Kel을 무시하면 Sunny가 집에 머무는 경로로 가서 비극적 결말, Basil과 대면 여부 등으로 분기 — 同
- **[SPOILER]** Sunny가 바이올린 사건 끝에 누나 Mari를 계단에서 밀어 사망케 했고, Basil이 자살로 위장. 트라우마 억압을 위해 Headspace와 Omori를 만들어냄 — 同
- 공포 기법: 밝고 아이 같은 이미지 ↔ 글리치·흑백 공간의 대비, 여러 화풍이 섞인 몬스터 — 同
- 반응: Metacritic 87(Steam API 표기 88), 2021 IGF 2개 부문 Honorable Mention, 2022년 말 100만 장 돌파 — 同. Steam(1150690) 80,571건, ≈97.1%, 소유자 100만–200만 — [Steam](https://store.steampowered.com/app/1150690); [SteamSpy](https://steamspy.com/app/1150690)
- 교훈(추론): **"전투 버프/디버프 = 감정"**으로 정신 상태를 시스템화. 플랫포머에서 감정 상태가 이동 물리(점프 높이, 관성, 시야)를 바꾸게 하면 같은 원리.

**⑥ Fear & Hunger (2018) / Fear & Hunger 2: Termina (2022)**
- 둘 다 RPG Maker MV, Miro Haverinen(핀란드), Happy Paintings — [Wikipedia: Fear & Hunger](https://en.wikipedia.org/wiki/Fear_%26_Hunger)
- F&H1: 파티원이 영구 사망하거나 **사지를 잃음**, **체력·정신·허기** 3중 관리, 경험치 없음, **세이브에 위험이 따름**, 많은 결과가 **동전 던지기**. 엔딩 10개(A–E 6개 + 캐릭터별 S엔딩 4개, 하드모드 전용) — 同. Steam 소개: Silent Hill부터 Nethack까지 영향, 로그라이크 요소 — [Steam](https://store.steampowered.com/app/1002300)
- Termina: 1942년, 신 Rher가 강제한 14인 배틀로열 "Termina 축제". **3일 제한, 세이브할 때마다 시계가 진행**. 플레이어블 8명, 엔딩 A/B/C(변형 포함) — [Wikipedia](https://en.wikipedia.org/wiki/Fear_%26_Hunger); [Steam](https://store.steampowered.com/app/2171440)
- 반응: 분위기·난이도·서사 호평, 성폭력·아동 대상 폭력 묘사 등은 비판 — [Wikipedia](https://en.wikipedia.org/wiki/Fear_%26_Hunger). Steam 리뷰 F&H1 21,294건 / Termina 14,521건 — [Steam F&H](https://store.steampowered.com/app/1002300); [Steam Termina](https://store.steampowered.com/app/2171440)
- 교훈(추론): **"세이브 = 비용(시간 경과)"**은 플랫포머 체크포인트에 서사적 무게를 부여하는 강력한 장치. 정신 게이지가 낮을수록 환각 적·가짜 발판이 등장하는 식으로 응용 가능.

**⑦ Rakuen (2017)** — RPG Maker XP, Laura Shigihara. Steam 소개: 입원한 소년이 엄마와 판타지 세계를 여행하며 **다른 환자들의 사연을 "그 사람의 입장에서 걸어보며"** 마무리를 도움 — [Steam](https://store.steampowered.com/app/559210); [List of RPG Maker games](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games). Steam 4,707건, ≈96.3%, Metacritic 84 — [SteamSpy](https://steamspy.com/app/559210)
- 교훈(추론): **옴니버스형 "타인의 이야기" 스테이지** — 각 스테이지가 한 인물의 트라우마를 해소하는 단편.

**⑧ Hylics (2015) / Space Funeral (2010)** — Hylics: RPG Maker VX Ace, Mason Lindroth, Steam 8,510건 ≈98.1%; 소개문 "a recreational program with light JRPG elements" — [Steam](https://store.steampowered.com/app/397740); [List](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games). Space Funeral: RPG Maker 2003, thecatamites(2010), Steam 미출시 — [List](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games)
- 교훈(추론): 초현실·비정형 미술(점토, 엉성한 도트)도 **일관된 톤**이면 독자적 정체성이 됨 — 소규모 팀의 그래픽 한계를 스타일로 전환.

**⑨ Hello Charlotte (etherane; Steam판 EP2 2016-11-21, EP3 2018-01-04)** — RPG Maker(VX로 기재; VX Ace 여부는 출처 충돌), 에스토니아 1인 개발 에피소드 시리즈(EP1 최초 공개연도 미확인) — [TV Tropes 스니펫](https://www.tvtropes.org/pmwiki/pmwiki.php/VideoGame/HelloCharlotte); [itch.io](https://etherane.itch.io/hcep3). Steam EP2(557630) 770건, EP3(760890) 3,247건 ≈98% — [Steam EP3](https://store.steampowered.com/app/760890)

**⑩ Pocket Mirror (2016) → GoldenerTraum (2023)** — RPG Maker VX Ace → 리메이크 MZ, AstralShift/VisuStella. 마녀의 집에 영향받은 고딕 호러, "자기 발견의 여정" — [List](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games); [Wikipedia: Witch's House](https://en.wikipedia.org/wiki/The_Witch%27s_House); [Steam](https://store.steampowered.com/app/1899060). Steam 1,630건 ≈93.5%

**⑪ In Stars and Time (2023)** — RPG Maker MV, insertdisc5(Adrienne Bazir), Armor Games Studios. Siffrin이 House of Change에서 죽으면 전날로 돌아가는 **타임루프**. **파티는 매 루프 잊고 Siffrin만 기억**. 대화를 반복해 정답 선택지·아이템을 찾고, 층 스킵, 본 대사 빨리감기 지원. 파티가 잊는 것을 지켜보며 Siffrin의 정신이 무너짐 — 동료를 "대사를 반복하는 배우"로 보는 연극 은유, 짜증·피로·자기혐오·환각. **[SPOILER]** 왕을 쓰러뜨려도 루프는 계속되며, Siffrin이 "동료들과 계속 머물고 싶었다"는 소원을 인정하고 동료들도 같은 마음임을 고백해야 루프가 끝남. 개발자: 코로나 봉쇄의 영향, 반복은 의도적("예술은 때때로 나쁜 감정을 느끼게 해야 한다"), Stanley Parable에서 영감받아 반복을 깨는 순간을 삽입. Metacritic 85, IGF 2024 2개 부문 Honorable Mention — [Wikipedia: In Stars and Time](https://en.wikipedia.org/wiki/In_Stars_and_Time). Steam(1677310) 8,044건 ≈97.6% — [Steam](https://store.steampowered.com/app/1677310)
- 교훈(추론): 루프의 진짜 "잠금 해제 조건"을 **캐릭터의 심리적 수용**에 둠 → 기믹이 아니라 테마가 열쇠. 플랫포머에서 "마지막 보스를 이겨도 루프가 안 끝나는" 설계로 차용 가능.

**⑫ Look Outside (2025)** — RPG Maker(목록상 MV/MZ), Francis Coulombe(캐나다), Devolver Digital, 2025-03-21. **Hawktober Horrors 2024 게임잼(1개월) 출품작을 5개월 더 개발**. 바깥을 본 사람은 괴물이 되는 세계, 아파트에 고립된 Sam. **15일 제한**, 허기·위생 관리, 랜덤한 노크에 응답할지 선택, **적 살해·절도 시 죄책감**, 신규 구역 탐험 시에만 시간 경과, 내구도 무기, 아파트에서만 세이브(노멀). 적이 가까이 올수록 정체가 드러나는 거리 메커닉, 비유클리드 건축, **안전한 집 vs 위험한 바깥의 대비**. 엔딩은 타이머·Jasper에게 바치는 4개 공물 정답 수·Sybil/십자말풀이책/Visitor 관련 선택 등으로 다수. Sweet Home(1989)에서 영감. Metacritic 83 — [Wikipedia: Look Outside](https://en.wikipedia.org/wiki/Look_Outside); [List](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games)
- 판매: 2025년 10월 20만 장 — [Niche Gamer](https://nichegamer.com/look-outside-tops-200k-copies-sold); **2026-08-08 Devolver 발표 50만 장 돌파** — [電ファミニコゲーマー](https://news.denfaminicogamer.jp/news/260810g). 콘솔판 2026-10-30 — [Wikipedia](https://en.wikipedia.org/wiki/Look_Outside). Steam(3373660) 14,489건 — [Steam](https://store.steampowered.com/app/3373660)
- 교훈(추론): **"한 건물 + N일 제한 + 하나의 금기(바깥을 보지 마라)"**라는 하이 콘셉트 한 줄이 마케팅·설계 모두를 견인. 플랫포머에도 "금기 하나"(예: 뒤돌아보지 마라 → 반대 방향 입력 금지)를 규칙으로 걸 수 있음.

**⑬ 기타 RPG Maker 상업 성공작(2015–2025)**
- *Angels of Death*(2015, VX Ace, Hoshikuzu KRNKRN): 4개 에피소드 심리 호러, Steam 5,063건 ≈94.9% — [List](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games); [Steam](https://store.steampowered.com/app/537110)
- *Your Turn To Die*(2017, MV, Nankidai): "multi-ending horror adventure", 데스게임, Steam(2023) 4,241건 ≈98.6% — [List](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games); [Steam](https://store.steampowered.com/app/2067780)
- *The Coffin of Andy and Leyley*(2023, MV, Nemlei/Kit9 Studio): 남매가 사탄 의식 실패 후 식인을 하게 되는 "walk-n-talk" 어드벤처, Steam 37,405건 ≈96.0%, 소유자 100만–200만 추정 — [List](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games); [Steam](https://store.steampowered.com/app/2378900); [SteamSpy](https://steamspy.com/app/2378900)
- *Black Souls*(2016, VX Ace) Steam 출시 2025-08 7,872건 / *Black Souls II* 2025-11 5,860건 — [List](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games); [Steam](https://store.steampowered.com/app/3755860); [Steam II](https://store.steampowered.com/app/3855540)
- *Felvidek*(2024, Jozef Pavelka·Vlado Ganaj) Steam 5,729건 ≈98.6% — [Steam](https://store.steampowered.com/app/2299900)

### Inferences
- Steam 성공작의 공통분모: (1) 한 문장 하이 콘셉트, (2) 시스템이 테마를 체현(Joy 금단, 감정 상성, 세이브=시간, 죄책감), (3) 다회차 동기(엔딩 다수/숨은 경로), (4) 1인~소수 개발, (5) 프리웨어·게임잼 → 상업 확장 경로(OneShot, Look Outside, OFF).
- 정신 상태 시스템은 "수치 게이지형(F&H 정신, Look Outside 허기/위생/죄책감)"과 "서사 묘사형(In Stars and Time의 붕괴 연출)", "전투 상태형(OMORI 감정)"으로 3분됨.

### Gaps
- To the Moon, OneShot, F&H 1·2, LISA의 공식 판매량은 Wikipedia에 없음(SteamSpy 소유자 추정치만 확보).
- OMORI의 엔딩 개수·조건(Hikikomori/Faraway 루트 명칭 등)은 팬 위키 접근 실패(HTTP 402)로 Wikipedia 요약 수준만 확보.
- OMOCAT, Kan Gao, OneShot 팀의 GDC/포스트모템 원문 미확보.
- Hello Charlotte의 정확한 버전(VX vs VX Ace) 미확정.

---

## Q3. 최신(2023–2026) 쯔꾸르·ACTION GAME MAKER 동향과 한국 사례

### Takeaway
2023–2026 RPG Maker 상업작은 Look Outside(50만 장), Coffin of Andy and Leyley(리뷰 3.7만), In Stars and Time, Black Souls Steam 진출 등으로 여전히 강하다. 한국 "탈쯔꾸르"의 대형 Steam 흥행 사례는 확인되지 않았으나, 한국 1인 개발 RPG Maker MV 작품 *Flower in Us*(1980년대 가상 한국 독재기 밀실극)가 2026 RPG Maker Award 베스트 어드벤처를 수상했다. ACTION GAME MAKER(2025-06, Godot 4.3 기반)로 만든 주목할 서사 히트작은 아직 찾지 못했다.

### Cited Findings
- **RPG Maker Award 2026**(첫 개최, 215개 출품): 대상 *Artis Impact*(Mas, 인간과 AI의 미래 세계 턴제 RPG), 베스트 어드벤처 *Flower in Us*, 베스트 액션 *Creepy Creepy Love*(BYYONI Entertainment), 베스트 프리게임 *Saihate Station*(びぶ/viv, 두 남자의 공의존 관계를 다룬 탐험/호러) 등 — [Final Weapon](https://finalweapon.net/2026/02/17/rpg-maker-awards-2026-winners/); [Gamer.ne.jp](https://www.gamer.ne.jp/news/202602090002/); [Steam: Saihate Station](https://store.steampowered.com/app/3079280). *Artis Impact*(RPG Maker MZ, 2025-08-07) Steam 2,389건 — [List](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games); [Steam](https://store.steampowered.com/app/1864000)
- **Flower in Us (사람 속에 피는 꽃, 2025-07-25)**: 한국 1인 개발자 Chalkseagull(+작화 carnet, 사운드 k'əmgo), 한국 퍼블리셔 PsychoFlux Entertainment, RPG Maker MV — [검색 결과 요약: itch.io 데모](https://psychoflux.itch.io/flower-in-us); [SteamDB](https://steamdb.info/app/2482920). 기억을 잃고 지하실에서 깨어난 주인공이 기둥에 묶인 여성(레지스탕스를 자칭, 주인공이 정권 경찰이라고 주장)과 협력해 탈출. **가상의 1980년대 한국 독재 정권**이 배경, 신뢰가 계속 변하고 주인공 기억이 **불확실(신뢰할 수 없는 화자)**, 대화 자체가 퍼즐, 선택에 따른 멀티엔딩. *Zero Escape/999*에 비유됨 — [Common Sense Gamer](https://commonsensegamer.com/locked-room-suspense-meets-1980s-dictatorship-flower-in-us-brings-zero-escape-style-tension-to-steam-today/); [gamebiz](https://gamebiz.jp/news/409734). Steam 리뷰 430건 — [Steam](https://store.steampowered.com/app/2482920)
- **기타 한국 RPG Maker/쯔꾸르풍 작품**: *학생들의 공포괴담 終*(Alman, 2021-05-25, "RPG Maker XP로 만든 호러", 한/영) — [Steam](https://store.steampowered.com/app/1627040); *Yaja*(2022 스토브 인디, 1인 개발 RPG Maker 2D 호러 어드벤처), *Enigma*(RPG Maker VX Ace, 그린라이트 시절) — [검색 결과 요약/Siliconera](https://siliconera.com/?p=452148); *귀향 Gwihyang: Homecoming*(GrooveDev, 2024, 한국 전통 이미지 + 변화하는 공간 속 괴물 회피 탈출; 엔진 미확인) — [Steam](https://store.steampowered.com/app/3060970); *Ghost Deliverer*(TEAMDADA, 2025-12, "한국퇴마협회 KEA" 오컬트 어드벤처; RPG Maker 호러에 영감받았다고 소개되나 엔진 미확인) — [Steam](https://store.steampowered.com/app/3816720)
- **한국 비-쯔꾸르 비교작**: *The Coma: Recut*(Devespresso) — 한국 고교생 영호가 세화고에서 사이코 살인마에게 쫓기는 **횡스크롤** 서바이벌 호러("Run, hide, explore"), Steam 2,732건 ≈84.3%; *The Coma 2* 2,833건 ≈95.6%, Metacritic 77 — [Steam](https://store.steampowered.com/app/600090); [Steam Coma 2](https://store.steampowered.com/app/1045720). *SANABI*(WONDER POTION, 2023) — 디스토피아 **액션 플랫포머**, 의수로 갈고리 이동하는 퇴역 군인, Steam 42,236건 ≈97.2%, 소유자 100만–200만 추정 — [Steam](https://store.steampowered.com/app/1562700); [SteamSpy](https://steamspy.com/app/1562700)
- **일본 2023 3D 호러 *Hollow Cocoon(ウツロマユ)***: RPG Maker 아님 — **Unity(HDRP)**, 2인 서클 NAYUTA STUDIO, 1980년대 일본 산촌 1인칭 호러, 2023-12-07 — [SteamDB](https://steamdb.info/app/2414630); [AUTOMATON](https://automaton-media.com/articles/newsjp/20231010-267633/). Steam 886건 ≈92.2% — [Steam](https://store.steampowered.com/app/2414630)
- **ACTION GAME MAKER**: Gotcha Gotcha Games(KADOKAWA 자회사), Godot Engine 4.3 기반, 2025년 6월(16일 또는 17일, 출처마다 다름) Steam 출시, $99.99, 집계 사이트 기준 Steam 평가 "Mixed"(35건) — [검색 결과 요약: Steam](https://store.steampowered.com/app/2987180/ACTION_GAME_MAKER/); [ANN 보도자료](https://www.animenewsnetwork.com/press-release/2025-06-16/rpg-maker-legacy-expands-with-action-game-maker-a-dev-toolkit-available-today/.225665). 『アクションゲームツクールMV』의 후속, 2026년 6월 v1.3에서 3D 배경을 쓰는 2.5D 지원 추가(KADOKAWA 발표) — [KADOKAWA](https://www.kadokawa.co.jp/topics/17087/). 2026년 3월 HD-2D 스타일의 신규 RPG Maker 프로젝트 티저 — [GameMeca](https://www.gamemeca.com/en/mv.php?gid=1773353)
- 한국어 검색에서 "한국 개발 쯔꾸르 게임의 Steam 흥행 사례"를 정리한 자료는 찾지 못함 — [thisisgame 등 검색 결과](https://www.thisisgame.com/articles/410373)

### Inferences
- 한국 개발자에게 유효한 차별화 축은 **로컬 역사·민속 호러**(Flower in Us의 독재기, 귀향의 전통 이미지, Ghost Deliverer의 퇴마, The Coma의 학교 괴담) — 대만 *Detention*(1960년대 계엄기 대만, 횡스크롤 호러, Steam 13,142건)과 같은 성공 공식 — [Steam: Detention](https://store.steampowered.com/app/555220).
- 한국 시장에서 **서사 중심 2D 플랫포머의 상업적 가능성**은 SANABI(리뷰 4.2만)로 입증됨 → "쯔꾸르식 심리 호러 서사 + 플랫포머 조작"은 비어 있는 교집합일 가능성(추론).
- ACTION GAME MAKER는 출시 1년여로 서사 히트 사례가 아직 없어, 선점 여지가 있으나 레퍼런스도 부족함.

### Gaps
- 텀블벅 펀딩으로 성공한 한국 탈쯔꾸르 작품의 구체적 사례·판매량을 찾지 못함(나무위키·디시 쯔꾸르 갤러리 등 국내 커뮤니티 직접 조사 필요).
- ACTION GAME MAKER로 제작된 출시작 목록, 공식 콘테스트 수상작 미확인. AGM에서 GDScript 직접 작성·OS 창 제어(메타 연출용)가 가능한지 미확인.
- SANABI·Gwihyang·Ghost Deliverer의 엔진 미확인. SANABI의 서사 구조(반전 등) 미조사.
- *Creepy Creepy Love*·BYYONI Entertainment 국적 미확인.

---

## Q4. 비교작(비-RPG Maker) — 메타·루프·플랫포머 서사의 기준점

### Takeaway
비교작은 RPG Maker 계보의 기법을 다른 엔진·장르로 확장한 사례로, 특히 Celeste(플랫포머로 정신건강 서사), Undertale(세이브를 기억하는 세계), DDLC(파일 조작 메타), Outer Wilds(지식만 남는 루프), Inscryption(게임 속 게임 + ARG)이 핵심 레퍼런스다. 모두 Steam 리뷰 9만~50만 건 규모의 대형 성공.

### Cited Findings (모두 **비교작, RPG Maker 아님**)
- **Undertale (2015)** — GameMaker Studio, Toby Fox. Kickstarter $5,000 목표 → $51,124. 루트: Neutral / True Pacifist / Genocide. **2회차 보스 대사가 이전 회차 행동에 따라 바뀌고, Genocide의 결과가 True Pacifist 엔딩을 영구히 변경**. 영향원: Moon: Remix RPG Adventure(러브 레벨·도덕 개념), EarthBound, Mother, SMT(몬스터와 대화) 등. 총 500만 장 이상. Metacritic 92 — [Wikipedia: Undertale](https://en.wikipedia.org/wiki/Undertale). Steam 313,980건 ≈96.6% — [Steam](https://store.steampowered.com/app/391540)
- **Deltarune** — 2018년부터 챕터식, Ch1–4 유료 패키지 2025-06-04, Ch5 2026-06-24. "선택과 무관하게 하나의 엔딩"으로 홍보 — [Wikipedia: Undertale](https://en.wikipedia.org/wiki/Undertale). Steam 130,118건 — [Steam](https://store.steampowered.com/app/1671210)
- **Doki Doki Literature Club! (2017)** — Ren'Py, Team Salvato(Dan Salvato). 연애 시뮬 외피의 메타 심리 호러. Monika가 실제 플레이어에게 말을 걸고, **게임 폴더의 캐릭터 파일을 삭제**하면 이야기가 진행되며, 파일을 추가가 아닌 **파괴**해 제4의 벽을 깸. 엔딩: 표준 / 모든 선택 컷신을 본 경우의 긍정 엔딩 / 새 게임 전 Monika 파일 삭제 시 조기 엔딩. 3개월 100만 DL, 이후 200만 DL. Salvato: "무서운 것을 들이미는 게 아니라 불편하게 만들어서 무서운 것"에서 영감 — [Wikipedia: DDLC](https://en.wikipedia.org/wiki/Doki_Doki_Literature_Club!). SteamSpy 긍정 222,387/부정 8,085(≈96.5%), 소유자 500만–1,000만; *Plus!* 30,748건 — [SteamSpy](https://steamspy.com/app/698780); [Steam Plus](https://store.steampowered.com/app/1388880)
- **Celeste (2018)** — Microsoft XNA, Maddy Thorson·Noel Berry. PICO-8 프로토타입(2015년 8월, 주말 동안 제작)에서 출발. 불안·우울을 가진 Madeline이 산을 오르고, **자기 의심의 인격화 Badeline**이 방해. 곤돌라에서 공황 발작 → Theo가 진정시킴. 제한된 벽 오르기 스태미나(볼더링에서 영감), 산이라는 수직 레벨. **Assist Mode**(속도↓·무한 대시·무적). Thorson 본인의 우울·불안 경험 기반(전문가 자문 없음), 2020년 Madeline이 트랜스 여성임을 언급. 판매 2018년 50만 → 2020년 3월 100만 → 2025년 1월 170만 — [Wikipedia: Celeste](https://en.wikipedia.org/wiki/Celeste_(video_game)). Steam 134,541건 ≈97.4% — [Steam](https://store.steampowered.com/app/504230)
- **Hollow Knight (2017)** — Team Cherry, 손그림 2D 액션 어드벤처, "폐허가 된 벌레 왕국" — [Steam](https://store.steampowered.com/app/367520). Steam 509,460건 ≈97.0% — [SteamSpy](https://steamspy.com/app/367520)
- **Outer Wilds (2019/Steam 2020)** — Mobius Digital. 루프가 앞으로 가져가는 것은 기억뿐 → **지식이 유일한 가치**. 능력 해금이 아닌 "세계에 대한 지식 수집"만으로 진행. 원래 루프는 행성 붕괴 같은 대규모·비가역 동적 시스템을 가능케 하려는 목적 — [Game Developer](https://www.gamedeveloper.com/design/live-die-repeat-how-i-outer-wilds-i-piques-curiosity-in-an-ambivalent-solar-system). Steam 91,511건 ≈95.5% — [Steam](https://store.steampowered.com/app/753640)
- **Inscryption (2021)** — Unity, Daniel Mullins Games. 3막(로그라이크 카드 → 도트 RPG → 카드), **Luke Carder가 녹화한 파운드 푸티지**라는 액자, 게임 속 게임, 실세계 ARG(우편 플로피 디스크). Ludum Dare 43 출품작에서 출발. 2022년 1월 100만 장, GDC Awards GOTY·IGF 대상 — [Wikipedia: Inscryption](https://en.wikipedia.org/wiki/Inscryption). Steam 136,532건 — [Steam](https://store.steampowered.com/app/1092790)
- **Pony Island (2016)** — "악마가 만든 고장 난 아케이드 기계에 갇힌" 위장 퍼즐 게임, Steam 14,909건, Metacritic 86 — [Steam](https://store.steampowered.com/app/405640)
- **The Stanley Parable: Ultra Deluxe (2022)** — "You will make a choice, and you will become powerless… The Stanley Parable is a game that plays you." Steam 34,605건 — [Steam](https://store.steampowered.com/app/1703340)
- **Slay the Princess — The Pristine Cut** — Steam 33,520건 ≈96.5%, Metacritic 90 — [Steam](https://store.steampowered.com/app/1989270)
- **INSIDE (2016)/LIMBO (2011)** — Playdead, "dark, narrative-driven platformer", 무드 아트·앰비언트 사운드. Steam 70,511건 / 41,060건 — [Steam INSIDE](https://store.steampowered.com/app/304430); [Steam LIMBO](https://store.steampowered.com/app/48000)
- **Fran Bow (2015)** — 정신 질환과 불공평한 운명을 겪는 소녀, Steam 20,998건 ≈97.5% — [Steam](https://store.steampowered.com/app/362680)

### Inferences
- Celeste는 "레벨 디자인 = 감정의 물리화"(오르기=극복, 스태미나=한계, Assist Mode=자기 돌봄의 허용)라는 점에서 이 프로젝트의 **1순위 레퍼런스**.
- Undertale/OneShot/DDLC의 메타는 모두 "**영속 데이터(세이브·파일·OS)**"를 서사 매체로 쓴다는 공통점 — 플랫포머에서도 user 디렉터리 파일·세이브 플래그로 동일 구현 가능(엔진 기능 확인 필요).
- Outer Wilds의 "지식 기반 진행"은 플랫포머 메트로배니아의 "능력 기반 진행"과 정반대 축 — 두 축을 섞으면(능력 + 비밀번호/지식) 다회차 진실 조립 구조가 됨.

### Gaps
- Hollow Knight의 환경 서사(로어 태블릿, 사냥꾼의 일지 등)에 대한 1차 분석 출처 미확보(Steam 설명만).
- Celeste의 개별 연출(깃털 호흡 장면, 6장 반영 장면)은 Wikipedia 전반부에서 확인 불가.
- Pony Island·Stanley Parable·Slay the Princess의 구조 분석 출처는 Steam 소개문 수준.

---

## Q5. 교차 패턴 — 선택 누적, 진엔딩, 루프 지식, 저사양 공포, 정신 상태, 메타 연출

### Takeaway
6개 패턴 모두 "시스템이 테마를 체현한다"는 원칙으로 수렴한다: 작은 선택은 숨은 플래그/영구 손실로 누적되고, 진엔딩은 회차를 넘는 정보(수집품·파일·이전 회차 기억)로 열리며, 공포는 그래픽 대신 소리·예측불가·안전지대 대비로 만들어지고, 정신 상태는 게이지·전투 상태·연출 붕괴로 표현되며, 메타는 세이브·파일·OS 창을 서사 매체로 쓴다.

### Cited Findings

**5-1. 작은 선택의 누적(숨은 변수/카르마)**
- Undertale: 몬스터와의 상호작용 방식에 따라 적 공격이 변하고, 2회차 보스 대사가 이전 회차 행동을 반영 — [Wikipedia: Undertale](https://en.wikipedia.org/wiki/Undertale)
- LISA: 선택의 대가로 팔을 잃어 스탯·금단이 악화, 동료 영구 사망 — [Wikipedia: LISA](https://en.wikipedia.org/wiki/Lisa:_The_Painful)
- Look Outside: 적 살해·절도 → 죄책감, 노크 응답 여부, 공물 정답 수 등 누적 요소가 엔딩 결정 — [Wikipedia: Look Outside](https://en.wikipedia.org/wiki/Look_Outside)
- Ib: Garry의 운명, Mary 그림을 태우는지 여부로 결말 분기 — [Wikipedia: Ib](https://en.wikipedia.org/wiki/Ib_(video_game))
- OMORI: Kel을 무시하는 초반 선택이 "집에 머무는" 경로와 비극적 결말로 연결 — [Wikipedia: OMORI](https://en.wikipedia.org/wiki/Omori_(video_game))
- Flower in Us: 신뢰가 계속 이동하는 2인극, 선택에 따른 멀티엔딩 — [Common Sense Gamer](https://commonsensegamer.com/locked-room-suspense-meets-1980s-dictatorship-flower-in-us-brings-zero-escape-style-tension-to-steam-today/)
- 비판 사례: LISA의 도덕적 선택이 "항상 유기적이진 않다"(RPGFan) — [Wikipedia: LISA](https://en.wikipedia.org/wiki/Lisa:_The_Painful)

**5-2. 멀티엔딩과 "진엔딩"의 회차 간 인코딩**
- OneShot: 1회차 클리어 후 실제 Documents 폴더의 메모 → Solstice 경로 — [Wikipedia: OneShot](https://en.wikipedia.org/wiki/OneShot)
- DDLC: 모든 선택 컷신을 본 경우에만 긍정 엔딩 — [Wikipedia: DDLC](https://en.wikipedia.org/wiki/Doki_Doki_Literature_Club!)
- Undertale: 무살생 클리어 세이브를 다시 불러와야 True Pacifist, Genocide는 이를 영구 오염 — [Wikipedia: Undertale](https://en.wikipedia.org/wiki/Undertale)
- Mad Father: 수집품이 추가 장면 해금, 진엔딩은 특정 선택 경로 — [Wikipedia: Mad Father](https://en.wikipedia.org/wiki/Mad_Father)
- Fear & Hunger: 엔딩 10개 중 4개(S엔딩)는 캐릭터별·하드모드 전용 → 캐릭터 교체 다회차로 진실 조립 — [Wikipedia: F&H](https://en.wikipedia.org/wiki/Fear_%26_Hunger)
- Inscryption: 본편 밖 실세계 ARG가 에필로그 영상까지 확장 — [Wikipedia: Inscryption](https://en.wikipedia.org/wiki/Inscryption)

**5-3. 루프가 보존하는 지식(플레이어 vs 캐릭터)**
- Outer Wilds: 기억만 루프를 넘음 → 플레이어 지식 = 캐릭터 지식(일치형) — [Game Developer](https://www.gamedeveloper.com/design/live-die-repeat-how-i-outer-wilds-i-piques-curiosity-in-an-ambivalent-solar-system)
- In Stars and Time: Siffrin만 기억, 파티는 망각 → 이 **비대칭이 정신 붕괴의 원인**으로 서사화. 반복 피로 완화를 위해 빨리감기·층 스킵 제공 — [Wikipedia: ISAT](https://en.wikipedia.org/wiki/In_Stars_and_Time)
- Undertale: 세계(일부 캐릭터)가 플레이어의 리셋/이전 회차를 기억 → **세이브/로드 자체가 서사 행위** — [Wikipedia: Undertale](https://en.wikipedia.org/wiki/Undertale)
- Termina: 세이브마다 3일 시계가 진행 → 세이브가 서사적 비용 — [Wikipedia: F&H](https://en.wikipedia.org/wiki/Fear_%26_Hunger)

**5-4. 제한된 그래픽으로 공포 만들기**
- 소리: Ib의 정적과 급작스러운 소리 — [Wikipedia: Ib](https://en.wikipedia.org/wiki/Ib_(video_game)); Corpse Party의 더미헤드 3D 음향 — [Wikipedia: Corpse Party](https://en.wikipedia.org/wiki/Corpse_Party)
- 추격: Ao Oni의 무작위+스크립트 추격 — [Wikipedia: Ao Oni](https://en.wikipedia.org/wiki/Ao_Oni); Mad Father의 QTE 도주 — [Wikipedia: Mad Father](https://en.wikipedia.org/wiki/Mad_Father); The Coma의 횡스크롤 도주·은신 — [Steam](https://store.steampowered.com/app/600090)
- 즉사/함정: 마녀의 집의 함정·점프스케어 — [Wikipedia: Witch's House](https://en.wikipedia.org/wiki/The_Witch%27s_House)
- 대비·안전지대: OMORI의 밝은 이미지 ↔ 글리치 흑백 — [Wikipedia: OMORI](https://en.wikipedia.org/wiki/Omori_(video_game)); Look Outside의 안전한 아파트 ↔ 위험한 바깥, 가까워질수록 정체가 드러나는 적, 비유클리드 공간 — [Wikipedia: Look Outside](https://en.wikipedia.org/wiki/Look_Outside)
- 불편함: DDLC "무서운 걸 들이미는 게 아니라 불편하게 만들어서" — [Wikipedia: DDLC](https://en.wikipedia.org/wiki/Doki_Doki_Literature_Club!)
- 무언 서사: Yume Nikki(대화 없음) — [Wikipedia: Yume Nikki](https://en.wikipedia.org/wiki/Yume_Nikki); INSIDE "dark, narrative-driven platformer" — [Steam](https://store.steampowered.com/app/304430)

**5-5. 정신 상태 시스템의 표현 방식**
- 전투 상태형: OMORI 감정 상성(Happy/Sad/Angry) — [Wikipedia: OMORI](https://en.wikipedia.org/wiki/Omori_(video_game))
- 게이지형: F&H 체력/정신/허기 — [Wikipedia: F&H](https://en.wikipedia.org/wiki/Fear_%26_Hunger); Look Outside 허기·위생·죄책감 — [Wikipedia: Look Outside](https://en.wikipedia.org/wiki/Look_Outside); LISA Joy 금단 — [Wikipedia: LISA](https://en.wikipedia.org/wiki/Lisa:_The_Painful)
- 상징 HP형: Ib 장미 — [Wikipedia: Ib](https://en.wikipedia.org/wiki/Ib_(video_game))
- 서사/연출 붕괴형: In Stars and Time(환각·자기혐오 묘사) — [Wikipedia: ISAT](https://en.wikipedia.org/wiki/In_Stars_and_Time); Celeste(Badeline·공황 발작) — [Wikipedia: Celeste](https://en.wikipedia.org/wiki/Celeste_(video_game))
- 이중 세계형: OMORI Headspace↔현실 — [Wikipedia: OMORI](https://en.wikipedia.org/wiki/Omori_(video_game)); Rakuen 병원↔판타지 — [Steam](https://store.steampowered.com/app/559210)

**5-6. 메타픽션 연출 방식**
- OS 조작: OneShot(창 이동·바탕화면·파일·종료=수면, 사용자명 호명) — [Wikipedia: OneShot](https://en.wikipedia.org/wiki/OneShot)
- 파일 조작/파괴: DDLC(캐릭터 파일 삭제) — [Wikipedia: DDLC](https://en.wikipedia.org/wiki/Doki_Doki_Literature_Club!)
- 세이브 기억: Undertale — [Wikipedia: Undertale](https://en.wikipedia.org/wiki/Undertale)
- 플레이어 직접 호명/공모: OFF — [Wikipedia: OFF](https://en.wikipedia.org/wiki/Off_(video_game))
- 액자(파운드 푸티지)·게임 속 게임·ARG: Inscryption — [Wikipedia: Inscryption](https://en.wikipedia.org/wiki/Inscryption)
- 고장 난 기계/가짜 장르: Pony Island — [Steam](https://store.steampowered.com/app/405640); DDLC 연애 시뮬 외피 — [Wikipedia: DDLC](https://en.wikipedia.org/wiki/Doki_Doki_Literature_Club!)
- 내레이터 대립: Stanley Parable — [Steam](https://store.steampowered.com/app/1703340)
- 이식 주의점: OneShot 콘솔판은 OS 접근이 불가해 **게임 내 가상 OS**로 대체 — [Wikipedia: OneShot](https://en.wikipedia.org/wiki/OneShot)

### Inferences
- **선택 누적 설계 원칙(추론)**: 숨은 변수는 (a) 엔딩 분기용 소수의 "핵심 플래그" + (b) 분위기·대사만 바꾸는 "카르마 수치"로 이원화하는 것이 안전. LISA 비판처럼 선택이 서사와 분리되면 효과가 떨어짐.
- **진엔딩 인코딩 4유형(추론)**: ① 수집 완전성(Mad Father, DDLC), ② 회차 간 정보 전달(OneShot 파일, Undertale 세이브), ③ 캐릭터/난이도 교체(F&H S엔딩), ④ 테마적 수용(ISAT 루프 해제).
- **루프 지식 3유형(추론)**: 일치형(Outer Wilds), 주인공만 기억형(ISAT), 세계가 기억형(Undertale). 플랫포머에서는 "플레이어만 기억(비밀번호·지름길)" 형태가 구현 비용이 가장 낮음.
- **메타는 "관계"가 받쳐줄 때만 감동**(OneShot의 Niko-플레이어, DDLC의 Monika-플레이어) — 트릭 단독은 기믹으로 소비됨.
- 콘솔 이식을 고려하면 OS 메타 대신 "게임 내 가상 OS/가짜 시스템 메시지" 방식이 안전(OneShot WME 선례).

### Gaps
- 각 게임의 히든 변수 수치 구조(예: Ib 호감도 포인트)를 확인할 1차 자료 부족.
- 공포 연출의 정량적 연구(학술 논문)는 이번 조사에서 확보하지 못함(RPG Maker 호러·Yume Nikki 학술 문헌 미조사).

---

## Q6. 2D 플랫포머 적용 가능성과 스토리 구조 분류(Taxonomy)

### Takeaway
횡스크롤 플랫포머로 가장 잘 번역되는 기법은 (1) 레벨=심리 은유(Celeste), (2) 영구 희생이 조작감을 바꾸는 선택(LISA), (3) 추격 도주 시퀀스(Ao Oni/The Coma), (4) 상징 HP·감정 상태가 이동 물리를 바꾸는 시스템(Ib/OMORI 응용), (5) 수집품=진실 조각과 다회차 진엔딩(Mad Father/OneShot), (6) 세이브/체크포인트의 서사화(Termina/Undertale), (7) 무언 환경 서사(INSIDE/Yume Nikki)이다. 아래 8유형 분류를 설계 템플릿으로 쓸 수 있다.

### Cited Findings (근거가 되는 사실)
- LISA는 RPG Maker 작품이면서 **2D 횡스크롤 오버월드**를 채택 — [Wikipedia: LISA](https://en.wikipedia.org/wiki/Lisa:_The_Painful)
- Celeste는 볼더링에서 착안한 스태미나·수직 레벨·Assist Mode로 정신건강 서사를 플랫포밍에 결합, 170만 장 — [Wikipedia: Celeste](https://en.wikipedia.org/wiki/Celeste_(video_game))
- INSIDE/LIMBO는 "dark, narrative-driven platformer" — [Steam](https://store.steampowered.com/app/304430)
- The Coma는 횡스크롤 추격·은신 호러 — [Steam](https://store.steampowered.com/app/600090); Detention은 대만 계엄기 횡스크롤 호러 — [Steam](https://store.steampowered.com/app/555220)
- SANABI는 한국산 서사형 액션 플랫포머로 리뷰 4.2만 건 — [Steam](https://store.steampowered.com/app/1562700)
- 프로토타입→상업 확장: OneShot(1개월 프리웨어→Steam), Look Outside(1개월 잼→+5개월→50만 장), Celeste(PICO-8 주말 프로토→170만 장), Inscryption(Ludum Dare→100만 장) — [OneShot](https://en.wikipedia.org/wiki/OneShot); [Look Outside](https://en.wikipedia.org/wiki/Look_Outside); [電ファミ](https://news.denfaminicogamer.jp/news/260810g); [Celeste](https://en.wikipedia.org/wiki/Celeste_(video_game)); [Inscryption](https://en.wikipedia.org/wiki/Inscryption)
- ACTION GAME MAKER는 Godot 4.3 기반 2D 액션 제작툴, v1.3에서 2.5D 지원 — [ANN](https://www.animenewsnetwork.com/press-release/2025-06-16/rpg-maker-legacy-expands-with-action-game-maker-a-dev-toolkit-available-today/.225665); [KADOKAWA](https://www.kadokawa.co.jp/topics/17087/)

### Inferences

**A. 스토리 구조 분류(Taxonomy) — 8유형 (추론, 위 사례 기반)**

| # | 유형 | 핵심 구조 | 대표작(툴) | 플랫포머 번역 |
|---|---|---|---|---|
| T1 | 탈출형 밀실 호러 | 갇힘→탐색→퍼즐 게이트→추격→진실→멀티엔딩 | Ao Oni(XP), 마녀의 집(VX), Ib(2000/MV), Mad Father(WOLF), Corpse Party(Dante 98), Flower in Us(MV) | 건물 단면도형 수직 맵, 잠긴 문=능력/열쇠 게이트, 추격 도주 구간 |
| T2 | 꿈·내면세계 탐험 | 현실↔내면 이중 세계, 상징 수집, 억압된 기억 | Yume Nikki(2003), OMORI(MV), Hylics(VX Ace), Pocket Mirror, Rakuen(XP) | 스테이지=심리 영역, 능력=감정/기억 상징, 현실 파트는 짧은 무전투 구간 |
| T3 | 기억 재구성·역순 | 결과 먼저, 원인을 거슬러 올라감; 기억 상실 화자 | To the Moon(XP), Flower in Us(MV), OMORI | 스테이지를 과거 순으로 역배치, 각 스테이지 끝 "기억 조각" |
| T4 | 시간 제한 생존 | N일 제한 + 자원/정신 게이지 + 안전지대 | Termina(MV, 3일), Look Outside(MV/MZ, 15일), F&H(MV) | 허브(안전한 방) ↔ 원정 스테이지, 원정마다 시간 소모, 체크포인트=비용 |
| T5 | 영구 희생 선택 | 되돌릴 수 없는 손실이 시스템을 바꿈 | LISA(VX Ace), F&H(사지 손실) | 능력/체력 상한을 대가로 NPC를 구함 → 이후 조작감 변화 |
| T6 | 타임루프 | 죽음/기한 → 리셋, 지식만 이월, 해제 조건=테마 | In Stars and Time(MV), Outer Wilds*, Termina | 짧은 루프 스테이지, 플레이어 지식(비밀번호·숨은 길)으로 단축, 최종 해제는 심리적 수용 |
| T7 | 메타픽션 | 플레이어 호명, 세이브/파일/OS를 서사 매체로 | OneShot(2003/XP), OFF(2003), Undertale*, DDLC*, Inscryption*, Pony Island* | 가짜 시스템 메시지, 세이브 슬롯 서사, 캐릭터가 "재시작"을 기억, 콘솔 대비 게임 내 가상 OS |
| T8 | 무언·환경 서사 | 대사 없이 공간·오브젝트로 전달 | Yume Nikki, INSIDE*, LIMBO*, Hollow Knight* | 배경 레이어·적 배치·폐허로 서사, 로어 아이템 |

(* = 비-RPG Maker 비교작)

**B. 이 프로젝트용 조합 템플릿 제안 (추론)**
- 기본 골격: **T2(내면세계) + T6(루프) + T7(가벼운 메타)** — 예: 주인공의 마음속 "탑/집"을 오르는 횡스크롤, 사망·포기 시 하루 전으로 돌아가며 주인공만 기억, 정신 상태가 이동 물리(점프·시야·배경 왜곡)를 바꿈, 진엔딩은 다회차 수집 조각 + "루프를 끝내고 싶지 않았다"는 테마적 수용.
- 보조 장치: T5의 영구 희생(능력 하나를 포기해 NPC를 구함), T1의 추격 도주 구간, T4의 허브-원정 구조.
- 로컬화: Flower in Us·Detention·The Coma처럼 **한국적 공간/역사(학교 괴담, 아파트, 근현대사)**를 배경으로 하면 차별화.
- 범위 관리: OneShot·Look Outside식으로 **1개월 잼 규모 프로토타입 → 반응 확인 → 확장** 경로 권장.

**C. 플랫포머 이식 시 리스크 (추론)**
- 루프 반복 피로: ISAT처럼 빨리감기·스킵 제공 필요(비평에서 반복이 호불호) — [Wikipedia: ISAT](https://en.wikipedia.org/wiki/In_Stars_and_Time)
- 난이도와 서사 접근성: Celeste의 Assist Mode가 해법 선례 — [Wikipedia: Celeste](https://en.wikipedia.org/wiki/Celeste_(video_game))
- 과도한 어둠: OMORI·F&H 모두 "불필요한 어둠/수위"가 비판 지점 — [Wikipedia: OMORI](https://en.wikipedia.org/wiki/Omori_(video_game)); [Wikipedia: F&H](https://en.wikipedia.org/wiki/Fear_%26_Hunger)
- 메타 연출의 플랫폼 의존성: OS 조작은 콘솔 불가 → 가상 OS 대체(OneShot WME) — [Wikipedia: OneShot](https://en.wikipedia.org/wiki/OneShot)

### Gaps
- ACTION GAME MAKER의 스크립팅 범위(파일 I/O, 창 제어, 셰이더 기반 화면 왜곡)를 공식 문서로 확인하지 못함 → 메타/정신 상태 연출의 구현 가능성은 별도 기술 조사 필요.
- Hollow Knight·Celeste 개별 연출 기법에 대한 개발자 1차 인터뷰(GDC 등) 원문 미확보.
- 과제에 언급된 "Rusty Lake"(RPG Maker 목록에 없음, 엔진 미확인), "Ever After?"(어느 작품인지 특정 불가)는 조사하지 못함.

---

### 부록: Steam 수치 요약 (2026-11-16 조회; 리뷰 수=Steam API, 긍정률·소유자=SteamSpy 추정)

| 작품 | 툴 | AppID | Steam 리뷰 수 | 긍정률(SteamSpy) | 소유자 추정 |
|---|---|---|---|---|---|
| OMORI | RPG Maker MV | 1150690 | 80,571 | 97.1% | 1–2M |
| To the Moon | RPG Maker XP | 206440 | 70,521 | 95.9% | 2–5M |
| OneShot | RPG Maker XP | 420530 | 60,198 | 98.2% | 1–2M |
| The Coffin of Andy and Leyley | RPG Maker MV | 2378900 | 37,405 | 96.0% | 1–2M |
| Fear & Hunger | RPG Maker MV | 1002300 | 21,294 | n/a | n/a |
| Fear & Hunger 2: Termina | RPG Maker MV | 2171440 | 14,521 | n/a | n/a |
| Look Outside | RPG Maker MV/MZ | 3373660 | 14,489 | (표본 99.0%, 오래됨) | 공식 50만 장(2026-08) |
| LISA: The Painful | RPG Maker VX Ace | 335670 | 13,202 | 95.6% | 0.5–1M |
| Hylics | RPG Maker VX Ace | 397740 | 8,510 | 98.1% | 200–500K |
| In Stars and Time | RPG Maker MV | 1677310 | 8,044 | 97.6% | 100–200K |
| Black Souls | RPG Maker VX Ace | 3755860 | 7,872 | n/a | n/a |
| Mad Father | WOLF RPG Editor | 483980 | 6,376 | 97.2% | 200–500K |
| Felvidek | RPG Maker | 2299900 | 5,729 | 98.6% | 100–200K |
| Angels of Death | RPG Maker VX Ace | 537110 | 5,063 | 94.9% | 100–200K |
| Ib (2022 리메이크) | RPG Maker MV | 1901370 | 5,004 | 99.0% | 200–500K |
| Rakuen | RPG Maker XP | 559210 | 4,707 | 96.3% | 200–500K |
| Your Turn To Die | RPG Maker MV | 2067780 | 4,241 | 98.6% | 100–200K |
| The Witch's House MV | RPG Maker MV | 885810 | 3,783 | 95.6% | 100–200K |
| OFF (2025) | (원작 RPG Maker 2003) | 3339880 | 3,233 | n/a | n/a |
| Artis Impact | RPG Maker MZ | 1864000 | 2,389 | n/a | n/a |
| Misao HD | WOLF RPG Editor(목록 스니펫) | 691450 | 2,379 | 95.7% | 100–200K |
| Pocket Mirror ~GoldenerTraum | RPG Maker MZ | 1899060 | 1,630 | 93.5% | 100–200K |
| Corpse Party (2021) | — | 1273260 | 1,452 | 92.0% | 50–100K |
| The Crooked Man | (미확정) | 736570 | 1,229 | 92.5% | — |
| Aooni (2024) | (원작 RPG Maker XP) | 2934190 | 956 | n/a | n/a |
| Flower in Us (한국) | RPG Maker MV | 2482920 | 430 | n/a | n/a |
| Yume Nikki (무료) | RPG Maker 2003 | 650700 | — | 94.1% (8,120/509) | 0.5–1M |
| *Hollow Knight* | 비교작 | 367520 | 509,460 | 97.0% | — |
| *Undertale* | GameMaker | 391540 | 313,980 | 96.6% | 5–10M |
| *DDLC* (무료) | Ren'Py | 698780 | — | 96.5% (222,387/8,085) | 5–10M |
| *Inscryption* | Unity | 1092790 | 136,532 | 96.8% | 2–5M |
| *Celeste* | XNA | 504230 | 134,541 | 97.4% | 공식 170만(2025-01) |
| *Deltarune* | 비교작 | 1671210 | 130,118 | n/a | — |
| *Outer Wilds* | 비교작 | 753640 | 91,511 | 95.5% | 2–5M |
| *INSIDE* | 비교작 | 304430 | 70,511 | 97.1% | 2–5M |
| *SANABI* (한국) | 비교작(엔진 미확인) | 1562700 | 42,236 | 97.2% | 1–2M |
| *Stanley Parable UD* | 비교작 | 1703340 | 34,605 | 94.1% | 1–2M |
| *Slay the Princess* | 비교작 | 1989270 | 33,520 | 96.5% | 1–2M |
| *Fran Bow* | 비교작 | 362680 | 20,998 | 97.5% | 1–2M |
| *Pony Island* | 비교작 | 405640 | 14,909 | 95.0% | 0.5–1M |
| *Detention* (대만) | 비교작 | 555220 | 13,142 | 95.7% | 200–500K |
| *The Coma: Recut* (한국) | 비교작 | 600090 | 2,732 | 84.3% | 100–200K |
| *Hollow Cocoon* | Unity(비-RPG Maker) | 2414630 | 886 | 92.2% | 50–100K |

출처: 각 행 `https://store.steampowered.com/app/<AppID>` 및 `https://steamspy.com/app/<AppID>`; 툴은 [Wikipedia: List of RPG Maker games](https://en.wikipedia.org/wiki/List_of_RPG_Maker_games) 및 위 개별 문서. Hollow Knight의 SteamSpy 소유자 구간(20–50M)은 비정상적으로 커 보여 제외. DDLC·Yume Nikki는 무료라 Steam API 리뷰 수 필드가 비정상(—)으로 SteamSpy 값 사용.

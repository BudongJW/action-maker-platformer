# 최근(2024-01 ~ 2026-11) 2D 플랫포머·메트로배니아·2D 액션 게임의 서사 방식과 흥행의 상관관계

> 조사일: 2026-11-17. 대상: 2024-01-01 ~ 2026-11-17 출시작. 2023년 이전 작품은 비교용으로만 다룸.
> 사용자 컨텍스트: ACTION GAME MAKER G(Godot 4.7 기반) 1인/소규모 개발, 심리 호러/미스터리 + 타임루프 + 다회차 멀티엔딩 + 가벼운 메타픽션, 장화홍련("홍련의 연못") 모티프 검토 중. Celeste/Hollow Knight/LISA/SANABI/INSIDE·Limbo는 이전 조사에서 다뤘으므로 비교로만 언급.
>
> **Steam 수치 읽는 법 (모든 표 공통)**: 2026-11-17에 Steam 스토어 페이지와 Steam appdetails API에서 직접 조회. "EN"은 스토어가 표시한 *영어 리뷰* 수와 긍정률("in your language"), "ALL"은 appdetails의 `recommendations.total`(전 언어 리뷰 총수). 스토어가 "for this game"으로 표시한 경우는 전 언어 수치. 리뷰 수는 판매량이 아니며 판매량의 대리지표일 뿐임.
> 스포일러는 **[스포일러]**로 표시. 게임 대사는 인용하지 않고 구조만 분석함.

---

## Q1. 어떤 최근작이 분석 대상으로 적합하며, 각 작품의 검증된 기본 데이터(개발사·국가·팀 규모·출시일·엔진·가격·상업 성과)는 무엇인가?

### Takeaway
2024-01 ~ 2026-11 사이 출시된 2D 플랫포머/메트로배니아/2D 액션 중 데이터가 확인된 21개 작품(+한국작 5개, 비교작 다수)을 정리했다. 공식 판매량이 공개된 대형 성공은 Silksong(700만+), Prince of Persia: The Lost Crown(첫해 130만), Nine Sols(80만), Animal Well(약 65만, 1인 개발), Mina the Hollower(50만+), REPLACED(Game Pass 포함 90만 명)이며, 서사 비중이 높은 게임과 거의 없는 게임이 모두 상위권에 섞여 있다. 즉 "서사의 양"보다 "핵심 플레이 + 강한 세계 정체성"이 흥행을 가른다.

### Cited Findings

**A. 핵심 분석 대상 (2024–2026 출시)**

| # | 작품 | 개발사(국가) / 팀 | 출시일 | 엔진 | 가격(Steam, 2026-11-17) | 상업 성과 | Steam 리뷰(2026-11-17) |
|---|---|---|---|---|---|---|---|
| 1 | Nine Sols | Red Candle Games(대만) / 풀타임 10명+ 또는 15명(출처 상충) | PC 2024-05-29, 콘솔 2024-11-26 | Unity | $29.99 | 2025년 5월 말 전 플랫폼 80만 장 | EN 95%/20,890, ALL 41,418 |
| 2 | Hollow Knight: Silksong | Team Cherry(호주) / 핵심 3인 + 외주, 개발 중 증원 없음 | 2025-09-04 | Unity | $19.99 | 2025-12 기준 700만 장+(Game Pass 제외), 첫날 동접 50만+ | EN 93%/147,546, ALL 391,949 |
| 3 | Prince of Persia: The Lost Crown | Ubisoft Montpellier(프랑스) + 부쿠레슈티·키이우·푸네 지원 | 콘솔/PC 2024-01-18, Steam 2024-08-08 | Unity | $29.99 | 첫해 130만 장(2025-01-31 보도), 2025-09 플레이어 300만+; 내부 기대치 미달로 팀 해체·재배치 | EN 85%/3,332, ALL 7,307 (Ubisoft Connect·콘솔 판매는 미포함) |
| 4 | ANIMAL WELL | Billy Basso(미국, 1인) / Bigmode 퍼블리싱 | 2024-05-09 | 자체 C++ 엔진 | $24.99 | 2024-08 기준 약 65만 장(개발자 추정) | EN 95%/13,167, ALL 23,115 |
| 5 | Neva | Nomada Studio(스페인) / Devolver | 2024-10-15 | Unity | $19.99 | 공식 판매량 없음(전작 Gris 300만+) | EN 94%/3,993, ALL 9,642 |
| 6 | ENDER MAGNOLIA: Bloom in the Mist | Adglobe·Live Wire(일본) / Binary Haze | 앞서해보기 2024-03, 정식 2025-01-22 | 미확인 | $24.99 | 전작 Ender Lilies와 합산 200만 장+(2025-01); 단독 수치는 추정치만(31만~120만으로 편차 큼) | EN 97%/4,769, ALL 17,466 |
| 7 | Tales of Kenzera: ZAU | Surgent Studios(영국) / EA Originals | 2024-04-23 | Unreal Engine | $19.99 | 공식 판매량 없음; 출시 3개월 만에 10여 명 해고, 이후 게임 부문 중단 보도 | 82%/909 (전 언어) |
| 8 | Ultros | Hadoque(스웨덴) / Kepler | 2024-02-13 | 미확인 | $24.99 | 공식 판매량 없음 | 80%/812 (전 언어) |
| 9 | Momodora: Moonlit Farewell | Bombservice(1인, rdein) / PLAYISM | 2024-01-11 | 미확인 | $16.99 | 공식 판매량 없음 | EN 93%/1,236, ALL 3,108 |
| 10 | Withering Rooms | Moonless Formless(미국 시애틀, 1인 Troy West) / Perp Games | 앞서해보기 2022-10-04, 정식 2024-04-05 | 미확인 | $24.99 | 공식 판매량 없음 | 96%/1,271 (전 언어, 압도적 긍정) |
| 11 | The Plucky Squire | All Possible Futures / Devolver | 2024-09-17 | 미확인 | $29.99 | 공식 판매량 없음 | EN 81%/1,169, ALL 2,840 |
| 12 | UFO 50 | Mossmouth(미국) | 2024-09-18 | 미확인 | $24.99 | 공식 판매량 없음(제3자 추정 약 52.7만) | EN 95%/6,632, ALL 7,217 |
| 13 | NINJA GAIDEN: Ragebound | The Game Kitchen(스페인) / Dotemu | 2025-07-31 | 미확인 | $24.99 | 제3자 추정 Steam 약 11.2만 장(2026-07, 중간 신뢰도) | EN 92%/1,208, ALL 2,578 |
| 14 | Mandragora: Whispers of the Witch Tree | Primal Game Studio / Knights Peak | 2025-04-17 | 미확인 | $39.99 | 공식 판매량 없음 | EN 78%/1,275, ALL 3,135 |
| 15 | Possessor(s) | Heart Machine(미국) / Devolver | 2025-11-11 | 미확인 | $9.99(조회 시점 표시가) | 공식 판매량 없음 | 74%/802 (전 언어) |
| 16 | Constance | Blue Backpack / ByteRockers' Games 등 | 2025-11-24 | 미확인 | $19.99 | 공식 판매량 없음 | EN 85%/1,260, ALL 3,001 |
| 17 | SHINOBI: Art of Vengeance | Lizardcube·SEGA | 2025-08-28(Steam 표기) | 미확인 | $29.99 | 공식 판매량 없음 | EN 90%/1,635, ALL 3,707 |
| 18 | MIO: Memories in Orbit | Douze Dixièmes(프랑스) / Focus Entertainment | 2026-01-20 | 미확인 | $19.99 | 공식 판매량 없음 | EN 86%/2,136, ALL 4,883 |
| 19 | REPLACED | Sad Cat Studios / Thunderful | 2026-04-14 | 미확인 | $19.99 | 출시 6개월 시점(2026-10-14) 구매자+Game Pass 합산 90만 명+ | EN 86%/3,812, ALL 10,048 |
| 20 | Mina the Hollower | Yacht Club Games(미국) | 2026-05-28/29 | 미확인 | $19.99 | 3일 만에 30만 장, 약 1.5주 만에 50만 장(전 플랫폼) | EN 88%/5,922, ALL 8,038 |
| 21 | Well Dweller | Kyle Thompson(Islets·Crypt Custodian 제작자) / Top Hat Studios | 2026-09-22 | 미확인 | $19.99 | 공식 판매량 없음 | EN 98%/2,216, ALL 4,705 (출시 2개월) |

출처(행 번호순):
- 1 Nine Sols — 개발사/엔진/출시일/엔딩: [Wikipedia](https://en.wikipedia.org/wiki/Nine_Sols); 80만 장: [TechRaptor via OpenCritic](https://opencritic.com/news/17369/nine-sols-sales-top-800k-developer-red-candle-reveals-techraptor), [Push Square 2025-05](https://www.pushsquare.com/news/2025/05/beloved-brutal-metroidvania-nine-sols-is-on-the-approach-to-selling-1-million-copies); 팀 규모 "풀타임 10명 이상": [Into Indie Games 인터뷰](https://intoindiegames.com/features/nine-sols-an-interview-with-red-candle-games/) — "9명→15명" 보도(The News Lens)와 상충(검색 요약 기준, 원문 미확인); Steam: [스토어](https://store.steampowered.com/app/1809540/)
- 2 Silksong — 팀/엔진/동접/수상: [Wikipedia](https://en.wikipedia.org/wiki/Hollow_Knight:_Silksong); 700만 장(Game Pass 제외): [PC Gamer](https://www.pcgamer.com/games/action/silksong-has-sold-more-than-7-million-copies-in-3-months-and-no-thats-not-counting-game-pass/); Steam: [스토어](https://store.steampowered.com/app/1030300/)
- 3 Lost Crown — 엔진/출시일/130만/300만/수상: [Wikipedia](https://en.wikipedia.org/wiki/Prince_of_Persia:_The_Lost_Crown); 100만 장 및 팀 재배치(2024-10): [Game World Observer](https://gameworldobserver.com/2024/10/23/pop-lost-crown-1-million-copies-team-moved-to-three-projects), [Shacknews](https://shacknews.com/article/141946/ubisoft-prince-of-persia-lost-crown-team-disbanded); Steam: [스토어](https://store.steampowered.com/app/2751000/)
- 4 Animal Well — 1인/7년/자체 엔진/65만: [Wikipedia](https://en.wikipedia.org/wiki/Animal_Well); Steam: [스토어](https://store.steampowered.com/app/813230/)
- 5 Neva — [Wikipedia](https://en.wikipedia.org/wiki/Neva_(video_game)); Gris 300만+: [GamesMarket](https://gamesmarkt.de/previews/neva-cb7d71580564eb6d1630213da19dbbf5); Steam: [스토어](https://store.steampowered.com/app/2420660/)
- 6 Ender Magnolia — 합산 200만: [RPG Site](https://www.rpgsite.net/news/16796-ender-magnolia-ender-lilies-sales-numbers-2-million-units-combined); 추정치 편차: [steamdata.ai](https://steamdata.ai/game/2725260), [VaporLens](https://vaporlens.app/app/2725260/ender_magnolia_bloom_in_the_mist/stats/details); Steam: [스토어](https://store.steampowered.com/app/2725260/)
- 7 Tales of Kenzera — [Wikipedia](https://en.wikipedia.org/wiki/Tales_of_Kenzera:_Zau); 해고: [PC Gamer](https://pcgamer.com/games/action/just-3-months-after-launching-tales-of-kenzera-zau-developer-surgent-studios-lays-off-just-over-a-dozen-employees); 게임 팀 중단: [Push Square 2024-10](https://pushsquare.com/news/2024/10/tales-of-kenzera-zau-dev-surgent-studios-puts-game-team-on-hiatus); Steam: [스토어](https://store.steampowered.com/app/2316580/)
- 8 Ultros — Steam [스토어](https://store.steampowered.com/app/2386310/); 스튜디오 소재지(예테보리·말뫼·스톡홀름 분산): [Nexarda](https://nexarda.com/studios/hadoque-(2282))
- 9 Momodora — 1인 개발(rdein, 2010년부터 시리즈): [Destructoid 등 리뷰 모음 검색](https://www.destructoid.com/reviews/review-momodora-moonlit-farewell/); Steam: [스토어](https://store.steampowered.com/app/1747760/)
- 10 Withering Rooms — 1인 개발 Troy West: [Seasoned Gaming 리뷰](https://seasonedgaming.com/2024/04/24/review-withering-rooms-a-nightmarish-dream); 앞서해보기 2022-10-04: [Game*Spark](https://www.gamespark.jp/article/2022/10/03/123065.html); Steam: [스토어](https://store.steampowered.com/app/2006140/)
- 11 Plucky Squire — Steam [스토어](https://store.steampowered.com/app/1627570/)
- 12 UFO 50 — Steam [스토어](https://store.steampowered.com/app/1147860/); 추정 판매 52.7만(비공식): [VaporLens](https://vaporlens.app/app/1147860/ufo_50/stats/details)
- 13 Ninja Gaiden: Ragebound — 추정치: [Raijin](https://raijin.gg/app/2542120/NINJA_GAIDEN_Ragebound); Steam: [스토어](https://store.steampowered.com/app/2542120/)
- 14 Mandragora — Steam [스토어](https://store.steampowered.com/app/1721060/)
- 15 Possessor(s) — Steam [스토어](https://store.steampowered.com/app/2132890/)
- 16 Constance — Steam [스토어](https://store.steampowered.com/app/2313700/)
- 17 Shinobi — Steam [스토어](https://store.steampowered.com/app/2361770/)
- 18 MIO — Steam [스토어](https://store.steampowered.com/app/1672810/)
- 19 REPLACED — 90만 명(2026-10-14): [WN Hub](https://wnhub.io/news/other/item-52378); 출시: [Thunderful](https://thunderfulgames.com/replaced-is-out-now-on-pc-and-xbox/); Steam: [스토어](https://store.steampowered.com/app/1663850/)
- 20 Mina — 30만/3일: [PC Gamer](https://pcgamer.com/games/action/mina-the-hollower-sells-300-000-in-3-days-yacht-club-games-is-saved); 50만: [Push Square 2026-06](https://www.pushsquare.com/news/2026/06/mina-the-hollower-well-on-its-way-to-saving-dev-sells-half-a-million-copies); 100만을 기대했다는 발언: [Tbreak](https://tbreak.com/mina-the-hollower-sales-yacht-club-games/); Steam: [스토어](https://store.steampowered.com/app/1875580/)
- 21 Well Dweller — 출시/플랫폼: [Invenglobal](https://www.invenglobal.com/articles/26622/metroidvania-action-adventure-well-dweller-released-achieves-overwhelmingly-positive-rating-on-steam); Steam: [스토어](https://store.steampowered.com/app/3699590/)

**B. 한국 개발작 (2024–2026)**

| 작품 | 개발/퍼블리셔 | 출시일 | 장르/서사 포인트 | Steam(2026-11-17) |
|---|---|---|---|---|
| SANABI: A Haunted Day (무료 스핀오프 DLC) | 원더포션 / 네오위즈 | 2025-11-26 | 본편 13년 전, 송 소령 시점의 외전. "한양", "의금부" 등 조선 제도 명칭을 사이버펑크에 이식 | EN 95%/288 — [스토어](https://store.steampowered.com/app/3996620/) |
| (비교) SANABI 본편 | 원더포션 / 네오위즈 | 2023-11-08(Steam 표기) | 스토리 리치 2D 액션 | EN 95%/4,845, **ALL 42,235** — [스토어](https://store.steampowered.com/app/1562700/) |
| The Coma 2B: Catacomb | Dvora Studio / Headup | 2024-10-25 | 한국 고교 배경 2D 횡스크롤 서바이벌 호러, 거울 차원, "도깨비 시장" 지하 시설, 수집형 노트 페이지로 진행 | 75%/598 — [스토어](https://store.steampowered.com/app/1781890/) |
| Solateria | 스튜디오 두달 / 신세계I&C | 2026-03-12 | 패링 중심 메트로배니아, "Untold Stories in a Fallen World" | 82%/782 — [스토어](https://store.steampowered.com/app/2947280/), [바이라인네트워크](https://byline.network/2026/02/19-583/) |
| Fatal Claw | NDEV GAMES / 컴투스홀딩스 | 2026-08-26 | 조상의 힘으로 되살아난 고양이, 지하세계 메트로배니아 | 89%/557 — [스토어](https://store.steampowered.com/app/2827750/) |
| (선행작) 장화홍련: 기억의 조각 (Rose and Lotus: Petals of Memories) | 5minlab / KRAFTON | 2023-06-28 | **장화홍련 원작**. 기억을 잃은 장화가 저택에서 깨어나 홍련과 탈출하는 포인트앤클릭 방탈출 | 78%/32 — [스토어](https://store.steampowered.com/app/699710/) |

**C. 비교작 (기간 내지만 비교용 / 기간 외)**

- Little Nightmares III (Supermassive, 2025-10-09 Steam 표기): EN 49%/5,126 "Mixed", ALL 10,413 — [스토어](https://store.steampowered.com/app/1392860/). 시리즈 누계 2,000만 장(2025-06, III 출시 전) — [VGChartz](https://www.vgchartz.com/article/465064/little-nightmares-series-tops-20-million-units-sold/).
- Rusty Rabbit (Nitroplus/NetEase, 2025-04-16 Steam 표기): 각본 우로부치 겐, 주인공 성우 쿠로다 타카야; Steam 67%/59 "Mixed"; Metacritic "mixed or average" — [스토어](https://store.steampowered.com/app/2530560/), [Nintendo World Report](https://nintendoworldreport.com/review/70857/rusty-rabbit-switch-review), [Siliconera](https://www.siliconera.com/review-rusty-rabbit-feels-well-rusty/).
- Blasphemous 2 – Mea Culpa DLC (2024-10-31): 51%/1,144 "Mixed" — [스토어](https://store.steampowered.com/app/2879370/).
- Bō: Path of the Teal Lotus (2024-07-17): 82%/1,444 — [스토어](https://store.steampowered.com/app/1614440/); Shadow of the Ninja – Reborn (2024-08-29): 71%/601 — [스토어](https://store.steampowered.com/app/2543760/); Haneda Girl (Studio Koba, 2025-05-23): 94%/77 — [스토어](https://store.steampowered.com/app/3169790/); Shadow Labyrinth (Bandai Namco, 2025-07-17): 54%/279 "Mixed" — [스토어](https://store.steampowered.com/app/1859430/); Gestalt: Steam & Cinder (2024-07-16, "Story Rich" 태그): 79%/1,936 — [스토어](https://store.steampowered.com/app/1231990/); Pepper Grinder (2024-03-28): 85%/1,140 — [스토어](https://store.steampowered.com/app/2076580/); BIOMORPH (2024-04-05): 91%/654 — [스토어](https://store.steampowered.com/app/1430220/); Rain World: The Watcher (2025-03-28): EN 77%/2,562 — [스토어](https://store.steampowered.com/app/2857120/).
- 기간 외 비교: Pseudoregalia(2023, 1인) EN 97%/14,239, ALL 17,300 — [스토어](https://store.steampowered.com/app/2365810/); Rusted Moss(2023) 88%/1,645 — [스토어](https://store.steampowered.com/app/1772830/); The Last Faith(2023) EN 85%/1,875 — [스토어](https://store.steampowered.com/app/1274600/); Afterimage(2023, 중국) EN 85%/1,500, ALL 7,085 — [스토어](https://store.steampowered.com/app/1701520/); Detention(2017, Red Candle의 대만 민속 호러) EN 96%/2,887, ALL 13,142 — [스토어](https://store.steampowered.com/app/555220/); Hollow Knight(2017) ALL 509,486 — [스토어](https://store.steampowered.com/app/367520/).
- Nubla 2 (2024-09-12)는 Steam 리뷰 없음 — 사용자가 언급한 "Nubla"는 교육용 퍼즐 플랫포머로 분석 가치 낮음 — [스토어](https://store.steampowered.com/app/1610450/).
- 사용자 후보 중 확인 결과: Islets(2022)·Pseudoregalia(2023)·Rusted Moss(2023)·The Last Faith(2023)는 기간 외. Constance는 2025-11-24, Mina the Hollower는 2026-05에 실제 출시됨.

**D. 시장 맥락**
- GameDiscoverCo는 2025년 Steam 메트로배니아 태그 신작 중 Silksong이 압도적 1위이며, 그 성공을 "원작 Hollow Knight가 이미 확보한 고객층(Steam 1,200만+)" 덕으로 분석 — [GameDiscoverCo](https://newsletter.gamediscover.co/p/5-things-you-didnt-know-about-hollow) (유료 기사, 서두만 확인).
- Mina the Hollower는 2026년 Metacritic 최고점 공동 1위였지만, Yacht Club 대표는 "가장 평이 좋은 게임이 왜 가장 빨리 팔리는 게임이 아닌가"라고 언급 — [GamesRadar](https://www.gamesradar.com/games/action/saving-the-studio-mina-the-hollower-sells-300-000-copies-in-3-days-as-head-wonders-how-come-the-best-reviewed-game-of-2026-is-not-the-fastest-selling-game/).

### Inferences
- 공식 수치 기준 상위권(Silksong, Lost Crown, Nine Sols, Animal Well, Mina, REPLACED)에는 "대사 거의 없음"(Animal Well)부터 "컷신·대사 대량"(Nine Sols, REPLACED)까지 모두 포함된다. 서사의 *양*은 흥행 예측 변수가 아니다.
- Lost Crown(130만 장)과 Tales of Kenzera(대형 퍼블리셔·BAFTA 수상에도 해고)는 "평단의 서사적 호평 ≠ 매출"을 보여준다. 반대로 1인/초소규모(Animal Well, Withering Rooms, Momodora, Well Dweller)는 서사를 최소화하고도 높은 긍정률을 기록.
- SANABI 본편의 ALL(42,235) 대비 EN(4,845) 비율은 영어권 밖(한국어·중국어 등) 리뷰 비중이 매우 크다는 뜻으로, 한국적 소재의 스토리 중심 2D 액션이 국내·아시아 시장에서 강한 반응을 얻을 수 있다는 정황 증거다(언어별 분포는 직접 확인하지 않음).
- 장화홍련 소재는 이미 2023년 포인트앤클릭(기억상실 + 저택 탈출)으로 상업화된 적이 있으나 리뷰 32건으로 존재감이 작았다. "소재 선점"보다는 장르(플랫포머+루프)와 재해석 각도로 차별화해야 한다.

### Gaps
- 대부분 작품의 엔진·팀 규모가 공개 자료로 확인되지 않음("미확인"으로 표기). 특히 Ultros(Hadoque) 인원, Neva 팀 규모, Constance/Mandragora 개발사 소재국은 이번 조사에서 1차 출처로 검증하지 못함.
- Neva, Ender Magnolia, Ultros, MIO, Constance, Possessor(s), Well Dweller, 한국작 4종의 공식 판매량은 찾지 못함. 제3자 추정치(steamdata.ai, VaporLens, Raijin 등)는 서로 최대 4배 차이.
- Silksong 확장 "Sea of Sorrow"는 2025-12-15에 2026년 무료 출시로 발표됐으나([Game Informer](https://gameinformer.com/2025/12/16/hollow-knight-silksong-sea-of-sorrow-is-a-free-nautical-expansion-launching-next-year)), 2026-11-17 현재 출시 여부는 확인하지 못함.
- Steam 리뷰 API(appreviews)가 차단되어 전 언어 긍정률은 일부 작품만 확보. ALL 수치는 총 리뷰 수만 의미.
- Mina the Hollower의 스토리 구조는 이번 조사 범위에서 확인하지 못함.

---

## Q2. 각 작품은 이야기를 어떻게 전달하는가? (전제·전달 채널·구조·메커닉과 주제의 연결·서사에 대한 평가)

### Takeaway
전달 채널은 크게 ① 컷신/초상화 대화 중심(Nine Sols, Lost Crown, REPLACED, Possessor(s), Mandragora), ② NPC 대화 + 환경(Silksong, MIO, Well Dweller), ③ 거의 무언(Neva, Animal Well, Little Nightmares III)으로 나뉜다. 평단이 가장 높게 친 서사는 "주제가 조작감·성장 시스템에 녹아든" 경우(Neva의 늑대 성장, Constance의 물감 오염, Nine Sols의 '태양=보스' 구조)였고, 가장 많이 비판받은 것은 "설명이 많은데 감정이 안 붙는" 경우(Lost Crown, Possessor(s), Rusty Rabbit)였다.

### Cited Findings

**Nine Sols (대만, 2024)**
- 전제: 열 번째 솔인 '예(Yi)'가 신쿤룬을 지배하는 아홉 솔에게 복수. 개발진은 이 세계를 "타오펑크(taopunk)"라 부름 — [Wikipedia](https://en.wikipedia.org/wiki/Nine_Sols).
- 기원: 프로토타입 단계에서 "후예(后羿)가 열 개의 태양을 쏜 신화를 SF로 바꾸면?"이라는 아이디어에서 출발, 신화 속 '태양'들이 소울라이크 보스 구조와 자연스럽게 맞물렸다고 설명. 스토리텔링 참고작은 곤 사토시의 《파프리카》《퍼펙트 블루》, 철학/캐릭터는 《에반게리온》 — [Digital Trends 인터뷰](https://www.digitaltrends.com/gaming/nine-sols-taopunk-developer-interview/).
- 호러 2편(Detention, Devotion) 이후 번아웃으로 새 장르를 시도했다고 함 — [Digital Trends](https://www.digitaltrends.com/gaming/nine-sols-taopunk-developer-interview/).
- 구조: 엔딩 2종(노멀/트루). 수집한 아이템과 NPC와의 상호작용으로 분기 **[경미한 스포일러: 엔딩 제목은 Wikipedia에 명시]** — [Wikipedia](https://en.wikipedia.org/wiki/Nine_Sols).
- 전달: 리뷰들은 "메트로배니아 장르에서 가장 시네마틱하고 명시적으로 이야기하는 작품 중 하나", 만화 컷 형식 패널이 이야기를 보충, 대사가 유머러스하고 캐릭터를 살린다고 평가 — [OpenCritic 리뷰 모음](https://opencritic.com/game/16798/view/reviews) (검색 요약 기반, 개별 매체 귀속은 미확인).
- 텍스트량: "방대한 양의 텍스트를 공들여 작성"했다는 보도 — [Game Developer 보도자료](https://www.gamedeveloper.com/press-release/nine-sols-ventures-into-new-territory-red-candle-games-stylized-taopunk-action-platformer-aims-for-global-market) (검색 요약 기반, 정확한 단어 수 없음).
- 비판: 대사만으로 된 회상 컷신의 페이싱, 일부 플레이어는 "혼란스럽거나 진부하거나 플레이를 방해한다"고 느낌, 컷신 일시정지 불가 — [OpenCritic 리뷰 모음](https://opencritic.com/game/16798/view/reviews) (검색 요약 기반).
- Steam 태그 상위에 "Story Rich" 포함 — [Steam](https://store.steampowered.com/app/1809540/).

**Hollow Knight: Silksong (호주, 2025)**
- 전제: 전작 조연 호넷이 납치되어 순례자의 왕국 파롬(Pharloom)으로 끌려가 '저주(Haunting)'에 걸린 존재들과 싸우고 성채를 지배하는 존재와 대면 — [Wikipedia](https://en.wikipedia.org/wiki/Hollow_Knight:_Silksong).
- 전달: NPC 대화와 환경 이미지로 서사 전달. 사이드퀘스트 'Wishes'를 NPC와 의뢰 게시판으로 제공·메뉴로 추적. 전작의 무언 주인공과 달리 호넷이 "날카롭고 퉁명스러워 웃긴" 대사를 함(NME) — [Wikipedia](https://en.wikipedia.org/wiki/Hollow_Knight:_Silksong).
- 구조 **[스포일러]**: 엔딩 다수. 특정 조건(일정 수의 Wish·목표 달성)을 채운 엔딩 이후 이어서 3막으로 진행되는 구조 — [Wikipedia](https://en.wikipedia.org/wiki/Hollow_Knight:_Silksong), [Hollow Knight Wiki](https://hollowknight.wiki/w/Endings_(Silksong)).
- 평가: IGN은 "글이 일관되게 강하다", VGC는 사이드퀘스트 NPC들의 캐릭터성과 유머를 칭찬. 반면 일부 사이드퀘스트는 "영감 없고 단조롭다"는 평 — [Wikipedia](https://en.wikipedia.org/wiki/Hollow_Knight:_Silksong).
- 현지화: 간체 중국어 번역 품질로 중국어권 부정 리뷰 1만 4천 건 이상, Team Cherry가 사과·재번역 약속, 팬 번역 모드 권장 — [GamesRadar](https://www.gamesradar.com/games/action/as-hollow-knight-silksongs-wonky-chinese-translation-leads-to-over-14-000-negative-steam-reviews-team-cherry-says-well-be-working-to-improve-the-translation-over-the-coming-weeks), [PC Gamer](https://www.pcgamer.com/games/action/hollow-knight-silksong-sinks-to-mixed-steam-review-status-among-chinese-gamers-over-its-bafflingly-bad-translation-with-team-cherry-promising-to-improve-it). 이후 패치 5에서 번체 중국어 추가·독일어 대본 대폭 수정 — [Team Cherry 블로그](https://www.teamcherry.com.au/blog/silksong-patch-5).

**Prince of Persia: The Lost Crown (프랑스, 2024)**
- 전제: 불사대(Immortals)의 젊은 전사 사르곤이 저주받은 카프산(Mount Qaf)에서 납치된 왕자를 구출. 시간 이상 현상으로 불사대가 성채에 갇힘, 시무르그의 깃털로 능력 획득 — [Wikipedia](https://en.wikipedia.org/wiki/Prince_of_Persia:_The_Lost_Crown).
- 신화 활용: 카프산은 페르시아 신화에서 시무르그가 사는 세계의 끝. 시무르그 이야기와 '일곱 계곡' 구조가 7명의 불사대 및 사르곤의 통과의례 서사에 영향 — [TheSixthAxis](https://www.thesixthaxis.com/2024/02/19/how-prince-of-persia-the-lost-crown-is-steeped-in-persian-mythology-playing-with-history/).
- 전달: 서사 비중을 크게 둠, 애니메(소년만화) 스타일, 전투 컷신, 맵 곳곳의 로어 노트로 사르곤 혈통에 관한 예언 공개, 페르시아어 더빙 지원 — [Wikipedia](https://en.wikipedia.org/wiki/Prince_of_Persia:_The_Lost_Crown), [GameSpot(애니 영향)](https://Gamespot.Com/articles/how-prince-of-persia-the-lost-crown-leans-into-its-shonen-anime-inspirations/1100-6519919/).
- 메커닉-주제: 시간 능력(시간의 모래), 디렉터는 "시간보다 공간 조작"을 강조 — [GamesRadar 인터뷰](https://www.gamesradar.com/prince-of-persia-lost-crown-interview).
- 평가(서사): "진행할수록 서사가 배경으로 밀려남", 조연이 거의 발전하지 않음(GameSpot), "불필요하게 복잡하고 난해"(GamesRadar+), 핵심 장면 전달이 어색해 감정 이입 불가(PC Gamer), 빠진 스토리 줄기가 최대 약점(VG247) — [Wikipedia 반응 섹션](https://en.wikipedia.org/wiki/Prince_of_Persia:_The_Lost_Crown).

**ANIMAL WELL (미국, 1인, 2024)**
- "목표·플롯·배경 설명이 전혀 주어지지 않음". 개발자는 "컷신 금지, 모든 정보는 환경이 전달"을 스스로 제약으로 설정 — [Wikipedia](https://en.wikipedia.org/wiki/Animal_Well).
- 구조: 4개 레이어. 2층=숨은 지역과 알, 3층=숨은 토끼와 ARG 요소(최소 50명 플레이어의 부분 해답이 필요한 퍼즐 포함), 4층=반복 플레이 도전 — [Wikipedia](https://en.wikipedia.org/wiki/Animal_Well).
- 평가: "퍼즐 해결자·보물찾기꾼의 꿈"(IGN·Polygon·PC Gamer), "환경 디자인의 마스터클래스"(Game Informer); D.I.C.E. 게임 디렉션 부문 수상 — [Wikipedia](https://en.wikipedia.org/wiki/Animal_Well). Steam 태그에 "Horror" 포함 — [Steam](https://store.steampowered.com/app/813230/).

**Neva (스페인, 2024)**
- 전제/구조: 알바와 늑대 네바가 어둠에 오염된 세계를 정화. 4개 챕터(계절)에 걸쳐 네바가 새끼에서 성체로 성장 — [Wikipedia](https://en.wikipedia.org/wiki/Neva_(video_game)).
- 전달: 거의 무언. 유일한 대사는 알바가 다양한 억양으로 "네바"를 부르는 것. 해석의 여지를 남기려는 의도 — [Wikipedia](https://en.wikipedia.org/wiki/Neva_(video_game)).
- 메커닉-주제: 전투가 둘의 관계 변화를 반영(Polygon) — [Wikipedia](https://en.wikipedia.org/wiki/Neva_(video_game)).
- 평가: "2024년 가장 가슴 아픈 게임"(Rolling Stone), 짧은 런타임으로 강한 감정을 끌어냄(Guardian). TGA 2024 Games for Impact 수상, BAFTA Artistic Achievement 수상 — [Wikipedia](https://en.wikipedia.org/wiki/Neva_(video_game)).

**Tales of Kenzera: ZAU (영국, 2024)**
- 전제: 젊은 주술사 자우가 죽음의 신 칼룽가에게 세 영혼을 바쳐 아버지를 되살리려 함. 크리에이티브 리드 아부바카 살림이 실제 아버지를 잃은 슬픔과 반투(Bantu) 문화에서 착안 — [Wikipedia](https://en.wikipedia.org/wiki/Tales_of_Kenzera:_Zau), [PC Gamer](https://pcgamer.com/games/action/just-3-months-after-launching-tales-of-kenzera-zau-developer-surgent-studios-lays-off-just-over-a-dozen-employees).
- 평가: Metacritic 76(PC/PS5/Xbox), BAFTA "Game Beyond Entertainment" 수상, TGA Games for Impact 후보, NYGA 연기상(살림) 후보 — [Wikipedia](https://en.wikipedia.org/wiki/Tales_of_Kenzera:_Zau).
- 상업: 출시 3개월 만에 10여 명 해고 — [PC Gamer](https://pcgamer.com/games/action/just-3-months-after-launching-tales-of-kenzera-zau-developer-surgent-studios-lays-off-just-over-a-dozen-employees). Steam에 한국어 미지원 — [Steam](https://store.steampowered.com/app/2316580/).

**Ultros (스웨덴, 2024) — 타임루프 메트로배니아**
- 전제: 블랙홀의 영원한 루프에 갇힌 우주 자궁 "사르코파구스"에 불시착. "이 순환을 끊을 것인가, 파괴에서 재생으로 잇는 고리가 될 것인가". 정신 건강·삶과 죽음·업(karma)의 순환을 "깊은 로어와 환경 스토리텔링"으로 다룬다고 소개 — [Steam](https://store.steampowered.com/app/2386310/).
- 루프 구조: 7개 주요 목표 중 하나를 달성할 때마다 사이클 시작점에서 다시 깨어남, 맵은 루프 간 유지 — [Hooked Gamers](https://hookedgamers.com/pc/ultros/review/article-2503.html), [Life is Xbox](https://lifeisxbox.eu/xbox-review-ultros).
- 평가: PC Gamer(82점)는 "순환과 공생, 죽음과 재생의 이야기", "난해한 타임루프 선(禪) 여정"으로 호평 — [PC Gamer](https://pcgamer.com/ultros-review). 반면 "자주 혼란스러웠다", "완전히 다른 언어를 읽는 느낌" — [Siliconera](https://siliconera.com/review-ultros-is-a-psychedelic-trip-with-a-familiar-formula); "루프 설계를 정당화하는 서사가 특별하지 않음" — [Gameluster](https://gameluster.com/?p=101913); "흥미롭지만 일관성은 부족" — [Galaxus](https://www.galaxus.ch/en/page/ultros-a-fever-dream-exciting-but-not-quite-coherent-31749). 사용자 리뷰 요약: 짧고 단순한 무음성 컷신, 깊이 부족 — [VaporLens](https://vaporlens.app/app/2386310/ultros).
- 상업: Steam 812건 80% — 2024년 주요작 중 리뷰 수 하위권 — [Steam](https://store.steampowered.com/app/2386310/).

**Withering Rooms (미국, 1인, 2024) — 2.5D 호러**
- 전제/구조: 매일 밤 구조가 재배치되는 빅토리아풍 저택(절차적 생성)에서 벌어지는 2.5D 호러 로그라이트 — [God is a Geek](https://godisageek.com/reviews/withering-rooms-review/), [CogConnected](https://cogconnected.com/review/withering-rooms-review/). 한 리뷰는 "끝나지 않는 호러 루프"로 요약 — [Indie Games Devel](https://indiegamesdevel.com/withering-rooms-review-an-endless-horror-loop-you-wont-easily-forget/).
- 평가: 고딕 호러 분위기·하프시코드 음악은 호평, 전투가 둔하고 시스템 설명 부족은 비판. Metacritic PC 75 — [God is a Geek](https://godisageek.com/reviews/withering-rooms-review/), [CogConnected](https://cogconnected.com/review/withering-rooms-review/). Steam 96% "압도적 긍정" — [Steam](https://store.steampowered.com/app/2006140/).

**The Plucky Squire (2024) — 메타픽션**
- 전제: 동화책 악당 험그럼프가 자신이 "늘 지는 악당"임을 자각하고 이야기를 다시 쓰려 주인공 조트를 책 밖으로 내쫓음 → 2D 책 속과 3D 책상 세계를 오가는 구조 — [Slant Magazine 등 리뷰](https://slantmagazine.com/games/the-plucky-squire-review).
- 평가: 메타 요소는 "기믹이 아니라 게임의 주제 자체"라는 호평이 많지만, 이야기 자체는 "종이처럼 얇다"(AV Club), "폭은 1마일, 깊이는 1인치"(Nintendo World Report), 초반 소개가 길다(Windows Central) — [AV Club](https://www.avclub.com/the-plucky-squire-review), [NWR](https://nintendoworldreport.com/review/68842/the-plucky-squire-switch-review), [Windows Central](https://www.windowscentral.com/gaming/the-plucky-squire-pc-review).

**UFO 50 (미국, 2024) — 메타 앤솔로지**
- 1980년대 가상의 회사 UFO Soft와 콘솔 LX의 대체 역사를 컬렉션 곳곳의 로어 조각으로 제시, 숨겨진 "51번째 게임"은 메타서사에 대한 메타서사로 보이며 개발진은 언급을 거부 — [PC Gamer](https://pcgamer.com/games/action/unsurprisingly-ufo-50-seems-to-have-a-big-secret-meta-game-that-ive-only-just-scratched-the-surface-of), [GamesRadar](https://www.gamesradar.com/platforms/pc-gaming/spelunky-legends-50-game-collection-of-roguelikes-jrpgs-and-more-launches-to-91-reviews-and-the-sudden-revelation-that-its-hiding-far-more-than-50-games). Metacritic 91 — [Steam](https://store.steampowered.com/app/1147860/).

**Constance (2025) — 번아웃 알레고리**
- 전제: 붓을 든 화가가 쇠퇴하는 정신 건강이 만든 내면 세계에서 탈출. 메커닉: 붓 기술 사용 시 물감이 '오염'되고 완전 오염 시 페널티, 여행 중 얻은 영감을 일지(journal)에 스케치해 능력 강화, 사망 시 "대가를 치르고 계속" 또는 "안전 지점 복귀" 선택 — [Steam](https://store.steampowered.com/app/2313700/).
- 평가: "이야기는 희박하지만 감정적으로 무겁다"(Geekly Grind), "진심이지만 일관성 부족"(ComicBook), 이동 불편함이 주인공의 심리를 반영(NoSmokeSport), "정신질환을 다루는 인디 메트로배니아는 이제 다소 클리셰"(Nintendo Life), OpenCritic 개별 점수 4/10~10/10 — [Geekly Grind](https://www.thegeeklygrind.com/archives/constance-review), [ComicBook](https://comicbook.com/gaming/review/constance-review-a-beautiful-hollow-knight-esque-metroidvania-about-burnout/), [Nintendo Life](https://www.nintendolife.com/reviews/switch-eshop/constance), [OpenCritic](https://opencritic.com/game/19641/constance/reviews?page=1).

**Mandragora (2025) — 분기 대화형 2.5D 소울라이크**
- 브라이언 미츠다(Vampire: Bloodlines 작가)가 이야기와 분기 서사 담당, 대화·선택으로 주인공(심문관) 정체성 형성, 대체 엔딩 — [MY.GAMES 인터뷰](https://about.my.games/news/428), [보도자료](https://gamespress.com/Mandragora-Whispers-of-the-Witch-Tree-Launches-Today).
- 평가: 대사·연기는 몰입감 있다는 호평. 그러나 "선택지가 이야기 방향에 실질적 영향이 없다", "탐색·백트래킹 때문에 이야기 진전 사이에 몇 시간이 흐른다", 예측 가능한 전개·들쭉날쭉한 성우 연기 — [MobileSyrup](https://mobilesyrup.com/2025/05/12/mandragora-review/), [Gaming Trend](https://gamingtrend.com/reviews/mandragora-whispers-of-the-witch-tree-review-glinda-elphaba-or-something-else-entirely), [Gamepressure](https://www.gamepressure.com/editorials/reviews/mandragora-whispers-of-the-witch-tree-review-short-of-a-screaming/ze76a).

**Possessor(s) (2025) — 비선형 + 대사 다량**
- 전제: 차원 재난으로 침수된 도시에서 숙주 루카와 비협조적 악마 렘이 한 몸으로 공존 — [Steam](https://store.steampowered.com/app/2132890/).
- 평가: 핵심 스토리 비트를 아무 순서로나 접할 수 있어 디테일을 놓치기 쉬움(CogConnected), 대사가 많은데 전부 무음성이라 읽을 양이 많음(LootLevelChill), "평범한 글"(Gaming Trend) vs "Heart Machine 최고의 스토리텔링"(Punished Backlog) — [CogConnected](https://cogconnected.com/review/possessors-review/), [LootLevelChill](https://lootlevelchill.com/reviews/possessors-review/), [Gaming Trend](https://gamingtrend.com/reviews/possessor-s-review-heart-machine-needs-a-defibrillator/), [Punished Backlog](https://punishedbacklog.com/possessors-review/?amp=1).

**MIO: Memories in Orbit (프랑스, 2026)**
- 전제: 기능이 멈춘 우주 방주 "Vessel"에서 깨어난 안드로이드 MIO가 잃어버린 기억을 되살림. 고장 난 로봇을 수리하면 방주의 과거를 알려줌 — [Steam](https://store.steampowered.com/app/1672810/).
- 평가: 이야기는 대부분 환경과 로봇들의 짧은 대사로 전달, 환경 단서로 방주의 역사를 맞춰가는 것이 가장 즐거운 부분(Destructoid), 환경 스토리텔링이 거대한 바이옴을 정당화(Slant), OpenCritic 85% 추천 — [Slant](https://www.slantmagazine.com/games/mio-memories-in-orbit-review/), [OpenCritic](https://opencritic.com/game/19840/-/reviews?page=3).

**REPLACED (2026) — 시네마틱 2.5D**
- 전제: 인간 몸에 갇힌 AI R.E.A.C.H.가 대체역사 1980년대 미국에서 자신을 만든 기업과 대면, "AI는 인간이 될 수 있는가" — [Steam](https://store.steampowered.com/app/1663850/). Steam 태그 "Cinematic", "Narrative" — [Steam](https://store.steampowered.com/app/1663850/).

**Well Dweller (2026) — 다크 동화**
- 전제: 성냥개비를 든 작은 새 글리머가 사악한 여왕을 불태워 가족을 구함. 사냥꾼에게 잡혀간 형제자매를 찾아 재회, 왕국 밑바닥의 NPC들과 동행 — [Steam](https://store.steampowered.com/app/3699590/).
- 평가: 이야기는 "여정 속에" 있음, 모든 NPC가 여왕에게 당한 각자의 사연을 갖고 있어 "조용한 슬픔"을 준다 — [Siliconera](https://www.siliconera.com/review-well-dweller-is-as-charming-as-islets-and-crypt-custodian/), [GameSpew](https://www.gamespew.com/2026/10/well-dweller-review/). 동화의 어두움을 게임으로 옮겼다는 개발 인터뷰 — [80.lv](https://80.lv/articles/developer-turns-darkness-of-classic-fairy-tales-into-video-game).

**Ender Magnolia (일본, 2025)**
- 전제: 과학과 마법이 만든 호문쿨루스가 사는 '연기의 땅'을 조율사 릴락이 횡단 — [God is a Geek](https://godisageek.com/2024/04/ender-magnolia-bloom-in-the-mist-is-early-access-review/).
- 구조: 전작처럼 엔딩 2종(A/B, B가 진엔딩), 엔딩 후 마지막 체크포인트에서 이어 다른 엔딩 도달 가능 — [Insider Gaming](https://insider-gaming.com/how-to-get-the-ending-b-in-ender-magnolia/).

**Momodora: Moonlit Farewell (1인, 2024)**
- 5부작·약 15년 시리즈의 완결편. 리뷰는 "짧고 스토리·캐릭터를 깊게 파지 않는다", 일부 플레이어는 엔딩이 "다소 밋밋한 작별"이라 평가 — [Switchaboo](https://switchaboo.com/momodora-moonlit-farewell-switch-review), [Backloggd](https://backloggd.com/u/APairofTimbs/review/1451653).

**The Coma 2B: Catacomb (한국, 2024)**
- 전제: 전작 주인공 영호가 거울 차원 "코마"로 돌아가 예솔의 노트 페이지를 모아 성검의 위치를 찾고, 도깨비 시장 아래 시설의 비밀을 푼다. 시리즈 사이를 잇는 '브릿지' 스토리 — [Steam](https://store.steampowered.com/app/1781890/).
- 평가: 영호는 성장하는 호감형 주인공, 만화풍 그림이 고어를 완화. 그러나 숨기 미니게임이 지나치게 길고 어려움, 스토리 일관성 부족, 최고의 순간은 전작 지식에 의존 — [Cubed3(6/10)](https://www.cubed3.com/games/reviews/nintendo-switch/the-coma-2b-catacomb), [Gameluster](https://gameluster.com/the-coma-2b-catacomb-review-difficult-nightmare-escape/).

**Rusty Rabbit (일본, 2025, 비교)**
- 우로부치 겐 원안·각본, 늙은 토끼 스탬프가 딸을 찾는 이야기. 톤과 주인공은 호평, 게임플레이는 "실망" — [Siliconera](https://www.siliconera.com/review-rusty-rabbit-feels-well-rusty/), [Shacknews](https://shacknews.com/article/143882/rusty-rabbit-review-score).

### Inferences
- **주제-메커닉 결합도가 서사 평가를 좌우**: Neva(관계 성장=전투 변화), Constance(정신 상태=물감 오염 게이지), Nine Sols(신화의 태양=보스)는 "이야기를 플레이로 체험"시켰다는 평가를 받았다. 반면 Lost Crown·Possessor(s)·Mandragora처럼 이야기가 컷신/대화창에 따로 떨어져 있으면 "배경으로 밀려남", "선택이 무의미" 비판이 나왔다.
- **루프 구조는 '읽히는 변화'가 필수**: Ultros는 루프를 핵심 정체성으로 내세웠으나 각 루프가 무엇을 바꾸는지가 불명확해 "혼란"과 "평범한 서사" 평을 받았고 상업적으로도 하위권이었다. Withering Rooms는 '매일 밤 재배치되는 저택'이라는 직관적 루프를 호러 긴장감의 엔진으로 써서 1인 개발로 96% 긍정을 얻었다.
- **비선형 + 다량 텍스트 = 위험 조합**: Possessor(s)는 순서 자유 + 무음성 다량 대사로 "디테일 손실, 읽을 게 많음"이 지적됐다. 메트로배니아에서 장문 대사를 쓸 거라면 핵심 비트는 선형으로 고정하는 편이 안전하다.
- 사용자의 시스템(초상화창·말풍선·바크·문서/일지·자막 큐)은 위 성공 사례의 채널(Silksong의 NPC 대화+퀘스트, MIO의 로봇 짧은 대사, Constance의 일지, Coma 2B의 노트 페이지)을 모두 커버한다.

### Gaps
- 어느 작품도 공개된 스크립트 단어 수를 찾지 못함(Silksong 단어 수 검색도 실패). Nine Sols 음성 언어(실제 언어/가상 언어) 여부, Silksong 호넷 음성 여부는 이번 조사로 확인 못함.
- Ender Magnolia의 로어 전달 방식(기억 조각·노트 등)은 1차 출처로 확인하지 못함.
- Tales of Kenzera의 프레임 장치(아버지의 책)·전달 방식, Neva·Animal Well의 정확한 플레이 시간은 확인 못함.
- Ninja Gaiden: Ragebound, Shinobi: Art of Vengeance, Mina the Hollower의 서사 구조는 이번 조사에서 다루지 못함(데이터 표에만 포함).

---

## Q3. 장르 특유의 서사 패턴은 무엇이며, 어떤 패턴이 상업적 성공과 상관이 있는가?

### Takeaway
10개 패턴을 도출했다. 흥행작에서 반복해서 보이고 비판도 적었던 것은 (1) 탐색을 통한 로어 + 짧은 NPC 대사(Silksong·Animal Well·MIO), (2) 신화/문화 특수성을 '장르로 재해석'하는 방식(Nine Sols), (3) 완성도 조건으로 잠긴 진엔딩(Nine Sols·Silksong·Ender Magnolia)이다. 다만 컷신 중심 작품(Nine Sols·REPLACED)도 흥행했으므로 채널 자체가 흥행을 결정하지는 않는다. 슬픔·정신 건강 알레고리와 무언 서사는 수상(Games for Impact, BAFTA)에는 강하지만 판매를 보장하지 않으며, 장문 컷신·분기 선택은 비용 대비 효과가 가장 불확실했다. 단, 이는 상관관계이며 모든 상위작의 공통 분모는 "핵심 플레이의 완성도"였다.

### Cited Findings

**패턴 1 — 신화·문화 특수성을 다른 장르로 '번역'하기**
- Nine Sols: 후예 신화를 SF로 바꾼 "타오펑크" → 80만 장 — [Digital Trends](https://www.digitaltrends.com/gaming/nine-sols-taopunk-developer-interview/), [OpenCritic/TechRaptor](https://opencritic.com/news/17369/nine-sols-sales-top-800k-developer-red-candle-reveals-techraptor).
- Lost Crown: 페르시아 신화(시무르그·카프산)를 소년만화 톤으로 → 첫해 130만 장이지만 기대 미달 — [TheSixthAxis](https://www.thesixthaxis.com/2024/02/19/how-prince-of-persia-the-lost-crown-is-steeped-in-persian-mythology-playing-with-history/), [Wikipedia](https://en.wikipedia.org/wiki/Prince_of_Persia:_The_Lost_Crown).
- Tales of Kenzera: 반투 신화 + 개인적 상실 → BAFTA 수상, 그러나 판매량 미공개·출시 3개월 후 해고·이후 게임 부문 중단 보도(판매 부진은 정황이며 개발 리드는 판매 부진 보도를 부인했다는 보도도 있음, 검색 요약 기반) — [Wikipedia](https://en.wikipedia.org/wiki/Tales_of_Kenzera:_Zau), [PC Gamer](https://pcgamer.com/games/action/just-3-months-after-launching-tales-of-kenzera-zau-developer-surgent-studios-lays-off-just-over-a-dozen-employees).
- SANABI 외전: 조선 제도 명칭(한양·의금부)을 사이버펑크로 — [Steam](https://store.steampowered.com/app/3996620/). Well Dweller: 고전 동화의 어두움을 메트로배니아로 → 98% 긍정 — [80.lv](https://80.lv/articles/developer-turns-darkness-of-classic-fairy-tales-into-video-game), [Steam](https://store.steampowered.com/app/3699590/).

**패턴 2 — 슬픔·치유·정신 건강 알레고리**
- Neva(상실/양육, TGA Games for Impact 수상), Tales of Kenzera(아버지 상실, BAFTA Beyond Entertainment 수상), Constance(번아웃), Ultros(정신 건강·순환) — [Neva Wikipedia](https://en.wikipedia.org/wiki/Neva_(video_game)), [Kenzera Wikipedia](https://en.wikipedia.org/wiki/Tales_of_Kenzera:_Zau), [Constance Steam](https://store.steampowered.com/app/2313700/), [Ultros Steam](https://store.steampowered.com/app/2386310/).
- Nintendo Life는 2025년 말 "정신질환을 다루는 인디 메트로배니아는 다소 클리셰가 됐다"고 지적 — [Nintendo Life](https://www.nintendolife.com/reviews/switch-eshop/constance).

**패턴 3 — 탐색을 통한 로어 / 환경 스토리텔링 (장르의 기본값)**
- Silksong: NPC 대화와 환경 이미지로 서사 — [Wikipedia](https://en.wikipedia.org/wiki/Hollow_Knight:_Silksong). MIO: 환경 단서와 로봇의 짧은 대사 — [Slant](https://www.slantmagazine.com/games/mio-memories-in-orbit-review/). Animal Well: 컷신 0, 환경이 모든 정보 전달 → 1인 개발 65만 장 — [Wikipedia](https://en.wikipedia.org/wiki/Animal_Well).
- Lost Crown도 맵 곳곳의 로어 노트로 주인공 혈통의 예언을 공개 — [Wikipedia](https://en.wikipedia.org/wiki/Prince_of_Persia:_The_Lost_Crown). Coma 2B는 노트 페이지 수집이 진행 동력 — [Steam](https://store.steampowered.com/app/1781890/).

**패턴 4 — 무언(Wordless) 서사**
- Neva: 이름 부르기 외 대사 없음, 다수 수상 — [Wikipedia](https://en.wikipedia.org/wiki/Neva_(video_game)). Animal Well: 플롯 자체가 없음 — [Wikipedia](https://en.wikipedia.org/wiki/Animal_Well).
- 반례: Little Nightmares III는 무언 서사 시리즈(누계 2,000만 장)임에도 Steam EN 49% "Mixed" — [Steam](https://store.steampowered.com/app/1392860/), [VGChartz](https://www.vgchartz.com/article/465064/little-nightmares-series-tops-20-million-units-sold/).

**패턴 5 — 말하는 주인공 + NPC 사이드스토리**
- Silksong은 전작과 달리 주인공 호넷이 말하며, 사이드퀘스트 NPC의 캐릭터성·유머가 호평 — [Wikipedia](https://en.wikipedia.org/wiki/Hollow_Knight:_Silksong). Well Dweller의 "모든 NPC가 여왕에게 당한 사연" — [GameSpew](https://www.gamespew.com/2026/10/well-dweller-review/). Possessor(s)는 "위험한 캐릭터들을 통해 전달되는 이야기"를 표방 — [Steam](https://store.steampowered.com/app/2132890/).

**패턴 6 — 보스전 = 캐릭터 비트**
- Nine Sols: 신화의 '태양들'이 곧 보스이며 이 구조가 소울라이크 보스전과 자연스럽게 맞물림 — [Digital Trends](https://www.digitaltrends.com/gaming/nine-sols-taopunk-developer-interview/). Lost Crown: 전투 컷신 — [Wikipedia](https://en.wikipedia.org/wiki/Prince_of_Persia:_The_Lost_Crown). Silksong **[스포일러]**: 최종 보스/조건에 따라 엔딩 분기 — [Wikipedia](https://en.wikipedia.org/wiki/Hollow_Knight:_Silksong).

**패턴 7 — 완성도 조건으로 잠긴 멀티엔딩/진엔딩**
- Nine Sols(아이템 수집 + NPC 상호작용 → 트루엔딩) — [Wikipedia](https://en.wikipedia.org/wiki/Nine_Sols); Silksong(Wish·목표 달성 → 추가 엔딩과 3막) — [Wikipedia](https://en.wikipedia.org/wiki/Hollow_Knight:_Silksong); Ender Magnolia(A/B, 배드엔딩은 쉽고 진엔딩은 오래 걸림) — [Insider Gaming](https://insider-gaming.com/how-to-get-the-ending-b-in-ender-magnolia/).
- 반면 "선택"에 의한 분기를 내세운 Mandragora는 "선택이 실질적 영향 없음" 비판 — [MobileSyrup](https://mobilesyrup.com/2025/05/12/mandragora-review/).

**패턴 8 — 루프·순환·기억 구조**
- Ultros(타임루프, 혼란 비판, 812 리뷰) — [PC Gamer](https://pcgamer.com/ultros-review), [Siliconera](https://siliconera.com/review-ultros-is-a-psychedelic-trip-with-a-familiar-formula); Withering Rooms(밤마다 재배치되는 저택, 96%) — [God is a Geek](https://godisageek.com/reviews/withering-rooms-review/); Lost Crown(시간 이상·시간 능력) — [Wikipedia](https://en.wikipedia.org/wiki/Prince_of_Persia:_The_Lost_Crown); MIO(잃어버린 기억 복원) — [Steam](https://store.steampowered.com/app/1672810/); 장화홍련: 기억의 조각(기억상실 시작) — [Steam](https://store.steampowered.com/app/699710/).

**패턴 9 — 메타픽션은 '발견 레이어'로 쓸 때 강함**
- UFO 50: 가상 회사 로어와 숨겨진 51번째 게임이 커뮤니티 발견을 유도, Metacritic 91 — [PC Gamer](https://pcgamer.com/games/action/unsurprisingly-ufo-50-seems-to-have-a-big-secret-meta-game-that-ive-only-just-scratched-the-surface-of), [Steam](https://store.steampowered.com/app/1147860/). Animal Well: 50명+ 협력이 필요한 ARG형 퍼즐 — [Wikipedia](https://en.wikipedia.org/wiki/Animal_Well).
- The Plucky Squire: 메타가 '본편 플롯'일 때 개념은 호평이나 이야기 "얇다" — [AV Club](https://www.avclub.com/the-plucky-squire-review).

**패턴 10 — 시네마틱/대사 다량 접근은 고비용·고분산**
- 성공: Nine Sols(컷신 다량, 80만), REPLACED(시네마틱, Game Pass 포함 90만 명) — [OpenCritic 리뷰 모음](https://opencritic.com/game/16798/view/reviews), [WN Hub](https://wnhub.io/news/other/item-52378).
- 부진/혼합: Rusty Rabbit(스타 작가·유명 성우, Steam 59건 Mixed), Possessor(s)(무음성 다량 대사, 74%), Shadow Labyrinth(54% Mixed), Lost Crown(음성 컷신에도 서사 혹평) — [Steam Rusty Rabbit](https://store.steampowered.com/app/2530560/), [Steam Possessor(s)](https://store.steampowered.com/app/2132890/), [Steam Shadow Labyrinth](https://store.steampowered.com/app/1859430/), [Lost Crown Wikipedia](https://en.wikipedia.org/wiki/Prince_of_Persia:_The_Lost_Crown).

### Inferences
- **상관관계 요약(추정)**: 공식 판매 상위작의 서사 채널은 혼재한다 — Silksong·Animal Well은 탐색형 로어 + 짧은 대사(또는 무언), Nine Sols는 컷신·대사 다량, REPLACED는 시네마틱, Lost Crown은 음성 컷신(Mina는 미조사). 공통점은 강한 시각적·세계관 정체성과 호평받은 핵심 플레이였다. 서사 접근 자체보다 "서사가 플레이 흐름을 끊지 않는가"가 흥행작과 부진작을 가르는 공통 변수로 보인다.
- **문화 특수성은 '그대로 재현'보다 '장르 번역'이 유리**: Nine Sols(신화→SF), SANABI(조선→사이버펑크), Well Dweller(동화→메트로배니아)처럼 낯선 장르 프레임에 넣었을 때 해외 접근성이 생겼다. 장화홍련도 "조선 공안(公案) 미스터리 + 타임루프 + 플랫포머"처럼 재조합하면 선행작(포인트앤클릭)과 확실히 구분된다.
- **슬픔/정신 건강 테마는 이제 차별화 요소가 아님**: 수상 가능성은 높이지만, 2025년부터 "클리셰" 지적이 나온다. 장화홍련의 원한·누명·계모 구도 같은 구체적·문화적 사건으로 감싸야 진부함을 피할 수 있다.
- **진엔딩 = 수집/완성도 게이트**는 메트로배니아 플레이어가 이미 익숙한 문법이라 저비용으로 다회차 동기를 만든다. 반면 대사 선택지 분기는 작성량이 기하급수로 늘고, 실제 영향이 약하면 역효과(Mandragora).
- **메타픽션은 '가볍게, 발견 레이어로'**: UFO 50·Animal Well처럼 숨겨진 레이어로 두면 커뮤니티 화제성을 만들고, 본편 플롯을 메타에 의존하면 Plucky Squire처럼 "얇다"는 평을 받을 위험이 있다.

### Gaps
- 서사 유형별 판매량을 통계적으로 검증한 데이터(예: 태그별 중앙값 판매량)는 찾지 못함. GameDiscoverCo 분석은 유료라 서두만 확인. 위 상관관계는 소수 사례 기반의 질적 추론임.
- 2024–2026년 출시된 2D '타임루프' 플랫포머 중 Ultros 외에 상업적으로 의미 있는 사례를 찾지 못함(데이터 공백 = 경쟁이 적다는 신호일 수도, 수요가 적다는 신호일 수도 있음).
- 한국 2D 호러 플랫포머의 판매 데이터(Coma 시리즈 등)는 공식 수치를 찾지 못함.

---

## Q4. 플레이어와 평론가는 이 장르의 서사에서 무엇을 비판하는가?

### Takeaway
반복적으로 나온 비판은 (1) 플레이 흐름을 끊는 대화·회상 컷신(페이싱), (2) 서사가 후반에 배경으로 밀려나거나 줄기가 누락됨, (3) 의도적 난해함이 '혼란'으로 받아들여짐, (4) 비선형 구조에서 핵심 비트 손실, (5) 무음성 장문 대사, (6) 실효성 없는 선택지, (7) 현지화 품질, (8) 주제의 클리셰화다.

### Cited Findings
- **페이싱/컷신**: Nine Sols — 대사만으로 된 회상 컷신이 페이싱을 해침, 컷신 일시정지 불가, 일부는 이야기가 플레이를 방해한다고 느낌 — [OpenCritic 리뷰 모음](https://opencritic.com/game/16798/view/reviews) (검색 요약). Mandragora — 백트래킹 탓에 이야기 진전 사이에 몇 시간이 흐름 — [Gaming Trend](https://gamingtrend.com/reviews/mandragora-whispers-of-the-witch-tree-review-glinda-elphaba-or-something-else-entirely). Plucky Squire — 초반 소개가 길다 — [Windows Central](https://www.windowscentral.com/gaming/the-plucky-squire-pc-review).
- **서사가 배경으로 밀려남/줄기 누락**: Lost Crown — "진행할수록 서사가 배경으로", "누락된 줄기가 최대 약점" — [Wikipedia](https://en.wikipedia.org/wiki/Prince_of_Persia:_The_Lost_Crown). Momodora — 스토리·캐릭터를 깊게 다루지 않음, 엔딩이 밋밋 — [Switchaboo](https://switchaboo.com/momodora-moonlit-farewell-switch-review), [Backloggd](https://backloggd.com/u/APairofTimbs/review/1451653).
- **의도적 난해함 = 혼란**: Ultros — [Siliconera](https://siliconera.com/review-ultros-is-a-psychedelic-trip-with-a-familiar-formula), [Galaxus](https://www.galaxus.ch/en/page/ultros-a-fever-dream-exciting-but-not-quite-coherent-31749). Lost Crown — "불필요하게 복잡" — [Wikipedia](https://en.wikipedia.org/wiki/Prince_of_Persia:_The_Lost_Crown).
- **비선형에서 비트 손실**: Possessor(s) — [CogConnected](https://cogconnected.com/review/possessors-review/).
- **무음성 장문**: Possessor(s) — "대사가 많고 전부 무음성이라 읽을 게 많다" — [LootLevelChill](https://lootlevelchill.com/reviews/possessors-review/). Ultros — 짧고 단순한 무음성 컷신(반대 방향의 비판: 너무 빈약) — [VaporLens](https://vaporlens.app/app/2386310/ultros).
- **실효성 없는 선택**: Mandragora — [MobileSyrup](https://mobilesyrup.com/2025/05/12/mandragora-review/).
- **현지화**: Silksong 간체 중국어 번역으로 부정 리뷰 1만 4천 건+ — [GamesRadar](https://www.gamesradar.com/games/action/as-hollow-knight-silksongs-wonky-chinese-translation-leads-to-over-14-000-negative-steam-reviews-team-cherry-says-well-be-working-to-improve-the-translation-over-the-coming-weeks). 전작 대비 중국어 번역 크레딧이 6명→2명이었다는 보도 — [80.lv](https://80.lv/articles/hollow-knight-silksong-s-steam-score-drops-over-poor-chinese-localization) (검색 요약 기반, 해당 수치를 보도한 매체가 80.lv인지는 미확정).
- **전작 의존**: Coma 2B — 최고의 순간이 이전 작품 지식에 의존, 스토리 비일관 — [Gameluster](https://gameluster.com/the-coma-2b-catacomb-review-difficult-nightmare-escape/).
- **테마 클리셰화**: Constance — [Nintendo Life](https://www.nintendolife.com/reviews/switch-eshop/constance).
- **서사 vs 게임플레이 불균형**: Rusty Rabbit — 톤·캐릭터는 호평, 게임플레이는 실망 — [Siliconera](https://www.siliconera.com/review-rusty-rabbit-feels-well-rusty/). Withering Rooms — 분위기 호평, 전투 둔함 — [God is a Geek](https://godisageek.com/reviews/withering-rooms-review/). Coma 2B — 숨기 미니게임이 과도하게 길고 어려움 — [Cubed3](https://www.cubed3.com/games/reviews/nintendo-switch/the-coma-2b-catacomb).

### Inferences
- 비판의 대부분은 "텍스트의 절대량"보다 **"텍스트가 놓인 위치와 타이밍"**을 향한다. 같은 컷신 다량이라도 Nine Sols는 보스·허브 구조에 묶어 호평이 우세했고, Lost Crown은 플레이와 분리돼 혹평이 나왔다.
- 호러에서는 "숨기/추격 시퀀스의 반복 난이도"가 서사 몰입을 깨는 주된 원인(Coma 2B). 타임루프 호러라면 반복 구간을 루프마다 단축·스킵 가능하게 하는 설계가 필요하다.
- 한국 1인 개발자가 다국어 출시를 할 때 대사량은 곧 번역 리스크다. Silksong 사례는 대형 히트작도 번역 품질로 특정 언어권 평가가 'Mixed'로 떨어질 수 있음을 보여준다.

### Gaps
- 대사량(단어 수)과 리뷰 점수의 상관을 정량적으로 보여주는 자료는 찾지 못함.
- Steam 사용자 리뷰 원문의 서사 관련 불만 비율(예: "too much text" 언급 빈도)은 API 차단으로 수집하지 못함.

---

## Q5. 1인/소규모 개발자를 위한 실무 교훈: 서사 범위, 대사량, 전달 채널별 비용 대비 효과

### Takeaway
증거상 1인/초소규모로 높은 평가를 얻은 사례(Animal Well, Withering Rooms, Momodora, Well Dweller, Pseudoregalia)는 모두 "짧은 대사 + 환경/문서 + 강한 단일 콘셉트"였다. 사용자 콘셉트(장화홍련 + 타임루프 + 다회차 + 가벼운 메타)는 Ultros의 실패 요인(불명확한 루프)과 장화홍련 선행작(포인트앤클릭, 저관심)을 피하면서, Nine Sols식 '신화의 장르 번역'과 Nine Sols/Silksong식 '완성도 게이트 진엔딩'을 결합하는 것이 가장 근거가 탄탄한 방향이다. 아래 수치 권고는 출처가 없는 **추정치**다.

### Cited Findings
- 1인 개발 성공 사례: Animal Well(7년, 자체 엔진, 컷신 없음, 약 65만 장) — [Wikipedia](https://en.wikipedia.org/wiki/Animal_Well); Withering Rooms(1인, 96% 긍정) — [Seasoned Gaming](https://seasonedgaming.com/2024/04/24/review-withering-rooms-a-nightmarish-dream), [Steam](https://store.steampowered.com/app/2006140/); Momodora(1인, 93%) — [Steam](https://store.steampowered.com/app/1747760/); Pseudoregalia(2023, 1인, EN 97%/14,239) — [Steam](https://store.steampowered.com/app/2365810/).
- Nine Sols 수준의 컷신·대사 볼륨은 풀타임 10~15명, 4~5년 개발로 만들어짐 — [Into Indie Games](https://intoindiegames.com/features/nine-sols-an-interview-with-red-candle-games/), [Digital Trends](https://www.digitaltrends.com/gaming/nine-sols-taopunk-developer-interview/) ("4년 이상").
- Silksong의 성공 요인 중 하나는 원작이 쌓은 고객층 — [GameDiscoverCo](https://newsletter.gamediscover.co/p/5-things-you-didnt-know-about-hollow). → 신규 IP 1인 개발자는 Silksong식 대규모 NPC 퀘스트망을 그대로 벤치마킹하기 어려움.
- 2D 호러에서 반복 숨기 구간은 비판 요인 — [Cubed3](https://www.cubed3.com/games/reviews/nintendo-switch/the-coma-2b-catacomb).
- 장화홍련 선행작은 기억상실·저택·자매 탈출 구도를 이미 사용 — [Steam](https://store.steampowered.com/app/699710/).
- 대부분의 2024–2026 주요작이 한국어를 지원하지만 Tales of Kenzera, UFO 50, Withering Rooms, Rusty Rabbit, Gestalt, BIOMORPH는 Steam상 한국어 미지원 — Steam appdetails 조회(2026-11-17), 예: [Tales of Kenzera](https://store.steampowered.com/app/2316580/), [UFO 50](https://store.steampowered.com/app/1147860/).

### Inferences

**(1) 서사 범위 권장 (추정)**
- 1회차 4~7시간, 루프 3~5회, 엔딩 3종(노멀/배드/트루) + 메타 히든 1종 정도가 1인 개발에서 관리 가능한 상한으로 보인다(Momodora·Neva급 짧은 런타임도 호평받음: [Switchaboo](https://switchaboo.com/momodora-moonlit-farewell-switch-review), [Wikipedia Neva](https://en.wikipedia.org/wiki/Neva_(video_game))).
- **총 대사량 추정 가이드(출처 없음, 경험적 추정)**: 핵심 플롯 대사 4,000~8,000단어(영어 기준) + 문서/일지 3,000~6,000단어 + 바크·말풍선 500~1,500줄. 합계 약 7,000~14,000단어로, 영어 1단어≈한국어 약 3자(공백 포함)로 환산하면 한국어 약 2만~4만 자, 원고지(200자) 약 100~200매 수준(환산 비율도 추정). 이 범위면 영·중·일 번역 비용과 품질 리스크를 통제할 수 있다. (검증 필요: 실제 비교 대상 게임의 단어 수는 공개 자료 없음)

**(2) 전달 채널별 비용 대비 효과 (사례 기반 순위, 추정)**

| 순위 | 채널 | 근거 사례 | 비용 | 사용자 시스템 대응 |
|---|---|---|---|---|
| 1 | 환경 스토리텔링(배경 미술·오브젝트 배치·루프마다 달라지는 방) | Animal Well, MIO, Withering Rooms | 미술 비용은 들지만 텍스트·번역 0 | 타일맵/오브젝트 상태를 루프 변수로 전환 |
| 2 | 수집 문서/일지(노트 페이지, 판결문, 편지) | Coma 2B, Lost Crown 로어 노트, Constance 일지 | 낮음(텍스트만), 번역 필요 | 문서/저널 시스템 |
| 3 | 바크·말풍선(짧은 NPC 반응, 루프마다 변화) | MIO 로봇의 짧은 대사, Silksong NPC 유머 | 매우 낮음 | 바크/말풍선 |
| 4 | 보스전 = 캐릭터 비트(전투 전후 2~4줄 + 패턴으로 성격 표현) | Nine Sols, Lost Crown | 중간(보스 설계에 포함) | 상태머신 보스 + 자막 큐 |
| 5 | 초상화 대화창(핵심 플롯 비트에만) | Nine Sols, Silksong | 중간(초상화 표정 수만큼 미술) | 포트레이트 창 |
| 6 | 풀 컷신/음성 | REPLACED, Lost Crown, Rusty Rabbit | 높음, 성과 편차 큼 | 최소화 권장 |

**(3) 타임루프 설계 교훈 (Ultros·Withering Rooms 대비)**
- 각 루프가 "새로 알게 된 사실 1개 + 새로 열리는 경로 1개"를 명시적으로 남기도록(일지 자동 기록) 설계해 Ultros식 혼란을 피한다.
- 반복 구간(추격·숨기)은 2회차부터 단축/스킵 — Coma 2B 비판 회피.
- 진엔딩은 "모든 루프에서 얻은 문서/기억 조각 수집 + 특정 NPC(예: 홍련) 관계 조건"으로 잠그는 Nine Sols/Silksong/Ender 방식이 저비용·고동기.

**(4) 장화홍련 재해석 방향 (추론)**
- 선행작이 "기억상실 + 저택 탈출"을 썼으므로, 원전의 다른 축 — 억울한 죽음의 진실을 관아(사또)에 호소해 신원(伸冤)하는 공안 구조, 연못이라는 경계 공간, 반복되는 사또의 죽음 — 을 루프·메타 장치로 쓰면 차별화된다. (원전 구조에 대한 해석은 본 조사 범위 밖이며 별도 검증 필요)
- 메타픽션은 UFO 50/Animal Well처럼 "숨겨진 레이어"(예: 여러 판본의 설화 문서가 루프마다 달라짐, 세이브 파일·회차를 인지하는 원귀)로 가볍게 두고, 본편 플롯을 메타에 의존하지 않는다(Plucky Squire 교훈).
- "슬픔/정신 건강"을 전면에 내세우기보다 구체적 사건(누명·가족·원한)으로 감싸야 2025년 이후의 '클리셰' 비판을 피할 수 있다.
- 한국적 명칭·제도를 그대로 노출하는 SANABI 방식은 국내(및 아시아) 반응에 유리한 정황(ALL 42,235 vs EN 4,845)이 있으나, 영어권을 위해 일지/문서에 짧은 맥락 설명을 넣는 방식이 필요해 보인다.

### Gaps
- 1인 개발 2D 게임의 대사 단어 수와 평가 사이 관계를 보여주는 1차 자료는 찾지 못함 — 위 단어 수 가이드는 순수 추정.
- ACTION GAME MAKER G의 대화 시스템 성능 한계(예: 대사 수가 많을 때의 관리 방식)는 본 조사 범위 밖.
- 장화홍련 원전의 판본·구조 분석과 국내 저작권(현대 각색물 제외 원전은 공유저작물로 추정) 확인은 별도 조사 필요.

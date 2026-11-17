# UI 문자열

메뉴, 옵션, 상호작용 프롬프트, 시스템 메시지처럼 **이야기가 아닌 고정 문구**를 둡니다. 대사·바크·문서는 여기 두지 않고 [`../story/`](../story/README.md)의 `.dlg`로 씁니다.

- 형식: Godot 번역 CSV ([Importing translations](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_translations.html)). 첫 열이 키, 이후 열이 언어 코드입니다. 쉼표가 들어간 문장은 큰따옴표로 감쌉니다.
- GDScript는 키만 씁니다: `tr("ui.prompt.hide")`. 한국어를 코드에 직접 쓰면 CI가 실패합니다(대사 규칙과 같음).
- 키 이름: `ui.<화면 또는 용도>.<항목>`.
- 영어는 UI 낱말 수준이라 같이 채웠습니다. 문구는 [`docs/decisions.md`](../../../docs/decisions.md)의 조작과 옵션 목록에 맞춘 1차안입니다.
- 글자 수 기준: Galmuri11 Condensed 12 px에서 한글 한 글자는 8 px입니다. 프롬프트는 6자 안팎으로 둡니다.

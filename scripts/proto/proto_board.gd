## Prototype deduction board (B in the workroom): the capture program's screen used as a board.
##
## The level's "board" block lists cards: {"flag", "doc", "tc"}. A card is pinned once its flag is
## on. Its title and text come from the story document `doc` (never from code), and `tc` (tape
## seconds) is printed on the card and, inside the board's timecode axis, marked on the waveforms.
## Optional rows (version 2): "knots" {"requires", "slots": [{"flag", "doc"}]} fills the seven knot
## slots as knots are untied, and "conclusions" {"requires", "slots": [{"flag", "docs"}]} shows the
## chosen answer of each conclusion (flag value n picks docs[n - 1]). Up/Down change the row.
class_name ProtoBoard
extends Control

signal closed

## Board art geometry in art pixels (the art is 320x180 and fills the screen).
const ART_HEIGHT := 180.0
## The timecode axis: [tape seconds, art x] at the art's labels 01:19, 01:40 and 01:59.
const AXIS := [Vector2(4740.0, 10.0), Vector2(6000.0, 140.0), Vector2(7140.0, 270.0)]
## Markers run down the waveform panel.
const MARKER_Y := Vector2(22.0, 66.0)
## Card slots (x, y, w, h): a picture box for the title and a strip for the timecode.
const CARD_X := [14.0, 54.0, 94.0, 134.0, 174.0]
const CARD := Rect2(0, 122, 33, 47)
const CARD_PICTURE := Rect2(3, 3, 27, 26)
const CARD_STRIP := Rect2(3, 30, 27, 15)
const PAPER := Color8(216, 216, 208)
const INK := Color8(30, 30, 36)
const ACCENT := Color8(240, 208, 112)
## The header row between the waveforms and the knots, and the text panel: over the knot row
## while the board has no knot row, otherwise over the lower half of the waveforms.
const HEADER := Rect2(14, 71, 300, 7)
const DETAIL := Rect2(12, 78, 304, 38)
const DETAIL_HIGH := Rect2(12, 28, 304, 40)
## Knot slots (seven, 44 px apart) and conclusion slots (three, 32 px apart).
const KNOT := Rect2(14, 80, 37, 33)
const KNOT_STEP := 44.0
const CONCLUSION := Rect2(222, 122, 27, 47)
const CONCLUSION_STEP := 32.0
enum Row { CARDS, KNOTS, CONCLUSIONS }

var runner: StoryRunner
## Names keys and buttons in the controls hint (set by the game).
var input: ProtoInput
var cfg: Dictionary = {}
var _selected := 0
var _row: int = Row.CARDS
var _row_selected: Dictionary = {}
var _scale := 4.0
var _font: Font
var _panel_style: StyleBox
var _layer: Control


func setup(board: Dictionary, art: ProtoArt, story: StoryRunner, font: Font, panel: StyleBox = null) -> void:
	cfg = board
	runner = story
	_font = font
	_panel_style = panel
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var back := ColorRect.new()
	back.anchor_right = 1.0
	back.anchor_bottom = 1.0
	back.color = Color(0.03, 0.03, 0.04)
	add_child(back)
	var spec: Dictionary = board.get("art", {})
	if art != null and art.enabled() and not spec.is_empty():
		var bg := TextureRect.new()
		bg.anchor_right = 1.0
		bg.anchor_bottom = 1.0
		bg.stretch_mode = TextureRect.STRETCH_SCALE
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		bg.texture = art.frame(String(spec.get("sheet", "")), String(spec.get("frame", "")))
		add_child(bg)
	_layer = Control.new()
	_layer.anchor_right = 1.0
	_layer.anchor_bottom = 1.0
	_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_layer)
	visible = false


## True once the board's "requires" flags are all on.
func available() -> bool:
	if cfg.get("cards", []).is_empty() or runner == null:
		return false
	for f in cfg.get("requires", []):
		if runner.get_flag(String(f)) != true:
			return false
	return true


func is_open() -> bool:
	return visible


func open() -> void:
	if is_inside_tree():
		_scale = get_viewport_rect().size.y / ART_HEIGHT
	_selected = 0
	_row = Row.CARDS
	_row_selected = {}
	visible = true
	_refresh()


func close() -> void:
	visible = false
	closed.emit()


## Input actions (ProtoInput): menu_left/menu_right choose in the row, menu_up/menu_down change the
## row, board or cancel closes. Returns true if the board is open (it takes every input).
func handle(cmds: Array) -> bool:
	if not visible:
		return false
	var rows := _rows()
	if cmds.has("cancel") or cmds.has("board"):
		close()
		return true
	if cmds.has("menu_up") or cmds.has("menu_down"):
		var i := rows.find(_row)
		_row = rows[(i + (1 if cmds.has("menu_down") else rows.size() - 1)) % rows.size()]
	elif cmds.has("menu_left"):
		_set_index(maxi(0, _index() - 1))
	elif cmds.has("menu_right"):
		_set_index(mini(_row_size(_row) - 1, _index() + 1))
	_refresh()
	return true


## Untied knots (filled knot slots).
func knot_count() -> int:
	var n := 0
	for knot in _slots("knots"):
		if _found(knot):
			n += 1
	return n


func has_knots() -> bool:
	return _row_open("knots")


func _rows() -> Array:
	var rows: Array = [Row.CARDS]
	if _row_open("knots"):
		rows.append(Row.KNOTS)
	if _row_open("conclusions"):
		rows.append(Row.CONCLUSIONS)
	return rows


func _row_open(key: String) -> bool:
	var block: Dictionary = cfg.get(key, {})
	if block.get("slots", []).is_empty():
		return false
	for f in block.get("requires", []):
		if runner.get_flag(String(f)) != true:
			return false
	return true


func _slots(key: String) -> Array:
	return cfg.get(key, {}).get("slots", [])


func _row_size(row: int) -> int:
	match row:
		Row.KNOTS:
			return _slots("knots").size()
		Row.CONCLUSIONS:
			return _slots("conclusions").size()
	return cfg.get("cards", []).size()


func _index() -> int:
	return _selected if _row == Row.CARDS else int(_row_selected.get(_row, 0))


func _set_index(i: int) -> void:
	if _row == Row.CARDS:
		_selected = i
	else:
		_row_selected[_row] = i


func found_count() -> int:
	var n := 0
	for card in cfg.get("cards", []):
		if _found(card):
			n += 1
	return n


## "01:40:52" for 6052 tape seconds.
static func timecode(seconds: float) -> String:
	var s := int(seconds)
	return "%02d:%02d:%02d" % [s / 3600, (s / 60) % 60, s % 60]


func _found(card: Dictionary) -> bool:
	return runner.get_flag(String(card.get("flag", ""))) == true


func _refresh() -> void:
	for c in _layer.get_children():
		_layer.remove_child(c)
		c.queue_free()
	var cards: Array = cfg.get("cards", [])
	var heading := tr("ui.board.title") + "   %d / %d" % [found_count(), cards.size()]
	if has_knots():
		heading += "      " + tr("ui.board.knots") + "   %d / %d" % [knot_count(), _slots("knots").size()]
	var title := _label(heading, 16, ACCENT)
	_place(title, HEADER)
	var hint := _label(input.fill(tr("ui.board.controls")) if input != null else tr("ui.board.controls"), 14, Color(0.62, 0.64, 0.7))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_place(hint, HEADER)
	# Five slots show a window of cards around the selection; arrows say there is more.
	var first := clampi(_selected - 2, 0, maxi(0, cards.size() - CARD_X.size()))
	for slot in CARD_X.size():
		if first + slot < cards.size():
			_card(cards[first + slot], float(CARD_X[slot]), _row == Row.CARDS and first + slot == _selected)
	if first > 0:
		_place(_label("<", 20, ACCENT), Rect2(5, 138, 8, 12))
	if first + CARD_X.size() < cards.size():
		_place(_label(">", 20, ACCENT), Rect2(209, 138, 8, 12))
	if has_knots():
		var knots := _slots("knots")
		for i in knots.size():
			_knot(knots[i], i, _row == Row.KNOTS and _index() == i)
	if _row_open("conclusions"):
		var slots := _slots("conclusions")
		for i in slots.size():
			_conclusion(slots[i], i, _row == Row.CONCLUSIONS and _index() == i)
	match _row:
		Row.KNOTS:
			var knot: Dictionary = _slots("knots")[_index()]
			_detail_doc(String(knot.get("doc", "")), _found(knot))
		Row.CONCLUSIONS:
			var slot: Dictionary = _slots("conclusions")[_index()]
			_detail_doc(_conclusion_doc(slot), _conclusion_doc(slot) != "")
		_:
			_detail(cards[_selected] if _selected < cards.size() else {})


## A knot slot: the knot's number, lit once the knot is untied.
func _knot(knot: Dictionary, i: int, selected: bool) -> void:
	var at := KNOT.position + Vector2(i * KNOT_STEP, 0)
	if selected:
		_frame(Rect2(at - Vector2(2, 2), KNOT.size + Vector2(4, 4)))
	var untied := _found(knot)
	var fill := ColorRect.new()
	fill.color = PAPER if untied else Color(0.06, 0.06, 0.08)
	_place(fill, Rect2(at + Vector2(2, 2), KNOT.size - Vector2(4, 4)))
	var number := _label(str(i + 1), 22, INK if untied else Color(0.5, 0.5, 0.56))
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_place(number, Rect2(at, KNOT.size))


## A conclusion slot: the short title of the chosen answer, or "?".
func _conclusion(slot: Dictionary, i: int, selected: bool) -> void:
	var at := CONCLUSION.position + Vector2(i * CONCLUSION_STEP, 0)
	if selected:
		_frame(Rect2(at - Vector2(2, 2), CONCLUSION.size + Vector2(4, 4)))
	var doc_id := _conclusion_doc(slot)
	if doc_id == "":
		var unknown := _label("?", 24, Color(0.45, 0.45, 0.5))
		unknown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		unknown.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_place(unknown, Rect2(at, CONCLUSION.size))
		return
	var fill := ColorRect.new()
	fill.color = PAPER
	_place(fill, Rect2(at + Vector2(2, 2), CONCLUSION.size - Vector2(4, 4)))
	var text := _label(ProtoUI.keep_words(String(runner.get_doc(doc_id).get("title", ""))), 12, INK)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.clip_text = true
	_place(text, Rect2(at + Vector2(3, 3), CONCLUSION.size - Vector2(6, 6)))


## The document of the answer chosen for a conclusion slot, or "" while it is open.
func _conclusion_doc(slot: Dictionary) -> String:
	var value: Variant = runner.get_flag(String(slot.get("flag", "")))
	var docs: Array = slot.get("docs", [])
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return ""
	var i := int(value) - 1
	return String(docs[i]) if i >= 0 and i < docs.size() else ""


func _frame(art_rect: Rect2) -> void:
	var frame := ReferenceRect.new()
	frame.editor_only = false
	frame.border_color = ACCENT
	frame.border_width = 3.0
	_place(frame, art_rect)


func _card(card: Dictionary, x: float, selected: bool) -> void:
	var at := Vector2(x, CARD.position.y)
	if selected:
		_frame(Rect2(at - Vector2(2, 2), CARD.size + Vector2(4, 4)))
	if not _found(card):
		var cover := ColorRect.new()
		cover.color = Color(0.06, 0.06, 0.08, 0.88)
		_place(cover, Rect2(at, CARD.size))
		var unknown := _label("?", 28, Color(0.45, 0.45, 0.5))
		unknown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		unknown.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_place(unknown, Rect2(at, CARD.size))
		return
	var doc := runner.get_doc(String(card.get("doc", "")))
	var heading := _label(ProtoUI.keep_words(String(doc.get("title", ""))), 13, INK)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.clip_text = true
	_place(heading, Rect2(at + CARD_PICTURE.position + Vector2(1, 1), CARD_PICTURE.size - Vector2(2, 2)))
	var strip := ColorRect.new()
	strip.color = PAPER
	_place(strip, Rect2(at + CARD_STRIP.position, CARD_STRIP.size))
	if card.has("tc"):
		var tc := float(card["tc"])
		var stamp := _label(timecode(tc), 13, INK)
		stamp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stamp.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_place(stamp, Rect2(at + CARD_STRIP.position, CARD_STRIP.size))
		_marker(tc, selected)


## A pin on the waveforms for a card's timecode, if the axis shows that time. The selected
## card's pin runs the height of both waveforms and carries its timecode.
func _marker(tc: float, selected: bool) -> void:
	var x := axis_x(tc)
	if x < 0.0:
		return
	var line := ColorRect.new()
	line.color = Color(ACCENT, 1.0 if selected else 0.6)
	var length := MARKER_Y.y - MARKER_Y.x if selected else 4.0
	_place(line, Rect2(x, MARKER_Y.x, 1.0 if selected else 0.5, length))
	if selected:
		var stamp := _label(timecode(tc), 12, Color(0.06, 0.06, 0.08))
		var back := ColorRect.new()
		back.color = ACCENT
		var at := Vector2(minf(x + 1.0, 290.0), MARKER_Y.x)
		_place(back, Rect2(at, Vector2(24, 5)))
		stamp.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_place(stamp, Rect2(at + Vector2(1, 0), Vector2(23, 5)))


## Art x of a tape time on the board's axis, or -1 outside it.
static func axis_x(tc: float) -> float:
	for i in AXIS.size() - 1:
		var a: Vector2 = AXIS[i]
		var b: Vector2 = AXIS[i + 1]
		if tc >= a.x and tc <= b.x:
			return a.y + (tc - a.x) / (b.x - a.x) * (b.y - a.y)
	return -1.0


## The selected card's document.
func _detail(card: Dictionary) -> void:
	_detail_doc("" if card.is_empty() else String(card.get("doc", "")), not card.is_empty() and _found(card))


## A document in the text panel: title and paragraphs when `shown`, otherwise only the title of a
## knot (what the lie is) or "Not found yet".
func _detail_doc(doc_id: String, shown: bool) -> void:
	var rect := DETAIL_HIGH if has_knots() else DETAIL
	var panel := Panel.new()
	if _panel_style != null:
		panel.add_theme_stylebox_override("panel", _panel_style)
	_place(panel, rect)
	var text := _label("", 16, Color(0.88, 0.9, 0.92))
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.clip_text = true
	var doc := runner.get_doc(doc_id) if doc_id != "" else {}
	if shown and not doc.is_empty():
		var lines := PackedStringArray([String(doc.get("title", ""))])
		for p in doc.get("paragraphs", []):
			lines.append(String(p))
		text.text = ProtoUI.keep_words("\n".join(lines))
	elif _row == Row.KNOTS and not doc.is_empty():
		text.text = ProtoUI.keep_words(String(doc.get("title", "")) + "\n" + tr("ui.board.knot_tied"))
	else:
		text.text = tr("ui.board.empty")
	_place(text, Rect2(rect.position + Vector2(4, 3), rect.size - Vector2(8, 6)))


func _place(node: Control, art_rect: Rect2) -> void:
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.position = art_rect.position * _scale
	node.size = art_rect.size * _scale
	_layer.add_child(node)


func _label(text: String, size_px: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	if _font != null:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	return l

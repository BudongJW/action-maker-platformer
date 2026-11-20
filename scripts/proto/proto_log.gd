## Dialogue log (docs/ui-ux.md P0-5): the lines, chosen options and captions of this session in
## order, each scene headed by its tape time (or the workroom), with the speaker's name. Earlier
## plays of the tape are folded into one row each, which accept opens. The game adds to it as lines
## are shown; it is not saved (a new game or Continue starts it empty).
##
## Keys: menu_up / menu_down move a row, menu_left / menu_right jump a scene, tab_prev / tab_next a
## page, accept opens or closes a folded play, cancel or the log key closes. The mouse wheel
## scrolls, a click on a folded play opens it, a right click closes.
class_name ProtoLog
extends Control

signal closed

## Oldest entries go first past this many.
const MAX_ENTRIES := 3000
const PAGE := 8
const NAME_COLOR := Color(0.95, 0.85, 0.55)
const TEXT_COLOR := Color(0.9, 0.91, 0.93)
const DIM := Color(0.55, 0.58, 0.63)
const CHOICE_COLOR := Color(0.75, 0.92, 1.0)

var input: ProtoInput
## {"play", "at" (tape seconds, -1 in the workroom), "kind": "scene" | "line" | "choice" | "caption",
## "speaker", "text"}
var entries: Array = []
## The play being watched now (its rows are never folded).
var current_play := 0
var _unfolded: Dictionary = {}
## One per row on screen: {"fold": play} or {"entry": index}.
var _shown: Array = []
var _selected := 0
var _font: Font
var _row_style: StyleBox
var _title: Label
var _scroll: ScrollContainer
var _rows: VBoxContainer
var _footer: Label


func setup(font: Font, panel: StyleBox, row_style: StyleBox) -> void:
	_font = font
	_row_style = row_style
	anchor_left = 0.08
	anchor_right = 0.92
	anchor_top = 0.07
	anchor_bottom = 0.93
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := PanelContainer.new()
	box.anchor_right = 1.0
	box.anchor_bottom = 1.0
	box.add_theme_stylebox_override("panel", panel if panel != null else _flat_panel())
	add_child(box)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	box.add_child(col)
	_title = _label(28, NAME_COLOR)
	col.add_child(_title)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 2)
	_scroll.add_child(_rows)
	_footer = _label(17, DIM)
	_footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_footer)
	visible = false


func clear() -> void:
	entries.clear()
	_unfolded.clear()


## A dialogue starts: a scene heading with its tape time (`at` < 0: the workroom).
func add_scene(play: int, at: int) -> void:
	_add({"play": play, "at": at, "kind": "scene", "speaker": "", "text": ""})


func add_line(play: int, at: int, speaker: String, text: String, kind := "line") -> void:
	if text.strip_edges() == "":
		return
	_add({"play": play, "at": at, "kind": kind, "speaker": speaker, "text": text})


func is_open() -> bool:
	return visible


## Opens at the newest line.
func open(play: int) -> void:
	current_play = play
	_title.text = tr("ui.log.title")
	_footer.text = input.fill(tr("ui.log.controls")) if input != null else tr("ui.log.controls")
	visible = true
	_rebuild()
	_selected = maxi(0, _shown.size() - 1)
	_refresh()


func close() -> void:
	visible = false
	closed.emit()


func handle(cmds: Array) -> bool:
	if not visible:
		return false
	if cmds.has("cancel") or cmds.has("log") or cmds.has("pause"):
		close()
		return true
	var n := _shown.size()
	if n == 0:
		return true
	if cmds.has("menu_up"):
		_selected = maxi(0, _selected - 1)
	elif cmds.has("menu_down"):
		_selected = mini(n - 1, _selected + 1)
	elif cmds.has("tab_prev"):
		_selected = maxi(0, _selected - PAGE)
	elif cmds.has("tab_next"):
		_selected = mini(n - 1, _selected + PAGE)
	elif cmds.has("menu_left") or cmds.has("menu_right"):
		_selected = _next_scene(-1 if cmds.has("menu_left") else 1)
	elif cmds.has("accept"):
		_toggle(_selected)
		return true
	_refresh()
	return true


func command(cmd: String) -> bool:
	return handle([cmd])


## Mouse: a click on a folded play opens it, a right click closes; the wheel scrolls the list.
func mouse(event: InputEvent) -> bool:
	if not visible:
		return false
	var button := event as InputEventMouseButton
	if button == null or not button.pressed:
		return true
	if button.button_index == MOUSE_BUTTON_RIGHT:
		close()
		return true
	if button.button_index != MOUSE_BUTTON_LEFT:
		return false  # the wheel goes on to the scroll container
	var rows := _rows.get_children()
	for i in rows.size():
		if (rows[i] as Control).get_global_rect().has_point(button.position):
			_selected = i
			if _shown[i].has("fold"):
				_toggle(i)
			else:
				_refresh()
			return true
	return true


## Rows on screen now (for tests and the bot).
func row_count() -> int:
	return _shown.size()


func _add(entry: Dictionary) -> void:
	entries.append(entry)
	if entries.size() > MAX_ENTRIES:
		entries.pop_front()
	if visible:
		_rebuild()
		_refresh()


func _toggle(i: int) -> void:
	if i < 0 or i >= _shown.size() or not _shown[i].has("fold"):
		return
	var play: int = int(_shown[i]["fold"])
	_unfolded[play] = not bool(_unfolded.get(play, false))
	_rebuild()
	_selected = i
	_refresh()


func _next_scene(direction: int) -> int:
	var i := _selected + direction
	while i >= 0 and i < _shown.size():
		var s: Dictionary = _shown[i]
		if s.has("fold") or String(entries[int(s["entry"])]["kind"]) == "scene":
			return i
		i += direction
	return 0 if direction < 0 else _shown.size() - 1


## Works out the rows: earlier plays folded unless opened, the current play in full.
func _rebuild() -> void:
	_shown.clear()
	var counts := {}
	for e in entries:
		if String(e["kind"]) != "scene":
			counts[int(e["play"])] = int(counts.get(int(e["play"]), 0)) + 1
	var folded_done := {}
	for i in entries.size():
		var play: int = int(entries[i]["play"])
		var folded := play != current_play and not bool(_unfolded.get(play, false))
		if play != current_play and not folded_done.has(play):
			folded_done[play] = true
			_shown.append({"fold": play, "count": int(counts.get(play, 0))})
		if not folded:
			_shown.append({"entry": i})


func _refresh() -> void:
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.queue_free()
	if _shown.is_empty():
		var empty := _label(22, DIM)
		empty.text = tr("ui.log.empty")
		_rows.add_child(empty)
		return
	for i in _shown.size():
		_rows.add_child(_row(_shown[i], i == _selected))
	_scroll_to(_rows.get_child(_selected))


## After the new rows have been laid out (a frame later), so the scroll range is right.
func _scroll_to(row: Control) -> void:
	await get_tree().process_frame
	if is_instance_valid(row) and row.get_parent() == _rows:
		_scroll.ensure_control_visible(row)


func _row(s: Dictionary, on: bool) -> Control:
	var row := PanelContainer.new()
	row.add_theme_stylebox_override("panel", _row_style if on and _row_style != null else _blank())
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if s.has("fold"):
		var l := _label(20, DIM if not on else TEXT_COLOR)
		var opened := bool(_unfolded.get(int(s["fold"]), false))
		l.text = ("- " if opened else "+ ") + tr("ui.log.fold").format({"n": int(s["fold"]), "count": int(s["count"])})
		row.add_child(l)
		return row
	var e: Dictionary = entries[int(s["entry"])]
	match String(e["kind"]):
		"scene":
			var l := _label(16, DIM)
			l.text = "%s  %s" % [tr("ui.deck.counter").format({"n": int(e["play"])}), _where(int(e["at"]))]
			row.add_child(l)
		"choice":
			var line := HBoxContainer.new()
			var mark := _label(20, CHOICE_COLOR)
			mark.text = tr("ui.log.chose")
			mark.custom_minimum_size.x = 150
			line.add_child(mark)
			line.add_child(_text(String(e["text"]), CHOICE_COLOR))
			row.add_child(line)
		_:
			var line := HBoxContainer.new()
			var who := _label(20, NAME_COLOR)
			who.text = String(e["speaker"])
			who.custom_minimum_size.x = 150
			who.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			line.add_child(who)
			line.add_child(_text(String(e["text"]), TEXT_COLOR if String(e["kind"]) == "line" else DIM))
			row.add_child(line)
	return row


func _text(text: String, color: Color) -> Label:
	var l := _label(22, color)
	l.text = ProtoUI.keep_words(text)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


static func _where(at: int) -> String:
	if at < 0:
		return TranslationServer.translate("ui.journal.workroom")
	return "%02d:%02d:%02d" % [at / 3600, (at / 60) % 60, at % 60]


func _blank() -> StyleBox:
	var sb := StyleBoxEmpty.new()
	if _row_style != null:
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			sb.set_content_margin(side, _row_style.get_content_margin(side))
	return sb


func _flat_panel() -> StyleBox:
	var flat := StyleBoxFlat.new()
	flat.bg_color = Color(0.08, 0.08, 0.1, 0.96)
	flat.set_content_margin_all(24)
	return flat


func _label(size_px: int, color: Color) -> Label:
	var l := Label.new()
	if _font != null:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

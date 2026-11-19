## Journal (docs/ui-ux.md P0-4): the documents found so far, by section, to read again. A list on
## the left (title, the tape time it was found or the workroom, a dot until it has been looked at
## here) and the selected document on paper on the right; accept shows it in the full document
## viewer (the game does that and comes back here).
##
## Sections come from the level's "journal" block: {"tabs": [{"label": UI string key,
## "categories": [document @category, ...]}]}; a tab without "categories" lists every document.
## Without the block there is one tab with everything. Found times and read marks are kept in the
## save (store / restore).
##
## Keys: menu_up / menu_down pick a document, tab_prev / tab_next or menu_left / menu_right change
## the section, accept reads it full size, cancel or the journal key closes. Mouse: hover or click a
## document, click a tab, wheel scrolls, right click closes.
class_name ProtoJournal
extends Control

signal closed
## The player asked to read `doc_id` in the full viewer.
signal read_doc(doc_id: String)

const INK := Color(0.1, 0.1, 0.13)
const DIM := Color(0.55, 0.58, 0.63)
const NEW_COLOR := Color(0.95, 0.72, 0.32)

var runner: StoryRunner
var input: ProtoInput
## Document id -> tape seconds it was found at (-1: in the workroom).
var times: Dictionary = {}
## Document id -> true once it has been selected here.
var read: Dictionary = {}
var _tabs: Array = [{"label": "ui.journal.tab_all"}]
var _tab := 0
var _selected := 0
var _docs: Array = []
var _font: Font
var _row_style: StyleBox
var _tab_on: StyleBoxFlat
var _tab_off: StyleBoxEmpty
var _title: Label
var _tab_bar: HBoxContainer
var _list_scroll: ScrollContainer
var _list: VBoxContainer
var _paper_scroll: ScrollContainer
var _doc_title: Label
var _doc_body: Label
var _footer: Label


func setup(font: Font, panel: StyleBox, row_style: StyleBox, paper: StyleBox) -> void:
	_font = font
	_row_style = row_style
	anchor_left = 0.06
	anchor_right = 0.94
	anchor_top = 0.07
	anchor_bottom = 0.93
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := PanelContainer.new()
	box.anchor_right = 1.0
	box.anchor_bottom = 1.0
	if panel != null:
		box.add_theme_stylebox_override("panel", panel)
	else:
		var flat := StyleBoxFlat.new()
		flat.bg_color = Color(0.08, 0.08, 0.1, 0.96)
		flat.set_content_margin_all(24)
		box.add_theme_stylebox_override("panel", flat)
	add_child(box)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	box.add_child(col)
	_title = _label(28, Color(0.95, 0.85, 0.55))
	col.add_child(_title)
	_tab_bar = HBoxContainer.new()
	_tab_bar.add_theme_constant_override("separation", 6)
	col.add_child(_tab_bar)
	_tab_on = StyleBoxFlat.new()
	_tab_on.bg_color = Color(1, 1, 1, 0.07)
	_tab_on.border_color = Color(0.95, 0.85, 0.55)
	_tab_on.border_width_bottom = 3
	_tab_off = StyleBoxEmpty.new()
	for sb: StyleBox in [_tab_on, _tab_off]:
		sb.content_margin_left = 12
		sb.content_margin_right = 12
		sb.content_margin_top = 2
		sb.content_margin_bottom = 5
	var split := HBoxContainer.new()
	split.add_theme_constant_override("separation", 16)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(split)
	_list_scroll = ScrollContainer.new()
	_list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_list_scroll.custom_minimum_size.x = 400
	split.add_child(_list_scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_scroll.add_child(_list)
	var sheet := PanelContainer.new()
	sheet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if paper != null:
		sheet.add_theme_stylebox_override("panel", paper)
	else:
		var flat := StyleBoxFlat.new()
		flat.bg_color = Color(0.85, 0.85, 0.82)
		flat.set_content_margin_all(22)
		sheet.add_theme_stylebox_override("panel", flat)
	split.add_child(sheet)
	_paper_scroll = ScrollContainer.new()
	_paper_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sheet.add_child(_paper_scroll)
	var paper_col := VBoxContainer.new()
	paper_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	paper_col.add_theme_constant_override("separation", 12)
	_paper_scroll.add_child(paper_col)
	_doc_title = _label(26, INK)
	_doc_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_doc_body = _label(21, INK)
	_doc_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	paper_col.add_child(_doc_title)
	paper_col.add_child(_doc_body)
	_footer = _label(17, DIM)
	_footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_footer)
	visible = false


## The level's "journal" block.
func configure(cfg: Dictionary) -> void:
	var tabs: Array = cfg.get("tabs", [])
	_tabs = tabs if not tabs.is_empty() else [{"label": "ui.journal.tab_all"}]


func reset() -> void:
	times.clear()
	read.clear()


func store() -> Dictionary:
	return {"times": times.duplicate(), "read": read.keys()}


func restore(saved: Dictionary) -> void:
	reset()
	var t: Dictionary = saved.get("times", {})
	for doc_id in t:
		times[String(doc_id)] = int(t[doc_id])
	for doc_id in saved.get("read", []):
		read[String(doc_id)] = true


## Notes when a document was found (call when the game collects it).
func found(doc_id: String, at: int) -> void:
	if not times.has(doc_id):
		times[doc_id] = at


func is_open() -> bool:
	return visible


func has_docs() -> bool:
	return runner != null and not _all_docs().is_empty()


func unread_count() -> int:
	return _all_docs().filter(func(d): return not read.has(d)).size()


func tab_count() -> int:
	return _tabs.size()


func current_tab() -> int:
	return _tab


## The documents of tab `i`, in story order.
func docs_in_tab(i: int) -> Array:
	var cats: Variant = _tabs[i].get("categories")
	if cats == null:
		return _all_docs()
	var out: Array = []
	for doc_id in _all_docs():
		if (cats as Array).has(String(runner.get_doc(doc_id).get("category", ""))):
			out.append(doc_id)
	return out


func open() -> void:
	_title.text = tr("ui.journal.title")
	_footer.text = input.fill(tr("ui.journal.controls")) if input != null else tr("ui.journal.controls")
	visible = true
	# The first section that has something in it.
	_tab = 0
	for i in _tabs.size():
		if not docs_in_tab(i).is_empty():
			_tab = i
			break
	_show_tab(_tab)


func close() -> void:
	visible = false
	closed.emit()


func handle(cmds: Array) -> bool:
	if not visible:
		return false
	if cmds.has("cancel") or cmds.has("journal") or cmds.has("pause"):
		close()
		return true
	if cmds.has("tab_prev") or cmds.has("menu_left"):
		_show_tab(_tab - 1)
	elif cmds.has("tab_next") or cmds.has("menu_right"):
		_show_tab(_tab + 1)
	elif cmds.has("menu_up") and not _docs.is_empty():
		_select(maxi(0, _selected - 1))
	elif cmds.has("menu_down") and not _docs.is_empty():
		_select(mini(_docs.size() - 1, _selected + 1))
	elif cmds.has("accept") and not _docs.is_empty():
		read_doc.emit(String(_docs[_selected]))
	return true


func command(cmd: String) -> bool:
	return handle([cmd])


func mouse(event: InputEvent) -> bool:
	if not visible:
		return false
	var button := event as InputEventMouseButton
	if button != null and not button.pressed:
		return true
	if button != null and button.button_index == MOUSE_BUTTON_RIGHT:
		close()
		return true
	if button != null and button.button_index != MOUSE_BUTTON_LEFT:
		return false  # the wheel scrolls the list or the paper
	var pos: Vector2 = (event as InputEventMouse).position
	var tabs := _tab_bar.get_children()
	for i in tabs.size():
		if button != null and (tabs[i] as Control).get_global_rect().has_point(pos):
			_show_tab(i)
			return true
	var rows := _list.get_children()
	if _list_scroll.get_global_rect().has_point(pos):
		for i in mini(rows.size(), _docs.size()):
			if (rows[i] as Control).get_global_rect().has_point(pos):
				if i != _selected:
					_select(i)
				elif button != null:
					read_doc.emit(String(_docs[i]))
				return true
	return true


func selected_doc() -> String:
	return String(_docs[_selected]) if not _docs.is_empty() else ""


func _all_docs() -> Array:
	return runner.collected_docs() if runner != null else []


func _show_tab(i: int) -> void:
	_tab = posmod(i, _tabs.size())
	_docs = docs_in_tab(_tab)
	for c in _tab_bar.get_children():
		_tab_bar.remove_child(c)
		c.queue_free()
	for t in _tabs.size():
		var tab := PanelContainer.new()
		tab.add_theme_stylebox_override("panel", _tab_on if t == _tab else _tab_off)
		var l := _label(22, Color.WHITE if t == _tab else Color(0.6, 0.65, 0.7))
		var unread: int = docs_in_tab(t).filter(func(d): return not read.has(d)).size()
		l.text = tr(String(_tabs[t]["label"])) + (" (%d)" % unread if unread > 0 and t != _tab else "")
		tab.add_child(l)
		_tab_bar.add_child(tab)
	_select(0)


## Shows document `i` of the current section on the paper and marks it read.
func _select(i: int) -> void:
	_selected = i
	if not _docs.is_empty():
		read[String(_docs[i])] = true
	_draw_list()
	if _docs.is_empty():
		_doc_title.text = ""
		_doc_body.text = tr("ui.journal.empty")
		return
	var doc := runner.get_doc(String(_docs[i]))
	_doc_title.text = ProtoUI.keep_words(String(doc.get("title", "")))
	_doc_title.visible = _doc_title.text != ""
	_doc_body.text = ProtoUI.keep_words("\n\n".join(PackedStringArray(doc.get("paragraphs", []))))
	_paper_scroll.scroll_vertical = 0


func _draw_list() -> void:
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	for i in _docs.size():
		var doc_id := String(_docs[i])
		var on := i == _selected
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", _row_style if on and _row_style != null else _blank())
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 8)
		line.add_child(_Dot.new(not read.has(doc_id)))
		var title := _label(20, Color.WHITE if on else Color(0.8, 0.82, 0.86))
		title.text = String(runner.get_doc(doc_id).get("title", doc_id))
		title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		title.clip_text = true
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(title)
		var when := _label(16, DIM)
		when.text = ProtoLog._where(int(times.get(doc_id, -1))) if times.has(doc_id) else ""
		line.add_child(when)
		row.add_child(line)
		_list.add_child(row)
	if not _docs.is_empty():
		_scroll_to(_list.get_child(_selected))


## After the new rows have been laid out (a frame later), so the scroll range is right.
func _scroll_to(row: Control) -> void:
	await get_tree().process_frame
	if is_instance_valid(row) and row.get_parent() == _list:
		_list_scroll.ensure_control_visible(row)


func _blank() -> StyleBox:
	var sb := StyleBoxEmpty.new()
	if _row_style != null:
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			sb.set_content_margin(side, _row_style.get_content_margin(side))
	return sb


func _label(size_px: int, color: Color) -> Label:
	var l := Label.new()
	if _font != null:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## The "not looked at here yet" mark: a filled square dot (shape and colour), or room for one.
class _Dot extends Control:
	var on := false

	func _init(is_new: bool) -> void:
		on = is_new
		custom_minimum_size = Vector2(10, 10)
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if on:
			draw_rect(Rect2(1, 1, 8, 8), ProtoJournal.NEW_COLOR)

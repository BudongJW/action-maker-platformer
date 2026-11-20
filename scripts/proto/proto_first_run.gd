## First run and the pages it shares with the options (docs/ui-ux.md P0-7):
##
## - "brightness": three marks on black (clearly visible, barely visible, not to be seen) and the
##   brightness value. The marks are drawn with the brightness pass's own curve
##   (ProtoScreen.gamma_for), on an opaque black over everything, so nothing else lies over them.
## - "notice": the content notice (the level's first "start_docs" document) with the two choices
##   that matter before anything plays: scare intensity and reduced flashing.
##
## On the very first launch the game runs both, then shows the title; the options open either one
## again (brightness in the display tab, the content notice in accessibility). Values go through
## ProtoSettings, so they are applied and saved at once. Text comes from the UI strings
## (ui.first.*) and the story document.
class_name ProtoFirstRun
extends Control

signal finished

## Linear grey of the three marks on black: clearly visible, barely visible, not to be seen.
const MARKS := [0.22, 0.075, 0.03]
const MARK_LABELS := ["ui.first.mark_clear", "ui.first.mark_faint", "ui.first.mark_hidden"]

var settings: ProtoSettings
var input: ProtoInput
var runner: StoryRunner
## The content notice document ("" for none).
var notice_doc := ""
## The last row on the notice page: "start" on the first run, "back" from the options.
var last_row := "start"
var _pages: Array = []
var _page := 0
var _selected := 0
var _font: Font
var _row_style: StyleBox
var _black: ColorRect
var _marks: Control
var _panel: PanelContainer
var _title: Label
var _body_scroll: ScrollContainer
var _body: Label
var _mark_row: HBoxContainer
var _rows: VBoxContainer
var _hint: Label
var _row_hint: Label
var _footer: Label


func setup(font: Font, panel: StyleBox, row_style: StyleBox) -> void:
	_font = font
	_row_style = row_style
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Opaque, over the game, its menus and the viewfinder.
	_black = ColorRect.new()
	_black.color = Color.BLACK
	_black.anchor_right = 1.0
	_black.anchor_bottom = 1.0
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_black)
	_marks = Control.new()
	_marks.anchor_right = 1.0
	_marks.anchor_bottom = 1.0
	_marks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_marks.draw.connect(_draw_marks)
	add_child(_marks)
	_panel = PanelContainer.new()
	_panel.anchor_left = 0.08
	_panel.anchor_right = 0.92
	_panel.anchor_top = 0.06
	_panel.anchor_bottom = 0.94
	_panel.add_theme_stylebox_override("panel", panel if panel != null else _flat())
	add_child(_panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	_panel.add_child(col)
	_title = _label(30, Color(0.95, 0.85, 0.55))
	col.add_child(_title)
	_hint = _label(20, Color(0.82, 0.85, 0.9))
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_hint)
	_body_scroll = ScrollContainer.new()
	_body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_body_scroll)
	_body = _label(20, Color(0.88, 0.89, 0.92))
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body_scroll.add_child(_body)
	# Captions under the three marks (the marks themselves are drawn on the layer below).
	_mark_row = HBoxContainer.new()
	_mark_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_mark_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(_mark_row)
	_rows = VBoxContainer.new()
	col.add_child(_rows)
	_row_hint = _label(18, Color(0.7, 0.75, 0.8))
	_row_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_row_hint)
	_footer = _label(17, Color(0.55, 0.6, 0.65))
	_footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_footer)
	visible = false


## Shows `pages` ("brightness", "notice") one after the other; `finished` when the last closes.
func start(pages: Array) -> void:
	_pages = pages
	_page = 0
	visible = true
	_show_page()


func is_open() -> bool:
	return visible


func page() -> String:
	return String(_pages[_page]) if visible else ""


func handle(cmds: Array) -> bool:
	if not visible:
		return false
	if page() == "brightness":
		if cmds.has("menu_left") or cmds.has("menu_right"):
			_change("brightness", -1 if cmds.has("menu_left") else 1)
		elif cmds.has("accept") or (cmds.has("cancel") and last_row == "back"):
			_next()
		return true
	var rows := _row_items()
	if cmds.has("menu_up"):
		_selected = maxi(0, _selected - 1)
	elif cmds.has("menu_down"):
		_selected = mini(rows.size() - 1, _selected + 1)
	elif cmds.has("menu_left") or cmds.has("menu_right"):
		var key: String = String(rows[_selected]["key"])
		if key != "":
			_change(key, -1 if cmds.has("menu_left") else 1)
	elif cmds.has("tab_prev") or cmds.has("tab_next"):
		_body_scroll.scroll_vertical += -120 if cmds.has("tab_prev") else 120
		return true
	elif cmds.has("accept"):
		var key: String = String(rows[_selected]["key"])
		if key == "":
			_next()
			return true
		_change(key, 1)
	elif cmds.has("cancel") and last_row == "back":
		_next()
		return true
	_draw_rows()
	return true


func command(cmd: String) -> bool:
	return handle([cmd])


## Mouse: a click on a row acts like accept (or picks it); on the brightness page a click goes on.
func mouse(event: InputEvent) -> bool:
	if not visible:
		return false
	var button := event as InputEventMouseButton
	if button == null or not button.pressed:
		return true
	if button.button_index != MOUSE_BUTTON_LEFT:
		return button.button_index != MOUSE_BUTTON_WHEEL_UP and button.button_index != MOUSE_BUTTON_WHEEL_DOWN
	if page() == "brightness":
		_next()
		return true
	var rows := _rows.get_children()
	for i in rows.size():
		if (rows[i] as Control).get_global_rect().has_point(button.position):
			_selected = i
			return handle(["accept"])
	return true


func _next() -> void:
	_page += 1
	if _page >= _pages.size():
		visible = false
		finished.emit()
		return
	_show_page()


func _show_page() -> void:
	_selected = 0
	for c in _mark_row.get_children():
		_mark_row.remove_child(c)
		c.queue_free()
	var bright := page() == "brightness"
	_marks.visible = bright
	_mark_row.visible = bright
	_body_scroll.visible = not bright
	# On the brightness page the panel is see-through, so the marks show.
	_panel.self_modulate.a = 0.0 if bright else 1.0
	if bright:
		_title.text = tr("ui.first.brightness_title")
		_hint.text = tr("ui.first.brightness_hint")
		for k in MARK_LABELS:
			var l := _label(18, Color(0.7, 0.72, 0.76))
			l.text = tr(String(k))
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			l.size_flags_vertical = Control.SIZE_FILL
			_mark_row.add_child(l)
		_footer.text = input.fill(tr("ui.first.brightness_controls")) if input != null else ""
	else:
		var doc: Dictionary = runner.get_doc(notice_doc) if runner != null and notice_doc != "" else {}
		_title.text = ProtoUI.keep_words(String(doc.get("title", ""))) if not doc.is_empty() else tr("ui.first.notice_title")
		_hint.text = ""
		_body.text = ProtoUI.keep_words("\n\n".join(PackedStringArray(doc.get("paragraphs", []))))
		_body_scroll.scroll_vertical = 0
		_footer.text = input.fill(tr("ui.first.notice_controls")) if input != null else ""
	_hint.visible = _hint.text != ""
	_draw_rows()
	_marks.queue_redraw()


func _row_items() -> Array:
	if page() == "brightness":
		return [{"key": "brightness", "label": "ui.options.brightness"}]
	return [
		{"key": "scare_mode", "label": "ui.options.scare_mode", "choices": ["ui.options.scare_default", "ui.options.scare_soft", "ui.options.scare_off"]},
		{"key": "photosafe", "label": "ui.options.reduce_flashing", "choices": ["ui.options.off", "ui.options.on"]},
		{"key": "", "label": "ui.first.start" if last_row == "start" else "ui.options.back"},
	]


func _change(key: String, direction: int) -> void:
	if settings == null:
		return
	var v := int(settings.values[key])
	if key == "brightness":
		v = clampi(v + direction, 0, 10)
	else:
		var n := 3 if key == "scare_mode" else 2
		v = (v + direction + n) % n
	settings.set_value(key, v)
	_draw_rows()
	_marks.queue_redraw()


func _draw_rows() -> void:
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.queue_free()
	var items := _row_items()
	for i in items.size():
		var item: Dictionary = items[i]
		var on := i == _selected
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", _row_style if on and _row_style != null else _blank())
		var line := HBoxContainer.new()
		var name_label := _label(22, Color.WHITE if on else Color(0.75, 0.8, 0.85))
		name_label.text = ("> " if on and _row_style == null else "") + tr(String(item["label"]))
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(name_label)
		var key: String = String(item["key"])
		if key != "" and settings != null:
			var value := _label(22, Color(0.75, 0.92, 1.0))
			var v := int(settings.values[key])
			value.text = "< %s >" % ("%d" % v if not item.has("choices") else tr(String(item["choices"][v])))
			line.add_child(value)
		row.add_child(line)
		_rows.add_child(row)
	var key_now: String = String(items[_selected]["key"])
	_row_hint.text = tr("ui.options.scare_hint") if page() == "notice" and key_now == "scare_mode" else ""
	_row_hint.visible = _row_hint.text != ""


## Three squares on black at MARKS' grey, through the brightness curve, mid-screen.
func _draw_marks() -> void:
	var view := _marks.size
	var side := 120.0
	var gamma := ProtoScreen.gamma_for(int(settings.values["brightness"]) if settings != null else 5)
	for i in MARKS.size():
		var center := Vector2(view.x * (0.3 + 0.2 * i), view.y * 0.5)
		var g := pow(float(MARKS[i]), 1.0 / gamma)
		_marks.draw_rect(Rect2(center - Vector2(side, side) / 2.0, Vector2(side, side)), Color(g, g, g))


func _blank() -> StyleBox:
	var sb := StyleBoxEmpty.new()
	if _row_style != null:
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			sb.set_content_margin(side, _row_style.get_content_margin(side))
	return sb


func _flat() -> StyleBox:
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

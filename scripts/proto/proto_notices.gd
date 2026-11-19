## Notices (docs/ui-ux.md P0-6): one-line messages at the top right, under the viewfinder's battery
## mark, each with a small drawn icon: a card pinned on the board, a knot untied, a document added
## to the journal, a track that can now be played, footage recorded, or a line of the story sent to
## [to=notice]. They stay NOTICE_SECS, fade out (no blinking), and stack three high; a fourth folds
## the oldest away early.
##
## While `held` (a scare is pending or playing) new notices wait, so nothing on screen moves in the
## moment before a scare (docs/scare-director.md: a stimulus 30-500 ms before a startle weakens it).
##
## Also draws the autosave mark at the bottom right: a tape reel turning while `saving()` is on.
class_name ProtoNotices
extends Control

const NOTICE_SECS := 3.5
const FADE_SECS := 0.4
const MAX_SHOWN := 3
## The save mark stays at least this long, so it can be seen at all.
const SAVE_SECS := 1.6
const TEXT_COLOR := Color(0.92, 0.93, 0.95)
const ICON_COLOR := Color(0.95, 0.85, 0.55)

var font: Font
## True while new notices must wait (set by the game every frame).
var held := false
var _queue: Array = []
var _stack: VBoxContainer
var _save: Control
var _reel: Control
var _save_label: Label
var _save_left := 0.0


func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stack = VBoxContainer.new()
	_stack.anchor_left = 0.955
	_stack.anchor_right = 0.955
	_stack.anchor_top = 0.128
	_stack.anchor_bottom = 0.128
	_stack.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_stack.add_theme_constant_override("separation", 6)
	_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stack)
	var save_row := HBoxContainer.new()
	save_row.anchor_left = 0.985
	save_row.anchor_right = 0.985
	save_row.anchor_top = 0.985
	save_row.anchor_bottom = 0.985
	save_row.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	save_row.grow_vertical = Control.GROW_DIRECTION_BEGIN
	save_row.add_theme_constant_override("separation", 6)
	save_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(save_row)
	_save_label = _label(16, Color(0.75, 0.78, 0.82))
	save_row.add_child(_save_label)
	_reel = _Glyph.new("reel", Color(0.75, 0.78, 0.82))
	save_row.add_child(_reel)
	save_row.visible = false
	_save = save_row


## Queues a notice. `kind`: "card", "knot", "doc", "track", "rec" or "info" (the icon).
func push(kind: String, text: String) -> void:
	_queue.append({"kind": kind, "text": text})


func clear() -> void:
	_queue.clear()
	for c in _stack.get_children():
		_stack.remove_child(c)
		c.queue_free()


## Shows the save mark for at least SAVE_SECS.
func saving() -> void:
	_save_left = SAVE_SECS
	_save_label.text = tr("ui.system.saving")


func shown_count() -> int:
	return _stack.get_child_count()


func queued_count() -> int:
	return _queue.size()


func shown_text(i: int) -> String:
	var item := _stack.get_child(i)
	return String(item.get_meta("text", ""))


func save_visible() -> bool:
	return _save.visible


func _process(delta: float) -> void:
	if not held:
		while not _queue.is_empty():
			var n: Dictionary = _queue.pop_front()
			if _stack.get_child_count() >= MAX_SHOWN:
				var oldest := _stack.get_child(0)
				_stack.remove_child(oldest)
				oldest.queue_free()
			_stack.add_child(_item(String(n["kind"]), String(n["text"])))
	for item in _stack.get_children():
		var left: float = float(item.get_meta("left")) - delta
		item.set_meta("left", left)
		if left <= 0.0:
			_stack.remove_child(item)
			item.queue_free()
		elif left < FADE_SECS:
			item.modulate.a = left / FADE_SECS
	_save_left = maxf(0.0, _save_left - delta)
	# The reel stands still and hides while a scare is pending, like the notices.
	_save.visible = _save_left > 0.0 and not held
	if _save.visible:
		_reel.queue_redraw()


func _item(kind: String, text: String) -> Control:
	var box := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.04, 0.06, 0.86)
	sb.border_color = Color(0.3, 0.31, 0.36)
	sb.set_border_width_all(1)
	sb.content_margin_left = 10
	sb.content_margin_right = 12
	sb.content_margin_top = 5
	sb.content_margin_bottom = 6
	box.add_theme_stylebox_override("panel", sb)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.set_meta("left", NOTICE_SECS)
	box.set_meta("text", text)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 8)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(_Glyph.new(kind, ICON_COLOR))
	var l := _label(20, TEXT_COLOR)
	l.text = ProtoUI.keep_words(text)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# As wide as the text, up to a third of the screen.
	var f: Font = font if font != null else ThemeDB.fallback_font
	l.custom_minimum_size.x = minf(f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 4.0, 420.0)
	line.add_child(l)
	box.add_child(line)
	return box


func _label(size_px: int, color: Color) -> Label:
	var l := Label.new()
	if font != null:
		l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l


## Square-pixel icons until the icon art (mbs_ui_icons) exists.
class _Glyph extends Control:
	var kind := ""
	var color := Color.WHITE
	var _t := 0.0

	func _init(glyph_kind: String, glyph_color: Color) -> void:
		kind = glyph_kind
		color = glyph_color
		custom_minimum_size = Vector2(16, 16)
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(delta: float) -> void:
		if kind == "reel" and is_visible_in_tree():
			_t += delta

	func _draw() -> void:
		var dark := Color(0.05, 0.05, 0.07)
		match kind:
			"card":
				draw_rect(Rect2(1, 3, 14, 11), color)
				draw_rect(Rect2(3, 7, 10, 1), dark)
				draw_rect(Rect2(3, 10, 7, 1), dark)
				draw_rect(Rect2(7, 1, 2, 3), Color(0.9, 0.35, 0.35))
			"doc":
				draw_rect(Rect2(3, 1, 10, 14), color)
				draw_rect(Rect2(10, 1, 3, 3), dark)
				for y in [5, 8, 11]:
					draw_rect(Rect2(5, y, 6, 1), dark)
			"knot":
				draw_rect(Rect2(1, 5, 14, 2), color)
				draw_rect(Rect2(1, 9, 14, 2), color)
				draw_rect(Rect2(6, 3, 4, 10), color)
				draw_rect(Rect2(7, 6, 2, 4), dark)
			"track":
				draw_rect(Rect2(0, 3, 16, 11), color)
				draw_rect(Rect2(3, 6, 3, 3), dark)
				draw_rect(Rect2(10, 6, 3, 3), dark)
				draw_rect(Rect2(4, 11, 8, 2), dark)
			"rec":
				draw_circle(Vector2(8, 8), 6.0, Color(0.92, 0.3, 0.3))
			"reel":
				draw_circle(Vector2(8, 8), 7.0, color)
				draw_circle(Vector2(8, 8), 2.0, dark)
				# Three spokes, a quarter turn a second (slow, no flicker).
				for k in 3:
					var a := _t * PI * 0.5 + k * TAU / 3.0
					draw_line(Vector2(8, 8) + Vector2(cos(a), sin(a)) * 2.5, Vector2(8, 8) + Vector2(cos(a), sin(a)) * 6.0, dark, 2.0)
			_:
				draw_rect(Rect2(7, 2, 2, 2), color)
				draw_rect(Rect2(7, 6, 2, 8), color)

## People page (affinity): everyone the player has met so far, each with their portrait, name and a
## gauge of how they feel about the player (the level's "affinity" block, docs/ui-ux.md). Opened
## from the pause menu; the game is paused while it is open.
##
## Keys: the menu keys move the selection, cancel, pause or accept closes. A right click closes.
class_name ProtoPeople
extends Control

signal closed

const NAME_COLOR := Color(0.95, 0.85, 0.55)
const TEXT_COLOR := Color(0.9, 0.91, 0.93)
const DIM := Color(0.55, 0.58, 0.63)
const COLUMNS := 4

var input: ProtoInput
## [{"id", "name", "portrait": Texture2D or null, and for people with affinity "value", "min", "max"}]
var people: Array = []
var _font: Font
var _title: Label
var _grid: GridContainer
var _empty: Label
var _footer: Label
var _cards: Array = []
var _selected := 0


func setup(font: Font, panel: StyleBox) -> void:
	_font = font
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
	col.add_theme_constant_override("separation", 10)
	box.add_child(col)
	_title = _label(28, NAME_COLOR)
	col.add_child(_title)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 18)
	_grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(_grid)
	_empty = _label(22, DIM)
	_empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_empty)
	_footer = _label(17, DIM)
	_footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_footer)
	visible = false


func is_open() -> bool:
	return visible


## Shows `list` (see `people`).
func open(list: Array) -> void:
	people = list
	_title.text = tr("ui.people.title")
	_footer.text = input.fill(tr("ui.people.controls")) if input != null else tr("ui.people.controls")
	_empty.text = tr("ui.people.empty") if people.is_empty() else ""
	_empty.visible = people.is_empty()
	_selected = 0
	_rebuild()
	visible = true


func close() -> void:
	visible = false
	closed.emit()


func handle(cmds: Array) -> bool:
	if not visible:
		return false
	if cmds.has("cancel") or cmds.has("pause") or cmds.has("accept"):
		close()
		return true
	var n := _cards.size()
	if n == 0:
		return true
	if cmds.has("menu_left"):
		_selected = maxi(0, _selected - 1)
	elif cmds.has("menu_right"):
		_selected = mini(n - 1, _selected + 1)
	elif cmds.has("menu_up"):
		_selected = maxi(0, _selected - COLUMNS)
	elif cmds.has("menu_down"):
		_selected = mini(n - 1, _selected + COLUMNS)
	_refresh()
	return true


func command(cmd: String) -> bool:
	return handle([cmd])


func mouse(event: InputEvent) -> bool:
	if not visible:
		return false
	var button := event as InputEventMouseButton
	if button != null and button.pressed and button.button_index == MOUSE_BUTTON_RIGHT:
		close()
		return true
	return button != null


func card_count() -> int:
	return _cards.size()


func _rebuild() -> void:
	for c in _grid.get_children():
		_grid.remove_child(c)
		c.queue_free()
	_cards.clear()
	for p in people:
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", _card_style(false))
		var col := VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", 6)
		card.add_child(col)
		var pic := TextureRect.new()
		pic.texture = p.get("portrait")
		pic.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		col.add_child(pic)
		var name_label := _label(22, TEXT_COLOR)
		name_label.text = String(p.get("name", ""))
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(name_label)
		if p.has("value"):
			var gauge := _Gauge.new()
			gauge.lo = float(p.get("min", -3.0))
			gauge.hi = float(p.get("max", 3.0))
			gauge.value = clampf(float(p.get("value", 0.0)), gauge.lo, gauge.hi)
			gauge.custom_minimum_size = Vector2(140, 14)
			gauge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			col.add_child(gauge)
		_grid.add_child(card)
		_cards.append(card)
	_refresh()


func _refresh() -> void:
	for i in _cards.size():
		(_cards[i] as PanelContainer).add_theme_stylebox_override("panel", _card_style(i == _selected))
	if _selected < _cards.size():
		# Keep the selected card in view when it is below the fold.
		(_grid.get_parent() as ScrollContainer).ensure_control_visible.call_deferred(_cards[_selected])


func _card_style(on: bool) -> StyleBox:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.12, 0.15, 0.95) if on else Color(0.07, 0.07, 0.09, 0.9)
	sb.border_color = NAME_COLOR if on else Color(0.2, 0.2, 0.24)
	sb.set_border_width_all(2)
	sb.set_content_margin_all(10)
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


## A row of cells from `lo` to `hi`; the cell for 0 is drawn as a tick, cells towards the value are
## filled (warm above zero, cold below), so the gauge reads without colour too.
class _Gauge extends Control:
	var value := 0.0
	var lo := -3.0
	var hi := 3.0

	func _draw() -> void:
		var cells := int(hi - lo) + 1
		if cells <= 0:
			return
		var w := size.x / cells
		var warm := Color(0.95, 0.72, 0.45)
		var cold := Color(0.45, 0.62, 0.85)
		var empty := Color(0.25, 0.25, 0.3)
		for i in cells:
			var v := lo + i
			var r := Rect2(i * w + 1, 0, w - 2, size.y)
			var filled := (v > 0 and v <= value) or (v < 0 and v >= value)
			var c := (warm if v > 0 else cold) if filled else empty
			if v == 0:
				# The middle: a thin bar, always drawn.
				draw_rect(Rect2(r.position.x + r.size.x / 2 - 1, 0, 2, size.y), Color(0.8, 0.8, 0.85))
			else:
				draw_rect(r, c, filled)
				if not filled:
					draw_rect(r, c, false, 1.0)

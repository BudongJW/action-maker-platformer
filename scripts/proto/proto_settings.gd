## Prototype settings screen (Esc): scare mode, reduce flashing, volumes, text size, subtitles and
## consent to effects outside the game window. Labels come from the UI strings table
## (assets/original/ui/strings.csv, keys ui.options.*), never from code. Values are applied at once
## and saved to user://proto_settings.cfg (the bot neither loads nor saves them).
class_name ProtoSettings
extends Control

signal closed

const STRINGS := "res://assets/original/ui/strings.csv"
const SAVE_PATH := "user://proto_settings.cfg"
const TEXT_SCALES := [0.85, 1.0, 1.25]

var director: ScareDirector
var audio: ProtoAudio
var ui: ProtoUI
var runner: StoryRunner
var persist := true
var values := {
	"scare_mode": 0, "photosafe": 0, "master_volume": 10, "ambience_volume": 8, "sfx_volume": 8,
	"text_size": 1, "subtitles": 1, "meta_os": 0,
}

var _items: Array = []
var _selected := 0
var _rows: VBoxContainer
var _title: Label
var _hint: Label
var _controls: Label
var _font: Font
var _row_style: StyleBox
var _cursor: Texture2D


func setup(font: Font, panel: StyleBox, row_style: StyleBox, cursor: Texture2D) -> void:
	_font = font
	_row_style = row_style
	_cursor = cursor
	_load_strings()
	_items = [
		{"key": "scare_mode", "label": "ui.options.scare_mode", "choices": ["ui.options.scare_default", "ui.options.scare_soft", "ui.options.scare_off"], "hint": "ui.options.scare_hint"},
		{"key": "photosafe", "label": "ui.options.reduce_flashing", "choices": ["ui.options.off", "ui.options.on"]},
		{"key": "master_volume", "label": "ui.options.master_volume", "range": 10},
		{"key": "ambience_volume", "label": "ui.options.ambience_volume", "range": 10},
		{"key": "sfx_volume", "label": "ui.options.sfx_volume", "range": 10},
		{"key": "text_size", "label": "ui.options.text_size", "choices": ["ui.options.size_small", "ui.options.size_normal", "ui.options.size_large"]},
		{"key": "subtitles", "label": "ui.options.subtitles", "choices": ["ui.options.off", "ui.options.on"]},
		{"key": "meta_os", "label": "ui.options.meta_effects", "choices": ["ui.options.off", "ui.options.on"], "hint": "ui.options.meta_effects_hint"},
		{"key": "", "label": "ui.options.back"},
	]
	anchor_left = 0.2
	anchor_right = 0.8
	anchor_top = 0.5
	anchor_bottom = 0.5
	grow_vertical = Control.GROW_DIRECTION_BOTH
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := PanelContainer.new()
	box.anchor_right = 1.0
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	if panel != null:
		box.add_theme_stylebox_override("panel", panel)
	else:
		var flat := StyleBoxFlat.new()
		flat.bg_color = Color(0.08, 0.08, 0.1, 0.95)
		flat.set_content_margin_all(24)
		box.add_theme_stylebox_override("panel", flat)
	add_child(box)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	box.add_child(col)
	_title = _label(24, Color(0.95, 0.85, 0.55))
	_rows = VBoxContainer.new()
	_hint = _label(15, Color(0.7, 0.75, 0.8))
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_controls = _label(14, Color(0.55, 0.6, 0.65))
	col.add_child(_title)
	col.add_child(_rows)
	col.add_child(_hint)
	col.add_child(_controls)
	visible = false
	if persist:
		_load_values()
	apply_all()


func is_open() -> bool:
	return visible


func open() -> void:
	_selected = 0
	visible = true
	_refresh()


func close() -> void:
	visible = false
	if persist:
		_save_values()
	closed.emit()


## Up/Down move, Left/Right change, Enter on "back" or Esc closes. Returns true if handled.
func handle_key(key: int) -> bool:
	if not visible:
		return false
	match key:
		KEY_ESCAPE:
			close()
		KEY_UP:
			_selected = (_selected - 1 + _items.size()) % _items.size()
		KEY_DOWN:
			_selected = (_selected + 1) % _items.size()
		KEY_LEFT:
			_step(-1)
		KEY_RIGHT:
			_step(1)
		KEY_ENTER, KEY_KP_ENTER, KEY_E:
			if String(_items[_selected]["key"]) == "":
				close()
				return true
			_step(1)
		_:
			return true
	if visible:
		_refresh()
	return true


## Changes one value from outside (the M and P shortcut keys) and keeps the screen in step.
func set_value(key: String, value: int) -> void:
	values[key] = value
	apply_all()
	if persist:
		_save_values()


func apply_all() -> void:
	if director != null:
		director.mode = int(values["scare_mode"]) as ScareDirector.Mode
		director.photosafe = int(values["photosafe"]) == 1
	AudioServer.set_bus_volume_db(0, _volume_db(int(values["master_volume"])))
	var sfx := AudioServer.get_bus_index(ProtoAudio.SFX_BUS)
	if sfx >= 0:
		AudioServer.set_bus_volume_db(sfx, _volume_db(int(values["sfx_volume"])))
	if audio != null:
		audio.set_ambience_offset(_volume_db(int(values["ambience_volume"])))
	if ui != null:
		ui.set_text_scale(TEXT_SCALES[int(values["text_size"])])
		ui.set_captions(int(values["subtitles"]) == 1)
	if runner != null:
		runner.flags.set_meta_os(int(values["meta_os"]) == 1)


func _step(direction: int) -> void:
	var item: Dictionary = _items[_selected]
	var key: String = String(item["key"])
	if key == "":
		return
	if item.has("range"):
		values[key] = clampi(int(values[key]) + direction, 0, int(item["range"]))
	else:
		var n: int = item["choices"].size()
		values[key] = (int(values[key]) + direction + n) % n
	apply_all()


func _refresh() -> void:
	_title.text = tr("ui.options.title")
	_controls.text = tr("ui.options.controls")
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.queue_free()
	for i in _items.size():
		var item: Dictionary = _items[i]
		var on := i == _selected
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", _row_style if on and _row_style != null else _blank())
		var line := HBoxContainer.new()
		var mark := TextureRect.new()
		mark.custom_minimum_size = Vector2(28, 0)
		mark.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		mark.texture = _cursor if on else null
		line.add_child(mark)
		var name_label := _label(18, Color.WHITE if on else Color(0.75, 0.8, 0.85))
		name_label.text = tr(String(item["label"]))
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(name_label)
		var key: String = String(item["key"])
		if key != "":
			var value_label := _label(18, Color(0.75, 0.92, 1.0))
			value_label.text = "< %s >" % _value_text(item)
			line.add_child(value_label)
		row.add_child(line)
		_rows.add_child(row)
	var selected: Dictionary = _items[_selected]
	_hint.text = tr(String(selected["hint"])) if selected.has("hint") else ""
	_hint.visible = _hint.text != ""


## Same padding as the highlight, so moving the cursor does not shift the rows.
func _blank() -> StyleBox:
	var sb := StyleBoxEmpty.new()
	if _row_style != null:
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			sb.set_content_margin(side, _row_style.get_content_margin(side))
	return sb


func _value_text(item: Dictionary) -> String:
	var v := int(values[String(item["key"])])
	if item.has("range"):
		return "%d" % v
	return tr(String(item["choices"][v]))


func _volume_db(step: int) -> float:
	return linear_to_db(maxf(step / 10.0, 0.0001)) if step > 0 else -80.0


func _label(size_px: int, color: Color) -> Label:
	var l := Label.new()
	if _font != null:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	return l


## Reads the UI strings CSV (keys, then one column per locale) into TranslationServer.
func _load_strings() -> void:
	if not FileAccess.file_exists(STRINGS):
		return
	var f := FileAccess.open(STRINGS, FileAccess.READ)
	var header := f.get_csv_line()
	var tables: Array = []
	for i in range(1, header.size()):
		var t := Translation.new()
		t.locale = header[i]
		tables.append(t)
	while not f.eof_reached():
		var row := f.get_csv_line()
		if row.size() < 2 or row[0] == "":
			continue
		for i in range(1, mini(row.size(), header.size())):
			tables[i - 1].add_message(row[0], row[i])
	for t in tables:
		TranslationServer.add_translation(t)


func _load_values() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	for key in values:
		values[key] = int(cfg.get_value("options", key, values[key]))


func _save_values() -> void:
	var cfg := ConfigFile.new()
	for key in values:
		cfg.set_value("options", key, values[key])
	cfg.save(SAVE_PATH)

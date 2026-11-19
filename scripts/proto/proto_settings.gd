## Prototype settings screen (Esc): scare mode, reduce flashing, volumes, text size, subtitles,
## consent to effects outside the game window, and a controls screen for rebinding (ProtoInput).
## Labels come from the UI strings table (assets/original/ui/strings.csv, keys ui.options.* and
## ui.input.*), never from code. Values are applied at once and saved to user://proto_settings.cfg
## with the input bindings (the bot neither loads nor saves them). Works with the keyboard, a
## gamepad and the mouse (hover to select, click to change, right-click to go back).
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
var input: ProtoInput
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
## "" for the settings list, "remap" for the controls screen.
var _mode := ""
var _remap_selected := 0
## The action waiting for a new key or button ("" if none).
var _waiting := ""


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
		{"key": "", "label": "ui.options.remap", "open": "remap"},
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
	_mode = ""
	_waiting = ""
	visible = true
	_refresh()


func close() -> void:
	visible = false
	if persist:
		_save_values()
	closed.emit()


## Input actions (ProtoInput.commands): menu_up/menu_down move, menu_left/menu_right change,
## accept on "back" or cancel closes. `event` is the raw event, for rebinding. Returns true if the
## screen is open (it takes every input while it is).
func handle(cmds: Array, event: InputEvent = null) -> bool:
	if not visible:
		return false
	if _waiting != "":
		_capture(event)
	elif _mode == "remap":
		_handle_remap(cmds)
	elif cmds.has("cancel"):
		close()
		return true
	elif cmds.has("menu_up"):
		_selected = (_selected - 1 + _items.size()) % _items.size()
	elif cmds.has("menu_down"):
		_selected = (_selected + 1) % _items.size()
	elif cmds.has("menu_left"):
		_step(-1)
	elif cmds.has("menu_right"):
		_step(1)
	elif cmds.has("accept"):
		_activate()
		if not visible:
			return true
	if visible:
		_refresh()
	return true


## Row of the controls screen entry in the settings list (the bot moves there).
func remap_row_index() -> int:
	for i in _items.size():
		if String(_items[i].get("open", "")) == "remap":
			return i
	return 0


## One command without a raw event (the bot, the reel).
func command(cmd: String) -> bool:
	return handle([cmd], null)


## Mouse: hovering a row selects it, a left click acts like accept, a right click like cancel.
func mouse(event: InputEvent) -> bool:
	if not visible:
		return false
	var button := event as InputEventMouseButton
	if button != null and not button.pressed:
		return true
	if button != null and button.button_index == MOUSE_BUTTON_RIGHT:
		return handle(["cancel"], null)
	var pos: Vector2 = (event as InputEventMouse).position
	var rows := _rows.get_children()
	for i in rows.size():
		if (rows[i] as Control).get_global_rect().has_point(pos):
			if _waiting != "":
				if button != null:
					_waiting = ""
					_refresh()
				return true
			if _mode == "remap":
				_remap_selected = i
			else:
				_selected = i
			if button != null and button.button_index == MOUSE_BUTTON_LEFT:
				return handle(["accept"], null)
			_refresh()
			return true
	return true


func _activate() -> void:
	var item: Dictionary = _items[_selected]
	if String(item.get("open", "")) == "remap" and input != null:
		_mode = "remap"
		_remap_selected = 0
	elif String(item["key"]) == "":
		close()
	else:
		_step(1)


## Rows of the controls screen: rebindable actions, then "reset" and "back".
func _remap_rows() -> Array:
	var rows: Array = input.rebindable() if input != null else []
	return rows + [{"action": "", "label": "ui.input.reset"}, {"action": "", "label": "ui.options.back"}]


func _handle_remap(cmds: Array) -> void:
	var rows := _remap_rows()
	if cmds.has("cancel"):
		_mode = ""
	elif cmds.has("menu_up"):
		_remap_selected = (_remap_selected - 1 + rows.size()) % rows.size()
	elif cmds.has("menu_down"):
		_remap_selected = (_remap_selected + 1) % rows.size()
	elif cmds.has("accept"):
		var row: Dictionary = rows[_remap_selected]
		if String(row["action"]) != "":
			_waiting = String(row["action"])
		elif String(row["label"]) == "ui.input.reset":
			input.reset_defaults()
			if persist:
				_save_values()
		else:
			_mode = ""


## While waiting: the next key, pad button or stick/trigger push becomes the binding. Escape, a
## mouse click or a command without an event cancels; Escape itself cannot be bound.
func _capture(event: InputEvent) -> void:
	var key := event as InputEventKey
	if event == null or (key != null and key.keycode == KEY_ESCAPE):
		_waiting = ""
		return
	var usable := (key != null and key.pressed and not key.echo) \
		or (event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed) \
		or (event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) >= ProtoInput.DEADZONE)
	if usable and input.rebind(_waiting, event):
		_waiting = ""
		if persist:
			_save_values()


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
	_title.text = tr("ui.input.title") if _mode == "remap" else tr("ui.options.title")
	_controls.text = input.fill(tr("ui.options.controls")) if input != null else tr("ui.options.controls")
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.queue_free()
	if _mode == "remap":
		var rows := _remap_rows()
		for i in rows.size():
			var row: Dictionary = rows[i]
			var action: String = row["action"]
			var value := ""
			if action == _waiting and action != "":
				value = tr("ui.input.waiting_short")
			elif action != "":
				value = "%s  |  %s" % [input.binding_name(action, "keyboard"), input.binding_name(action, "pad")]
			_add_row(i == _remap_selected, tr(String(row["label"])), value)
		_hint.text = input.fill(tr("ui.input.waiting")) if _waiting != "" else tr("ui.input.hint")
		_hint.visible = true
		return
	for i in _items.size():
		var item: Dictionary = _items[i]
		var key: String = String(item["key"])
		_add_row(i == _selected, tr(String(item["label"])), "< %s >" % _value_text(item) if key != "" else "")
	var selected: Dictionary = _items[_selected]
	_hint.text = tr(String(selected["hint"])) if selected.has("hint") else ""
	_hint.visible = _hint.text != ""


func _add_row(on: bool, label_text: String, value_text: String) -> void:
	var row := PanelContainer.new()
	row.add_theme_stylebox_override("panel", _row_style if on and _row_style != null else _blank())
	var line := HBoxContainer.new()
	var mark := TextureRect.new()
	mark.custom_minimum_size = Vector2(28, 0)
	mark.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	mark.texture = _cursor if on else null
	line.add_child(mark)
	var name_label := _label(18, Color.WHITE if on else Color(0.75, 0.8, 0.85))
	name_label.text = label_text
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(name_label)
	if value_text != "":
		var value_label := _label(18, Color(0.75, 0.92, 1.0))
		value_label.text = value_text
		line.add_child(value_label)
	row.add_child(line)
	_rows.add_child(row)


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
	if input != null and cfg.has_section("input"):
		var saved := {}
		for action in cfg.get_section_keys("input"):
			saved[action] = cfg.get_value("input", action, [])
		input.restore(saved)


func _save_values() -> void:
	var cfg := ConfigFile.new()
	for key in values:
		cfg.set_value("options", key, values[key])
	if input != null:
		var bindings := input.store()
		for action in bindings:
			cfg.set_value("input", action, bindings[action])
	cfg.save(SAVE_PATH)

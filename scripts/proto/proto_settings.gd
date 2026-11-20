## Prototype settings screen (Esc), in five tabs (docs/ui-ux.md P0-8): display (window mode, VHS
## texture strength, screen shake), audio (volumes), text (text size, captions, caption background,
## speaker names, auto-advance and its speed), accessibility (scare mode, reduce flashing, chase
## assist, consent to effects outside the game window) and controls (rebinding through ProtoInput,
## fast-forward hold or toggle).
##
## Labels come from the UI strings table (assets/original/ui/strings.csv, keys ui.options.* and
## ui.input.*), never from code. Values are applied at once and saved to user://proto_settings.cfg
## with the input bindings (the bot and reels neither load nor save them). Works with the keyboard,
## a gamepad and the mouse (hover to select, click to change or to pick a tab, right-click to go
## back).
class_name ProtoSettings
extends Control

signal closed
## A row that opens a page of its own ("brightness", "content"): the game shows it and calls
## back_from_page() when it closes.
signal open_page(page_name: String)

const STRINGS := "res://assets/original/ui/strings.csv"
const SAVE_PATH := "user://proto_settings.cfg"
const TEXT_SCALES := [0.85, 1.0, 1.2, 1.4]
## Opacity of the box behind captions and bubbles.
const TEXT_BG := [0.0, 0.5, 0.75, 1.0]
## Auto-advance waits the reading time (ProtoUI.reading_secs) times this: slow, normal, fast.
const ADVANCE_FACTORS := [1.3, 1.0, 0.8]
## Chase assist: the chaser's speed is multiplied by this.
const CHASE_ASSIST_SPEED := 0.7
## Tallest the list of rows gets before it scrolls (the controls screen has fourteen).
const MAX_LIST_HEIGHT := 430.0

var director: ScareDirector
var audio: ProtoAudio
var ui: ProtoUI
var runner: StoryRunner
var input: ProtoInput
var fx: ProtoFX
var screen: ProtoScreen
var persist := true
## The window mode is applied only for the player's own runs (not the bot or a reel).
var apply_window := false
var values := {
	"fullscreen": 0, "brightness": 5, "vhs_strength": 2, "screen_shake": 1,
	"master_volume": 10, "ambience_volume": 8, "sfx_volume": 8, "sound_captions": 0,
	"text_size": 1, "subtitles": 1, "text_bg": 2, "speaker_names": 1, "advance": 0,
	"advance_speed": 1,
	"scare_mode": 0, "photosafe": 0, "chase_assist": 0, "meta_os": 0,
	"ff_hold": 0,
	# Not a row: set once the first-run pages (brightness, content notice) have been through.
	"first_run_done": 0,
}

## [{"label": tab name key, "items": [item, ...]}]. An item is {"key", "label", "hint"?} with
## "choices" (string keys), "labels" (shown as they are) or "range" (0..range); or {"key": "",
## "open": "remap"} for the controls screen, or {"key": ""} for "back".
var _tabs: Array = []
var _tab := 0
var _items: Array = []
## Row of the current tab; -1 is the tab bar (left/right there change the tab).
var _selected := 0
var _tab_bar: HBoxContainer
var _tab_on: StyleBoxFlat
var _tab_off: StyleBoxEmpty
var _scroll: ScrollContainer
var _rows: VBoxContainer
var _title: Label
var _hint: Label
var _controls: Label
var _font: Font
var _row_style: StyleBox
var _cursor: Texture2D
## "" for the settings tabs, "remap" for the controls screen.
var _mode := ""
var _remap_selected := 0
## The action waiting for a new key or button ("" if none).
var _waiting := ""


func setup(font: Font, panel: StyleBox, row_style: StyleBox, cursor: Texture2D) -> void:
	_font = font
	_row_style = row_style
	_cursor = cursor
	_load_strings()
	var off_on := ["ui.options.off", "ui.options.on"]
	var back := {"key": "", "label": "ui.options.back"}
	_tabs = [
		{"label": "ui.options.tab_display", "items": [
			{"key": "fullscreen", "label": "ui.options.window_mode", "choices": ["ui.options.windowed", "ui.options.fullscreen"]},
			{"key": "brightness", "label": "ui.options.brightness", "range": 10, "open": "brightness", "hint": "ui.options.brightness_hint"},
			{"key": "vhs_strength", "label": "ui.options.vhs_strength", "choices": ["ui.options.off", "ui.options.soft", "ui.options.default"], "hint": "ui.options.vhs_hint"},
			{"key": "screen_shake", "label": "ui.options.screen_shake", "choices": off_on},
			back,
		]},
		{"label": "ui.options.tab_audio", "items": [
			{"key": "master_volume", "label": "ui.options.master_volume", "range": 10},
			{"key": "ambience_volume", "label": "ui.options.ambience_volume", "range": 10},
			{"key": "sfx_volume", "label": "ui.options.sfx_volume", "range": 10},
			{"key": "sound_captions", "label": "ui.options.sound_captions", "choices": off_on, "hint": "ui.options.sound_captions_hint"},
			back,
		]},
		{"label": "ui.options.tab_text", "items": [
			{"key": "text_size", "label": "ui.options.text_size", "choices": ["ui.options.size_small", "ui.options.size_normal", "ui.options.size_large", "ui.options.size_larger"]},
			{"key": "subtitles", "label": "ui.options.subtitles", "choices": off_on},
			{"key": "text_bg", "label": "ui.options.text_bg", "labels": ["0%", "50%", "75%", "100%"], "hint": "ui.options.text_bg_hint"},
			{"key": "speaker_names", "label": "ui.options.speaker_names", "choices": off_on},
			{"key": "advance", "label": "ui.options.advance", "choices": ["ui.options.advance_manual", "ui.options.advance_auto"], "hint": "ui.options.advance_hint"},
			{"key": "advance_speed", "label": "ui.options.advance_speed", "choices": ["ui.options.speed_slow", "ui.options.speed_normal", "ui.options.speed_fast"]},
			back,
		]},
		{"label": "ui.options.tab_access", "items": [
			{"key": "scare_mode", "label": "ui.options.scare_mode", "choices": ["ui.options.scare_default", "ui.options.scare_soft", "ui.options.scare_off"], "hint": "ui.options.scare_hint"},
			{"key": "photosafe", "label": "ui.options.reduce_flashing", "choices": off_on, "hint": "ui.options.reduce_flashing_hint"},
			{"key": "chase_assist", "label": "ui.options.chase_assist", "choices": off_on, "hint": "ui.options.chase_assist_hint"},
			{"key": "meta_os", "label": "ui.options.meta_effects", "choices": off_on, "hint": "ui.options.meta_effects_hint"},
			{"key": "", "label": "ui.options.content_notice", "open": "content", "hint": "ui.options.content_notice_hint"},
			back,
		]},
		{"label": "ui.options.tab_controls", "items": [
			{"key": "", "label": "ui.options.remap", "open": "remap", "hint": "ui.options.remap_hint"},
			{"key": "ff_hold", "label": "ui.options.hold_toggle", "choices": ["ui.options.press_toggle", "ui.options.press_hold"]},
			back,
		]},
	]
	_items = _tabs[0]["items"]
	anchor_left = 0.2
	anchor_right = 0.8
	# The top stays put; the panel grows down as far as the longest tab (or the controls list) needs.
	anchor_top = 0.07
	anchor_bottom = 0.07
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := PanelContainer.new()
	box.anchor_right = 1.0
	if panel != null:
		box.add_theme_stylebox_override("panel", panel)
	else:
		var flat := StyleBoxFlat.new()
		flat.bg_color = Color(0.08, 0.08, 0.1, 0.95)
		flat.set_content_margin_all(24)
		box.add_theme_stylebox_override("panel", flat)
	add_child(box)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	box.add_child(col)
	_title = _label(28, Color(0.95, 0.85, 0.55))
	_tab_bar = HBoxContainer.new()
	_tab_bar.add_theme_constant_override("separation", 6)
	# The current tab: a light underline in the title colour (a drawn tab comes with the UI art).
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
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.add_child(_rows)
	_hint = _label(18, Color(0.7, 0.75, 0.8))
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_controls = _label(17, Color(0.55, 0.6, 0.65))
	_controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_title)
	col.add_child(_tab_bar)
	col.add_child(_scroll)
	col.add_child(_hint)
	col.add_child(_controls)
	visible = false
	if persist:
		_load_values()
	apply_all()


func is_open() -> bool:
	return visible


func open() -> void:
	_show_tab(0)
	_mode = ""
	_waiting = ""
	visible = true
	_refresh()


func close() -> void:
	visible = false
	if persist:
		_save_values()
	closed.emit()


## A page opened from a row has closed: the settings come back where they were.
func back_from_page() -> void:
	visible = true
	if persist:
		_save_values()
	_refresh()


func tab_count() -> int:
	return _tabs.size()


## Index of a tab by its name key's last part ("display", "audio", "text", "access", "controls").
func tab_index(tab_name: String) -> int:
	for i in _tabs.size():
		if String(_tabs[i]["label"]) == "ui.options.tab_" + tab_name:
			return i
	return -1


func current_tab() -> int:
	return _tab


## Input actions (ProtoInput.commands): menu_up/menu_down move, menu_left/menu_right change (or
## change the tab on the tab bar), tab_prev/tab_next change the tab, accept on "back" or cancel
## closes. `event` is the raw event, for rebinding. Returns true if the screen is open (it takes
## every input while it is).
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
	elif cmds.has("tab_prev") or cmds.has("tab_next"):
		_show_tab(_tab + (-1 if cmds.has("tab_prev") else 1), _selected == -1)
	elif cmds.has("menu_up"):
		_selected = _selected - 1 if _selected > -1 else _items.size() - 1
	elif cmds.has("menu_down"):
		_selected = _selected + 1 if _selected < _items.size() - 1 else -1
	elif cmds.has("menu_left") or cmds.has("menu_right"):
		var direction := -1 if cmds.has("menu_left") else 1
		if _selected == -1:
			_show_tab(_tab + direction, true)
		else:
			_step(direction)
	elif cmds.has("accept"):
		_activate()
		if not visible:
			return true
	if visible:
		_refresh()
	return true


## Row of the controls screen entry in its tab (the bot moves there after picking the tab).
func remap_row_index() -> int:
	var tab := tab_index("controls")
	var items: Array = _tabs[tab]["items"] if tab >= 0 else _items
	for i in items.size():
		if String(items[i].get("open", "")) == "remap":
			return i
	return 0


## One command without a raw event (the bot, the reel).
func command(cmd: String) -> bool:
	return handle([cmd], null)


## Mouse: hovering a row selects it, a left click acts like accept (and on a tab, opens it), a
## right click like cancel.
func mouse(event: InputEvent) -> bool:
	if not visible:
		return false
	var button := event as InputEventMouseButton
	if button != null and not button.pressed:
		return true
	if button != null and button.button_index == MOUSE_BUTTON_RIGHT:
		return handle(["cancel"], null)
	var pos: Vector2 = (event as InputEventMouse).position
	var left := button != null and button.button_index == MOUSE_BUTTON_LEFT
	if _mode == "" and _waiting == "":
		var tabs := _tab_bar.get_children()
		for i in tabs.size():
			if left and (tabs[i] as Control).get_global_rect().has_point(pos):
				_show_tab(i, true)
				_refresh()
				return true
	var rows := _rows.get_children()
	for i in rows.size():
		if _scroll.get_global_rect().has_point(pos) and (rows[i] as Control).get_global_rect().has_point(pos):
			if _waiting != "":
				if button != null:
					_waiting = ""
					_refresh()
				return true
			if _mode == "remap":
				_remap_selected = i
			else:
				_selected = i
			if left:
				return handle(["accept"], null)
			_refresh()
			return true
	return true


## Shows tab `index` (wrapping round). `on_bar` keeps the focus on the tab bar.
func _show_tab(index: int, on_bar := false) -> void:
	_tab = posmod(index, _tabs.size())
	_items = _tabs[_tab]["items"]
	_selected = -1 if on_bar else 0


func _activate() -> void:
	if _selected == -1:
		_selected = 0
		return
	var item: Dictionary = _items[_selected]
	var page := String(item.get("open", ""))
	if page == "remap" and input != null:
		_mode = "remap"
		_remap_selected = 0
	elif page != "" and page != "remap":
		# The page takes the screen; back_from_page() brings the settings back.
		visible = false
		open_page.emit(page)
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


func auto_advance() -> bool:
	return int(values["advance"]) == 1


## How long auto-advance waits, as a multiple of the reading time.
func advance_factor() -> float:
	return ADVANCE_FACTORS[clampi(int(values["advance_speed"]), 0, ADVANCE_FACTORS.size() - 1)]


func chase_speed_factor() -> float:
	return CHASE_ASSIST_SPEED if int(values["chase_assist"]) == 1 else 1.0


func ff_hold() -> bool:
	return int(values["ff_hold"]) == 1


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
		ui.set_text_background(TEXT_BG[int(values["text_bg"])])
		ui.show_names = int(values["speaker_names"]) == 1
	if fx != null:
		fx.shake = int(values["screen_shake"]) == 1
	if screen != null:
		screen.set_strength(int(values["vhs_strength"]))
		screen.set_brightness(int(values["brightness"]))
	if runner != null:
		runner.flags.set_meta_os(int(values["meta_os"]) == 1)
	if apply_window and DisplayServer.get_name() != "headless":
		var full := DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
		if full != (int(values["fullscreen"]) == 1):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if not full else DisplayServer.WINDOW_MODE_WINDOWED)


func _step(direction: int) -> void:
	var item: Dictionary = _items[_selected]
	var key: String = String(item["key"])
	if key == "":
		return
	if item.has("range"):
		values[key] = clampi(int(values[key]) + direction, 0, int(item["range"]))
	else:
		var n := _choice_count(item)
		values[key] = (int(values[key]) + direction + n) % n
	apply_all()


func _choice_count(item: Dictionary) -> int:
	return (item["labels"] as Array).size() if item.has("labels") else (item["choices"] as Array).size()


func _refresh() -> void:
	_title.text = tr("ui.input.title") if _mode == "remap" else tr("ui.options.title")
	_controls.text = (input.fill(tr("ui.options.controls")) if input != null else tr("ui.options.controls")) \
		+ "\n" + tr("ui.options.saving_hint")
	_clear(_rows)
	_clear(_tab_bar)
	_tab_bar.visible = _mode != "remap"
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
			_add_row(i == _remap_selected, tr(String(row["label"])), value, 20)
		_hint.text = input.fill(tr("ui.input.waiting")) if _waiting != "" else tr("ui.input.hint")
		_hint.visible = true
		_fit_list(_remap_selected)
		return
	for i in _tabs.size():
		_add_tab(i == _tab, _selected == -1, tr(String(_tabs[i]["label"])))
	for i in _items.size():
		var item: Dictionary = _items[i]
		var key: String = String(item["key"])
		_add_row(i == _selected, tr(String(item["label"])), "< %s >" % _value_text(item) if key != "" else "")
	_hint.text = ""
	if _selected >= 0 and _items[_selected].has("hint"):
		_hint.text = input.fill(tr(String(_items[_selected]["hint"]))) if input != null else tr(String(_items[_selected]["hint"]))
	_hint.visible = _hint.text != ""
	_fit_list(_selected)


## The list is as tall as its rows up to MAX_LIST_HEIGHT, then scrolls to keep `selected` in view.
func _fit_list(selected: int) -> void:
	_scroll.custom_minimum_size.y = minf(_rows.get_combined_minimum_size().y, MAX_LIST_HEIGHT)
	if selected >= 0 and selected < _rows.get_child_count():
		_scroll_to.call_deferred(_rows.get_child(selected))


## After layout. Several commands in one frame (the bot) rebuild the rows each time, so the row
## asked for may be gone by then.
func _scroll_to(row: Control) -> void:
	if is_instance_valid(row) and row.get_parent() == _rows:
		_scroll.ensure_control_visible(row)


func _clear(node: Node) -> void:
	for c in node.get_children():
		node.remove_child(c)
		c.queue_free()


## One tab name; the current tab is highlighted, and marked with arrows while the bar has the focus.
func _add_tab(current: bool, focused: bool, text: String) -> void:
	var tab := PanelContainer.new()
	tab.add_theme_stylebox_override("panel", _tab_on if current else _tab_off)
	var l := _label(22, Color.WHITE if current else Color(0.6, 0.65, 0.7))
	l.text = ("< %s >" % text) if current and focused else text
	tab.add_child(l)
	_tab_bar.add_child(tab)


func _add_row(on: bool, label_text: String, value_text: String, size_px := 22) -> void:
	var row := PanelContainer.new()
	row.add_theme_stylebox_override("panel", _row_style if on and _row_style != null else _blank())
	var line := HBoxContainer.new()
	var mark := TextureRect.new()
	mark.custom_minimum_size = Vector2(28, 0)
	mark.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	mark.texture = _cursor if on else null
	line.add_child(mark)
	var name_label := _label(size_px, Color.WHITE if on else Color(0.75, 0.8, 0.85))
	name_label.text = label_text
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(name_label)
	if value_text != "":
		var value_label := _label(size_px, Color(0.75, 0.92, 1.0))
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
	if item.has("labels"):
		return String(item["labels"][v])
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
	_clamp_values()
	if input != null and cfg.has_section("input"):
		var saved := {}
		for action in cfg.get_section_keys("input"):
			saved[action] = cfg.get_value("input", action, [])
		input.restore(saved)


## Keeps loaded values inside their item's range (an older or hand-edited file).
func _clamp_values() -> void:
	for tab in _tabs:
		for item in tab["items"]:
			var key: String = String(item["key"])
			if key == "" or not values.has(key):
				continue
			var top: int = int(item["range"]) if item.has("range") else _choice_count(item) - 1
			values[key] = clampi(int(values[key]), 0, top)


func _save_values() -> void:
	var cfg := ConfigFile.new()
	for key in values:
		cfg.set_value("options", key, values[key])
	if input != null:
		var bindings := input.store()
		for action in bindings:
			cfg.set_value("input", action, bindings[action])
	cfg.save(SAVE_PATH)

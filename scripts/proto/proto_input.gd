## Input for the prototype: every control is a Godot InputMap action with keyboard and gamepad
## defaults (docs/ui-ux.md P0-1). The game asks commands(event) which actions an event presses,
## instead of comparing key codes. Gameplay actions can be rebound; bindings are stored with the
## settings. On-screen hints name the key or button of the device the player used last.
##
## Gamepad buttons are named by position (bottom, right, left, top), not by any maker's letters.
class_name ProtoInput
extends Node

signal device_changed(device: String)

## How far a stick or trigger must move to count as a press.
const DEADZONE := 0.5

## [action, UI label key ("" = not listed), keyboard keys, pad buttons, pad axes [[axis, sign]], rebindable]
const ACTIONS := [
	["move_left", "ui.input.move_left", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], [[JOY_AXIS_LEFT_X, -1]], true],
	["move_right", "ui.input.move_right", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], [[JOY_AXIS_LEFT_X, 1]], true],
	["move_up", "ui.input.move_up", [KEY_W, KEY_UP], [JOY_BUTTON_DPAD_UP], [[JOY_AXIS_LEFT_Y, -1]], true],
	["move_down", "ui.input.move_down", [KEY_S, KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], [[JOY_AXIS_LEFT_Y, 1]], true],
	["jump", "ui.input.jump", [KEY_SPACE], [JOY_BUTTON_A], [], true],
	["interact", "ui.input.interact", [KEY_E, KEY_ENTER, KEY_KP_ENTER], [JOY_BUTTON_X], [], true],
	["track_linear", "ui.input.track_linear", [KEY_Z], [JOY_BUTTON_LEFT_SHOULDER], [], true],
	["track_hifi", "ui.input.track_hifi", [KEY_X], [JOY_BUTTON_RIGHT_SHOULDER], [], true],
	["track_mix", "ui.input.track_mix", [KEY_C], [JOY_BUTTON_Y], [], true],
	["rec", "ui.input.rec", [KEY_R], [], [[JOY_AXIS_TRIGGER_RIGHT, 1]], true],
	["ff", "ui.input.ff", [KEY_F], [], [[JOY_AXIS_TRIGGER_LEFT, 1]], true],
	["board", "ui.input.board", [KEY_B], [JOY_BUTTON_BACK], [], true],
	["journal", "ui.input.journal", [KEY_J], [JOY_BUTTON_LEFT_STICK], [], true],
	["log", "ui.input.log", [KEY_L], [JOY_BUTTON_RIGHT_STICK], [], true],
	["pause", "ui.input.pause", [KEY_ESCAPE], [JOY_BUTTON_START], [], false],
	# Fixed, so menus always work whatever the player rebinds.
	["accept", "", [KEY_ENTER, KEY_KP_ENTER, KEY_E], [JOY_BUTTON_A], [], false],
	["cancel", "", [KEY_ESCAPE], [JOY_BUTTON_B], [], false],
	["menu_up", "", [KEY_UP], [JOY_BUTTON_DPAD_UP], [[JOY_AXIS_LEFT_Y, -1]], false],
	["menu_down", "", [KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], [[JOY_AXIS_LEFT_Y, 1]], false],
	["menu_left", "", [KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], [[JOY_AXIS_LEFT_X, -1]], false],
	["menu_right", "", [KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], [[JOY_AXIS_LEFT_X, 1]], false],
	# Tabs of the settings screen (the shoulders are track buttons only while the game runs).
	["tab_prev", "", [KEY_PAGEUP], [JOY_BUTTON_LEFT_SHOULDER], [], false],
	["tab_next", "", [KEY_TAB, KEY_PAGEDOWN], [JOY_BUTTON_RIGHT_SHOULDER], [], false],
	# The workroom's own action (the level's "hub.actions" also keep their letter keys).
	["workroom_action", "", [KEY_D], [JOY_BUTTON_Y], [], false],
	["choose_1", "", [KEY_1], [], [], false],
	["choose_2", "", [KEY_2], [], [], false],
	["choose_3", "", [KEY_3], [], [], false],
	["choose_4", "", [KEY_4], [], [], false],
	# Development shortcuts, keyboard only.
	["debug_scare_mode", "", [KEY_M], [], [], false],
	["debug_photosafe", "", [KEY_P], [], [], false],
]

const PAD_NAMES := {
	JOY_BUTTON_A: "ui.pad.south", JOY_BUTTON_B: "ui.pad.east", JOY_BUTTON_X: "ui.pad.west",
	JOY_BUTTON_Y: "ui.pad.north", JOY_BUTTON_LEFT_SHOULDER: "ui.pad.left_shoulder",
	JOY_BUTTON_RIGHT_SHOULDER: "ui.pad.right_shoulder", JOY_BUTTON_BACK: "ui.pad.select",
	JOY_BUTTON_START: "ui.pad.start", JOY_BUTTON_DPAD_UP: "ui.pad.dpad_up",
	JOY_BUTTON_DPAD_DOWN: "ui.pad.dpad_down", JOY_BUTTON_DPAD_LEFT: "ui.pad.dpad_left",
	JOY_BUTTON_DPAD_RIGHT: "ui.pad.dpad_right", JOY_BUTTON_LEFT_STICK: "ui.pad.left_stick_press",
	JOY_BUTTON_RIGHT_STICK: "ui.pad.right_stick_press",
}
const AXIS_NAMES := {
	JOY_AXIS_TRIGGER_LEFT: "ui.pad.left_trigger", JOY_AXIS_TRIGGER_RIGHT: "ui.pad.right_trigger",
	JOY_AXIS_LEFT_X: "ui.pad.left_stick", JOY_AXIS_LEFT_Y: "ui.pad.left_stick",
	JOY_AXIS_RIGHT_X: "ui.pad.right_stick", JOY_AXIS_RIGHT_Y: "ui.pad.right_stick",
}

## "keyboard" (keys and mouse) or "pad".
var device := "keyboard"
## Pad axis bindings by action: [axis, sign], kept here because a stick returning to the centre
## does not match an action, so presses are detected from the raw axis value.
var _axes: Dictionary = {}
var _held: Dictionary = {}


func _ready() -> void:
	reset_defaults()


## Every action back to its default keys and buttons.
func reset_defaults() -> void:
	_axes.clear()
	for a in ACTIONS:
		var action: String = a[0]
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		InputMap.add_action(action, 0.2 if action.begins_with("move_") else DEADZONE)
		for key in a[2]:
			var e := InputEventKey.new()
			e.keycode = key
			InputMap.action_add_event(action, e)
		for button in a[3]:
			var b := InputEventJoypadButton.new()
			b.button_index = button
			InputMap.action_add_event(action, b)
		for axis in a[4]:
			_add_axis(action, int(axis[0]), int(axis[1]))


## Actions this event presses (once per press: no key repeat, sticks and triggers count when they
## cross the dead zone). Also notes which device the player is using.
func commands(event: InputEvent) -> Array[String]:
	var out: Array[String] = []
	if event is InputEventJoypadMotion:
		var m := event as InputEventJoypadMotion
		for action in _axes:
			var bind: Array = _axes[action]
			if int(bind[0]) != m.axis:
				continue
			var down: bool = m.axis_value * float(bind[1]) >= DEADZONE
			if down and not _held.get(action, false):
				out.append(action)
			_held[action] = down
		if not out.is_empty():
			_set_device("pad")
		return out
	if event is InputEventKey:
		var k := event as InputEventKey
		if not k.pressed or k.echo:
			return out
		_set_device("keyboard")
	elif event is InputEventJoypadButton:
		if not (event as InputEventJoypadButton).pressed:
			return out
		_set_device("pad")
	else:
		if event is InputEventMouseButton or event is InputEventMouseMotion:
			_set_device("keyboard")
		return out
	for a in ACTIONS:
		if event.is_action_pressed(String(a[0])):
			out.append(String(a[0]))
	return out


## The key or button for an action on the current device, for hints ("" if none).
func label(action: String) -> String:
	if not InputMap.has_action(action):
		return ""
	for e in InputMap.action_get_events(action):
		if device == "pad" and e is InputEventJoypadButton:
			return tr(String(PAD_NAMES.get((e as InputEventJoypadButton).button_index, "ui.pad.button")))
		if device != "pad" and e is InputEventKey:
			return OS.get_keycode_string((e as InputEventKey).keycode)
	if device == "pad" and _axes.has(action):
		return tr(String(AXIS_NAMES.get(int(_axes[action][0]), "ui.pad.button")))
	return ""


## The binding of one device, for the controls screen: "keyboard" or "pad".
func binding_name(action: String, which: String) -> String:
	var saved := device
	device = which
	var text := label(action)
	device = saved
	return text if text != "" else tr("ui.input.none")


## Replaces {action} placeholders in a UI string with "[key]" for the current device.
func fill(text: String) -> String:
	if not "{" in text:
		return text
	for a in ACTIONS:
		var token := "{%s}" % a[0]
		if token in text:
			var name := label(String(a[0]))
			text = text.replace(token, "[%s]" % name if name != "" else "")
	return text


## Rebindable actions with their UI labels, in screen order.
func rebindable() -> Array:
	var out: Array = []
	for a in ACTIONS:
		if bool(a[5]):
			out.append({"action": a[0], "label": a[1]})
	return out


## Binds a key (keyboard) or a pad button or axis (gamepad) to an action, replacing that device's
## old binding. If another rebindable action used the same input, the two swap.
func rebind(action: String, event: InputEvent) -> bool:
	var pad := event is InputEventJoypadButton or event is InputEventJoypadMotion
	if not (pad or event is InputEventKey):
		return false
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE:
		return false
	var old := _device_events(action, pad)
	for a in rebindable():
		var other: String = a["action"]
		if other != action and _matches(other, event):
			_clear_device(other, pad)
			for e in old:
				_add_event(other, e)
	_clear_device(action, pad)
	_add_event(action, event)
	return true


## Bindings of the rebindable actions, for the settings file: {action: ["k:65", "b:0", "a:5:1"]}.
func store() -> Dictionary:
	var out := {}
	for a in rebindable():
		var action: String = a["action"]
		var codes: Array = []
		for e in InputMap.action_get_events(action):
			var code := _code(e)
			if code != "":
				codes.append(code)
		var bind: Array = _axes.get(action, [])
		if not bind.is_empty():
			codes.append("a:%d:%d" % [bind[0], bind[1]])
		out[action] = codes
	return out


func restore(saved: Dictionary) -> void:
	for action in saved:
		if not InputMap.has_action(String(action)) or typeof(saved[action]) != TYPE_ARRAY:
			continue
		InputMap.action_erase_events(String(action))
		_axes.erase(action)
		for code in saved[action]:
			var e := _from_code(String(code))
			if e != null:
				_add_event(String(action), e)


func _set_device(which: String) -> void:
	if which != device:
		device = which
		device_changed.emit(which)


func _add_axis(action: String, axis: int, sign: int) -> void:
	var m := InputEventJoypadMotion.new()
	m.axis = axis
	m.axis_value = float(sign)
	InputMap.action_add_event(action, m)
	_axes[action] = [axis, sign]


func _add_event(action: String, event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		var m := event as InputEventJoypadMotion
		_add_axis(action, m.axis, 1 if m.axis_value >= 0.0 else -1)
	elif event is InputEventKey:
		var e := InputEventKey.new()
		e.keycode = (event as InputEventKey).keycode
		InputMap.action_add_event(action, e)
	elif event is InputEventJoypadButton:
		var b := InputEventJoypadButton.new()
		b.button_index = (event as InputEventJoypadButton).button_index
		InputMap.action_add_event(action, b)


func _device_events(action: String, pad: bool) -> Array:
	var out: Array = []
	for e in InputMap.action_get_events(action):
		if pad == (e is InputEventJoypadButton or e is InputEventJoypadMotion):
			out.append(e)
	return out


func _clear_device(action: String, pad: bool) -> void:
	for e in _device_events(action, pad):
		InputMap.action_erase_event(action, e)
	if pad:
		_axes.erase(action)


func _matches(action: String, event: InputEvent) -> bool:
	if event is InputEventJoypadMotion:
		var m := event as InputEventJoypadMotion
		var bind: Array = _axes.get(action, [])
		return not bind.is_empty() and int(bind[0]) == m.axis and signf(m.axis_value) == float(bind[1])
	for e in InputMap.action_get_events(action):
		if e is InputEventKey and event is InputEventKey and (e as InputEventKey).keycode == (event as InputEventKey).keycode:
			return true
		if e is InputEventJoypadButton and event is InputEventJoypadButton \
				and (e as InputEventJoypadButton).button_index == (event as InputEventJoypadButton).button_index:
			return true
	return false


func _code(e: InputEvent) -> String:
	if e is InputEventKey:
		return "k:%d" % (e as InputEventKey).keycode
	if e is InputEventJoypadButton:
		return "b:%d" % (e as InputEventJoypadButton).button_index
	return ""


func _from_code(code: String) -> InputEvent:
	var parts := code.split(":")
	match parts[0]:
		"k":
			var e := InputEventKey.new()
			e.keycode = int(parts[1])
			return e
		"b":
			var b := InputEventJoypadButton.new()
			b.button_index = int(parts[1]) as JoyButton
			return b
		"a":
			if parts.size() == 3:
				var m := InputEventJoypadMotion.new()
				m.axis = int(parts[1]) as JoyAxis
				m.axis_value = float(parts[2])
				return m
	return null

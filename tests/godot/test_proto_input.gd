## Headless tests for scripts/proto/proto_input.gd. Run through tools/run_godot_tests.py.
extends SceneTree

const Input_ := preload("res://scripts/proto/proto_input.gd")

var _checks := 0
var _failures: Array = []
var _test := ""
var _input: Node


func _initialize() -> void:
	var tests := [
		"test_keys_press_actions",
		"test_pad_buttons_and_axes",
		"test_labels_follow_device",
		"test_rebind_swaps_and_saves",
	]
	for test_name in tests:
		_test = test_name
		_input = Input_.new()
		root.add_child(_input)
		# The root is not ready yet during _initialize, so _ready() would run later.
		_input.reset_defaults()
		call(test_name)
		_input.free()
	print("prototype input: %d checks, %d failure(s) in %d tests" % [_checks, _failures.size(), tests.size()])
	for failure in _failures:
		printerr("FAIL ", failure)
	quit(1 if not _failures.is_empty() else 0)


func check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_failures.append("%s: %s" % [_test, what])


func key(code: Key, pressed := true, echo := false) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = pressed
	e.echo = echo
	return e


func pad(button: JoyButton, pressed := true) -> InputEventJoypadButton:
	var e := InputEventJoypadButton.new()
	e.button_index = button
	e.pressed = pressed
	return e


func axis(a: JoyAxis, value: float) -> InputEventJoypadMotion:
	var e := InputEventJoypadMotion.new()
	e.axis = a
	e.axis_value = value
	return e


func test_keys_press_actions() -> void:
	var cmds: Array = _input.commands(key(KEY_E))
	check(cmds.has("accept") and cmds.has("interact"), "E is both accept and interact")
	check(_input.commands(key(KEY_ESCAPE)).has("pause"), "Escape pauses")
	check(_input.commands(key(KEY_ESCAPE)).has("cancel"), "Escape cancels")
	check(_input.commands(key(KEY_Z)) == ["track_linear"], "Z is LINEAR")
	check(_input.commands(key(KEY_E, true, true)).is_empty(), "key repeat is ignored")
	check(_input.commands(key(KEY_E, false)).is_empty(), "key release is ignored")
	check(_input.commands(key(KEY_3)).has("choose_3"), "number keys choose")
	check(_input.device == "keyboard", "device is the keyboard")


func test_pad_buttons_and_axes() -> void:
	var cmds: Array = _input.commands(pad(JOY_BUTTON_A))
	check(cmds.has("jump") and cmds.has("accept"), "bottom button jumps and accepts")
	check(_input.device == "pad", "device switched to the gamepad")
	check(_input.commands(pad(JOY_BUTTON_X)).has("interact"), "left button interacts")
	check(_input.commands(pad(JOY_BUTTON_A, false)).is_empty(), "button release is ignored")
	check(_input.commands(axis(JOY_AXIS_TRIGGER_RIGHT, 0.8)) == ["rec"], "right trigger records once")
	check(_input.commands(axis(JOY_AXIS_TRIGGER_RIGHT, 0.95)).is_empty(), "holding the trigger does not repeat")
	check(_input.commands(axis(JOY_AXIS_TRIGGER_RIGHT, 0.0)).is_empty(), "releasing presses nothing")
	check(_input.commands(axis(JOY_AXIS_TRIGGER_RIGHT, 0.7)) == ["rec"], "pressing again records again")
	check(_input.commands(axis(JOY_AXIS_TRIGGER_RIGHT, 0.3)).is_empty(), "inside the dead zone presses nothing")
	var stick: Array = _input.commands(axis(JOY_AXIS_LEFT_Y, 0.9))
	check(stick.has("menu_down") and stick.has("move_down"), "stick down moves menus and the player")
	check(_input.commands(axis(JOY_AXIS_LEFT_Y, -0.9)).has("menu_up"), "stick up crosses straight to up")


func test_labels_follow_device() -> void:
	_input.commands(key(KEY_A))
	check(_input.label("board") == "B", "keyboard label: B")
	check(_input.fill("Board {board}") == "Board [B]", "fill uses the keyboard key")
	_input.commands(pad(JOY_BUTTON_BACK))
	check(_input.label("board") == "ui.pad.select", "pad label is the position name key (no strings loaded here)")
	check(_input.label("rec") == "ui.pad.right_trigger", "trigger label")
	check(_input.binding_name("board", "keyboard") == "B", "binding_name for the other device")
	check(_input.device == "pad", "binding_name leaves the device as it was")
	check(_input.fill("{nothing} stays") == "{nothing} stays", "unknown tokens stay")


func test_rebind_swaps_and_saves() -> void:
	check(_input.rebind("interact", key(KEY_Q)), "rebind interact to Q")
	check(_input.commands(key(KEY_Q)).has("interact"), "Q interacts")
	check(not _input.commands(key(KEY_E)).has("interact"), "E no longer interacts")
	check(_input.commands(key(KEY_E)).has("accept"), "E still accepts (fixed menu action)")
	check(_input.rebind("jump", key(KEY_Q)), "rebind jump to Q, which interact uses")
	check(_input.commands(key(KEY_Q)) == ["jump"], "Q now only jumps")
	check(_input.commands(key(KEY_SPACE)).has("interact"), "interact took jump's old key (swap)")
	check(not _input.rebind("jump", key(KEY_ESCAPE)), "Escape cannot be bound")
	check(_input.rebind("rec", axis(JOY_AXIS_TRIGGER_LEFT, 1.0)), "bind REC to the left trigger")
	check(_input.commands(axis(JOY_AXIS_TRIGGER_LEFT, 0.9)).has("rec"), "left trigger records")
	check(not _input.commands(axis(JOY_AXIS_TRIGGER_LEFT, 0.0)).has("ff") , "release is quiet")
	var saved: Dictionary = _input.store()
	_input.reset_defaults()
	check(_input.commands(key(KEY_E)).has("interact"), "defaults are back")
	_input.restore(saved)
	check(_input.commands(key(KEY_Q)) == ["jump"], "restored keyboard binding")
	check(_input.commands(axis(JOY_AXIS_TRIGGER_LEFT, 0.9)).has("rec"), "restored axis binding")
	check(_input.rebindable().size() == 12, "twelve rebindable actions")

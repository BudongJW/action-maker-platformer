## Headless tests for scripts/tracks/track_mixer.gd. Run through tools/run_godot_tests.py.
extends SceneTree

const Mixer := preload("res://scripts/tracks/track_mixer.gd")

var _checks := 0
var _failures: Array = []
var _test := ""
var _nodes: Array = []


## Stand-in for StoryRunner: records set_flag() calls.
class FakeStory:
	extends Node
	var flags: Dictionary = {}

	func set_flag(flag_name: String, value: Variant) -> bool:
		flags[flag_name] = value
		return true


func _initialize() -> void:
	var tests := [
		"test_track_flag_and_crossfade",
		"test_segments_and_divergence",
		"test_timeline_events_fire_once_per_pass",
		"test_layers",
		"test_time_scale_and_pause",
	]
	for test_name in tests:
		_test = test_name
		call(test_name)
		for node in _nodes:
			node.free()
		_nodes.clear()
	print("track mixer: %d checks, %d failure(s) in %d tests" % [_checks, _failures.size(), tests.size()])
	for failure in _failures:
		printerr("FAIL ", failure)
	quit(1 if not _failures.is_empty() else 0)


func test_track_flag_and_crossfade() -> void:
	var m := make_mixer()
	var story := FakeStory.new()
	_nodes.append(story)
	m.bind_story(story)
	check_eq(story.flags.get("loop.track_hifi"), false, "LINEAR at start")
	check_eq(story.flags.get("loop.track_mix"), false, "not MIX at start")
	var changes: Array = []
	m.track_changed.connect(func(t): changes.append(t))
	m.set_track(Mixer.Track.HIFI)
	check_eq(story.flags.get("loop.track_hifi"), true, "HIFI sets the flag")
	m.tick(0.125)
	check_near(m.gains().x, 0.5, "crossfade halfway after half the fade time")
	m.tick(0.5)
	check(m.gains().is_equal_approx(Vector2(1, 0)), "HIFI gains after the fade")
	m.set_track(Mixer.Track.MIX)
	m.tick(1.0)
	check_near(m.gains().x, sqrt(0.5), "MIX keeps equal power")
	check_eq(story.flags.get("loop.track_hifi"), false, "MIX is not HIFI for the story")
	check_eq(story.flags.get("loop.track_mix"), true, "MIX sets its own flag")
	m.set_track(Mixer.Track.LINEAR)
	check_eq(story.flags.get("loop.track_mix"), false, "leaving MIX clears it")
	m.set_track(Mixer.Track.MIX)
	check_eq(changes, [Mixer.Track.HIFI, Mixer.Track.MIX, Mixer.Track.LINEAR, Mixer.Track.MIX], "track_changed signals")
	# A new loop clears loop.* flags; staying on the same track must not leave them unset.
	m.set_track(Mixer.Track.HIFI)
	story.flags.clear()
	m.set_track(Mixer.Track.HIFI)
	check_eq(story.flags.get("loop.track_hifi"), null, "set_track to the same track writes nothing")
	m.sync_flags()
	check_eq(story.flags.get("loop.track_hifi"), true, "sync_flags writes the HIFI flag again")
	check_eq(story.flags.get("loop.track_mix"), false, "sync_flags writes the MIX flag again")


func test_segments_and_divergence() -> void:
	var m := make_mixer()
	# Two dubbed segments: 00:58:12-01:03:40 and 01:19:05-01:31:52.
	m.set_segments([[3492, 3820], [4745, 5512]])
	check_near(m.divergence(3000.0), 0.0, "identical far from a segment")
	check_near(m.divergence(3487.0), 0.5, "ramps up 5 s before a segment")
	check_near(m.divergence(3600.0), 1.0, "fully diverged inside")
	check_eq(m.segment_at(5000.0), 1, "segment lookup")
	check_eq(m.segment_at(4000.0), -1, "no segment between")
	var entered: Array = []
	var exited: Array = []
	m.segment_entered.connect(func(i): entered.append(i))
	m.segment_exited.connect(func(i): exited.append(i))
	m.seek(3480.0)
	for i in 30:
		m.tick(1.0)  # 10 tape seconds each
	check_eq(entered, [0], "entered the first segment")
	check_eq(exited, [], "still inside at tape 3780")
	m.tick(5.0)
	check_eq(exited, [0], "left the first segment at tape 3830")


func test_timeline_events_fire_once_per_pass() -> void:
	var m := make_mixer()
	var story := FakeStory.new()
	_nodes.append(story)
	m.bind_story(story)
	var fired: Array = []
	m.timeline_event.connect(func(n): fired.append(n))
	m.add_event(6000.0, "power_cut", "loop.power_cut")
	m.seek(5990.0)
	m.tick(0.5)
	check_eq(fired, [], "not yet")
	m.tick(1.0)
	check_eq(fired, ["power_cut"], "fires when the playhead reaches it")
	check_eq(story.flags.get("loop.power_cut"), true, "event flag written")
	m.tick(10.0)
	check_eq(fired.size(), 1, "fires once per pass")
	m.rewind()
	m.seek(5999.0)
	m.tick(1.0)
	check_eq(fired.size(), 2, "re-armed after a rewind")
	m.rewind()
	m.seek(6100.0)
	m.tick(0.1)
	check_eq(fired.size(), 2, "seeking past an event does not fire it")


func test_layers() -> void:
	var m := make_mixer()
	var root := Node2D.new()
	var roof := Node2D.new()
	roof.add_to_group("track_hifi_only")
	var set_piece := Node2D.new()
	set_piece.add_to_group("track_linear_only")
	root.add_child(roof)
	root.add_child(set_piece)
	_nodes.append(root)
	m.set_track(Mixer.Track.HIFI)
	m.apply_layers(root)
	check(roof.visible and not set_piece.visible, "HIFI shows only HIFI nodes")
	check_eq(roof.process_mode, Node.PROCESS_MODE_INHERIT, "HIFI node active")
	check_eq(set_piece.process_mode, Node.PROCESS_MODE_DISABLED, "LINEAR node disabled in HIFI")
	m.set_track(Mixer.Track.MIX)
	m.apply_layers(root)
	check(roof.visible and set_piece.visible, "MIX shows both")
	check_near(roof.modulate.a, 0.5, "MIX draws track-only nodes translucent")
	check_eq(roof.process_mode, Node.PROCESS_MODE_DISABLED, "nothing track-only collides in MIX")
	m.set_track(Mixer.Track.LINEAR)
	m.apply_layers(root)
	check(set_piece.visible and not roof.visible and is_equal_approx(set_piece.modulate.a, 1.0), "LINEAR restores opacity")


func test_time_scale_and_pause() -> void:
	var m := make_mixer()
	m.tick(1.0)
	check_near(m.tape_time(), 10.0, "two-hour tape in twelve minutes: 10 tape seconds per second")
	m.paused = true
	m.tick(5.0)
	check_near(m.tape_time(), 10.0, "paused clock")


# --- helpers -----------------------------------------------------------------------


func make_mixer() -> Mixer:
	var m: Mixer = Mixer.new()
	m.auto_process = false
	_nodes.append(m)
	return m


func check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append("%s: %s" % [_test, message])


func check_eq(actual: Variant, expected: Variant, message: String) -> void:
	_checks += 1
	if typeof(actual) != typeof(expected) or actual != expected:
		_failures.append("%s: %s: expected %s, got %s" % [_test, message, var_to_str(expected), var_to_str(actual)])


func check_near(actual: Variant, expected: float, message: String, tolerance: float = 0.01) -> void:
	_checks += 1
	if typeof(actual) not in [TYPE_FLOAT, TYPE_INT] or absf(float(actual) - expected) > tolerance:
		_failures.append("%s: %s: expected %.3f, got %s" % [_test, message, expected, var_to_str(actual)])

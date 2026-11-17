## Headless tests for scripts/scare/scare_director.gd. Run through tools/run_godot_tests.py.
extends SceneTree

const Director := preload("res://scripts/scare/scare_director.gd")
const CONFIG_FILE := "user://scare_director_test.json"
const LOG_FILE := "user://scare_director_test_log.csv"

var _checks := 0
var _failures: Array = []
var _test := ""
var _nodes: Array = []


## Stand-in for StoryRunner: the `command` signal and the start()/is_running() methods.
class FakeStory:
	extends Node
	signal command(cmd: String, args: Array)
	var started: Array = []
	var running := false

	func start(dialogue_id: String) -> bool:
		started.append(dialogue_id)
		return true

	func is_running() -> bool:
		return running


## Records signals with the director clock time.
class Log:
	var events: Array = []
	var director

	func attach(d) -> void:
		director = d
		d.scare_scheduled.connect(func(id, delay): events.append(["scheduled", id, d.now(), delay]))
		d.lead_started.connect(func(id, duck): events.append(["lead", id, d.now(), duck]))
		d.quiet_window_started.connect(func(id): events.append(["quiet", id, d.now()]))
		d.prepulse.connect(func(id): events.append(["prepulse", id, d.now()]))
		d.scare_onset.connect(func(id, info): events.append(["onset", id, d.now(), info]))
		d.scare_finished.connect(func(id): events.append(["finished", id, d.now()]))
		d.dialogue_requested.connect(func(id, dlg): events.append(["dialogue", id, d.now(), dlg]))

	func first(kind: String, id: String = "") -> Array:
		for e in events:
			if e[0] == kind and (id == "" or e[1] == id):
				return e
		return []

	func all(kind: String) -> Array:
		return events.filter(func(e): return e[0] == kind)


func _initialize() -> void:
	var tests := [
		"test_delay_bounds_and_constant_hazard",
		"test_stage_timing_and_quiet_window",
		"test_input_trigger_minimum_delay",
		"test_soft_off_and_photosafe_modes",
		"test_repeat_attenuation_and_interval",
		"test_relax_defers_real_scares_except_pairs",
		"test_story_binding_and_after_dialogue",
		"test_config_file_and_log",
	]
	for test_name in tests:
		_test = test_name
		call(test_name)
		for node in _nodes:
			node.free()
		_nodes.clear()
	for path in [CONFIG_FILE, LOG_FILE]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("scare director: %d checks, %d failure(s) in %d tests" % [_checks, _failures.size(), tests.size()])
	for failure in _failures:
		printerr("FAIL ", failure)
	quit(1 if not _failures.is_empty() else 0)


# --- tests -------------------------------------------------------------------------


func test_delay_bounds_and_constant_hazard() -> void:
	var d := make_director({})
	var spec := {"mean": 1.2, "min": 0.6, "max": 4.0}
	var n := 6000
	var samples: Array = []
	var in_bounds := true
	for i in n:
		var x: float = d.sample_delay(spec)
		samples.append(x)
		in_bounds = in_bounds and x >= 0.6 and x <= 4.0
	check(in_bounds, "all samples inside [min, max]")
	# Conditional probability of firing in the next second, given it has not fired yet.
	var h1 := _hazard(samples, 0.6, 1.6)
	var h2 := _hazard(samples, 1.6, 2.6)
	check(absf(h1 - 0.60) < 0.04, "hazard in the first second is about 0.60 (got %.3f)" % h1)
	check(absf(h2 - h1) < 0.12, "hazard stays nearly flat (%.3f then %.3f)" % [h1, h2])
	# A uniform window over the same range would rise from 0.29 to 0.42.
	check(h2 - h1 < 0.13, "flatter than a uniform window")


func test_stage_timing_and_quiet_window() -> void:
	var d := make_director({"a": {"kind": "real", "delay": {"mean": 2.0, "min": 2.0, "max": 2.0},
		"lead_s": 1.5, "duck_db": -20.0, "body_ms": 600, "sustain_s": 4.0, "level_lu": 16,
		"visual": {"flash": true, "area": 0.2, "shake": 0.4}, "cue": "sting_a"}})
	var log := Log.new()
	log.attach(d)
	check(d.trigger("a"), "trigger accepted")
	var quiet_at_1_4 := true
	var quiet_at_1_6 := false
	var duck_mid := 0.0
	for i in 160:
		d.tick(0.05)
		var t: float = d.now()
		if is_equal_approx(t, 1.4):
			quiet_at_1_4 = d.is_quiet()
		if is_equal_approx(t, 1.6):
			quiet_at_1_6 = d.is_quiet()
		if is_equal_approx(t, 1.25):
			duck_mid = d.current_duck_db()
	check_near(log.first("lead", "a")[2], 0.5, "bed duck starts lead_s before the onset")
	check_near(log.first("quiet", "a")[2], 1.5, "quiet window starts 0.5 s before the onset")
	check_near(log.first("onset", "a")[2], 2.0, "onset after the delay")
	check_near(log.first("finished", "a")[2], 6.6, "finished after body and sustain")
	check(not quiet_at_1_4 and quiet_at_1_6, "is_quiet() only inside the window")
	check_near(duck_mid, -10.0, "duck ramps linearly during the lead", 0.6)
	var info: Dictionary = log.first("onset", "a")[3]
	check_eq(info["cue"], "sting_a", "onset carries the subtitle cue")
	check_eq(info["flash"], true, "flash kept in default mode")
	check_near(float(info["level_lu"]), 16.0, "level unchanged in default mode")
	check(not d.is_quiet() and not d.is_busy(), "idle after the scare")


func test_input_trigger_minimum_delay() -> void:
	var d := make_director({"b": {"delay": {"mean": 0.1, "min": 0.0, "max": 0.3}, "body_ms": 200, "sustain_s": 0.0}})
	var log := Log.new()
	log.attach(d)
	d.trigger("b", true)
	for i in 40:
		d.tick(0.05)
	check(log.first("onset", "b")[2] >= 0.6 - 0.001, "input-triggered scare waits at least 0.6 s (PPI window)")


func test_soft_off_and_photosafe_modes() -> void:
	var cfg := {"c": {"delay": {"mean": 1.0, "min": 1.0, "max": 1.0}, "level_lu": 18, "rise_ms": 2,
		"body_ms": 500, "sustain_s": 0.0, "visual": {"flash": true, "area": 0.2, "shake": 0.5}}}
	var soft := make_director(cfg)
	soft.mode = Director.Mode.SOFT
	var log := Log.new()
	log.attach(soft)
	soft.trigger("c")
	for i in 40:
		soft.tick(0.05)
	check_near(log.first("prepulse", "c")[2], 0.91, "soft mode prepulse 90 ms before the onset", 0.051)
	var info: Dictionary = log.first("onset", "c")[3]
	check_near(float(info["level_lu"]), 8.0, "soft mode lowers the stinger by 10 dB")
	check(info["flash"] == false and float(info["shake"]) == 0.0, "soft mode removes flash and shake")

	var off := make_director(cfg)
	off.mode = Director.Mode.OFF
	var log2 := Log.new()
	log2.attach(off)
	off.trigger("c")
	for i in 40:
		off.tick(0.05)
	var info2: Dictionary = log2.first("onset", "c")[3]
	check(float(info2["rise_ms"]) >= 1500.0, "off mode turns the stinger into a slow swell")
	check(log2.first("prepulse").is_empty(), "no prepulse outside soft mode")

	var safe := make_director(cfg)
	safe.photosafe = true
	var log3 := Log.new()
	log3.attach(safe)
	safe.trigger("c")
	for i in 40:
		safe.tick(0.05)
	var info3: Dictionary = log3.first("onset", "c")[3]
	check(info3["flash"] == false and float(info3["area"]) <= 0.1, "photosafe removes flashes and shrinks the area")


func test_repeat_attenuation_and_interval() -> void:
	var d := make_director({"caught": {"kind": "fail", "immediate": true, "level_lu": 14, "repeat_step_db": -4,
		"repeat_floor_lu": 2, "replace_after": 3, "min_repeat_interval_s": 20, "body_ms": 500, "sustain_s": 0.0, "relax_s": 0.0}})
	var log := Log.new()
	log.attach(d)
	var levels: Array = []
	check(d.trigger("caught"), "first catch")
	d.tick(1.0)
	check(not d.trigger("caught"), "second catch within 20 s is ignored")
	d.tick(20.0)
	for k in 4:
		check(d.trigger("caught"), "catch %d accepted after the interval" % (k + 2))
		d.tick(21.0)
	for e in log.all("onset"):
		levels.append(float(e[3]["level_lu"]))
	check_eq(levels, [14.0, 10.0, 6.0, 2.0, 2.0], "-4 dB per repeat down to the floor")
	check_eq(log.all("onset")[2][3]["variant"], "replacement", "third catch switches to the replacement variant")
	check_eq(d.repeat_count("caught"), 5, "repeat count")


func test_relax_defers_real_scares_except_pairs() -> void:
	var fixed := {"mean": 1.0, "min": 1.0, "max": 1.0}
	var d := make_director({
		"bird": {"kind": "false", "delay": fixed, "body_ms": 400, "sustain_s": 0.0, "relax_s": 40.0},
		"speaker": {"kind": "real", "delay": fixed, "body_ms": 900, "sustain_s": 4.0, "allow_during_relax_of": "bird"},
		"other": {"kind": "real", "delay": fixed, "body_ms": 900, "sustain_s": 4.0},
	})
	var log := Log.new()
	log.attach(d)
	d.trigger("bird")
	d.tick(2.0)
	check(d.is_relaxing(), "relax period after a scare")
	d.trigger("other")
	var sched: Array = log.first("scheduled", "other")
	check(float(sched[3]) > 30.0, "an unrelated real scare waits for the relax period to end")
	d.cancel_all()

	var d2 := make_director({
		"bird": {"kind": "false", "delay": fixed, "body_ms": 400, "sustain_s": 0.0, "relax_s": 40.0},
		"speaker": {"kind": "real", "delay": fixed, "body_ms": 900, "sustain_s": 4.0, "allow_during_relax_of": "bird"},
	})
	var log2 := Log.new()
	log2.attach(d2)
	d2.trigger("bird")
	d2.tick(2.0)
	d2.trigger("speaker")
	check_near(float(log2.first("scheduled", "speaker")[3]), 1.0, "the paired real scare may follow the false one")


func test_story_binding_and_after_dialogue() -> void:
	var story := FakeStory.new()
	_nodes.append(story)
	var d := make_director({"door": {"kind": "false", "delay": {"mean": 1.0, "min": 1.0, "max": 1.0},
		"body_ms": 300, "sustain_s": 0.0, "after_dialogue": "door_after"}})
	d.bind_story(story)
	var log := Log.new()
	log.attach(d)
	story.command.emit("emit", ["scare_door"])
	story.command.emit("emit", ["chase_start"])
	story.command.emit("sfx", ["scare_door"])
	for i in 40:
		d.tick(0.05)
	check_eq(log.all("onset").size(), 1, "only `emit scare_<id>` triggers")
	check_eq(log.first("dialogue", "door")[3], "door_after", "after_dialogue requested")
	check_eq(story.started, ["door_after"], "after_dialogue started on the story runner")


func test_config_file_and_log() -> void:
	var f := FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	f.store_string(JSON.stringify({"format": 1, "settings": {"soft_gain_db": -12},
		"scares": {"x": {"kind": "real", "delay": {"mean": 1.0, "min": 1.0, "max": 1.0}, "level_lu": 12, "body_ms": 500, "sustain_s": 0.0}}}))
	f.close()
	var d := make_director({})
	check_eq(d.configure_from_file(CONFIG_FILE), OK, "config file loads")
	check(d.has_scare("x"), "scare from the file")
	check_near(d.soft_gain_db, -12.0, "settings from the file")
	d.log_path = LOG_FILE
	d.trigger("x")
	d.tick(2.0)
	var lines := FileAccess.get_file_as_string(LOG_FILE).strip_edges().split("\n")
	check_eq(lines.size(), 2, "log has a header and one row")
	check(lines[1].contains(",x,real,1,default,"), "log row records the scare")


# --- helpers -----------------------------------------------------------------------


func make_director(scares: Dictionary) -> Director:
	var d: Director = Director.new()
	d.auto_process = false
	d.rng.seed = 12345
	d.configure({"format": 1, "scares": scares})
	_nodes.append(d)
	return d


func _hazard(samples: Array, a: float, b: float) -> float:
	var alive := 0
	var fired := 0
	for x in samples:
		if x >= a:
			alive += 1
			if x < b:
				fired += 1
	return float(fired) / max(1, alive)


func check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append("%s: %s" % [_test, message])


func check_eq(actual: Variant, expected: Variant, message: String) -> void:
	_checks += 1
	if typeof(actual) != typeof(expected) or actual != expected:
		_failures.append("%s: %s: expected %s, got %s" % [_test, message, var_to_str(expected), var_to_str(actual)])


func check_near(actual: Variant, expected: float, message: String, tolerance: float = 0.051) -> void:
	_checks += 1
	if typeof(actual) not in [TYPE_FLOAT, TYPE_INT] or absf(float(actual) - expected) > tolerance:
		_failures.append("%s: %s: expected %.3f, got %s" % [_test, message, expected, var_to_str(actual)])

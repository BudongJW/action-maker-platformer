## Headless tests for scripts/story/. Run through tools/run_godot_tests.py, which builds a
## temporary Godot project containing the runtime, these tests and a compiled story made from
## the examples in docs/script-format.md plus tests/godot/fixtures/runtime.dlg.
extends SceneTree

const Runner := preload("res://scripts/story/story_runner.gd")
const Condition := preload("res://scripts/story/story_condition.gd")
const Flags := preload("res://scripts/story/story_flags.gd")
const Text := preload("res://scripts/story/story_text.gd")

const STORY := "res://assets/original/story/compiled/story.json"
const STRINGS := "res://assets/original/story/compiled"
const META_FILE := "user://story_runtime_test_meta.json"

var _checks := 0
var _failures: Array = []
var _test := ""
var _runners: Array = []


class Recorder:
	var started: Array = []
	var lines: Array = []
	var choices: Array = []
	var commands: Array = []
	var finished: Array = []

	func attach(runner) -> void:
		runner.dialogue_started.connect(func(id): started.append(id))
		runner.line_started.connect(func(id, speaker, expression, attrs, text):
			lines.append({"id": id, "speaker": speaker, "expression": expression, "attrs": attrs, "text": text}))
		runner.choices_presented.connect(func(options): choices.append(options))
		runner.command.connect(func(cmd, args): commands.append([cmd, args]))
		runner.dialogue_finished.connect(func(id): finished.append(id))

	func last_line() -> Dictionary:
		return lines[-1] if not lines.is_empty() else {}

	func last_choices() -> Array:
		return choices[-1] if not choices.is_empty() else []


func _initialize() -> void:
	var tests := [
		"test_conditions",
		"test_flags_tiers_and_save",
		"test_meta_persistence",
		"test_text_helpers",
		"test_pond_ghost_first_loop",
		"test_pond_ghost_second_loop",
		"test_requires_and_forbids",
		"test_deja_vu_across_new_games",
		"test_enable_if_and_jumps",
		"test_commands_and_once_choices",
		"test_locked_choices_are_skipped",
		"test_switch",
		"test_wait_blocks_until_resume",
		"test_wait_resumed_from_handler",
		"test_text_interpolation",
		"test_meta_targets_and_fallbacks",
		"test_pick_priority_and_once",
		"test_loop_reset_command",
		"test_barks",
		"test_docs_and_cues",
		"test_locale_fallback",
		"test_save_restore_through_runner",
	]
	for test_name in tests:
		_test = test_name
		call(test_name)
		for runner in _runners:
			runner.free()
		_runners.clear()
	if FileAccess.file_exists(META_FILE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(META_FILE))
	print("story runtime: %d checks, %d failure(s) in %d tests" % [_checks, _failures.size(), tests.size()])
	for failure in _failures:
		printerr("FAIL ", failure)
	quit(1 if not _failures.is_empty() else 0)


# --- helpers ---------------------------------------------------------------------


func check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append("%s: %s" % [_test, message])


func check_eq(actual: Variant, expected: Variant, message: String) -> void:
	_checks += 1
	if typeof(actual) != typeof(expected) or actual != expected:
		_failures.append("%s: %s: expected %s (%s), got %s (%s)" % [
			_test, message, var_to_str(expected), type_string(typeof(expected)),
			var_to_str(actual), type_string(typeof(actual))])


func make_runner(meta_path: String = "") -> Runner:
	var runner: Runner = Runner.new()
	runner.flags.meta_path = meta_path
	runner.auto_resume_blocking = false
	check_eq(runner.load_story(STORY, STRINGS), OK, "load_story")
	runner.flags.new_game()
	_runners.append(runner)
	return runner


func with_recorder(runner: Runner) -> Recorder:
	var rec := Recorder.new()
	rec.attach(runner)
	return rec


## Advances lines until a new choice list appears or the dialogue ends.
func advance_to_choices(runner: Runner, rec: Recorder) -> void:
	var count := rec.choices.size()
	for i in 50:
		if rec.choices.size() > count or not runner.is_running():
			return
		runner.advance()


func remove_meta_file() -> void:
	if FileAccess.file_exists(META_FILE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(META_FILE))


func ids(lines: Array) -> Array:
	return lines.map(func(line): return line["id"])


# --- unit tests --------------------------------------------------------------------


func test_conditions() -> void:
	var flags := Flags.new()
	flags.meta_path = ""
	flags.set_flag("save.n", 2.0)
	flags.set_flag("save.route", "east")
	check(Condition.evaluate(null, flags), "null condition holds")
	check(Condition.evaluate({"cmp": ">=", "a": {"var": "save.n"}, "b": 2.0}, flags), "2 >= 2")
	check(not Condition.evaluate({"cmp": "<", "a": {"var": "save.n"}, "b": 2}, flags), "not 2 < 2")
	check(Condition.evaluate({"cmp": "==", "a": {"var": "save.unset"}, "b": 0}, flags), "unset == 0")
	check(not Condition.evaluate({"var": "save.unset"}, flags), "unset is false")
	check(Condition.evaluate({"cmp": "==", "a": {"var": "save.route"}, "b": "east"}, flags), "string equality")
	check(Condition.evaluate({"cmp": "!=", "a": {"var": "save.unset"}, "b": "east"}, flags), "unset != string")
	check(not Condition.evaluate({"cmp": "==", "a": {"var": "save.route"}, "b": 1}, flags), "string vs number")
	check(Condition.evaluate({"and": [{"var": "save.n"}, {"not": {"var": "save.unset"}}]}, flags), "and/not")
	check(Condition.evaluate({"or": [{"var": "save.unset"}, true]}, flags), "or with literal")
	check_eq(flags.get_flag("save.n"), 2, "whole floats are stored as ints")


func test_flags_tiers_and_save() -> void:
	var flags := Flags.new()
	flags.meta_path = ""
	flags.new_game()
	check(not flags.set_flag("sys.loop_count", 3), "sys is read-only")
	check(not flags.set_flag("seen.save.x", true), "seen is read-only")
	check(not flags.set_flag("nonsense", 1), "tier required")
	flags.set_flag("loop.a", true)
	flags.set_flag("save.b", 1)
	flags.set_flag("meta.c", true)
	flags.apply_set("save.b", "+=", 2.0)
	flags.apply_set("save.b", "-=", 1)
	check_eq(flags.get_flag("save.b"), 2, "+= and -=")
	flags.mark_seen("blk")
	flags.mark_chosen("line_x")
	check_eq(flags.get_flag("sys.loop_count"), 1, "first loop")
	flags.reset_loop()
	check_eq(flags.get_flag("loop.a"), null, "loop flags cleared")
	check(not flags.is_seen("blk", "loop"), "seen.loop cleared")
	check(flags.is_seen("blk", "save") and flags.is_seen("blk", "meta"), "seen.save/meta kept")
	check_eq(flags.get_flag("sys.loop_count"), 2, "loop count incremented")
	flags.set_flag("loop.d", 5)
	var data := flags.serialize_save()
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(data))
	flags.new_game()
	check_eq(flags.get_flag("save.b"), null, "new game clears save")
	check_eq(flags.get_flag("meta.c"), true, "new game keeps meta")
	check(flags.restore_save(parsed), "restore_save")
	check_eq(flags.get_flag("save.b"), 2, "save restored")
	check_eq(flags.get_flag("loop.d"), 5, "loop state restored")
	check_eq(flags.get_flag("sys.loop_count"), 2, "loop count restored")
	check(flags.was_chosen("line_x"), "once choices restored")
	check(flags.is_seen("blk", "save"), "seen.save restored")
	# sys.gore: set by the game from its settings, read-only for the script.
	check_eq(flags.get_flag("sys.gore"), true, "sys.gore shown by default")
	flags.gore = false
	check_eq(flags.get_flag("sys.gore"), false, "sys.gore follows the game setting")
	check(not flags.set_flag("sys.gore", true), "sys.gore is read-only")


func test_meta_persistence() -> void:
	remove_meta_file()
	var flags := Flags.new()
	flags.meta_path = META_FILE
	flags.new_game()
	flags.set_flag("meta.ending_true", true)
	flags.mark_seen("blk")
	flags.set_meta_os(true)
	var other := Flags.new()
	other.meta_path = META_FILE
	other.load_meta()
	check_eq(other.get_flag("meta.ending_true"), true, "meta flag persisted")
	check(other.is_seen("blk", "meta"), "seen.meta persisted")
	check(not other.is_seen("blk", "save"), "seen.save not in meta file")
	check_eq(other.get_flag("sys.meta_os"), true, "meta consent persisted")
	check_eq(other.get_flag("sys.playthrough"), 1, "playthrough persisted")


func test_text_helpers() -> void:
	var resolve := func(inner: String) -> String: return "<%s>" % inner
	check_eq(Text.interpolate("a {save.x} b {@player_name} \\{c} \\\\ d", resolve),
		"a <save.x> b <@player_name> {c} \\ d", "interpolate")
	var split := Text.split_waits("[b]ab[/b][wait=0.25]cd[wait=1]")
	check_eq(split["text"], "[b]ab[/b]cd", "waits removed")
	check_eq(split["waits"], [{"at": 2, "seconds": 0.25}, {"at": 4, "seconds": 1.0}], "wait positions")
	check_eq(Text.format_value(5.0), "5", "whole float")
	check_eq(Text.format_value(null), "", "null")


# --- spec example (docs/script-format.md, section 13) ----------------------------------


func test_pond_ghost_first_loop() -> void:
	var runner := make_runner()
	var rec := with_recorder(runner)
	runner.set_flag("loop.night", true)
	check(runner.is_available("ch01_pond_ghost"), "available at night")
	check(runner.start("ch01_pond_ghost"), "start")
	check_eq(rec.started, ["ch01_pond_ghost"], "started signal")
	check_eq(rec.last_line()["id"], "ch01_pg_001", "first line")
	check_eq(rec.last_line()["attrs"]["target"], "bubble", "block @style applies to narrator")
	runner.advance()
	var line: Dictionary = rec.last_line()
	check_eq(line["id"], "ch01_pg_002", "second line")
	check_eq(line["expression"], "sad", "expression")
	check_eq(line["attrs"]["display_name"], runner.display_name("hongryeon", "unknown"), "alias name")
	check_eq(line["attrs"]["alias"], "unknown", "alias id for the game (portraits by alias)")
	check_eq(line["attrs"]["portrait"], "res://assets/original/characters/hongryeon/portraits/sad.png", "portrait")
	check_eq(line["text"], runner.get_text("ch01_pg_002"), "text from string table")
	runner.advance()
	check_eq(rec.last_choices().size(), 1, "loop-gated option hidden on the first loop")
	check_eq(rec.last_choices()[0]["line_id"], "ch01_pg_003", "visible option")
	check(runner.choose(0), "choose")
	check_eq(rec.last_line()["id"], "ch01_pg_004", "option body")
	check_eq(rec.last_line()["expression"], "sad", "expression carries over")
	runner.advance()
	check_eq(rec.last_line()["id"], "ch01_pg_007", "rejoins after the choice")
	runner.advance()
	check_eq(rec.finished, ["ch01_pond_ghost"], "finished")
	check(not runner.is_running(), "not running")
	check(runner.flags.is_seen("ch01_pond_ghost", "meta"), "seen recorded at the end")
	check_eq(runner.get_flag("save.told_ghost_loop"), null, "branch not taken")


func test_pond_ghost_second_loop() -> void:
	var runner := make_runner()
	var rec := with_recorder(runner)
	runner.reset_loop()
	runner.set_flag("loop.night", true)
	runner.start("ch01_pond_ghost")
	runner.advance()
	runner.advance()
	var options: Array = rec.last_choices()
	check_eq(options.size(), 2, "both options on the second loop")
	check(String(options[1]["text"]).begins_with("2"), "loop count interpolated into option text")
	runner.choose(1)
	check_eq(runner.get_flag("save.told_ghost_loop"), true, "set in option body")
	check_eq(rec.last_line()["id"], "ch01_pg_006", "option body line")
	check_eq(rec.last_line()["expression"], "surprised", "expression")
	runner.advance()
	check_eq(rec.last_line()["id"], "ch01_pg_008", "jumped to label")
	runner.advance()
	var system_line: Dictionary = rec.last_line()
	check_eq(system_line["id"], "ch01_pg_009", "system line")
	check_eq(system_line["attrs"]["requested_target"], "window_title", "requested meta target")
	check_eq(system_line["attrs"]["target"], "caption", "falls back without consent")
	check_eq(runner.get_flag("meta.knows_name"), true, "meta flag set")
	runner.advance()
	check_eq(rec.finished, ["ch01_pond_ghost"], "finished")


func test_requires_and_forbids() -> void:
	var runner := make_runner()
	check(not runner.is_available("ch01_pond_ghost"), "requires loop.night")
	runner.set_flag("loop.night", true)
	runner.set_flag("loop.pond_sealed", true)
	check(not runner.is_available("ch01_pond_ghost"), "forbids loop.pond_sealed")
	check(not runner.is_available("missing"), "unknown dialogue")
	check_eq(runner.pick(["ch01_pond_ghost"]), "", "pick returns empty when nothing is available")


func test_deja_vu_across_new_games() -> void:
	remove_meta_file()
	var runner := make_runner(META_FILE)
	var rec := with_recorder(runner)
	runner.start("ch01_ibang_greeting")
	check_eq(rec.lines[0]["id"], "ch01_ib_002", "no deja vu line the first time")
	runner.stop()
	runner.new_game()
	runner.start("ch01_ibang_greeting")
	check_eq(rec.last_line()["id"], "ch01_ib_001", "deja vu line after a new game (seen.meta)")
	check_eq(rec.last_line()["expression"], "uneasy", "expression")


func test_enable_if_and_jumps() -> void:
	var runner := make_runner()
	var rec := with_recorder(runner)
	runner.start("ch01_ibang_greeting")
	advance_to_choices(runner, rec)
	var options: Array = rec.last_choices()
	check_eq(options.size(), 2, "loop-gated option hidden")
	check_eq(options[1]["enabled"], false, "option disabled without the seal")
	check(not runner.choose(1), "disabled option refused")
	check(runner.choose(0), "enabled option")
	check_eq(runner.get_flag("save.asked_about_previous"), true, "set in body")
	check_eq(rec.last_line()["id"], "ch01_ib_005", "body line")
	runner.advance()
	check_eq(rec.last_line()["id"], "ch01_ib_008", "bottleneck line")
	runner.advance()
	check(not runner.is_running(), "ended")
	runner.set_flag("save.has_seal", true)
	runner.start("ch01_ibang_greeting")
	check_eq(rec.last_line()["id"], "ch01_ib_001", "deja vu line once the dialogue has been seen")
	advance_to_choices(runner, rec)
	check_eq(rec.last_choices()[1]["enabled"], true, "enabled with the seal")
	runner.choose(1)
	check_eq(rec.last_line()["id"], "ch01_ib_009", "inline jump to label")
	runner.advance()
	check_eq(runner.get_flag("save.ibang_trust"), 1, "+= on an unset flag")


func test_commands_and_once_choices() -> void:
	var runner := make_runner()
	var rec := with_recorder(runner)
	runner.reset_loop()
	runner.start("ch01_ibang_greeting")
	advance_to_choices(runner, rec)
	check_eq(rec.last_choices().size(), 3, "third option visible on loop 2")
	runner.choose(2)
	check_eq(rec.last_line()["attrs"]["emote"], "sweat", "emote attribute")
	runner.advance()
	check_eq(rec.commands, [["sfx", ["drum_far"]]], "sfx command")
	check_eq(runner.get_flag("loop.ibang_suspicious"), true, "loop flag set")
	check(not runner.is_running(), "ended")

	runner.start("rt_once")
	check_eq(rec.last_choices().size(), 2, "both options first")
	runner.choose(0)
	check_eq(rec.last_line()["id"], "rt_o_003", "fall through to after the group")
	runner.advance()
	runner.start("rt_once")
	check_eq(rec.last_choices().size(), 1, "[once] option hidden after being chosen")
	check_eq(rec.last_choices()[0]["line_id"], "rt_o_002", "remaining option")


func test_locked_choices_are_skipped() -> void:
	var runner := make_runner()
	var rec := with_recorder(runner)
	var before := rec.choices.size()
	runner.start("rt_locked")
	check_eq(rec.choices.size(), before, "no choices presented when every option is disabled")
	check_eq(rec.last_line()["id"], "rt_l_002", "skipped to after the group")


func test_switch() -> void:
	var runner := make_runner()
	var rec := with_recorder(runner)
	runner.start("rt_switch")
	runner.advance()
	check_eq(rec.finished, ["rt_switch"], "first dialogue finished")
	check_eq(rec.started, ["rt_switch", "rt_target"], "second dialogue started")
	check_eq(rec.last_line()["id"], "rt_s_002", "second dialogue line")
	check_eq(runner.current_dialogue(), "rt_target", "current dialogue")


func test_wait_blocks_until_resume() -> void:
	var runner := make_runner()
	var rec := with_recorder(runner)
	runner.start("rt_wait")
	runner.advance()
	check_eq(rec.commands, [["wait", [0.5]]], "wait command emitted")
	check_eq(ids(rec.lines), ["rt_w_001"], "paused before the next line")
	check(not runner.advance(), "advance ignored while blocked")
	check(runner.resume(), "resume")
	check_eq(rec.last_line()["id"], "rt_w_002", "continued after resume")


func test_wait_resumed_from_handler() -> void:
	var runner := make_runner()
	var rec := with_recorder(runner)
	runner.command.connect(func(cmd, _args):
		if cmd == "wait":
			runner.resume())
	runner.start("rt_wait")
	runner.advance()
	check_eq(ids(rec.lines), ["rt_w_001", "rt_w_002"], "synchronous resume continues once")
	runner.advance()
	check_eq(rec.finished, ["rt_wait"], "finished exactly once")


func test_text_interpolation() -> void:
	var runner := make_runner()
	var rec := with_recorder(runner)
	runner.player_name = "Tester"
	runner.start("rt_text")
	var line: Dictionary = rec.last_line()
	check_eq(line["text"], "coins 5, name Tester, user Tester, brace {x} end", "placeholders and escapes")
	var before_wait := "coins 5, name Tester, user Tester, brace {x}"
	check_eq(line["attrs"]["waits"], [{"at": before_wait.length(), "seconds": 0.5}], "wait marker position")


func test_meta_targets_and_fallbacks() -> void:
	var runner := make_runner()
	var rec := with_recorder(runner)
	runner.start("rt_meta")
	check_eq(rec.commands[0][0], "shake", "window_shake falls back to shake without consent")
	check_eq(rec.last_line()["attrs"]["target"], "fake_os_dialog", "os_dialog fallback")
	runner.advance()
	check_eq(rec.last_line()["attrs"]["target"], "journal_note", "desktop_file fallback")
	runner.advance()
	runner.flags.set_meta_os(true)
	rec.commands.clear()
	runner.start("rt_meta")
	var expected_shake := "window_shake" if DisplayServer.get_name() != "Wayland" else "shake"
	check_eq(rec.commands[0][0], expected_shake, "window_shake with consent")
	check_eq(rec.last_line()["attrs"]["target"], "os_dialog", "os_dialog with consent on desktop")


func test_pick_priority_and_once() -> void:
	var runner := make_runner()
	var candidates := ["rt_pick_low", "rt_pick_high"]
	check_eq(runner.pick(candidates), "rt_pick_high", "highest priority")
	runner.start("rt_pick_high")
	runner.advance()
	check_eq(runner.pick(candidates), "rt_pick_low", "@once loop hides it for this loop")
	runner.reset_loop()
	check_eq(runner.pick(candidates), "rt_pick_high", "available again next loop")


func test_loop_reset_command() -> void:
	var runner := make_runner()
	var rec := with_recorder(runner)
	runner.set_flag("loop.temp", true)
	runner.start("rt_loop")
	runner.advance()
	check_eq(runner.get_flag("loop.temp"), null, "loop flags cleared by do loop_reset")
	check_eq(rec.last_line()["text"], "loop count is now 2", "loop count updated")


func test_barks() -> void:
	var runner := make_runner()
	runner.rng.seed = 7
	var seen_ids: Array = []
	for i in 4:
		var event: Dictionary = runner.bark("rt_bark_free")
		seen_ids.append(event["id"])
	for i in range(1, seen_ids.size()):
		check(seen_ids[i] != seen_ids[i - 1], "no immediate repeat (%s)" % [seen_ids])
	check_eq(runner.bark("rt_bark_cool")["id"], "rt_b_003", "first bark")
	check_eq(runner.bark("rt_bark_cool"), {}, "cooling down")
	check_eq(runner.bark("ch01_night_watch"), {}, "requires loop.night")
	runner.set_flag("loop.night", true)
	var watch: Dictionary = runner.bark("ch01_night_watch")
	check(String(watch["id"]).begins_with("ch01_bk_"), "spec bark pool")
	check_eq(watch["attrs"]["target"], "bubble", "barks default to bubble")


func test_docs_and_cues() -> void:
	var runner := make_runner()
	check(not runner.is_doc_collected("ch01_prev_diary"), "not collected yet")
	check(runner.collect_doc("ch01_prev_diary"), "collect")
	check(runner.is_doc_collected("ch01_prev_diary"), "collected")
	check_eq(runner.collected_docs("journal"), ["ch01_prev_diary"], "journal category")
	check_eq(runner.collected_docs("other"), [], "other category")
	var doc: Dictionary = runner.get_doc("ch01_prev_diary")
	check_eq(doc["title"], runner.get_text("ch01_dc_001"), "doc title")
	check_eq(doc["paragraphs"].size(), 2, "doc paragraphs")
	var lines: Array = runner.play_cue("ch01_opening")
	check_eq(lines.size(), 2, "cue lines")
	check_eq(lines[1]["attrs"]["at"], 3.5, "cue timing")
	check_eq(lines[1]["attrs"]["target"], "caption", "cues default to caption")


func test_locale_fallback() -> void:
	var runner := make_runner()
	check(runner.set_locale("en"), "switch to en")
	check_eq(runner.get_text("ch01_pg_002"), "You came again. Do you remember which night this is?", "translated line")
	check_eq(runner.display_name("hongryeon"), "Hongryeon", "translated name")
	var fallback: String = runner.get_text("ch01_pg_001")
	check(not fallback.is_empty() and fallback != "ch01_pg_001", "untranslated line falls back to the source text")
	check(not runner.set_locale("xx"), "unknown locale refused")
	check_eq(runner.get_flag("sys.locale"), "en", "sys.locale")


func test_save_restore_through_runner() -> void:
	var runner := make_runner()
	runner.set_flag("save.coins", 9)
	runner.reset_loop()
	var data: Dictionary = runner.serialize_save()
	var other := make_runner()
	check(other.restore_save(data), "restore")
	check_eq(other.get_flag("save.coins"), 9, "flag")
	check_eq(other.get_flag("sys.loop_count"), 2, "loop count")

## Headless tests for scripts/proto/proto_story_algo.gd (roles from affinity, weighted random
## events). Run through tools/run_godot_tests.py.
extends SceneTree

const Algo := preload("res://scripts/proto/proto_story_algo.gd")

var _checks := 0
var _failures: Array = []
var _test := ""


func _initialize() -> void:
	var tests := [
		"test_highest_and_lowest",
		"test_first_match_and_default",
		"test_event_weight",
		"test_draw_is_repeatable",
		"test_draw_without_replacement",
		"test_draw_follows_weights",
	]
	for test_name in tests:
		_test = test_name
		call(test_name)
	print("story algorithm: %d checks, %d failure(s) in %d tests" % [_checks, _failures.size(), tests.size()])
	for failure in _failures:
		printerr("FAIL ", failure)
	quit(1 if not _failures.is_empty() else 0)


func _check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_failures.append("%s: %s" % [_test, what])


func test_highest_and_lowest() -> void:
	var helper := {"pick": "highest", "min": 2, "people": ["sunrye", "mansu", "mijeong"], "default": "none"}
	_check(Algo.pick_role(helper, {"sunrye": 1, "mansu": 3, "mijeong": 2}) == "mansu", "highest value wins")
	_check(Algo.pick_role(helper, {"sunrye": 2, "mansu": 2, "mijeong": 2}) == "sunrye", "a tie goes to the earlier person")
	_check(Algo.pick_role(helper, {"sunrye": 1, "mansu": 1}) == "none", "nobody at the minimum gives the default")
	_check(Algo.pick_role(helper, {}) == "none", "missing values count as 0")
	var villain := {"pick": "lowest", "max": -2, "people": ["jonggil", "mansu"], "default": "dub"}
	_check(Algo.pick_role(villain, {"jonggil": -2, "mansu": -3}) == "mansu", "lowest value wins")
	_check(Algo.pick_role(villain, {"jonggil": -2, "mansu": -2}) == "jonggil", "a tie goes to the earlier person")
	_check(Algo.pick_role(villain, {"jonggil": -1, "mansu": 3}) == "dub", "nobody at the maximum gives the default")
	_check(Algo.pick_role({"people": ["a"]}, {"a": -5}) == "a", "highest is the default mode, without bounds")


func test_first_match_and_default() -> void:
	var daesin := {"pick": "first", "people": [{"id": "gyeongho", "min": 2}, {"id": "mijeong", "min": 3}], "default": "seojin"}
	_check(Algo.pick_role(daesin, {"gyeongho": 2, "mijeong": 3}) == "gyeongho", "the first match wins over a later one")
	_check(Algo.pick_role(daesin, {"gyeongho": 1, "mijeong": 3}) == "mijeong", "a later person when the first misses")
	_check(Algo.pick_role(daesin, {"gyeongho": 1, "mijeong": 2}) == "seojin", "the default when nobody matches")
	_check(Algo.pick_role({"pick": "first", "people": []}, {}) == "none", "no default gives none")
	var bounded := {"pick": "first", "max": 0, "people": [{"id": "a"}, {"id": "b", "max": 5}]}
	_check(Algo.pick_role(bounded, {"a": 1, "b": 4}) == "b", "a person's own bound wins over the role's")


func test_event_weight() -> void:
	var values := {"save.aff_mansu": 2.0, "save.aff_sunrye": -3.0, "!save.role_villain=dub": 1.0}
	var value_of := func(key: String) -> float: return float(values.get(key, 0.0))
	_check(is_equal_approx(Algo.event_weight({}, value_of), 1.0), "the base weight is 1")
	_check(is_equal_approx(Algo.event_weight({"weight": 0.5, "weights": {"save.aff_mansu": 1}}, value_of), 2.5), "a factor adds its flag's value")
	_check(is_equal_approx(Algo.event_weight({"weights": {"save.aff_mansu": -0.5, "save.aff_sunrye": -0.5}}, value_of), 1.5), "factors add up")
	_check(is_equal_approx(Algo.event_weight({"weight": 0, "weights": {"!save.role_villain=dub": 2}}, value_of), 2.0), "a condition counts as 1")


func test_draw_is_repeatable() -> void:
	var events := [{"id": "a"}, {"id": "b"}, {"id": "c"}, {"id": "d"}, {"id": "e"}]
	var none := func(_key: String) -> float: return 0.0
	var seed_value: int = Algo.seed_for(7, 3, "tape")
	var first: Array = Algo.draw(events, 2, seed_value, none)
	_check(first == Algo.draw(events, 2, seed_value, none), "the same seed draws the same events")
	_check(Algo.seed_for(7, 3, "tape") != Algo.seed_for(7, 4, "tape"), "the play number changes the seed")
	_check(Algo.seed_for(7, 3, "tape") != Algo.seed_for(7, 3, "hub"), "the pool name changes the seed")
	var differs := false
	for play in range(1, 12):
		if Algo.draw(events, 2, Algo.seed_for(7, play, "tape"), none) != first:
			differs = true
	_check(differs, "other plays draw other events")


func test_draw_without_replacement() -> void:
	var none := func(_key: String) -> float: return 0.0
	var events := [{"id": "a"}, {"id": "b"}, {"id": "zero", "weight": 0}, {"id": "neg", "weight": -1}, {"weight": 3}]
	for s in range(20):
		var picked: Array = Algo.draw(events, 5, Algo.seed_for(s, 1, "p"), none)
		_check(picked.size() == 2 and "a" in picked and "b" in picked, "only events weighing more than 0 (and with an id) are drawn, each once: %s" % [picked])
	_check(Algo.draw(events, 0, 1, none).is_empty(), "drawing 0 gives nothing")
	var grouped := [{"id": "coffee", "group": "jonggil"}, {"id": "monitor", "group": "jonggil"}, {"id": "salt"}]
	for s in range(20):
		var picked: Array = Algo.draw(grouped, 3, Algo.seed_for(s, 1, "p"), none)
		_check(picked.size() == 2 and "salt" in picked and ("coffee" in picked) != ("monitor" in picked), "one event per group: %s" % [picked])
	_check(Algo.draw([], 3, 1, none).is_empty(), "an empty pool gives nothing")


func test_draw_follows_weights() -> void:
	var values := {"save.aff_mansu": 3.0}
	var value_of := func(key: String) -> float: return float(values.get(key, 0.0))
	var events := [{"id": "light", "weight": 1, "weights": {"save.aff_mansu": 1}}, {"id": "blind", "weight": 1, "weights": {"save.aff_mansu": -1}}, {"id": "other"}]
	var count := {"light": 0, "blind": 0, "other": 0}
	for s in range(400):
		var picked: Array = Algo.draw(events, 1, Algo.seed_for(s, 1, "tape"), value_of)
		count[picked[0]] += 1
	_check(count["blind"] == 0, "an event that weighs 0 here is never drawn")
	_check(count["light"] > count["other"] * 2, "a heavier event is drawn more often: %s" % [count])

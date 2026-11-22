## The story algorithm of the prototype (the level's "story_algorithm" block, prototype/README.md):
## roles picked from affinity values, and weighted random events drawn per play. Pure functions, so
## tests/godot/test_story_algo.gd can check them without a game.
class_name ProtoStoryAlgo
extends RefCounted


## Picks a role from the people's values (person id -> number; a missing value counts as 0).
## `role`: {"pick": "highest" | "lowest" | "first", "people": [id or {"id", "min", "max"}],
## "min", "max", "default"}. "min"/"max" bound who may take the role (a person's own bounds win over
## the role's). "highest" and "lowest" take the extreme value, an earlier person on a tie; "first"
## takes the first person within bounds. Nobody within bounds gives "default" ("none" if unset).
static func pick_role(role: Dictionary, values: Dictionary) -> String:
	var mode := String(role.get("pick", "highest"))
	var best := ""
	var best_value := 0.0
	for entry: Variant in role.get("people", []):
		var person: Dictionary = entry if typeof(entry) == TYPE_DICTIONARY else {"id": entry}
		var id := String(person.get("id", ""))
		if id == "":
			continue
		var v := float(values.get(id, 0.0))
		var lo: Variant = person.get("min", role.get("min"))
		var hi: Variant = person.get("max", role.get("max"))
		if lo != null and v < float(lo):
			continue
		if hi != null and v > float(hi):
			continue
		if mode == "first":
			return id
		if best == "" or (mode == "lowest" and v < best_value) or (mode != "lowest" and v > best_value):
			best = id
			best_value = v
	return best if best != "" else String(role.get("default", "none"))


## An event's weight: "weight" (default 1) plus, for each "weights" key, its factor times
## `value_of.call(key)` (the game gives a flag's number, true as 1, a met condition as 1).
static func event_weight(event: Dictionary, value_of: Callable) -> float:
	var w := float(event.get("weight", 1.0))
	var factors: Dictionary = event.get("weights", {})
	for key: String in factors:
		w += float(factors[key]) * float(value_of.call(key))
	return w


## The seed of one draw: the same game seed, play number and pool always draw the same events, so
## loading a save cannot draw again.
static func seed_for(base: int, play: int, pool: String) -> int:
	return hash("%d:%d:%s" % [base, play, pool])


## Draws up to `count` events without putting them back; an event weighing 0 or less is never drawn,
## and once an event with a "group" is drawn the others of that group are not (for example two
## events that contradict each other). Returns their ids in the order drawn.
static func draw(events: Array, count: int, seed_value: int, value_of: Callable) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var bag: Array = []
	for event: Dictionary in events:
		var w := event_weight(event, value_of)
		if w > 0.0 and String(event.get("id", "")) != "":
			bag.append([String(event["id"]), w, String(event.get("group", ""))])
	var picked: Array = []
	while picked.size() < count and not bag.is_empty():
		var total := 0.0
		for item: Array in bag:
			total += float(item[1])
		var roll := rng.randf() * total
		var at := bag.size() - 1
		for i in bag.size():
			roll -= float(bag[i][1])
			if roll < 0.0:
				at = i
				break
		picked.append(bag[at][0])
		var group: String = bag[at][2]
		bag.remove_at(at)
		if group != "":
			bag = bag.filter(func(item: Array) -> bool: return item[2] != group)
	return picked

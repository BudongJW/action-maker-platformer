## Flag store for the story runtime.
##
## Tiers (docs/script-format.md, section 6.2):
##   loop.*   cleared by reset_loop()
##   save.*   stored in the save file (serialize_save / restore_save)
##   meta.*   survives new games and save deletion; written to meta_path on every change
##   seen.<loop|save|meta>.<block id>   set by mark_seen()
##   sys.*    read-only runtime values: loop_count, playthrough, meta_os, locale, gore
class_name StoryFlags
extends RefCounted

signal flag_changed(flag_name: String, value: Variant)

const TIERS := ["loop", "save", "meta"]
const SAVE_FORMAT := 1
const META_FORMAT := 1

## File for meta.* values, seen.meta.* records, the playthrough count and meta consent.
## Set to an empty string to disable persistence (for tests).
var meta_path: String = "user://meta.dat"
## Current display locale, readable as sys.locale.
var locale: String = ""
## Whether the player lets graphic (gore) descriptions and pictures show, readable as sys.gore.
## The game sets it from its settings; false means the script's veiled version is used.
var gore: bool = true

var _values: Dictionary = {}
var _chosen: Dictionary = {}
var _loop_count: int = 1
var _playthrough: int = 0
var _meta_os: bool = false


# --- Reading and writing -----------------------------------------------------


## Returns the value of a flag, or null if it was never set.
func get_flag(flag_name: String) -> Variant:
	if flag_name.begins_with("sys."):
		match flag_name:
			"sys.loop_count":
				return _loop_count
			"sys.playthrough":
				return _playthrough
			"sys.meta_os":
				return _meta_os
			"sys.locale":
				return locale
			"sys.gore":
				return gore
		push_warning("StoryFlags: unknown runtime flag '%s'" % flag_name)
		return null
	return _values.get(flag_name)


## Sets a loop.*, save.* or meta.* flag. Returns false for read-only or invalid names.
func set_flag(flag_name: String, value: Variant) -> bool:
	var tier := writable_tier(flag_name)
	if tier.is_empty():
		push_error("StoryFlags: '%s' is not writable (use loop.*, save.* or meta.*)" % flag_name)
		return false
	value = _normalize(value)
	_values[flag_name] = value
	flag_changed.emit(flag_name, value)
	if tier == "meta":
		save_meta()
	return true


## Applies a compiled `set` operation: mode is "=", "+=" or "-=".
func apply_set(flag_name: String, mode: String, value: Variant) -> bool:
	match mode:
		"=":
			return set_flag(flag_name, value)
		"+=", "-=":
			var current: Variant = get_flag(flag_name)
			var base := 0.0
			if typeof(current) == TYPE_INT or typeof(current) == TYPE_FLOAT:
				base = float(current)
			var delta := float(value)
			return set_flag(flag_name, base + delta if mode == "+=" else base - delta)
	push_error("StoryFlags: unknown set mode '%s'" % mode)
	return false


## Returns the tier of a writable flag name ("loop", "save" or "meta"), or "".
static func writable_tier(flag_name: String) -> String:
	var parts := flag_name.split(".")
	if parts.size() >= 2 and parts[0] in TIERS and not parts[1].is_empty():
		return parts[0]
	return ""


# --- Seen and chosen records -------------------------------------------------


## Records that a dialogue or document was seen, in all three tiers.
func mark_seen(block_id: String) -> void:
	for tier in TIERS:
		_values["seen.%s.%s" % [tier, block_id]] = true
	save_meta()


func is_seen(block_id: String, tier: String = "save") -> bool:
	return _values.get("seen.%s.%s" % [tier, block_id], false) == true


## Records a [once] choice (save tier).
func mark_chosen(line_id: String) -> void:
	_chosen[line_id] = true


func was_chosen(line_id: String) -> bool:
	return _chosen.has(line_id)


# --- Loops, games and consent ------------------------------------------------


## Starts a new game: clears loop and save state, keeps meta, counts a playthrough.
func new_game() -> void:
	_erase_prefixes(["loop.", "save.", "seen.loop.", "seen.save."])
	_chosen.clear()
	_loop_count = 1
	_playthrough += 1
	save_meta()


## Ends the current loop: clears loop.* and seen.loop.*, increments sys.loop_count.
func reset_loop() -> void:
	_erase_prefixes(["loop.", "seen.loop."])
	_loop_count += 1


## Records the player's consent to effects that touch the real OS (sys.meta_os).
func set_meta_os(enabled: bool) -> void:
	_meta_os = enabled
	save_meta()


# --- Save files ----------------------------------------------------------------


## Returns the save-file state: loop.*, save.*, seen.loop.*, seen.save.*, [once] choices and loop count.
func serialize_save() -> Dictionary:
	var values := {}
	for key in _values:
		if _has_prefix(key, ["loop.", "save.", "seen.loop.", "seen.save."]):
			values[key] = _values[key]
	return {
		"format": SAVE_FORMAT,
		"loop_count": _loop_count,
		"values": values,
		"chosen": _chosen.keys(),
	}


## Replaces the save-file state with data from serialize_save(). Meta state is untouched.
func restore_save(data: Dictionary) -> bool:
	if int(data.get("format", 0)) != SAVE_FORMAT:
		push_error("StoryFlags: unsupported save format %s" % [data.get("format")])
		return false
	_erase_prefixes(["loop.", "save.", "seen.loop.", "seen.save."])
	var values: Dictionary = data.get("values", {})
	for key in values:
		if _has_prefix(key, ["loop.", "save.", "seen.loop.", "seen.save."]):
			_values[key] = _normalize(values[key])
	_loop_count = int(data.get("loop_count", 1))
	_chosen.clear()
	for line_id in data.get("chosen", []):
		_chosen[String(line_id)] = true
	return true


# --- Meta file -------------------------------------------------------------------


## Loads meta state from meta_path, if it exists.
func load_meta() -> void:
	if meta_path.is_empty() or not FileAccess.file_exists(meta_path):
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(meta_path))
	if typeof(data) != TYPE_DICTIONARY or int(data.get("format", 0)) != META_FORMAT:
		push_warning("StoryFlags: ignoring unreadable meta file %s" % meta_path)
		return
	_erase_prefixes(["meta.", "seen.meta."])
	var values: Dictionary = data.get("values", {})
	for key in values:
		if _has_prefix(key, ["meta.", "seen.meta."]):
			_values[key] = _normalize(values[key])
	_playthrough = int(data.get("playthrough", 0))
	_meta_os = bool(data.get("meta_os", false))


## Writes meta state to meta_path. Called automatically whenever meta state changes.
func save_meta() -> void:
	if meta_path.is_empty():
		return
	var values := {}
	for key in _values:
		if _has_prefix(key, ["meta.", "seen.meta."]):
			values[key] = _values[key]
	var file := FileAccess.open(meta_path, FileAccess.WRITE)
	if file == null:
		push_error("StoryFlags: cannot write %s (%s)" % [meta_path, error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify({
		"format": META_FORMAT,
		"playthrough": _playthrough,
		"meta_os": _meta_os,
		"values": values,
	}))


# --- Helpers -------------------------------------------------------------------


func _erase_prefixes(prefixes: Array) -> void:
	for key in _values.keys():
		if _has_prefix(key, prefixes):
			_values.erase(key)


static func _has_prefix(key: String, prefixes: Array) -> bool:
	for prefix in prefixes:
		if key.begins_with(prefix):
			return true
	return false


## JSON numbers arrive as floats; keep whole numbers as ints so they print as "3", not "3.0".
static func _normalize(value: Variant) -> Variant:
	if typeof(value) == TYPE_FLOAT and is_finite(value) and value == floorf(value) and absf(value) < 1.0e15:
		return int(value)
	return value

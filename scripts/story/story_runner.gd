## Runs compiled story data: dialogues, barks, documents and subtitle cues.
##
## Loads assets/original/story/compiled/story.json and strings.<locale>.json produced by
## tools/storyc.py. This script contains no dialogue text; every displayed string comes from
## the compiled string tables. Contract: docs/script-format.md, section 11.
##
## Typical use (for example as an autoload):
##     runner.load_story("res://assets/original/story/compiled/story.json",
##                       "res://assets/original/story/compiled")
##     runner.line_started.connect(_on_line)        # show the line, then call runner.advance()
##     runner.choices_presented.connect(_on_choices)  # show options, then call runner.choose(i)
##     runner.start(runner.pick(["intro_again", "intro"]))
class_name StoryRunner
extends Node

## A dialogue started. Lock player input until dialogue_finished.
signal dialogue_started(dialogue_id: String)
## Show a line, then call advance(). attrs: dialogue_id, display_name, portrait, color, blip,
## target, requested_target, emote, voice, voice_path, side, waits.
signal line_started(line_id: String, speaker: String, expression: String, attrs: Dictionary, text: String)
## Show options ({line_id, text, enabled}), then call choose(index).
signal choices_presented(choices: Array)
## A `do` command for the game to perform (sfx, music, shake, fade, emit, wait, loop_reset, window_shake).
## For wait and fade the dialogue pauses until resume() or, in the scene tree, until the duration passes.
signal command(cmd: String, args: Array)
signal dialogue_finished(dialogue_id: String)
## A bark line from bark(). attrs also has pool_id and speaker_node.
signal bark_started(pool_id: String, line_id: String, speaker: String, expression: String, attrs: Dictionary, text: String)
signal doc_collected(doc_id: String)
## Subtitle lines from play_cue(); each has the line fields plus attrs.at and attrs.dur (seconds).
signal cue_started(cue_id: String, lines: Array)

const FORMAT := 1
const META_TARGETS := ["os_dialog", "window_title", "desktop_file"]
## In-game replacements for meta targets when the player has not consented or the platform cannot do it.
const META_FALLBACKS := {
	"os_dialog": "fake_os_dialog",
	"window_title": "caption",
	"desktop_file": "journal_note",
}
## Commands that pause the dialogue, with the index of their duration argument.
const BLOCKING_COMMANDS := {"wait": 0, "fade": 1}
const MAX_STEPS := 10000

const _Flags := preload("story_flags.gd")
const _Condition := preload("story_condition.gd")
const _Text := preload("story_text.gd")

enum State { IDLE, LINE, CHOICE, BLOCKED }

## Flag store (loop / save / meta tiers). Call flags.new_game() when starting a new game.
var flags := _Flags.new()
## Value for the {@player_name} token, and the fallback for {@os_user}.
var player_name: String = ""
## Resume blocking commands on a timer when the runner is in the scene tree.
var auto_resume_blocking: bool = true
## Random source for barks; seed it for reproducible tests.
var rng := RandomNumberGenerator.new()

var _story: Dictionary = {}
var _strings: Dictionary = {}
var _strings_dir: String = ""
var _source_locale: String = ""
var _locale: String = ""
var _state: State = State.IDLE
var _dialogue_id: String = ""
var _dialogue: Dictionary = {}
var _code: Array = []
var _pc: int = 0
var _last_expression: Dictionary = {}
var _pending_choices: Array = []
var _block_token: int = 0
var _run_id: int = 0
var _bark_memory: Dictionary = {}


# --- Loading and text ------------------------------------------------------------


## Loads story.json and the source-locale string table. Also loads the meta file.
func load_story(story_json_path: String, strings_dir: String) -> Error:
	var data: Variant = _read_json(story_json_path)
	if typeof(data) != TYPE_DICTIONARY:
		return ERR_PARSE_ERROR
	if int(data.get("format", 0)) != FORMAT:
		push_error("StoryRunner: unsupported story format %s in %s" % [data.get("format"), story_json_path])
		return ERR_INVALID_DATA
	stop()
	_story = data
	_strings.clear()
	_strings_dir = strings_dir
	_source_locale = String(data.get("source_locale", ""))
	if not _load_strings(_source_locale):
		return ERR_FILE_NOT_FOUND
	if _locale.is_empty() or not _locale in locales():
		_locale = _source_locale
	if _locale != _source_locale and not _load_strings(_locale):
		_locale = _source_locale
	flags.locale = _locale
	flags.load_meta()
	return OK


func locales() -> Array:
	return _story.get("locales", [_source_locale])


## Switches the display locale. Lines without an up-to-date translation fall back to the source locale.
func set_locale(locale: String) -> bool:
	if not locale in locales():
		push_error("StoryRunner: locale '%s' is not in story.json" % locale)
		return false
	if not _strings.has(locale) and not _load_strings(locale):
		return false
	_locale = locale
	flags.locale = locale
	return true


func get_locale() -> String:
	return _locale


## Raw text for a line ID in the current locale (falling back to the source locale).
func get_text(line_id: String) -> String:
	var text: Variant = _lookup(line_id)
	if text == null:
		push_warning("StoryRunner: no text for '%s'" % line_id)
		return line_id
	return text


## Display name of a speaker, or of one of its aliases. Empty for narrator and system.
func display_name(speaker: String, alias: String = "") -> String:
	var key := "name.%s" % speaker if alias.is_empty() else "name.%s.%s" % [speaker, alias]
	var text: Variant = _lookup(key)
	return "" if text == null else text


## Text for a line ID with placeholders filled in and [wait=] markers removed.
func format_line(line_id: String) -> String:
	return _Text.split_waits(_interpolate(get_text(line_id)))["text"]


# --- Dialogues -----------------------------------------------------------------------


func has_dialogue(dialogue_id: String) -> bool:
	return _dialogues().has(dialogue_id)


## True if the dialogue exists, its @requires/@forbids hold and its @once tier has not seen it.
func is_available(dialogue_id: String) -> bool:
	var d: Variant = _dialogues().get(dialogue_id)
	if d == null:
		return false
	var once: Variant = d.get("once")
	if once != null and flags.is_seen(dialogue_id, String(once)):
		return false
	return _Condition.evaluate(d.get("requires"), flags)


## Returns the available dialogue with the highest @priority (ties: earliest in the list), or "".
func pick(dialogue_ids: Array) -> String:
	var best := ""
	var best_priority := 0
	for id in dialogue_ids:
		if not is_available(String(id)):
			continue
		var priority := int(_dialogues()[id].get("priority", 0))
		if best.is_empty() or priority > best_priority:
			best = String(id)
			best_priority = priority
	return best


## Starts a dialogue without checking availability. Ends any dialogue already running.
func start(dialogue_id: String) -> bool:
	var d: Variant = _dialogues().get(dialogue_id)
	if d == null:
		push_error("StoryRunner: unknown dialogue '%s'" % dialogue_id)
		return false
	stop()
	_dialogue_id = dialogue_id
	_dialogue = d
	_code = d.get("code", [])
	_pc = 0
	_last_expression.clear()
	dialogue_started.emit(dialogue_id)
	_run()
	return true


## Moves past the line being shown.
func advance() -> bool:
	if _state != State.LINE:
		return false
	_state = State.IDLE
	_run()
	return true


## Picks an option by its index in the last choices_presented list. Disabled options are refused.
func choose(index: int) -> bool:
	if _state != State.CHOICE or index < 0 or index >= _pending_choices.size():
		return false
	var choice: Dictionary = _pending_choices[index]
	if not choice["enabled"]:
		return false
	if choice["once"]:
		flags.mark_chosen(choice["id"])
	_pending_choices.clear()
	_pc = choice["pc"]
	_state = State.IDLE
	_run()
	return true


## Continues after a blocking command (wait, fade).
func resume() -> bool:
	if _state != State.BLOCKED:
		return false
	_state = State.IDLE
	_run()
	return true


## Ends the running dialogue, if any. It counts as seen.
func stop() -> void:
	if _dialogue_id.is_empty():
		return
	var id := _dialogue_id
	flags.mark_seen(id)
	_dialogue_id = ""
	_dialogue = {}
	_code = []
	_pc = 0
	_state = State.IDLE
	_pending_choices.clear()
	_block_token += 1
	_run_id += 1
	dialogue_finished.emit(id)


func is_running() -> bool:
	return not _dialogue_id.is_empty()


func current_dialogue() -> String:
	return _dialogue_id


## Executes ops until the dialogue waits for the game (line, choice, blocking command) or ends.
## Signal handlers may call advance/choose/resume/start/stop re-entrantly; when that starts a
## newer run, this one returns without touching state.
func _run() -> void:
	_run_id += 1
	var my_run := _run_id
	var steps := 0
	while not _dialogue_id.is_empty() and my_run == _run_id:
		steps += 1
		if steps > MAX_STEPS:
			push_error("StoryRunner: '%s' ran %d steps without waiting; stopping" % [_dialogue_id, MAX_STEPS])
			stop()
			return
		if _pc < 0 or _pc >= _code.size():
			stop()
			return
		var op: Dictionary = _code[_pc]
		match String(op.get("op", "")):
			"line":
				_pc += 1
				_state = State.LINE
				var event := _line_event(op, _dialogue.get("style"), "", true)
				event["attrs"]["dialogue_id"] = _dialogue_id
				line_started.emit(event["id"], event["speaker"], event["expression"], event["attrs"], event["text"])
				return
			"choice":
				if _present_choices(op):
					return
				_pc = int(op["skip_pc"])
			"branch":
				_pc = _pc + 1 if _Condition.evaluate(op.get("if"), flags) else int(op["else_pc"])
			"goto":
				_pc = int(op["pc"])
			"set":
				flags.apply_set(String(op["var"]), String(op["mode"]), op["value"])
				_pc += 1
			"do":
				_pc += 1
				if _run_command(String(op["cmd"]), op.get("args", [])):
					return
			"switch":
				start(String(op["dialogue"]))
				return
			"end":
				stop()
				return
			_:
				push_error("StoryRunner: unknown op %s in '%s'" % [op, _dialogue_id])
				stop()
				return


func _present_choices(op: Dictionary) -> bool:
	var pending: Array = []
	var shown: Array = []
	var any_enabled := false
	for option in op.get("options", []):
		if option.has("if") and not _Condition.evaluate(option["if"], flags):
			continue
		var id := String(option["id"])
		var once := bool(option.get("once", false))
		if once and flags.was_chosen(id):
			continue
		var enabled := true
		if option.has("enable_if"):
			enabled = _Condition.evaluate(option["enable_if"], flags)
		any_enabled = any_enabled or enabled
		pending.append({"id": id, "pc": int(option["pc"]), "enabled": enabled, "once": once})
		shown.append({"line_id": id, "text": format_line(id), "enabled": enabled})
	if not any_enabled:
		return false
	_pending_choices = pending
	_state = State.CHOICE
	choices_presented.emit(shown)
	return true


## Emits a command. Returns true if the dialogue must pause (blocking command).
func _run_command(cmd: String, args: Array) -> bool:
	var emitted := cmd
	if cmd == "loop_reset":
		flags.reset_loop()
	elif cmd == "window_shake" and not meta_allowed("window_shake"):
		emitted = "shake"
	if not BLOCKING_COMMANDS.has(cmd):
		command.emit(emitted, args)
		return false
	_state = State.BLOCKED
	_block_token += 1
	var token := _block_token
	command.emit(emitted, args)
	# A handler may already have called resume(); only schedule the timer if still blocked here.
	if token == _block_token and _state == State.BLOCKED and auto_resume_blocking and is_inside_tree():
		var index: int = BLOCKING_COMMANDS[cmd]
		var seconds := float(args[index]) if args.size() > index else 0.0
		_resume_after(seconds, token)
	return true


func _resume_after(seconds: float, token: int) -> void:
	await get_tree().create_timer(seconds).timeout
	if token == _block_token and _state == State.BLOCKED:
		resume()


# --- Barks, documents, cues ----------------------------------------------------------


## Picks and emits a bark line from a pool. Returns the line event, or {} if the pool's
## conditions fail, it is cooling down, or it has no lines. The previous line is not repeated.
func bark(pool_id: String, speaker_node: Node = null) -> Dictionary:
	var pool: Variant = _story.get("barks", {}).get(pool_id)
	if pool == null:
		push_error("StoryRunner: unknown bark pool '%s'" % pool_id)
		return {}
	if not _Condition.evaluate(pool.get("requires"), flags):
		return {}
	var now := Time.get_ticks_msec()
	var memory: Dictionary = _bark_memory.get(pool_id, {})
	var cooldown: Variant = pool.get("cooldown")
	if cooldown != null and memory.has("time") and now - int(memory["time"]) < int(float(cooldown) * 1000.0):
		return {}
	var lines: Array = pool.get("lines", [])
	var candidates: Array = []
	for line in lines:
		if lines.size() > 1 and line["id"] == memory.get("line"):
			continue
		candidates.append(line)
	if candidates.is_empty():
		return {}
	var total := 0.0
	for line in candidates:
		total += float(line.get("w", 1))
	var roll := rng.randf() * total
	var chosen: Dictionary = candidates[-1]
	for line in candidates:
		roll -= float(line.get("w", 1))
		if roll < 0.0:
			chosen = line
			break
	_bark_memory[pool_id] = {"time": now, "line": chosen["id"]}
	var event := _line_event(chosen, null, "bubble", false)
	event["attrs"]["pool_id"] = pool_id
	event["attrs"]["speaker_node"] = speaker_node
	bark_started.emit(pool_id, event["id"], event["speaker"], event["expression"], event["attrs"], event["text"])
	return event


## Marks a document as found (seen.<tier>.<doc_id>) and emits doc_collected.
func collect_doc(doc_id: String) -> bool:
	if not _story.get("docs", {}).has(doc_id):
		push_error("StoryRunner: unknown document '%s'" % doc_id)
		return false
	flags.mark_seen(doc_id)
	doc_collected.emit(doc_id)
	return true


func is_doc_collected(doc_id: String) -> bool:
	return flags.is_seen(doc_id, "save")


## Returns {"id", "category", "title", "paragraphs"} with display text, or {} if unknown.
func get_doc(doc_id: String) -> Dictionary:
	var doc: Variant = _story.get("docs", {}).get(doc_id)
	if doc == null:
		return {}
	var paragraphs: Array = []
	for line_id in doc.get("paragraphs", []):
		paragraphs.append(format_line(String(line_id)))
	var title_id: Variant = doc.get("title")
	return {
		"id": doc_id,
		"category": "" if doc.get("category") == null else String(doc["category"]),
		"title": "" if title_id == null else format_line(String(title_id)),
		"paragraphs": paragraphs,
	}


## IDs of collected documents in story order, optionally only one category.
func collected_docs(category: String = "") -> Array:
	var out: Array = []
	var docs: Dictionary = _story.get("docs", {})
	for doc_id in docs:
		var doc_category: Variant = docs[doc_id].get("category")
		if is_doc_collected(doc_id) and (category.is_empty() or doc_category == category):
			out.append(doc_id)
	return out


## Returns and emits the lines of a subtitle cue; schedule them with attrs.at and attrs.dur.
func play_cue(cue_id: String) -> Array:
	var cue: Variant = _story.get("cues", {}).get(cue_id)
	if cue == null:
		push_error("StoryRunner: unknown cue '%s'" % cue_id)
		return []
	var lines: Array = []
	for line in cue.get("lines", []):
		var event := _line_event(line, null, "caption", false)
		event["attrs"]["at"] = float(line.get("at", 0.0))
		event["attrs"]["dur"] = float(line.get("dur", 0.0))
		lines.append(event)
	cue_started.emit(cue_id, lines)
	return lines


# --- Game state ----------------------------------------------------------------------


func new_game() -> void:
	stop()
	flags.new_game()


func reset_loop() -> void:
	flags.reset_loop()


func get_flag(flag_name: String) -> Variant:
	return flags.get_flag(flag_name)


func set_flag(flag_name: String, value: Variant) -> bool:
	return flags.set_flag(flag_name, value)


func serialize_save() -> Dictionary:
	return flags.serialize_save()


func restore_save(data: Dictionary) -> bool:
	stop()
	return flags.restore_save(data)


## Whether a meta effect may touch the real OS: the player consented (sys.meta_os) and the
## platform supports it. Window movement does nothing on Wayland, so window_shake is refused there.
func meta_allowed(target: String) -> bool:
	if not flags.get_flag("sys.meta_os"):
		return false
	if not OS.has_feature("pc") or OS.has_feature("web"):
		return false
	match target:
		"window_shake":
			return DisplayServer.get_name() != "Wayland"
		"desktop_file":
			return not OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).is_empty()
	return true


# --- Internals -------------------------------------------------------------------------


func _line_event(op: Dictionary, block_style: Variant, kind_default: String, remember: bool) -> Dictionary:
	var line_id := String(op.get("id", ""))
	var speaker := String(op.get("speaker", ""))
	var character: Dictionary = _story.get("characters", {}).get(speaker, {})
	var expression := ""
	if op.has("expression"):
		expression = String(op["expression"])
	elif _last_expression.has(speaker):
		expression = _last_expression[speaker]
	elif character.get("default_expression") != null:
		expression = String(character["default_expression"])
	if remember:
		_last_expression[speaker] = expression
	var requested := ""
	if op.has("to"):
		requested = String(op["to"])
	elif not kind_default.is_empty():
		requested = kind_default
	elif block_style != null:
		requested = String(block_style)
	elif character.get("style") != null:
		requested = String(character["style"])
	else:
		requested = "window"
	var target := requested
	if requested in META_TARGETS and not meta_allowed(requested):
		target = META_FALLBACKS[requested]
	var portraits: Dictionary = character.get("portraits", {})
	var portrait: Variant = portraits.get(expression, portraits.get(character.get("default_expression"), ""))
	var split := _Text.split_waits(_interpolate(get_text(line_id)))
	var attrs := {
		"display_name": display_name(speaker, String(op.get("name", ""))),
		"portrait": "" if portrait == null else String(portrait),
		"color": String(character.get("color", "")),
		"blip": String(character.get("blip", "")),
		"target": target,
		"requested_target": requested,
		"emote": String(op.get("emote", "")),
		"voice": String(op.get("voice", "")),
		"voice_path": _voice_path(line_id),
		"side": String(op.get("side", "")),
		"waits": split["waits"],
	}
	return {"id": line_id, "speaker": speaker, "expression": expression, "attrs": attrs, "text": split["text"]}


func _interpolate(raw: String) -> String:
	return _Text.interpolate(raw, _resolve_placeholder)


func _resolve_placeholder(inner: String) -> String:
	if inner.begins_with("@"):
		match inner.substr(1):
			"player_name":
				return player_name
			"loop_count":
				return str(flags.get_flag("sys.loop_count"))
			"os_user":
				return _os_user()
		push_warning("StoryRunner: unknown token {%s}" % inner)
		return ""
	return _Text.format_value(flags.get_flag(inner))


func _os_user() -> String:
	if meta_allowed("os_user"):
		for variable in ["USERNAME", "USER"]:
			var value := OS.get_environment(variable)
			if not value.is_empty():
				return value
	return player_name


func _voice_path(line_id: String) -> String:
	for locale in [_locale, _source_locale]:
		var path := "res://assets/original/voice/%s/%s.ogg" % [locale, line_id]
		if ResourceLoader.exists(path):
			return path
	return ""


func _lookup(key: String) -> Variant:
	var table: Dictionary = _strings.get(_locale, {})
	if table.has(key):
		return table[key]
	var source: Dictionary = _strings.get(_source_locale, {})
	return source.get(key)


func _dialogues() -> Dictionary:
	return _story.get("dialogues", {})


func _load_strings(locale: String) -> bool:
	var data: Variant = _read_json(_strings_dir.path_join("strings.%s.json" % locale))
	if typeof(data) != TYPE_DICTIONARY:
		return false
	_strings[locale] = data
	return true


func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("StoryRunner: file not found: %s" % path)
		return null
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		push_error("StoryRunner: %s:%d: %s" % [path, json.get_error_line(), json.get_error_message()])
		return null
	return json.data

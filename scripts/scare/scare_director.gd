## Schedules jump scares with timing rules taken from startle research.
##
## The director holds no scare text. A scare is triggered by ID (for example by the story
## runtime command `do emit scare_<id>`), waits a delay drawn from a truncated exponential
## distribution, ducks the ambience bed, keeps a quiet window before the onset and then emits
## `scare_onset` on the same frame as the stinger, so picture and sound start together.
## Rules, numbers and sources: docs/scare-director.md.
##
## Typical use:
##     director.configure_from_file("res://assets/original/story/scares.json")
##     director.bind_story(story_runner)              # listens for "emit scare_<id>"
##     director.scare_onset.connect(_on_scare_onset)  # draw the scare, start the chase
##     # UI and sound effects ask director.is_quiet() before playing anything.
class_name ScareDirector
extends Node

## A scare was accepted and will start after `delay` seconds.
signal scare_scheduled(scare_id: String, delay: float)
## Start lowering the ambience bed by `duck_db` (the director also does it if `bed_bus` is set).
signal lead_started(scare_id: String, duck_db: float)
## From now until the onset, nothing else may make a sound or change the picture.
signal quiet_window_started(scare_id: String)
## Soft mode only: a short weak sound 60-120 ms before the onset (prepulse inhibition).
signal prepulse(scare_id: String)
## The scare starts. Draw it on this frame. `info` keys: kind, family, level_lu, rise_ms,
## body_ms, flash, area, shake, cue, variant, mode, repeat.
signal scare_onset(scare_id: String, info: Dictionary)
## Body and sustain are over; the relax period starts.
signal scare_finished(scare_id: String)
## A dialogue should start now (the scare's `after_dialogue`).
signal dialogue_requested(scare_id: String, dialogue_id: String)

enum Mode { DEFAULT, SOFT, OFF }

## A sound or picture change 30-500 ms before a startle stimulus inhibits it.
const QUIET_WINDOW := 0.5
## Soft mode prepulse lead (inhibition peaks at 60-120 ms).
const PREPULSE_LEAD := 0.09
## Delay distribution used when a scare gives none.
const DEFAULT_DELAY := {"mean": 1.5, "min": 0.6, "max": 6.0}

## Intensity setting chosen by the player.
var mode: Mode = Mode.DEFAULT
## Photosensitivity-safe setting: no flashes, smaller visual area.
var photosafe: bool = false
## Gain change in soft mode, in dB.
var soft_gain_db: float = -10.0
## Rise time used in OFF mode; a slow swell does not trigger the startle reflex.
var off_rise_ms: float = 1500.0
## Minimum delay after a trigger caused by player input (the input sound is a prepulse otherwise).
var min_input_delay: float = 0.6
## Call tick() from _process(). Turn off in tests and drive tick() by hand.
var auto_process: bool = true
## Optional audio buses. Empty names are ignored.
var bed_bus: String = ""
var ui_bus: String = ""
## Start a scare's `after_dialogue` on the bound StoryRunner when the scare ends.
var auto_start_dialogue: bool = true
## Append one CSV row per onset for playtest calibration. Empty path disables logging.
var log_path: String = ""
## Random source; seed it for reproducible tests.
var rng := RandomNumberGenerator.new()

var _scares: Dictionary = {}
var _clock: float = 0.0
var _active: Dictionary = {}
var _pending: Array = []
var _counts: Dictionary = {}
var _last_onset: Dictionary = {}
var _relax_until: float = -1.0
var _relax_id: String = ""
var _duck_db: float = 0.0
var _bed_base_db: float = 0.0
var _bed_captured: bool = false
var _restore_from: float = 0.0
var _restore_start: float = -1.0
var _story: Node = null


func _process(delta: float) -> void:
	if auto_process:
		tick(delta)


# --- Configuration -----------------------------------------------------------------


## Loads a JSON file: {"format": 1, "settings": {...}, "scares": {"<id>": {...}}}.
func configure_from_file(path: String) -> Error:
	if not FileAccess.file_exists(path):
		push_error("ScareDirector: cannot open %s" % path)
		return ERR_FILE_NOT_FOUND
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		push_error("ScareDirector: %s is not a JSON object" % path)
		return ERR_PARSE_ERROR
	configure(data)
	return OK


## Accepts the same structure as the JSON file.
func configure(data: Dictionary) -> void:
	var settings: Dictionary = data.get("settings", {})
	soft_gain_db = float(settings.get("soft_gain_db", soft_gain_db))
	off_rise_ms = float(settings.get("off_rise_ms", off_rise_ms))
	min_input_delay = float(settings.get("min_input_delay", min_input_delay))
	bed_bus = String(settings.get("bed_bus", bed_bus))
	ui_bus = String(settings.get("ui_bus", ui_bus))
	_scares.clear()
	var scares: Dictionary = data.get("scares", {})
	for key in scares:
		_scares[String(key)] = _normalized(scares[key])


func has_scare(scare_id: String) -> bool:
	return _scares.has(scare_id)


func scare_config(scare_id: String) -> Dictionary:
	return _scares.get(scare_id, {}).duplicate(true)


## Connects to a StoryRunner: `do emit scare_<id>` triggers <id>.
func bind_story(runner: Node) -> void:
	_story = runner
	if runner.has_signal("command") and not runner.command.is_connected(_on_story_command):
		runner.command.connect(_on_story_command)


# --- Triggering --------------------------------------------------------------------


## Requests a scare. Returns false if it is unknown or blocked by its repeat interval.
## `from_input`: the trigger came from a player action (enforces min_input_delay).
func trigger(scare_id: String, from_input: bool = false) -> bool:
	if not _scares.has(scare_id):
		push_warning("ScareDirector: unknown scare '%s'" % scare_id)
		return false
	var cfg: Dictionary = _scares[scare_id]
	var interval: float = float(cfg["min_repeat_interval_s"])
	if _last_onset.has(scare_id) and _clock - float(_last_onset[scare_id]) < interval:
		return false
	if not _active.is_empty():
		_pending.append({"id": scare_id, "input": from_input})
		return true
	var start: float = _clock
	if _blocked_by_relax(cfg):
		start = _relax_until
	_schedule(scare_id, start, from_input)
	return true


## Cancels the running and pending scares (for example on a loop reset).
func cancel_all() -> void:
	_active.clear()
	_pending.clear()
	_restore_start = -1.0
	_set_duck(0.0)
	_set_ui_mute(false)


## Seconds on the director's clock.
func now() -> float:
	return _clock


## True between `onset - QUIET_WINDOW` and the onset. UI sounds and effects must wait.
func is_quiet() -> bool:
	if _active.is_empty():
		return false
	return _clock >= float(_active["quiet_at"]) and _clock < float(_active["onset_at"])


func is_busy() -> bool:
	return not _active.is_empty()


func is_relaxing() -> bool:
	return _clock < _relax_until


## Current duck applied to the ambience bed, in dB (0 or negative).
func current_duck_db() -> float:
	return _duck_db


## How many times the scare has started.
func repeat_count(scare_id: String) -> int:
	return int(_counts.get(scare_id, 0))


## Delay from a truncated exponential distribution. The hazard of an exponential is constant,
## so waiting longer does not make the scare easier to predict (unlike a uniform window).
func sample_delay(spec: Dictionary) -> float:
	var mean: float = maxf(0.001, float(spec.get("mean", DEFAULT_DELAY["mean"])))
	var lo: float = maxf(0.0, float(spec.get("min", DEFAULT_DELAY["min"])))
	var hi: float = maxf(lo, float(spec.get("max", lo + 3.0 * mean)))
	var f_lo: float = 1.0 - exp(-lo / mean)
	var f_hi: float = 1.0 - exp(-hi / mean)
	var u: float = lerpf(f_lo, f_hi, rng.randf())
	return clampf(-mean * log(1.0 - u), lo, hi)


## Advances the director clock and fires due events in order.
func tick(delta: float) -> void:
	var target: float = _clock + maxf(0.0, delta)
	var guard := 0
	while guard < 64:
		guard += 1
		var next_time: float = _next_event_time()
		if next_time < 0.0 or next_time > target:
			break
		_clock = maxf(_clock, next_time)
		_fire_due()
	_clock = target
	_update_duck()


# --- Internals ---------------------------------------------------------------------


func _normalized(raw: Variant) -> Dictionary:
	var d: Dictionary = raw if typeof(raw) == TYPE_DICTIONARY else {}
	var kind: String = String(d.get("kind", "real"))
	var visual: Dictionary = d.get("visual", {}) if typeof(d.get("visual")) == TYPE_DICTIONARY else {}
	var delay: Dictionary = d.get("delay", {}) if typeof(d.get("delay")) == TYPE_DICTIONARY else {}
	return {
		"kind": kind,
		"family": String(d.get("family", "")),
		"delay": delay,
		"immediate": bool(d.get("immediate", false)),
		"level_lu": float(d.get("level_lu", 12.0)),
		"rise_ms": float(d.get("rise_ms", 2.0)),
		"body_ms": float(d.get("body_ms", 500.0)),
		"lead_s": float(d.get("lead_s", 1.5)),
		"duck_db": float(d.get("duck_db", -20.0)),
		"sustain_s": float(d.get("sustain_s", 4.0)),
		"relax_s": float(d.get("relax_s", 36.0 if kind != "false" else 10.0)),
		"repeat_step_db": float(d.get("repeat_step_db", 0.0)),
		"repeat_floor_lu": float(d.get("repeat_floor_lu", 2.0)),
		"replace_after": int(d.get("replace_after", 0)),
		"min_repeat_interval_s": float(d.get("min_repeat_interval_s", 0.0)),
		"allow_during_relax_of": String(d.get("allow_during_relax_of", "")),
		"flash": bool(visual.get("flash", false)),
		"area": float(visual.get("area", 0.2)),
		"shake": float(visual.get("shake", 0.0)),
		"cue": String(d.get("cue", "")),
		"after_dialogue": String(d.get("after_dialogue", "")),
	}


func _blocked_by_relax(cfg: Dictionary) -> bool:
	if not is_relaxing():
		return false
	if String(cfg["kind"]) != "real":
		return false
	return String(cfg["allow_during_relax_of"]) != _relax_id


func _schedule(scare_id: String, start: float, from_input: bool) -> void:
	var cfg: Dictionary = _scares[scare_id]
	var delay: float = 0.0
	if not bool(cfg["immediate"]):
		var spec: Dictionary = cfg["delay"]
		delay = sample_delay(spec if not spec.is_empty() else DEFAULT_DELAY)
		if from_input:
			delay = maxf(delay, min_input_delay)
	var onset: float = start + delay
	var body: float = float(cfg["body_ms"]) / 1000.0
	_active = {
		"id": scare_id,
		"lead_at": maxf(start, onset - float(cfg["lead_s"])),
		"quiet_at": maxf(start, onset - QUIET_WINDOW),
		"prepulse_at": onset - PREPULSE_LEAD if mode == Mode.SOFT else -1.0,
		"onset_at": onset,
		"finish_at": onset + body + float(cfg["sustain_s"]),
		"done": {},
		"delay": delay,
	}
	scare_scheduled.emit(scare_id, start - _clock + delay)


func _next_event_time() -> float:
	if _active.is_empty():
		return -1.0
	var done: Dictionary = _active["done"]
	var best := -1.0
	for key in ["lead_at", "quiet_at", "prepulse_at", "onset_at", "finish_at"]:
		var t: float = float(_active[key])
		if t < 0.0 or done.has(key):
			continue
		if best < 0.0 or t < best:
			best = t
	return best


func _fire_due() -> void:
	var done: Dictionary = _active["done"]
	var scare_id: String = _active["id"]
	var cfg: Dictionary = _scares[scare_id]
	for key in ["lead_at", "quiet_at", "prepulse_at", "onset_at", "finish_at"]:
		var t: float = float(_active[key])
		if t < 0.0 or done.has(key) or t > _clock:
			continue
		done[key] = true
		match key:
			"lead_at":
				lead_started.emit(scare_id, float(cfg["duck_db"]))
			"quiet_at":
				_set_ui_mute(true)
				quiet_window_started.emit(scare_id)
			"prepulse_at":
				prepulse.emit(scare_id)
			"onset_at":
				_set_ui_mute(false)
				_onset(scare_id, cfg)
			"finish_at":
				_finish(scare_id, cfg)
				return


func _onset(scare_id: String, cfg: Dictionary) -> void:
	var k: int = int(_counts.get(scare_id, 0)) + 1
	_counts[scare_id] = k
	_last_onset[scare_id] = _clock
	var level: float = float(cfg["level_lu"]) + float(cfg["repeat_step_db"]) * (k - 1)
	if float(cfg["repeat_step_db"]) < 0.0:
		level = maxf(level, float(cfg["repeat_floor_lu"]))
	var rise: float = float(cfg["rise_ms"])
	var flash: bool = bool(cfg["flash"])
	var shake: float = float(cfg["shake"])
	var area: float = float(cfg["area"])
	var mode_name := "default"
	if mode == Mode.SOFT:
		level += soft_gain_db
		shake = 0.0
		flash = false
		mode_name = "soft"
	elif mode == Mode.OFF:
		rise = maxf(rise, off_rise_ms)
		shake = 0.0
		flash = false
		mode_name = "off"
	if photosafe:
		flash = false
		area = minf(area, 0.1)
	var variant := "normal"
	if int(cfg["replace_after"]) > 0 and k >= int(cfg["replace_after"]):
		variant = "replacement"
	var info := {
		"kind": cfg["kind"], "family": cfg["family"], "level_lu": level, "rise_ms": rise,
		"body_ms": cfg["body_ms"], "flash": flash, "area": area, "shake": shake, "cue": cfg["cue"],
		"variant": variant, "mode": mode_name, "repeat": k, "delay": _active.get("delay", 0.0),
	}
	_write_log(scare_id, info)
	scare_onset.emit(scare_id, info)


func _finish(scare_id: String, cfg: Dictionary) -> void:
	_active = {}
	_restore_from = _duck_db
	_restore_start = _clock
	_relax_until = _clock + float(cfg["relax_s"])
	_relax_id = scare_id
	scare_finished.emit(scare_id)
	var dialogue_id: String = cfg["after_dialogue"]
	if dialogue_id != "":
		dialogue_requested.emit(scare_id, dialogue_id)
		if auto_start_dialogue and _story != null and _story.has_method("start"):
			if not _story.call("is_running"):
				_story.call("start", dialogue_id)
	if not _pending.is_empty():
		var next: Dictionary = _pending.pop_front()
		var next_cfg: Dictionary = _scares[next["id"]]
		var start: float = _relax_until if _blocked_by_relax(next_cfg) else _clock
		_schedule(String(next["id"]), start, bool(next["input"]))


func _update_duck() -> void:
	if _active.is_empty():
		# Restore the bed over one second after a scare ends.
		if _restore_start >= 0.0 and _clock - _restore_start < 1.0:
			_set_duck(_restore_from * (1.0 - (_clock - _restore_start)))
		else:
			_restore_start = -1.0
			_set_duck(0.0)
		return
	var cfg: Dictionary = _scares[_active["id"]]
	var lead_at: float = float(_active["lead_at"])
	var onset_at: float = float(_active["onset_at"])
	if _clock < lead_at:
		_set_duck(0.0)
	elif _clock < onset_at:
		var span: float = max(0.001, onset_at - lead_at)
		_set_duck(float(cfg["duck_db"]) * clampf((_clock - lead_at) / span, 0.0, 1.0))
	else:
		_set_duck(float(cfg["duck_db"]))


func _set_duck(db: float) -> void:
	_duck_db = db
	if bed_bus == "":
		return
	var idx := AudioServer.get_bus_index(bed_bus)
	if idx >= 0:
		if not _bed_captured:
			_bed_base_db = AudioServer.get_bus_volume_db(idx)
			_bed_captured = true
		AudioServer.set_bus_volume_db(idx, _bed_base_db + db)


func _set_ui_mute(muted: bool) -> void:
	if ui_bus == "":
		return
	var idx := AudioServer.get_bus_index(ui_bus)
	if idx >= 0:
		AudioServer.set_bus_mute(idx, muted)


func _on_story_command(cmd: String, args: Array) -> void:
	if cmd != "emit" or args.is_empty():
		return
	var event_name: String = String(args[0])
	if event_name.begins_with("scare_"):
		trigger(event_name.substr(6), true)


func _write_log(scare_id: String, info: Dictionary) -> void:
	if log_path == "":
		return
	var exists := FileAccess.file_exists(log_path)
	var f := FileAccess.open(log_path, FileAccess.READ_WRITE if exists else FileAccess.WRITE)
	if f == null:
		return
	if exists:
		f.seek_end()
	else:
		f.store_line("time_ms,scare,kind,repeat,mode,delay_s,level_lu,rise_ms,flash")
	f.store_line("%d,%s,%s,%d,%s,%.3f,%.1f,%.0f,%s" % [
		Time.get_ticks_msec(), scare_id, info["kind"], info["repeat"], info["mode"],
		float(info["delay"]), float(info["level_lu"]), float(info["rise_ms"]), str(info["flash"])])
	f.close()

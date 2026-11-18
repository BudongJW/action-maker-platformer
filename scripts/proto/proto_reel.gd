## Plays a scripted sequence of scenes for a demo video: `-- --reel <file.json>`. Record it with
## Godot's movie writer (`--write-movie out.avi`, see prototype/README.md "Reel").
##
## The reel file holds every visible word (title cards come from it, dialogue from the story);
## this script only drives the game. It takes over from the start screen: triggers, the hub queue
## and the end flag are switched off while it runs.
##
## {"line_secs": 1.4, "per_char": 0.06, "max_line_secs": 5.5, "choice_secs": 1.6, "steps": [...]}
## Steps ({"do": kind, ...}):
##   title {text, sub, secs}        black card with two lines of text (fades in and out)
##   hub {text}                     the 2026 workroom picture, no tape
##   tape {at, track, x, y, events, rec} play the tape from `at` seconds; `events` fires timeline
##                                  events already passed (for example "power_cut"); REC is on
##                                  unless rec is false
##   flags {set: {flag: value}, seen: [block ids]}
##   dialogue {id, choices: [i...], stop_after}  plays a dialogue; choices are taken in order
##   doc {id, secs}                 shows a document
##   walk {to, secs, jump}          walks the player toward x (secs is the limit)
##   warp {x, y}, track {track}, wait {secs}, cue {id, secs}, scare {id, secs}
##   board {keys: ["RIGHT", "DOWN", ...], key_secs}   opens the deduction board and presses keys
##   end                            stops every sound and quits (ends the movie)
class_name ProtoReel
extends Node

const KEYS := {"LEFT": KEY_LEFT, "RIGHT": KEY_RIGHT, "UP": KEY_UP, "DOWN": KEY_DOWN, "B": KEY_B}

var game: ProtoGame
var running := false
var _cfg: Dictionary = {}
var _steps: Array = []
var _index := -1
var _step: Dictionary = {}
var _t := 0.0
var _line_left := 0.0
var _choice_left := -1.0
var _choices_queue: Array = []
var _lines := 0
var _started := false
var _keys: Array = []
var _key_left := 0.0
var _overlay: CanvasLayer
var _back: ColorRect
var _title: Label
var _sub: Label


## Loads the reel and starts it. Returns false (and the game runs normally) if the file is bad.
func start(owner_game: ProtoGame, path: String) -> bool:
	game = owner_game
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY or parsed.get("steps", []).is_empty():
		push_error("ProtoReel: cannot read %s" % path)
		return false
	_cfg = parsed
	_steps = parsed["steps"]
	_build_overlay()
	running = true
	# Take over from the start screen: no start document, no workroom queue.
	game._hub_queue.clear()
	game._after_doc = Callable()
	game.ui.hide_doc()
	game.runner.stop()
	game.player.bot = true
	game.runner.line_started.connect(_on_line)
	game.runner.choices_presented.connect(_on_choices)
	_next()
	return true


func _build_overlay() -> void:
	_overlay = CanvasLayer.new()
	_overlay.layer = 30
	add_child(_overlay)
	_back = ColorRect.new()
	_back.anchor_right = 1.0
	_back.anchor_bottom = 1.0
	_back.color = Color(0.02, 0.02, 0.03, 0.0)
	_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_back)
	_title = _card_label(40, 0.40)
	_sub = _card_label(22, 0.54)


func _card_label(size_px: int, top: float) -> Label:
	var l := Label.new()
	l.anchor_left = 0.1
	l.anchor_right = 0.9
	l.anchor_top = top
	l.anchor_bottom = top + 0.12
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if game.font != null:
		l.add_theme_font_override("font", game.font)
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", Color(0.92, 0.9, 0.84, 0.0))
	_overlay.add_child(l)
	return l


func _on_line(_id: String, _speaker: String, _expression: String, _attrs: Dictionary, text: String) -> void:
	_lines += 1
	_choice_left = -1.0
	var secs := float(_cfg.get("line_secs", 1.4)) + text.length() * float(_cfg.get("per_char", 0.06))
	_line_left = clampf(secs, float(_cfg.get("min_line_secs", 1.8)), float(_cfg.get("max_line_secs", 5.5)))


func _on_choices(_options: Array) -> void:
	_choice_left = float(_cfg.get("choice_secs", 1.6))


## Called by the game every frame while the reel runs.
func tick(delta: float) -> void:
	if not running:
		return
	_t += delta
	var kind := String(_step.get("do", ""))
	var secs := float(_step.get("secs", 0.0))
	match kind:
		"title":
			var fade := 0.6
			var a := clampf(minf(_t / fade, (secs - _t) / fade), 0.0, 1.0)
			_set_card_alpha(a)
			if _t >= secs:
				_set_card_alpha(0.0)
				_next()
		"dialogue":
			_tick_dialogue(delta)
		"walk":
			var dx := float(_step.get("to", 0.0)) - game.player.global_position.x
			game.player.bot_axis = signf(dx) if absf(dx) > 12.0 else 0.0
			if bool(_step.get("jump", false)) and fmod(_t, 1.0) < delta:
				game.player.bot_jump = true
			if absf(dx) <= 12.0 or _t >= (secs if secs > 0.0 else 20.0):
				game.player.bot_axis = 0.0
				_next()
		"board":
			_key_left -= delta
			if _key_left <= 0.0:
				if _keys.is_empty():
					if game.board.is_open():
						game.board.close()
					game.ui.set_hub("")  # closing the board puts the workroom prompt back
					_next()
				else:
					game.board.handle_key(int(KEYS.get(String(_keys.pop_front()), KEY_RIGHT)))
					_key_left = float(_step.get("key_secs", 0.9))
		_:
			if _t >= secs:
				if kind == "doc":
					game.ui.hide_doc()
				_next()


func _tick_dialogue(delta: float) -> void:
	if not game.runner.is_running():
		_next()
		return
	if _step.has("stop_after") and _lines >= int(_step["stop_after"]) and _line_left <= 0.0:
		game.runner.stop()
		return
	if _choice_left >= 0.0:
		_choice_left -= delta
		if _choice_left <= 0.0:
			_choice_left = -1.0
			var pick: int = int(_choices_queue.pop_front()) if not _choices_queue.is_empty() else -1
			if pick < 0:
				pick = game._selected
			game._selected = pick
			game.ui.show_choices(game._choices, pick)
			game._choose(pick)
		return
	_line_left -= delta
	if _line_left <= 0.0 and game._choices.is_empty():
		game.runner.advance()


func _set_card_alpha(a: float) -> void:
	_back.color.a = a
	_title.add_theme_color_override("font_color", Color(0.92, 0.9, 0.84, a))
	_sub.add_theme_color_override("font_color", Color(0.7, 0.72, 0.76, a))


func _next() -> void:
	_index += 1
	_t = 0.0
	_lines = 0
	_line_left = 0.0
	_choice_left = -1.0
	if _index >= _steps.size():
		_finish()
		return
	_step = _steps[_index]
	match String(_step.get("do", "")):
		"title":
			_title.text = String(_step.get("text", ""))
			_sub.text = String(_step.get("sub", ""))
		"hub":
			game.runner.stop()
			game.phase = ProtoGame.Phase.HUB
			game.player.frozen = true
			game.ui.set_darkness(0.0)
			game.ui.set_hub(String(_step.get("text", "")))
			game._show_hub_art(true)
			game.audio.enter_hub()
			_next()
		"tape":
			_tape()
			_next()
		"flags":
			_flags(_step)
			_next()
		"dialogue":
			_choices_queue = _step.get("choices", []).duplicate()
			game.runner.start(String(_step.get("id", "")))
		"doc":
			game._show_doc(String(_step.get("id", "")))
		"warp":
			_warp(float(_step.get("x", 0.0)), float(_step.get("y", 780.0)))
			_next()
		"track":
			game._set_track(_track(String(_step.get("track", "hifi"))))
			_next()
		"cue":
			game.ui.play_cue(game.runner.play_cue(String(_step.get("id", ""))))
		"scare":
			game.director.trigger(String(_step.get("id", "")))
		"board":
			game.board.open()
			_keys = _step.get("keys", []).duplicate()
			_key_left = float(_step.get("key_secs", 0.9))
		"end":
			_finish()


func _tape() -> void:
	game.runner.stop()
	game._hub_queue.clear()
	if game.phase != ProtoGame.Phase.TAPE:
		game._start_loop()
	game.ui.set_hub("")
	game.ui.set_darkness(0.0)
	game._events.clear()
	game.mixer.seek(float(_step.get("at", 0.0)))
	for ev in _step.get("events", []):
		game._on_timeline_event(String(ev))
	game._set_track(_track(String(_step.get("track", "linear"))))
	game.ff = 1.0
	game.player.recording = bool(_step.get("rec", true))
	if _step.has("x"):
		_warp(float(_step["x"]), float(_step.get("y", 780.0)))


func _flags(step: Dictionary) -> void:
	var values: Dictionary = step.get("set", {})
	for f in values:
		game.runner.set_flag(String(f), values[f])
	for id in step.get("seen", []):
		game.runner.flags.mark_seen(String(id))


func _warp(x: float, y: float) -> void:
	game.player.global_position = Vector2(x, y)
	game.player.velocity = Vector2.ZERO
	game.player.camera().reset_smoothing()


func _track(track_name: String) -> TrackMixer.Track:
	return {"hifi": TrackMixer.Track.HIFI, "linear": TrackMixer.Track.LINEAR, "mix": TrackMixer.Track.MIX}.get(track_name, TrackMixer.Track.HIFI)


func _finish() -> void:
	running = false
	print("reel: %d frames, %d steps" % [game._stats["frames"], _steps.size()])
	game.audio.stop_all()
	game.fx.stop_audio()
	OS.delay_msec(150)
	get_tree().quit(0)

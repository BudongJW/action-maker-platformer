## Vertical-slice prototype: wires StoryRunner, ScareDirector and TrackMixer to a graybox level
## so the loop, the two tracks and the scares can be played and playtested before the
## ACTION GAME MAKER G version exists.
##
## Content comes from res://assets/original/story/ (compiled story, scares.json, proto_level.json):
## the private story pack when present, otherwise the generic demo in prototype/demo/. The level's
## optional "art" block swaps the graybox for pixel art (ProtoArt).
## Build and run with tools/build_prototype.py. Pass `-- --bot` to let it play itself (CI).
##
## Keys: A/D or arrows move, Space jump, W/S climb, Enter/E advance or play, 1-4 choose,
## Z LINEAR, X HI-FI, C MIX, R camera REC, F fast-forward, M scare mode (default / soft / off),
## P photosensitivity-safe scares, Up/Down move the choice cursor.
class_name ProtoGame
extends Node2D

const STORY := "res://assets/original/story/compiled/story.json"
const STRINGS := "res://assets/original/story/compiled"
const SCARES := "res://assets/original/story/scares.json"
const LEVEL := "res://assets/original/story/proto_level.json"
const FONT_NAMES := ["Noto Sans CJK KR", "Noto Sans KR", "Malgun Gothic", "Apple SD Gothic Neo",
	"NanumGothic", "WenQuanYi Zen Hei", "Noto Sans CJK JP", "sans-serif"]

enum Phase { HUB, TAPE, END }

var runner: StoryRunner
var director: ScareDirector
var mixer: TrackMixer
var level: ProtoLevel
var player: ProtoPlayer
var ui: ProtoUI
var fx: ProtoFX
var art: ProtoArt
var audio: ProtoAudio
var font: Font
var data: Dictionary = {}
var phase: Phase = Phase.HUB
var bot := false
var ff := 1.0

var _hub_queue: Array = []
var _play_after := false
var _done: Dictionary = {}
var _events: Dictionary = {}
var _choices: Array = []
var _chaser: Node2D
var _chaser_sprite: AnimatedSprite2D
var _chaser_on := false
var _catching := false
var _bot_timer := 0.0
var _bot_jump_timer := 0.0
var _bot_dir := 1.0
var _stats := {"frames": 0, "loops": 0, "dialogues": 0, "lines": 0, "scares": 0, "triggers": 0, "docs": 0}
var _max_frames := 40000
var _bot_loops := 4
var _last_safe := Vector2.ZERO
var _tint: CanvasModulate
var _step_timer := 0.0
var _last_rec := false
var _voice_speakers: Array = []
var _finished := false
var _selected := 0
var _after_doc: Callable = Callable()


func _ready() -> void:
	bot = "--bot" in OS.get_cmdline_user_args()
	var sf := SystemFont.new()
	sf.font_names = PackedStringArray(FONT_NAMES)
	font = sf
	ThemeDB.fallback_font = sf
	data = _load_json(LEVEL)

	runner = StoryRunner.new()
	add_child(runner)
	if runner.load_story(STORY, STRINGS) != OK:
		push_error("ProtoGame: no compiled story at %s" % STORY)
	runner.new_game()

	director = ScareDirector.new()
	director.auto_process = false
	add_child(director)
	if FileAccess.file_exists(SCARES):
		director.configure_from_file(SCARES)
	director.bind_story(runner)

	mixer = TrackMixer.new()
	mixer.auto_process = false
	var tape: Dictionary = data.get("tape", {})
	mixer.time_scale = float(tape.get("time_scale", 10.0))
	mixer.set_segments(tape.get("segments", []))
	for ev in tape.get("events", []):
		mixer.add_event(float(ev["at"]), String(ev["name"]), String(ev.get("flag", "")))
	add_child(mixer)
	mixer.bind_story(runner)

	audio = ProtoAudio.new()
	add_child(audio)
	if audio.setup(data.get("audio", {})):
		mixer.hifi_bus = ProtoAudio.HIFI_BUS
		mixer.linear_bus = ProtoAudio.LINEAR_BUS
		director.prepulse.connect(func(_scare_id): audio.play("prepulse", ProtoAudio.STINGER_BUS))

	RenderingServer.set_default_clear_color(Color(0.06, 0.07, 0.09))
	art = ProtoArt.new()
	art.setup(data.get("art", {}))
	_tint = CanvasModulate.new()
	add_child(_tint)
	level = ProtoLevel.new()
	level.build(data, font, art)
	add_child(level)
	_build_chaser()

	player = ProtoPlayer.new()
	player.level = level
	player.bot = bot
	add_child(player)
	player.set_camera_limits(level.size)
	if art.enabled():
		var spec: Dictionary = art.cfg.get("player", {})
		if not spec.is_empty():
			player.set_art(art.make_sprite(spec))
		player.set_camera_zoom(art.zoom(), float(art.cfg.get("camera_offset_y", -60.0)))

	ui = ProtoUI.new()
	ui.font = font
	add_child(ui)
	ui.apply_skin(art)
	fx = ProtoFX.new()
	fx.ui = ui
	fx.art = art
	fx.audio = audio
	fx.camera = player.camera()
	add_child(fx)
	fx.attach(ui)
	if not audio.enabled():
		fx.start_bed()
	if art.enabled():
		var vf: Dictionary = art.cfg.get("viewfinder", {})
		if not vf.is_empty():
			var sheet: String = String(vf.get("sheet", ""))
			ui.set_viewfinder(art.frame(sheet, String(vf.get("rec", "rec"))),
				art.frame(sheet, String(vf.get("standby", "standby"))))
		var wave: Dictionary = art.cfg.get("voice_wave", {})
		_voice_speakers = wave.get("speakers", [])
		ui.set_voice_color(Color.html(String(wave.get("color", "7fe0d0"))))

	runner.dialogue_started.connect(func(_id): _stats["dialogues"] += 1)
	runner.line_started.connect(_on_line)
	runner.choices_presented.connect(_on_choices)
	runner.dialogue_finished.connect(_on_dialogue_finished)
	director.scare_onset.connect(_on_scare_onset)
	director.scare_finished.connect(_on_scare_finished)
	mixer.timeline_event.connect(_on_timeline_event)
	mixer.set_track(TrackMixer.Track.LINEAR)
	mixer.apply_layers(level)
	if bot:
		ff = 20.0
	# A start notice (content warning, settings) can be shown as a document before anything else.
	var start_docs: Array = data.get("hub", {}).get("start_docs", [])
	if not start_docs.is_empty() and not runner.get_doc(String(start_docs[0])).is_empty():
		_show_hub_art(true)
		audio.enter_hub()
		_show_doc(String(start_docs[0]), func(): _enter_hub(true))
	else:
		_enter_hub(true)


# --- Phases --------------------------------------------------------------------------


func _enter_hub(first: bool) -> void:
	phase = Phase.HUB
	player.frozen = true
	ui.set_darkness(0.0)
	_show_hub_art(true)
	audio.enter_hub()
	var hub: Dictionary = data.get("hub", {})
	_hub_queue = (hub.get("start", []) if first else []) + hub.get("between", [])
	_run_hub_queue()


func _run_hub_queue() -> void:
	var hub_scares: Dictionary = data.get("hub", {}).get("scares", {})
	while not _hub_queue.is_empty():
		var id: String = String(_hub_queue.pop_front())
		if not runner.is_available(id):
			continue
		var scare: String = String(hub_scares.get(id, ""))
		if scare != "" and director.has_scare(scare):
			director.trigger(scare)  # the scare's after_dialogue starts `id`
		else:
			runner.start(id)
		return
	ui.set_hub("WORKROOM  -  PLAY %d\n[Enter] play the tape" % int(runner.get_flag("sys.loop_count")))


func _on_play() -> void:
	ui.set_hub("")
	audio.play("deck_play")
	for entry in data.get("hub", {}).get("on_play", []):
		var id: String = String(entry.get("dialogue", ""))
		if id != "" and runner.is_available(id):
			_play_after = true
			var scare: String = String(entry.get("scare", ""))
			if scare != "" and director.has_scare(scare):
				director.trigger(scare)
			else:
				runner.start(id)
			return
	_start_loop()


func _start_loop() -> void:
	phase = Phase.TAPE
	ui.set_hub("")
	_show_hub_art(false)
	mixer.rewind()
	audio.enter_tape()
	audio.play("tape_start")
	_done.clear()
	_events.clear()
	_chaser_on = false
	_catching = false
	player.pose_override = ""
	_chaser.visible = false
	ui.set_darkness(0.0)
	var start: Array = data.get("player_start", [100, 600])
	player.global_position = Vector2(float(start[0]), float(start[1]))
	player.velocity = Vector2.ZERO
	_last_safe = player.global_position
	player.frozen = false
	if not _hifi_unlocked():
		mixer.set_track(TrackMixer.Track.LINEAR)
	mixer.apply_layers(level)
	_apply_tint()


func _end_loop() -> void:
	_stats["loops"] += 1
	director.cancel_all()
	audio.play("deck_rewind")
	runner.stop()
	ui.hide_window()
	_choices.clear()
	runner.reset_loop()
	_chaser_on = false
	_chaser.visible = false
	if bot and _stats["loops"] >= _bot_loops:
		_finish_bot("loops")
		return
	_enter_hub(false)


func _complete() -> void:
	phase = Phase.END
	player.frozen = true
	ui.set_hub("END OF SLICE")
	if bot:
		_finish_bot("complete")


# --- Frame -----------------------------------------------------------------------------


func _process(delta: float) -> void:
	_stats["frames"] += 1
	director.tick(delta)
	if phase == Phase.TAPE:
		var talking := runner.is_running() or ui.doc_open()
		player.frozen = talking or _catching
		# Fast-forward pauses while a scare is pending or relaxing: the director runs in real
		# time, so a sped-up tape would push the next scare past its moment.
		var speed := 1.0 if director.is_busy() or director.is_relaxing() else ff
		mixer.tick(0.0 if talking else delta * speed)
		_keep_in_level()
		_check_triggers()
		_update_chaser(delta)
		level.update_backdrop(player.camera().get_screen_center_position().x, player.camera().zoom.x)
		audio.update(mixer.tape_time(), _events)
		_footsteps(delta)
		if mixer.tape_time() >= float(data.get("tape", {}).get("length", 7200.0)):
			_end_loop()
	_update_hud()
	if bot:
		_bot_step(delta)
		if _stats["frames"] > _max_frames:
			_finish_bot("frame limit")


func _unhandled_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo:
		return
	var key: int = k.keycode
	if key in [KEY_ENTER, KEY_KP_ENTER, KEY_E]:
		if ui.doc_open():
			_close_doc()
		elif runner.is_running():
			if _choices.is_empty():
				runner.advance()
			else:
				_choose(_selected)
		elif phase == Phase.HUB and not director.is_busy():
			_on_play()
	elif key in [KEY_UP, KEY_DOWN] and not _choices.is_empty():
		_move_selection(-1 if key == KEY_UP else 1)
	elif key >= KEY_1 and key <= KEY_4:
		_choose(key - KEY_1)
	elif key == KEY_Z:
		_set_track(TrackMixer.Track.LINEAR)
	elif key == KEY_X:
		_set_track(TrackMixer.Track.HIFI)
	elif key == KEY_C:
		_set_track(TrackMixer.Track.MIX)
	elif key == KEY_R:
		player.recording = not player.recording
	elif key == KEY_F:
		ff = 1.0 if ff > 1.0 else 4.0
	elif key == KEY_M:
		director.mode = ((int(director.mode) + 1) % 3) as ScareDirector.Mode
		ui.toast("SCARES " + ["DEFAULT", "SOFT", "OFF"][int(director.mode)])
	elif key == KEY_P:
		director.photosafe = not director.photosafe
		ui.toast("PHOTOSAFE " + ("ON" if director.photosafe else "OFF"))


# --- Story and scares ----------------------------------------------------------------------


func _on_line(_id: String, speaker: String, _expression: String, attrs: Dictionary, text: String) -> void:
	_stats["lines"] += 1
	_choices.clear()
	ui.show_line(String(attrs.get("display_name", speaker)), text)
	# Some voices have no body on screen; a soft waveform stands in for them.
	ui.set_voice(speaker in _voice_speakers)


func _on_choices(options: Array) -> void:
	_choices = options
	_selected = 0
	for i in options.size():
		if options[i]["enabled"]:
			_selected = i
			break
	ui.show_choices(options, _selected)


func _move_selection(step: int) -> void:
	for n in _choices.size():
		_selected = (_selected + step + _choices.size()) % _choices.size()
		if _choices[_selected]["enabled"]:
			break
	ui.show_choices(_choices, _selected)


## Opens the document viewer; `then` runs when it is closed.
func _show_doc(doc_id: String, then: Callable = Callable()) -> void:
	var doc := runner.get_doc(doc_id)
	if doc.is_empty():
		if then.is_valid():
			then.call()
		return
	_after_doc = then
	_bot_timer = 0.0
	ui.show_doc(doc)


func _close_doc() -> void:
	ui.hide_doc()
	var then := _after_doc
	_after_doc = Callable()
	if then.is_valid():
		then.call()


func _choose(index: int) -> void:
	if index < 0 or index >= _choices.size() or not _choices[index]["enabled"]:
		return
	_choices.clear()
	runner.choose(index)


func _on_dialogue_finished(_id: String) -> void:
	ui.hide_window()
	ui.set_voice(false)
	_choices.clear()
	var end_flag: String = String(data.get("end_flag", ""))
	if end_flag != "" and runner.get_flag(end_flag) == true:
		_complete()
		return
	if phase == Phase.HUB:
		if _play_after:
			_play_after = false
			_start_loop()
		else:
			_run_hub_queue()


func _on_scare_onset(id: String, info: Dictionary) -> void:
	_stats["scares"] += 1
	fx.onset(id, info)
	var cue: String = String(info.get("cue", ""))
	if cue != "":
		ui.play_cue(runner.play_cue(cue))


func _on_scare_finished(id: String) -> void:
	var chaser: Dictionary = data.get("chaser", {})
	if id == String(chaser.get("catch_scare", "")):
		_catching = false
		player.pose_override = ""
		if phase == Phase.TAPE:
			_end_loop()
		return
	if phase == Phase.TAPE and id in chaser.get("start_after", []) and mixer.get_track() == TrackMixer.Track.LINEAR:
		_chaser_on = true
		_chaser.visible = true
		_chaser.position = player.global_position + Vector2(float(chaser.get("offset", -360)), -56)
		if _chaser_sprite != null:
			_chaser_sprite.play("idle")


func _on_timeline_event(event_name: String) -> void:
	_events[event_name] = true
	if event_name == String(data.get("darkness_event", "")):
		ui.set_darkness(float(data.get("darkness_alpha", 0.55)))


func _check_triggers() -> void:
	if runner.is_running() or _catching or ui.doc_open():
		return
	var t := mixer.tape_time()
	var p := player.global_position + Vector2(0, -20)
	for tr in data.get("triggers", []):
		var id: String = String(tr["id"])
		if _done.has(id):
			continue
		if tr.has("loop") and int(runner.get_flag("sys.loop_count")) != int(tr["loop"]):
			continue
		if tr.has("from") and t < float(tr["from"]):
			continue
		if tr.has("to") and t > float(tr["to"]):
			continue
		if tr.has("track") and not _track_is(String(tr["track"])):
			continue
		if tr.has("after_event") and not _events.has(String(tr["after_event"])):
			continue
		if tr.has("rect") and not ProtoLevel.to_rect(tr["rect"]).has_point(p):
			continue
		if tr.has("rec_flag") and not player.recording:
			continue
		if _fire(tr):
			_stats["triggers"] += 1
			_done[id] = true
		if runner.is_running():
			return


func _fire(tr: Dictionary) -> bool:
	if tr.has("rec_flag"):
		runner.set_flag(String(tr["rec_flag"]), true)
		ui.toast("REC  " + String(tr["rec_flag"]))
		return true
	if tr.has("scare"):
		return director.trigger(String(tr["scare"]))
	if tr.has("doc"):
		runner.collect_doc(String(tr["doc"]))
		_show_doc(String(tr["doc"]))
		return true
	if tr.has("bark"):
		var line := runner.bark(String(tr["bark"]))
		if not line.is_empty():
			ui.bubble("%s: %s" % [line["attrs"].get("display_name", ""), line.get("text", "")])
		return false
	if tr.has("cue"):
		var cues: Dictionary = tr["cue"]
		var key := "hifi" if mixer.get_track() == TrackMixer.Track.HIFI else "linear"
		if cues.has(key):
			ui.play_cue(runner.play_cue(String(cues[key])))
			return true
		return false
	if tr.has("dialogue"):
		var id := runner.pick(tr["dialogue"])
		if id != "":
			runner.start(id)
			return true
	return false


## Falling below the level (into the water) puts the player back on the last safe ground.
func _keep_in_level() -> void:
	if player.is_on_floor():
		_last_safe = player.global_position
	elif player.global_position.y > level.size.y + 60.0:
		player.global_position = _last_safe
		player.velocity = Vector2.ZERO
		ui.toast("RESPAWN")


func _update_chaser(delta: float) -> void:
	if not _chaser_on or _catching:
		return
	var linear := mixer.get_track() == TrackMixer.Track.LINEAR
	_chaser.visible = linear
	if not linear or runner.is_running():
		return
	var target := player.global_position + Vector2(-18, -56)
	var speed: float = float(data.get("chaser", {}).get("speed", 150.0))
	if _chaser_sprite != null:
		_chaser_sprite.flip_h = target.x < _chaser.position.x
	_chaser.position.x = move_toward(_chaser.position.x, target.x, speed * delta)
	if absf(target.y - _chaser.position.y) < 120.0:
		_chaser.position.y = move_toward(_chaser.position.y, target.y, speed * delta)
	if _chaser.position.distance_to(target) < 30.0:
		_catching = true
		_chaser_on = false
		player.pose_override = "caught"
		if _chaser_sprite != null and _chaser_sprite.sprite_frames.has_animation("lunge"):
			_chaser_sprite.play("lunge")
		var catch_id: String = String(data.get("chaser", {}).get("catch_scare", ""))
		if catch_id == "" or not director.trigger(catch_id):
			_catching = false
			_end_loop()


# --- Art ----------------------------------------------------------------------------------


func _build_chaser() -> void:
	_chaser = Node2D.new()
	_chaser.visible = false
	level.add_child(_chaser)
	var spec: Dictionary = art.cfg.get("chaser", {}) if art.enabled() else {}
	if not spec.is_empty():
		# The chaser keeps its own colours (it only exists on the dubbed track).
		_chaser_sprite = art.make_sprite(spec, false)
		_chaser_sprite.position = Vector2(18, 56)
		_chaser.add_child(_chaser_sprite)
		return
	var box := ColorRect.new()
	box.color = Color(0.9, 0.45, 0.8, 0.85)
	box.size = Vector2(36, 56)
	_chaser.add_child(box)


## The hub (2026 workroom) is a full-screen picture when the art block has "hub_backdrop".
func _show_hub_art(on: bool) -> void:
	if not art.enabled():
		return
	var spec: Dictionary = art.cfg.get("hub_backdrop", {})
	if spec.is_empty():
		return
	ui.set_backdrop(art.frame(String(spec.get("texture", "")), String(spec.get("frame", ""))) if on else null)


## Footsteps while walking on the ground; silent in the scare director's quiet window, since a
## sound 30-500 ms before a startle stimulus weakens it.
func _footsteps(delta: float) -> void:
	if player.frozen or not player.is_on_floor() or absf(player.velocity.x) < 1.0 or director.is_quiet():
		_step_timer = 0.0
		return
	_step_timer -= delta
	if _step_timer <= 0.0:
		_step_timer = float(data.get("audio", {}).get("step_interval", 0.32))
		audio.play("step")


# --- Tracks and HUD ------------------------------------------------------------------------


func _hifi_unlocked() -> bool:
	var flag: String = String(data.get("tracks", {}).get("hifi_flag", "save.hifi_unlocked"))
	return runner.get_flag(flag) == true


func _set_track(track: TrackMixer.Track) -> void:
	var tracks: Dictionary = data.get("tracks", {})
	if track == TrackMixer.Track.HIFI and not _hifi_unlocked():
		ui.toast("HI-FI locked")
		return
	if track == TrackMixer.Track.MIX and runner.get_flag(String(tracks.get("mix_flag", "save.mix_unlocked"))) != true:
		ui.toast("MIX locked")
		return
	mixer.set_track(track)
	mixer.apply_layers(level)
	_apply_tint()


## LINEAR reads as the staged broadcast night, HI-FI as the real one by the water.
## With art the palettes do this (art block "palettes": linear, hifi, mix) and the badge follows.
func _apply_tint() -> void:
	if art.enabled():
		_tint.color = Color.WHITE
		var key: String = ["hifi", "linear", "mix"][mixer.get_track()]
		var mix_amount := 0.5 if key == "mix" and not art.cfg.get("palettes", {}).has("mix") else 1.0
		art.set_palette("hifi" if mix_amount < 1.0 else key, mix_amount)
		var badges: Dictionary = art.cfg.get("badges", {})
		ui.set_badge(art.frame(String(badges.get("sheet", "")), String(badges.get(key, ""))) if badges.has(key) else null)
		return
	match mixer.get_track():
		TrackMixer.Track.LINEAR:
			_tint.color = Color(1.0, 0.86, 0.96)
		TrackMixer.Track.HIFI:
			_tint.color = Color(0.78, 0.95, 1.0)
		_:
			_tint.color = Color.WHITE


func _track_is(track_name: String) -> bool:
	match track_name:
		"hifi":
			return mixer.get_track() == TrackMixer.Track.HIFI
		"linear":
			return mixer.get_track() == TrackMixer.Track.LINEAR
		"mix":
			return mixer.get_track() == TrackMixer.Track.MIX
	return true


func _update_hud() -> void:
	var t := int(mixer.tape_time())
	var tc := "%02d:%02d:%02d" % [t / 3600, (t / 60) % 60, t % 60]
	ui.set_timecode(tc)
	ui.set_recording(player.recording)
	if player.recording != _last_rec:
		_last_rec = player.recording
		audio.play("rec_on" if player.recording else "rec_off")
	var names := ["HI-FI", "LINEAR", "MIX"]
	var mode := ""
	if director.mode != ScareDirector.Mode.DEFAULT or director.photosafe:
		mode = "  SCARES %s%s" % [["DEFAULT", "SOFT", "OFF"][int(director.mode)], " PHOTOSAFE" if director.photosafe else ""]
	ui.set_hud("%s %s  TC %s  PLAY %d%s%s\n[Z]LIN [X]HIFI [C]MIX [R]REC [F]FF [M]SCARES [P]PHOTOSAFE" % [
		"REC" if player.recording else "   ", names[mixer.get_track()], tc,
		int(runner.get_flag("sys.loop_count")), "  FF x%d" % int(ff) if ff > 1.0 else "", mode])


# --- Bot -----------------------------------------------------------------------------------


func _bot_step(delta: float) -> void:
	_bot_timer += delta
	_bot_jump_timer += delta
	if ui.doc_open():
		if _bot_timer > 0.15:
			_bot_timer = 0.0
			_stats["docs"] += 1
			_close_doc()
		return
	if runner.is_running():
		if _bot_timer > 0.03:
			_bot_timer = 0.0
			if _choices.is_empty():
				runner.advance()
			else:
				for i in _choices.size():
					if _choices[i]["enabled"]:
						_choose(i)
						break
		return
	if phase == Phase.HUB:
		if not director.is_busy() and _bot_timer > 0.2:
			_bot_timer = 0.0
			_on_play()
		return
	if phase != Phase.TAPE:
		return
	player.recording = true
	if _hifi_unlocked() and mixer.get_track() != TrackMixer.Track.HIFI:
		_set_track(TrackMixer.Track.HIFI)
	# Optional route in the level data: stand at `x` during a tape-time window.
	var t := mixer.tape_time()
	var target := -1.0
	for r in data.get("bot_route", []):
		if t >= float(r["from"]) and t <= float(r["to"]):
			target = float(r["x"])
	if target >= 0.0:
		var dx := target - player.global_position.x
		player.bot_axis = signf(dx) if absf(dx) > 16.0 else 0.0
	else:
		if player.global_position.x > level.size.x - 80.0:
			_bot_dir = -1.0
		elif player.global_position.x < 80.0:
			_bot_dir = 1.0
		player.bot_axis = _bot_dir
	if _bot_jump_timer > 1.1 and player.bot_axis != 0.0:
		_bot_jump_timer = 0.0
		player.bot_jump = true


func _finish_bot(reason: String) -> void:
	if _finished:
		return
	_finished = true
	var flags: PackedStringArray = []
	for f in data.get("report_flags", []):
		flags.append("%s=%s" % [f, str(runner.get_flag(String(f)))])
	print("prototype: %d frames, %d loops, %d dialogues, %d lines, %d scares, %d triggers, %d docs (%s) %s" % [
		_stats["frames"], _stats["loops"], _stats["dialogues"], _stats["lines"], _stats["scares"],
		_stats["triggers"], _stats["docs"], reason, " ".join(flags)])
	# Stop every sound and give the audio thread a moment to release its playbacks, so a
	# headless run exits without leaked audio objects.
	audio.stop_all()
	fx.stop_audio()
	OS.delay_msec(150)
	get_tree().quit(0)


func _exit_tree() -> void:
	ThemeDB.fallback_font = null


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("ProtoGame: missing %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

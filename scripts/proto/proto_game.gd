## Vertical-slice prototype: wires StoryRunner, ScareDirector and TrackMixer to a graybox level
## so the loop, the two tracks and the scares can be played and playtested before the
## ACTION GAME MAKER G version exists.
##
## Content comes from res://assets/original/story/ (compiled story, scares.json, proto_level.json):
## the private story pack when present, otherwise the generic demo in prototype/demo/. The level's
## optional "art" block swaps the graybox for pixel art (ProtoArt).
## Build and run with tools/build_prototype.py. Pass `-- --bot` to let it play itself (CI).
##
## Controls are input actions (ProtoInput: keyboard, gamepad, rebindable; mouse for dialogue,
## choices and menus). Default keys: A/D or arrows move, Space jump, W/S climb, Enter/E advance or
## play, 1-4 choose, Z LINEAR, X HI-FI, C MIX, R camera REC, F fast-forward, M scare mode
## (default / soft / off), P photosensitivity-safe scares, Up/Down move the choice cursor, Esc
## pause, B the deduction board in the workroom (when the level has a "board" block). `-- --reel <file.json>` plays a
## scripted sequence of scenes instead (ProtoReel, for demo videos).
class_name ProtoGame
extends Node2D

const STORY := "res://assets/original/story/compiled/story.json"
const STRINGS := "res://assets/original/story/compiled"
const SCARES := "res://assets/original/story/scares.json"
const LEVEL := "res://assets/original/story/proto_level.json"
const FONT_NAMES := ["Noto Sans CJK KR", "Noto Sans KR", "Malgun Gothic", "Apple SD Gothic Neo",
	"NanumGothic", "WenQuanYi Zen Hei", "Noto Sans CJK JP", "sans-serif"]

enum Phase { HUB, TAPE, END, TITLE }

const SAVE_PATH := "user://proto_save.json"
const SAVE_FORMAT := 1
const PAUSE_OPTIONS := ["resume", "journal", "log", "options", "to_title"]

var runner: StoryRunner
var director: ScareDirector
var mixer: TrackMixer
var level: ProtoLevel
var player: ProtoPlayer
var ui: ProtoUI
var fx: ProtoFX
var screen: ProtoScreen
var input: ProtoInput
var art: ProtoArt
var audio: ProtoAudio
var settings: ProtoSettings
var board: ProtoBoard
var reel: ProtoReel
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
## Seconds until auto-advance moves past the line on screen (-1: not counting).
var _auto_left := -1.0
## The development status line at the top (`-- --debug-hud`); the deck panel replaces it.
var _debug_hud := false
## The journal (found documents) and the dialogue log; "pause" when one was opened from the
## pause menu, which comes back when it closes.
var journal: ProtoJournal
var backlog: ProtoLog
var _menu_return := ""
## A document opened from the journal is on screen; closing it goes back to the journal.
var _journal_reading := false
var _bot_tried_journal := false
## What the notices last saw (board cards and knots, unlocked tracks); taken silently at the
## start of a game or after loading, so only changes make notices.
var _notice_state: Dictionary = {}
var _notice_ready := false
## A document collected and on screen: its notice waits until it is closed.
var _doc_notice := ""
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
var _bot_tried_settings := false
var _bot_tried_board := false
## Board state the bot last looked at (it opens the board again when something new is on it).
var _bot_board_seen := ""
## Choice menus the bot has met in the current dialogue: key -> indices already chosen.
var _bot_menus: Dictionary = {}
## Triggers with "interact" fire only when the player presses Enter/E inside them.
var _interact_pressed := false
var _prompt_shown := ""
var _prompt_here := ""
var _water_rise: Array = []
## `-- --trace` prints triggers, dialogues, scares and loop ends with the tape time (bot debugging).
var _trace := false
var _water_barked: Array = []
## Escorts ("escorts" in the level): [{cfg, node, ribbon, index, done}] — a prop that walks a path
## while the player stays near it (for example a soul basket crossing a cloth road).
var _escorts: Array = []
var _chaser_flag_started := false
var _scare_on := ""  # scare id between its onset and its end
var _cut_cfg: Dictionary = {}  # the running dialogue's art "cuts" entry
var _cut_lines := {}  # line id -> text of the lines shown in the running dialogue
var _cut_shown: Dictionary = {}
var _cut_anim: Array = []  # frames of an animated cut
var _cut_anim_fps := 2.0
var _cut_anim_t := 0.0
var _bot_actions := {}  # workroom action keys the bot has used
var _save_path := SAVE_PATH  # "" keeps the save in memory (bot runs, reels)
var _memory_save: Dictionary = {}
var _bot_reloaded := false
var _title_options: Array = []
var _title_selected := 0
var _paused := false
var _pause_selected := 0
var _pause_hub_text := ""
var _selected := 0
var _after_doc: Callable = Callable()


func _ready() -> void:
	bot = "--bot" in OS.get_cmdline_user_args()
	_trace = "--trace" in OS.get_cmdline_user_args()
	var sf := SystemFont.new()
	sf.font_names = PackedStringArray(FONT_NAMES)
	font = sf
	ThemeDB.fallback_font = sf
	data = _load_json(LEVEL)

	runner = StoryRunner.new()
	add_child(runner)
	if bot or "--reel" in OS.get_cmdline_user_args():
		# Bot runs and reels keep meta.* (endings seen, second playthrough) in memory only, so they
		# neither read nor change the player's file and every run starts the same.
		runner.flags.meta_path = ""
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
	_build_escorts()

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

	input = ProtoInput.new()
	add_child(input)
	input.device_changed.connect(func(_d): _refresh_hints())
	# Before the first hint is drawn (the UI strings load with the settings screen below).
	call_deferred("_refresh_hints")
	ui = ProtoUI.new()
	ui.font = font
	add_child(ui)
	ui.apply_skin(art)
	ui.deck.input = input
	_debug_hud = "--debug-hud" in OS.get_cmdline_user_args()
	TranslationServer.set_locale(String(runner.get_flag("sys.locale")))
	if data.has("board"):
		# Under the settings screen, so Esc settings still draw on top.
		board = ProtoBoard.new()
		board.input = input
		ui.add_child(board)
		board.setup(data["board"], art, runner, font, ui.window_style())
		board.closed.connect(_show_hub_prompt)
	# The journal and the dialogue log, under the settings screen too.
	journal = ProtoJournal.new()
	journal.runner = runner
	journal.input = input
	ui.add_child(journal)
	journal.setup(font, ui.window_style(), ui.choice_style(), ui.paper_style())
	journal.configure(data.get("journal", {}))
	journal.closed.connect(_on_menu_closed)
	journal.read_doc.connect(_read_from_journal)
	backlog = ProtoLog.new()
	backlog.input = input
	ui.add_child(backlog)
	backlog.setup(font, ui.window_style(), ui.choice_style())
	backlog.closed.connect(_on_menu_closed)
	settings = ProtoSettings.new()
	settings.director = director
	settings.audio = audio
	settings.ui = ui
	settings.runner = runner
	settings.input = input
	# Bot runs and reels use the default settings and leave the player's file alone.
	var reel_run := "--reel" in OS.get_cmdline_user_args()
	settings.persist = not bot and not reel_run
	settings.apply_window = settings.persist
	ui.add_child(settings)
	settings.setup(font, ui.window_style(), ui.choice_style(), ui.cursor_texture())
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
	# VHS texture and the two-picture MIX, between the world and the UI.
	screen = ProtoScreen.new()
	add_child(screen)
	screen.setup(art, level, mixer)
	mixer.track_changed.connect(func(track: int): screen.set_mix(track == TrackMixer.Track.MIX))
	# Screen shake and the VHS strength need these two, made after the settings screen.
	settings.fx = fx
	settings.screen = screen
	settings.apply_all()

	runner.dialogue_started.connect(_on_dialogue_started)
	runner.line_started.connect(_on_line)
	runner.choices_presented.connect(_on_choices)
	runner.dialogue_finished.connect(_on_dialogue_finished)
	director.scare_onset.connect(_on_scare_onset)
	director.scare_finished.connect(_on_scare_finished)
	mixer.timeline_event.connect(_on_timeline_event)
	mixer.set_track(TrackMixer.Track.LINEAR)
	mixer.apply_layers(level)
	if bot:
		ff = float(data.get("bot_ff", 20.0))
		_max_frames = int(data.get("bot_max_frames", _max_frames))
		_bot_loops = int(data.get("bot_loops", _bot_loops))
	var args := OS.get_cmdline_user_args()
	if bot or "--reel" in args:
		# Bot runs and reels keep their save in memory, like meta.*: the player's save stays as it is.
		_save_path = ""
		_begin_game()
	else:
		_show_title()
	var at := args.find("--reel")
	if at >= 0 and at + 1 < args.size():
		reel = ProtoReel.new()
		add_child(reel)
		if not reel.start(self, args[at + 1]):
			reel.queue_free()
			reel = null


# --- Title, saves ----------------------------------------------------------------------


## The title screen: Continue (when there is a save), New Game, Options, Quit. Its title text comes
## from the level ("title": {"text", "sub"}); the menu words from the UI strings.
func _show_title() -> void:
	phase = Phase.TITLE
	player.frozen = true
	_show_hub_art(true)
	audio.enter_hub()
	ui.set_hub("")
	_title_options = (["continue"] if not _read_save().is_empty() else []) + ["new_game", "options", "quit"]
	_title_selected = 0
	_draw_title()


func _draw_title() -> void:
	var cfg: Dictionary = data.get("title", {})
	var labels: Array = _title_options.map(func(o): return tr("ui.title." + o))
	ui.show_title(String(cfg.get("text", "")), String(cfg.get("sub", "")), labels, _title_selected)


func _title_cmd(cmds: Array) -> void:
	if cmds.has("menu_up") or cmds.has("menu_down"):
		_title_selected = wrapi(_title_selected + (-1 if cmds.has("menu_up") else 1), 0, _title_options.size())
		_draw_title()
	elif cmds.has("cancel") and _title_options.has("confirm_yes"):
		_show_title()
	elif cmds.has("accept"):
		match String(_title_options[_title_selected]):
			"continue":
				ui.hide_title()
				_continue_game()
			"new_game":
				if not _read_save().is_empty():
					# A new game overwrites the save at its first workroom visit: ask first.
					_title_options = ["confirm_no", "confirm_yes"]
					_title_selected = 0
					ui.show_title("", tr("ui.title.confirm_new"), _title_options.map(func(o): return tr("ui." + o.replace("confirm_", "common."))), 0)
					return
				_start_new_game()
			"confirm_yes":
				_start_new_game()
			"confirm_no":
				_show_title()
			"options":
				settings.open()
			"quit":
				get_tree().quit(0)


func _start_new_game() -> void:
	ui.hide_title()
	runner.new_game()
	_notice_ready = false
	ui.notices.clear()
	journal.reset()
	backlog.clear()
	_begin_game()


## The pause menu (Esc during play): Resume, Options, Back to Title. The game waits while it is open.
func _open_pause() -> void:
	_paused = true
	_pause_selected = 0
	# The workroom text and the debug line would show through the menu.
	_pause_hub_text = ui.hub_text()
	ui.set_hub("")
	ui.set_hud("")
	_draw_pause()


func _draw_pause() -> void:
	ui.show_title(tr("ui.pause.title"), "", PAUSE_OPTIONS.map(func(o): return tr("ui.pause." + o)), _pause_selected, true)


func _pause_cmd(cmds: Array) -> void:
	if cmds.has("menu_up") or cmds.has("menu_down"):
		_pause_selected = wrapi(_pause_selected + (-1 if cmds.has("menu_up") else 1), 0, PAUSE_OPTIONS.size())
		_draw_pause()
	elif cmds.has("cancel") or cmds.has("pause"):
		_close_pause()
	elif cmds.has("accept"):
		match String(PAUSE_OPTIONS[_pause_selected]):
			"resume":
				_close_pause()
			"journal":
				_open_journal("pause")
			"log":
				_open_log("pause")
			"options":
				settings.open()
			"to_title":
				# Progress since the last workroom visit is not kept (the save is made there).
				get_tree().reload_current_scene()


func _close_pause() -> void:
	_paused = false
	ui.hide_title()
	ui.set_hub(_pause_hub_text)


## A new game: the start document (content warning) if there is one, then the workroom.
func _begin_game() -> void:
	var start_docs: Array = data.get("hub", {}).get("start_docs", [])
	if not start_docs.is_empty() and not runner.get_doc(String(start_docs[0])).is_empty():
		phase = Phase.HUB
		_show_hub_art(true)
		audio.enter_hub()
		_show_doc(String(start_docs[0]), func(): _enter_hub(true))
	else:
		_enter_hub(true)


func _continue_game() -> void:
	var state := _read_save()
	if state.is_empty() or not _restore(state):
		runner.new_game()
		_begin_game()
		return
	_log("continue")
	backlog.clear()  # the log is not saved
	_enter_hub(false)


## Saves at the start of every workroom visit (before its dialogues run), so Continue comes back to
## the last workroom: between tapes, and before the choice that ends the game.
func _autosave() -> void:
	var state := {"format": SAVE_FORMAT, "story": runner.serialize_save(),
		"track": ["hifi", "linear", "mix"][int(mixer.get_track())], "journal": journal.store()}
	ui.notices.saving()
	if _save_path == "":
		_memory_save = JSON.parse_string(JSON.stringify(state))  # the same round trip as a file
		return
	var f := FileAccess.open(_save_path, FileAccess.WRITE)
	if f == null:
		push_warning("ProtoGame: cannot write %s" % _save_path)
		return
	f.store_string(JSON.stringify(state))


func _read_save() -> Dictionary:
	if _save_path == "":
		return _memory_save
	if not FileAccess.file_exists(_save_path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(_save_path))
	if typeof(parsed) != TYPE_DICTIONARY or int(parsed.get("format", 0)) != SAVE_FORMAT:
		push_warning("ProtoGame: ignoring unreadable save %s" % _save_path)
		return {}
	return parsed


func _restore(state: Dictionary) -> bool:
	if not runner.restore_save(state.get("story", {})):
		return false
	mixer.set_track(_track_named(String(state.get("track", "linear"))))
	journal.restore(state.get("journal", {}))
	_notice_ready = false
	return true


## The bot loads its own save once (at the second workroom visit) and checks that the story state
## comes back unchanged, so the smoke test covers saving and loading.
func _bot_reload_check() -> bool:
	if not bot or _bot_reloaded or _stats["loops"] < 1 or _memory_save.is_empty():
		return false
	_bot_reloaded = true
	var before := JSON.stringify(runner.serialize_save())
	runner.new_game()
	if not _restore(_memory_save) or JSON.stringify(runner.serialize_save()) != before:
		push_error("ProtoGame: the story state changed in a save and load")
	_log("save round trip")
	return true


# --- Phases --------------------------------------------------------------------------


func _enter_hub(first: bool) -> void:
	phase = Phase.HUB
	player.frozen = true
	ui.set_darkness(0.0)
	_show_hub_art(true)
	audio.enter_hub()
	_autosave()
	if _bot_reload_check():
		_enter_hub(false)
		return
	var hub: Dictionary = data.get("hub", {})
	_hub_queue = (hub.get("start", []) if first else []) + hub.get("between", [])
	_run_hub_queue()


func _run_hub_queue() -> void:
	var hub_scares: Dictionary = data.get("hub", {}).get("scares", {})
	while not _hub_queue.is_empty():
		var entry: Variant = _hub_queue.pop_front()
		if typeof(entry) == TYPE_DICTIONARY:
			# A document found in the workroom: collect it once and show it, then go on.
			var doc_id: String = String(entry.get("doc", ""))
			if doc_id == "" or runner.is_doc_collected(doc_id) or not _requirements_met(entry):
				continue
			_collect_doc(doc_id)
			_show_doc(doc_id, _run_hub_queue)
			return
		var id: String = String(entry)
		if not runner.is_available(id):
			continue
		var scare: String = String(hub_scares.get(id, ""))
		if scare != "" and director.has_scare(scare):
			director.trigger(scare)  # the scare's after_dialogue starts `id`
		else:
			runner.start(id)
		return
	_show_hub_prompt()


func _show_hub_prompt() -> void:
	var text := tr("ui.hub.counter").format({"n": int(runner.get_flag("sys.loop_count"))}) + "\n" + input.fill(tr("ui.hub.play"))
	if _board_ready():
		text += "\n" + input.fill(tr("ui.board.open"))
	if journal.has_docs():
		text += "\n" + input.fill(tr("ui.hub.journal"))
	for action in _hub_actions_ready():
		# {key}: the action's own letter on the keyboard, the workroom button on a gamepad.
		var key_name := input.label("workroom_action") if input.device == "pad" else String(action.get("key", ""))
		text += "\n" + input.fill(tr(String(action.get("prompt", "")))).replace("{key}", "[%s]" % key_name)
	if _paused:
		_pause_hub_text = text  # shown again when the pause menu closes
		return
	ui.set_hub(text)


## Workroom actions ("hub": {"actions": [{key, dialogue, requires, prompt, bot}]}): a key that opens
## a dialogue between tapes, for example closing out the job early. They wait like the board.
func _hub_actions_ready() -> Array:
	var ready: Array = []
	if phase != Phase.HUB or runner.is_running() or ui.doc_open() or director.is_busy() or not _hub_queue.is_empty():
		return ready
	for action in data.get("hub", {}).get("actions", []):
		if _requirements_met(action) and runner.is_available(String(action.get("dialogue", ""))):
			ready.append(action)
	return ready


func _hub_action(action: Dictionary) -> void:
	ui.set_hub("")
	_log("hub action " + String(action.get("key", "")))
	runner.start(String(action.get("dialogue", "")))


## The board opens in the workroom between dialogues once its "requires" flags are on.
func _board_ready() -> bool:
	return board != null and phase == Phase.HUB and board.available() and not runner.is_running() \
		and not ui.doc_open() and not director.is_busy() and _hub_queue.is_empty()


func _open_board() -> void:
	ui.set_hub("")
	board.open()
	_log("board %d/%d" % [board.found_count(), board.cfg.get("cards", []).size()])


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
	ui.deck.open()  # the deck shows itself as the tape starts
	ui.set_hub("")
	_show_hub_art(false)
	mixer.rewind()
	audio.enter_tape()
	audio.play("tape_start")
	_done.clear()
	_events.clear()
	_chaser_on = false
	_catching = false
	_chaser_flag_started = false
	_scare_on = ""
	player.pose_override = ""
	_chaser.visible = false
	_reset_escorts()
	ui.set_darkness(0.0)
	_water_rise.clear()
	_water_barked.clear()
	for i in level.water_zones.size():
		_water_rise.append(0.0)
		_water_barked.append(false)
	var start: Array = data.get("player_start", [100, 600])
	player.global_position = Vector2(float(start[0]), float(start[1]))
	player.velocity = Vector2.ZERO
	_last_safe = player.global_position
	player.frozen = false
	if not _hifi_unlocked():
		mixer.set_track(TrackMixer.Track.LINEAR)
	# The story cleared loop.* flags when the last loop ended; a loop that starts on the same
	# track needs its track flags written again.
	mixer.sync_flags()
	mixer.apply_layers(level)
	_apply_tint()


func _end_loop() -> void:
	_log("loop end")
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
	# "end_docs": [{doc, requires}] — the first document whose flags hold is shown before the end
	# (an ending's title card, credits).
	for entry in data.get("end_docs", []):
		var doc_id: String = String(entry.get("doc", ""))
		if _requirements_met(entry) and not runner.get_doc(doc_id).is_empty():
			_collect_doc(doc_id)
			_show_doc(doc_id, _end_card)
			return
	_end_card()


func _end_card() -> void:
	# "credits": {doc, secs} rolls a document before the last card (Enter or Esc skips it).
	var credits: Dictionary = data.get("credits", {})
	var doc := runner.get_doc(String(credits.get("doc", "")))
	if not doc.is_empty() and not ui.credits_running():
		_log("credits")
		ui.roll_credits(doc, float(credits.get("secs", 40.0)), _end_text)
		return
	_end_text()


func _end_text() -> void:
	ui.set_hub("END OF SLICE\n[Enter] title")
	if bot:
		_finish_bot("complete")


# --- Frame -----------------------------------------------------------------------------


func _process(delta: float) -> void:
	_stats["frames"] += 1
	var reel_on := reel != null and reel.running
	if reel_on:
		reel.tick(delta)
	if settings.is_open() or (board != null and board.is_open()) or _paused or journal.is_open() \
			or backlog.is_open() or _journal_reading:
		# The settings screen and the board pause the tape, the player and the scare clock.
		player.frozen = true
		return
	director.tick(delta)
	_animate_cut(delta)
	# Nothing new moves on screen while a scare is pending or playing.
	ui.notices.held = director.is_quiet() or director.is_busy()
	_watch_notices()
	if not bot and not reel_on:
		_auto_advance(delta)
	if phase == Phase.TAPE:
		var talking := runner.is_running() or ui.doc_open()
		player.frozen = talking or _catching
		# Fast-forward pauses while a scare is pending or relaxing: the director runs in real
		# time, so a sped-up tape would push the next scare past its moment.
		if settings.ff_hold() and not bot and not reel_on:
			ff = 4.0 if Input.is_action_pressed("ff") else 1.0
		var speed := 1.0 if director.is_busy() or director.is_relaxing() else ff
		mixer.tick(0.0 if talking else delta * speed * _tape_scale())
		_keep_in_level()
		if not reel_on:
			_check_triggers()
		_update_chaser(delta)
		level.update_backdrop(player.camera().get_screen_center_position().x, player.camera().zoom.x)
		audio.update(mixer.tape_time(), _events)
		_footsteps(delta)
		_update_water(delta)
		_update_escorts(delta)
		level.update_flag_props(func(f): return runner.get_flag(f) == true)
		if mixer.tape_time() >= float(data.get("tape", {}).get("length", 7200.0)) and not reel_on:
			_end_loop()
	var tc := _update_camera()
	if reel_on or phase == Phase.TITLE or not _debug_hud:
		ui.set_hud("")
	else:
		_update_hud(tc)
	_update_deck()
	if bot and not reel_on:
		_bot_step(delta)
		if _stats["frames"] > _max_frames:
			_finish_bot("frame limit")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		return
	var cmds := input.commands(event)
	# The controls screen waiting for a new binding needs every key and button, even unbound ones.
	if settings.is_open() and (not cmds.is_empty() or event is InputEventKey or event is InputEventJoypadButton):
		settings.handle(cmds, event)
		return
	if cmds.is_empty():
		return
	_command(cmds, event as InputEventKey)


## One press of one or more input actions (see ProtoInput.ACTIONS). `key` is the key event when the
## press came from the keyboard, for the workroom actions' own letter keys.
func _command(cmds: Array, key: InputEventKey = null) -> void:
	if ui.credits_running():
		if cmds.has("accept") or cmds.has("cancel"):
			ui.skip_credits()
		return
	if settings.handle(cmds):
		return
	if phase == Phase.TITLE:
		_title_cmd(cmds)
		return
	if phase == Phase.END and not ui.doc_open() and cmds.has("accept"):
		get_tree().reload_current_scene()  # back to the title; Continue returns to the last workroom
		return
	if board != null and board.handle(cmds):
		return
	if journal.handle(cmds) or backlog.handle(cmds):
		return
	if _journal_reading:
		if cmds.has("accept") or cmds.has("interact") or cmds.has("cancel"):
			_close_doc()
		return
	if (cmds.has("journal") or cmds.has("log")) and _menus_allowed():
		if cmds.has("journal"):
			_open_journal("")
		else:
			_open_log("")
		return
	if cmds.has("board") and _board_ready():
		_open_board()
		return
	var hub_actions := _hub_actions_ready()
	for action in hub_actions:
		if key != null and key.keycode == OS.find_keycode_from_string(String(action.get("key", ""))):
			_hub_action(action)
			return
	if cmds.has("workroom_action") and not hub_actions.is_empty():
		_hub_action(hub_actions[0])
		return
	if _paused:
		_pause_cmd(cmds)
		return
	if cmds.has("pause"):
		if phase in [Phase.HUB, Phase.TAPE]:
			_open_pause()
		else:
			settings.open()
		return
	var talking := ui.doc_open() or runner.is_running()
	if talking and (cmds.has("accept") or cmds.has("interact")):
		if ui.doc_open():
			_close_doc()
		elif _choices.is_empty():
			runner.advance()
		else:
			_choose(_selected)
		return
	if not talking and phase == Phase.HUB and cmds.has("accept") and not director.is_busy():
		_on_play()
		return
	if not talking and phase == Phase.TAPE and cmds.has("interact") and _prompt_here != "":
		_interact_pressed = true
		return
	if not _choices.is_empty() and (cmds.has("menu_up") or cmds.has("menu_down")):
		_move_selection(-1 if cmds.has("menu_up") else 1)
		return
	for i in 4:
		if cmds.has("choose_%d" % (i + 1)):
			_choose(i)
			return
	if cmds.has("track_linear"):
		_set_track(TrackMixer.Track.LINEAR)
	elif cmds.has("track_hifi"):
		_set_track(TrackMixer.Track.HIFI)
	elif cmds.has("track_mix"):
		_set_track(TrackMixer.Track.MIX)
	elif cmds.has("rec"):
		player.recording = not player.recording
	elif cmds.has("ff") and not settings.ff_hold():
		ff = 1.0 if ff > 1.0 else 4.0
	elif cmds.has("debug_scare_mode"):
		settings.set_value("scare_mode", (int(director.mode) + 1) % 3)
		ui.notices.push("info", "%s: %s" % [tr("ui.options.scare_mode"),
			tr(["ui.options.scare_default", "ui.options.scare_soft", "ui.options.scare_off"][int(director.mode)])])
	elif cmds.has("debug_photosafe"):
		settings.set_value("photosafe", 0 if director.photosafe else 1)
		ui.notices.push("info", "%s: %s" % [tr("ui.options.reduce_flashing"), tr("ui.options.on" if director.photosafe else "ui.options.off")])


## Mouse: menus and the settings screen take hover and clicks, a left click elsewhere advances
## dialogue or closes a document, hovering a choice selects it and clicking it picks it, a right
## click is cancel. Handled before the GUI so the dialogue window does not swallow the click.
func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton or event is InputEventMouseMotion) or reel != null:
		return
	input.commands(event)  # notes that the player is on keyboard and mouse
	if settings.mouse(event):
		get_viewport().set_input_as_handled()
		return
	if journal.is_open() or backlog.is_open():
		# The wheel is left to the lists' scroll containers.
		if journal.mouse(event) or backlog.mouse(event):
			get_viewport().set_input_as_handled()
		return
	var button := event as InputEventMouseButton
	var pos: Vector2 = (event as InputEventMouse).position
	if button != null and not button.pressed:
		return
	if button != null and button.button_index == MOUSE_BUTTON_RIGHT:
		_command(["cancel"])
		get_viewport().set_input_as_handled()
		return
	var left := button != null and button.button_index == MOUSE_BUTTON_LEFT
	var item := ui.menu_item_at(pos)
	if item >= 0 and (phase == Phase.TITLE or _paused):
		if phase == Phase.TITLE:
			_title_selected = item
			_draw_title()
		else:
			_pause_selected = item
			_draw_pause()
		if left:
			_command(["accept"])
		get_viewport().set_input_as_handled()
		return
	var choice := ui.choice_at(pos)
	if choice >= 0 and not _choices.is_empty():
		if choice != _selected:
			_selected = choice
			ui.show_choices(_choices, _selected)
		if left:
			_choose(choice)
		get_viewport().set_input_as_handled()
		return
	if left and (ui.credits_running() or ui.doc_open() or runner.is_running() or phase in [Phase.HUB, Phase.END]):
		if board != null and board.visible:
			return
		_command(["accept"])
		get_viewport().set_input_as_handled()


## Hints that name keys follow the device the player used last.
func _refresh_hints() -> void:
	ui.next_hint = input.fill(tr("ui.dialogue.next_hint"))
	ui.choice_hint = input.fill(tr("ui.dialogue.choice_hint" if input.device == "pad" else "ui.dialogue.choice_hint_keys"))
	# Redraw only what is on screen now: the workroom list, the interaction prompt.
	if phase == Phase.HUB and ui.hub_text() != "":
		_show_hub_prompt()
	_prompt_shown = ""
	_show_prompt()


# --- Story and scares ----------------------------------------------------------------------


func _on_line(id: String, speaker: String, _expression: String, attrs: Dictionary, text: String) -> void:
	_stats["lines"] += 1
	_choices.clear()
	if not _cut_cfg.is_empty():
		_cut_lines[id] = text
		_apply_cut()
	# Meta outputs: the runtime replaces them with stand-ins unless the player allowed them
	# (attrs.target). The prototype changes the real window title when allowed and draws the
	# other two inside the game either way.
	var target: String = String(attrs.get("target", ""))
	var requested: String = String(attrs.get("requested_target", target))
	if target == "notice":
		# [to=notice]: a notice instead of a dialogue line, and the dialogue goes straight on (a reel
		# keeps its own pace).
		ui.notices.push("info", text)
		backlog.add_line(_play_count(), _tape_at(), "", text, "caption")
		if reel == null or not reel.running:
			runner.advance.call_deferred()
		return
	var kind := ""
	if target == "fake_os_dialog" or target == "os_dialog":
		kind = "os"
	elif requested == "window_title":
		kind = "title"
		if target == "window_title":
			DisplayServer.window_set_title(text)
	elif target == "journal_note" or target == "desktop_file":
		kind = "note"
	ui.show_line(String(attrs.get("display_name", speaker)), text, kind)
	backlog.add_line(_play_count(), _tape_at(), String(attrs.get("display_name", speaker)), text)
	# Auto-advance (a setting) waits as long as the line takes to read; up to 12 seconds, since a
	# dialogue window line can be three times as long as a caption.
	_auto_left = ProtoUI.reading_secs(text, 0.6, 0.06, 1.5, 12.0) * settings.advance_factor() \
		if settings.auto_advance() else -1.0
	# Some voices have no body on screen; a soft waveform stands in for them.
	ui.set_voice(speaker in _voice_speakers)


## Auto-advance: once the line has been on screen long enough, the next one. Never past choices
## or an open document, and the clock stops while a menu is open (_process returns before this).
func _auto_advance(delta: float) -> void:
	if _auto_left <= 0.0 or not runner.is_running() or not _choices.is_empty() or ui.doc_open():
		return
	_auto_left -= delta
	if _auto_left <= 0.0:
		_auto_left = -1.0
		runner.advance()


func _on_choices(options: Array) -> void:
	_choices = options
	_auto_left = -1.0  # choices always wait for the player
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
	if _doc_notice != "":
		ui.notices.push("doc", tr("ui.notice.doc").format({"title": String(runner.get_doc(_doc_notice).get("title", ""))}))
		_doc_notice = ""
	var then := _after_doc
	_after_doc = Callable()
	if then.is_valid():
		then.call()


func _choose(index: int) -> void:
	if index < 0 or index >= _choices.size() or not _choices[index]["enabled"]:
		return
	backlog.add_line(_play_count(), _tape_at(), "", String(_choices[index]["text"]), "choice")
	_choices.clear()
	runner.choose(index)


func _on_dialogue_started(id: String) -> void:
	_bot_menus.clear()
	backlog.add_scene(_play_count(), _tape_at())
	_stats["dialogues"] += 1
	_log("dialogue " + id)
	# Art "cuts": {dialogue_id: {"texture", "frame", "when"}} shows a picture while that dialogue plays.
	_cut_cfg = art.cfg.get("cuts", {}).get(id, {}) if art.enabled() else {}
	_cut_lines.clear()
	_cut_shown = {}
	_apply_cut()


## Picks the dialogue's picture: the last "when" entry ({from_line, requires, texture, frame}) whose
## line has been shown and whose flags hold, else the entry itself. Checked again on every line, so
## the picture can change halfway (a close-up, then the wide shot; the camera switched off).
func _apply_cut() -> void:
	if _cut_cfg.is_empty():
		ui.set_cut(null)
		return
	var pick: Dictionary = _cut_cfg
	for alt in _cut_cfg.get("when", []):
		if (not alt.has("from_line") or _cut_lines.has(String(alt["from_line"]))) and _requirements_met(alt):
			pick = alt
	if pick == _cut_shown:
		return
	_cut_shown = pick
	_cut_anim.clear()
	if bool(pick.get("none", false)):
		ui.set_cut(null)  # no picture from here on
		return
	ui.set_cut_text("", {})
	var texture: String = String(pick.get("texture", ""))
	for f in pick.get("frames", []):
		_cut_anim.append(art.frame(texture, String(f)))
	_cut_anim_fps = float(pick.get("fps", 2.0))
	_cut_anim_t = 0.0
	ui.set_cut(_cut_anim[0] if not _cut_anim.is_empty() else art.frame(texture, String(pick.get("frame", ""))))
	# "text": {rect, size, color, fill} writes the text of the entry's own line on the picture
	# (a headline that changes with the player's choices), in the picture's pixels.
	if pick.has("text"):
		ui.set_cut_text(String(_cut_lines.get(String(pick.get("from_line", "")), "")), pick["text"])


## "frames": [names] with "fps" turns a cut into a short loop (a counter ticking over).
func _animate_cut(delta: float) -> void:
	if _cut_anim.size() < 2:
		return
	var before := int(_cut_anim_t * _cut_anim_fps)
	_cut_anim_t += delta
	var now := int(_cut_anim_t * _cut_anim_fps)
	if now != before:
		ui.set_cut(_cut_anim[now % _cut_anim.size()])


func _on_dialogue_finished(_id: String) -> void:
	_auto_left = -1.0
	_cut_cfg = {}
	_cut_anim.clear()
	ui.set_cut(null)
	ui.hide_window()
	ui.set_voice(false)
	_choices.clear()
	if reel != null and reel.running:
		return  # the reel decides what comes next
	# A dialogue that hands over to another ("=> ~id") finishes before the next one starts; decide
	# what comes next once that has happened.
	_after_dialogue.call_deferred()


func _after_dialogue() -> void:
	if runner.is_running():
		return
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
	_scare_on = id
	_log("scare " + id)
	_stats["scares"] += 1
	fx.onset(id, info)
	var cue: String = String(info.get("cue", ""))
	if cue != "":
		_play_cue(cue)


func _on_scare_finished(id: String) -> void:
	if _scare_on == id:
		_scare_on = ""
	# Level data can wait for a scare to end ("requires": ["loop.scare_done_<id>"]).
	runner.set_flag("loop.scare_done_" + id, true)
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
	_prompt_here = ""
	if runner.is_running() or _catching or ui.doc_open():
		_show_prompt()
		return
	_apply_rules()
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
		if not _requirements_met(tr):
			continue
		if bool(tr.get("interact", false)):
			# No prompt when pressing would do nothing (no dialogue of the list can start).
			if tr.has("dialogue") and runner.pick(tr["dialogue"]) == "":
				continue
			_prompt_here = String(tr.get("prompt", "ui.prompt.examine"))
			if not _interact_pressed:
				continue
			_interact_pressed = false
		if _fire(tr):
			_stats["triggers"] += 1
			# "repeat": true keeps a trigger (a door) usable again in the same loop.
			if not bool(tr.get("repeat", false)):
				_done[id] = true
			_log("trigger " + id)
			if tr.has("mark"):
				runner.set_flag(String(tr["mark"]), true)
		if runner.is_running():
			break
	_interact_pressed = false
	_show_prompt()


func _fire(tr: Dictionary) -> bool:
	if tr.has("sfx"):
		audio.play(String(tr["sfx"]))
	if bool(tr.get("end_loop", false)):
		# The tape is over for this loop (for example rewound once the story has reached its end).
		_end_loop.call_deferred()
		return true
	if tr.has("set_track"):
		_set_track(_track_named(String(tr["set_track"])), true)
	if tr.has("warp"):
		# A door: move the player to [x, y] (for example into a room built elsewhere in the level).
		var to: Array = tr["warp"]
		player.global_position = Vector2(float(to[0]), float(to[1]))
		player.velocity = Vector2.ZERO
		_last_safe = player.global_position
		player.camera().reset_smoothing()
		return true
	if tr.has("set_flag"):
		runner.set_flag(String(tr["set_flag"]), true)
		return true
	if tr.has("rec_flag"):
		runner.set_flag(String(tr["rec_flag"]), true)
		# A board card on this flag gets its own notice (_watch_notices).
		if not _is_card_flag(String(tr["rec_flag"])):
			ui.notices.push("rec", tr("ui.notice.rec"))
		return true
	if tr.has("scare"):
		return director.trigger(String(tr["scare"]))
	if tr.has("doc"):
		_collect_doc(String(tr["doc"]))
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
			_play_cue(String(cues[key]))
			return true
		return false
	if tr.has("dialogue"):
		var id := runner.pick(tr["dialogue"])
		if id != "":
			runner.start(id)
			return true
	return false


## Level "requires": flags that must be true; a leading "!" means it must not be true.
## Works for any trigger or hub entry; seen.* flags are allowed.
func _requirements_met(entry: Dictionary) -> bool:
	for f in entry.get("requires", []):
		var name: String = String(f)
		var negate := name.begins_with("!")
		if negate:
			name = name.substr(1)
		var on: bool
		var eq := name.find("=")
		if eq > 0:
			# "flag=value" compares a number or text flag, for example "save.ending=5".
			on = str(runner.get_flag(name.substr(0, eq))) == name.substr(eq + 1)
		else:
			on = runner.get_flag(name) == true
		if on == negate:
			return false
	return true


## Level "rules": {"all": [flags], "set": flag} turns a flag on once all the others are on.
func _apply_rules() -> void:
	for rule in data.get("rules", []):
		var target: String = String(rule.get("set", ""))
		if target == "" or runner.get_flag(target) == true:
			continue
		var all_on := true
		for f in rule.get("all", []):
			if runner.get_flag(String(f)) != true:
				all_on = false
				break
		if all_on:
			runner.set_flag(target, true)


func _show_prompt() -> void:
	if _prompt_here == _prompt_shown:
		return
	_prompt_shown = _prompt_here
	ui.set_prompt(tr(_prompt_here) + "  " + input.fill("{interact}") if _prompt_here != "" else "")


## Rising water ("rising_water"): while the player stays in the zone on its track (HI-FI by default)
## the water climbs `rate` px/s up to `max_rise`; elsewhere it falls back. On other tracks it stands
## at `linear_y`. Going under puts the player back at `respawn` and lets the water fall again.
func _update_water(delta: float) -> void:
	var feet := player.global_position
	for i in level.water_zones.size():
		var cfg: Dictionary = level.water_zones[i]["cfg"]
		var inside := feet.x >= float(cfg["x0"]) and feet.x <= float(cfg["x1"])
		# A zone with "after_event" / "requires" floods only once those hold (otherwise it stays at
		# its linear_y, as on the other track).
		var on_track := _track_is(String(cfg.get("track", "hifi"))) and _zone_active(cfg)
		var rise: float = _water_rise[i]
		if on_track and inside and not runner.is_running() and not ui.doc_open():
			rise = minf(rise + float(cfg.get("rate", 4.0)) * delta, float(cfg.get("max_rise", 120.0)))
		elif not inside:
			rise = maxf(rise - float(cfg.get("rate", 4.0)) * 4.0 * delta, 0.0)
		_water_rise[i] = rise
		var y := float(cfg.get("base_y", level.size.y)) - rise if on_track else float(cfg.get("linear_y", cfg.get("base_y", level.size.y)))
		level.set_zone_water(i, y)
		if on_track and not _water_barked[i] and rise >= float(cfg.get("bark_rise", 1e9)):
			_water_barked[i] = true
			var line := runner.bark(String(cfg.get("bark", "")))
			if not line.is_empty():
				ui.bubble(String(line.get("text", "")))
		if inside and feet.y > y + float(cfg.get("submerge", 24.0)):
			var spot: Array = cfg.get("respawn", [float(cfg["x0"]) - 40.0, float(cfg.get("linear_y", 800.0)) - 10.0])
			player.global_position = Vector2(float(spot[0]), float(spot[1]))
			player.velocity = Vector2.ZERO
			_last_safe = player.global_position
			_water_rise[i] = 0.0
			_water_barked[i] = false
			if _debug_hud:
				ui.toast("RESPAWN")


func _zone_active(cfg: Dictionary) -> bool:
	if cfg.has("after_event") and not _events.has(String(cfg["after_event"])):
		return false
	return _requirements_met(cfg)


## Falling below the level (into the water) puts the player back on the last safe ground.
func _keep_in_level() -> void:
	if player.is_on_floor():
		_last_safe = player.global_position
	elif player.global_position.y > level.size.y + 60.0:
		player.global_position = _last_safe
		player.velocity = Vector2.ZERO
		if _debug_hud:
			ui.toast("RESPAWN")


func _update_chaser(delta: float) -> void:
	# "start_flag" / "stop_flag": a chase that a flag starts (once per loop, "start_offset" from the
	# player) and another flag ends.
	var chaser_cfg: Dictionary = data.get("chaser", {})
	var stop_flag: String = String(chaser_cfg.get("stop_flag", ""))
	if _chaser_on and stop_flag != "" and runner.get_flag(stop_flag) == true:
		_chaser_on = false
		_chaser.visible = false
	var start_flag: String = String(chaser_cfg.get("start_flag", ""))
	if not _chaser_on and not _catching and not _chaser_flag_started and start_flag != "" \
			and runner.get_flag(start_flag) == true and not runner.is_running() \
			and (stop_flag == "" or runner.get_flag(stop_flag) != true):
		_chaser_flag_started = true
		_chaser_on = true
		_chaser.position = player.global_position + Vector2(float(chaser_cfg.get("start_offset", -360)), -56)
	if not _chaser_on or _catching:
		return
	var linear := mixer.get_track() == TrackMixer.Track.LINEAR
	_chaser.visible = linear
	# It holds still while a scare is on screen, so a player startled by one is not caught for it.
	if not linear or runner.is_running() or _scare_on != "":
		return
	var target := player.global_position + Vector2(-18, -56)
	var speed: float = float(data.get("chaser", {}).get("speed", 150.0)) * settings.chase_speed_factor()
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


## Why the player cannot switch to `track` now: "" (they can), "locked" (the story has not unlocked
## it yet) or "held" ("locks": [{"requires": [...], "allow": ["linear", "mix"]}] keeps the player
## off it while the flags hold).
func _track_block(track: TrackMixer.Track) -> String:
	var tracks: Dictionary = data.get("tracks", {})
	var track_name: String = ["hifi", "linear", "mix"][int(track)]
	for lock in tracks.get("locks", []):
		if _requirements_met(lock) and not lock.get("allow", []).has(track_name):
			return "held"
	if track == TrackMixer.Track.HIFI and not _hifi_unlocked():
		return "locked"
	if track == TrackMixer.Track.MIX and runner.get_flag(String(tracks.get("mix_flag", "save.mix_unlocked"))) != true:
		return "locked"
	return ""


## A trigger's "set_track" is forced and ignores locks and unlocks. A blocked switch says why and
## marks the switch on the deck.
func _set_track(track: TrackMixer.Track, forced: bool = false) -> void:
	if not forced:
		var block := _track_block(track)
		if block != "":
			ui.notices.push("track", tr("ui.deck.held" if block == "held" else "ui.deck.locked").format({"track": ProtoDeck.NAMES[track]}))
			ui.deck.warn(track)
			return
	mixer.set_track(track)
	mixer.apply_layers(level)
	_apply_tint()


## LINEAR reads as the staged broadcast night, HI-FI as the real one by the water.
## With art the palettes do this (art block "palettes": linear, hifi) and the badge follows. MIX
## keeps the LINEAR colours and ProtoScreen lays the HI-FI picture over them; without that
## (no shader), the world is drawn halfway to the HI-FI palette instead.
func _apply_tint() -> void:
	if art.enabled():
		_tint.color = Color.WHITE
		var key: String = ["hifi", "linear", "mix"][mixer.get_track()]
		if key != "mix":
			art.set_palette(key)
		elif screen.mix_available():
			art.set_palette("linear")
		else:
			art.set_palette("hifi", 0.5)
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


## The camera overlay: timecode, REC and the camera switched off. Runs in reel mode too.
func _update_camera() -> String:
	var t := int(mixer.tape_time())
	var tc := "%02d:%02d:%02d" % [t / 3600, (t / 60) % 60, t % 60]
	ui.set_timecode(tc)
	# art "viewfinder": {"off_flag": ...} — once the camera is switched off for good, no viewfinder.
	var off_flag: String = String(art.cfg.get("viewfinder", {}).get("off_flag", "")) if art.enabled() else ""
	var camera_off: bool = off_flag != "" and runner.get_flag(off_flag) == true
	ui.set_camera_off(camera_off)
	# The tape texture goes with the camera (its own "vhs" off_flag when the art block names one).
	screen.set_vhs(screen.vhs_off_flag == "" or runner.get_flag(screen.vhs_off_flag) != true)
	screen.set_still(director.photosafe)
	if camera_off:
		player.recording = false
	ui.set_recording(player.recording)
	if player.recording != _last_rec:
		_last_rec = player.recording
		audio.play("rec_on" if player.recording else "rec_off")
	return tc


## The deck panel: off on the title and after the ending, open in the workroom.
func _update_deck() -> void:
	ui.deck_mode = "off" if phase == Phase.TITLE or phase == Phase.END else ("hub" if phase == Phase.HUB else "tape")
	var blocked := {}
	for t in [TrackMixer.Track.HIFI, TrackMixer.Track.LINEAR, TrackMixer.Track.MIX]:
		blocked[t] = _track_block(t)
	ui.deck.show_state(mixer.get_track(), blocked, int(runner.get_flag("sys.loop_count")), ff)


# --- Journal and dialogue log ---------------------------------------------------------------


func _play_count() -> int:
	return int(runner.get_flag("sys.loop_count"))


## Tape seconds now, or -1 outside the tape (the workroom).
func _tape_at() -> int:
	return int(mixer.tape_time()) if phase == Phase.TAPE else -1


## Collects a document and notes for the journal when it was found. Its notice shows once the
## document (opened right after) is closed.
func _collect_doc(doc_id: String) -> void:
	if runner.collect_doc(doc_id):
		journal.found(doc_id, _tape_at())
		if phase != Phase.END:
			_doc_notice = doc_id


## Notices for what turned on since the last frame: a board card pinned, a knot untied, a track
## unlocked. The first look after a new game or a load only takes stock.
func _watch_notices() -> void:
	var now := {}
	if board != null:
		for card in board.cfg.get("cards", []):
			now["card:" + String(card.get("doc", ""))] = runner.get_flag(String(card.get("flag", ""))) == true
		for slot in board.cfg.get("knots", {}).get("slots", []):
			now["knot:" + String(slot.get("doc", ""))] = runner.get_flag(String(slot.get("flag", ""))) == true
	for t in [TrackMixer.Track.HIFI, TrackMixer.Track.MIX]:
		now["track:%d" % t] = _track_block(t) != "locked"
	if _notice_ready:
		for key: String in now:
			if now[key] and not _notice_state.get(key, false):
				_notice_for(key)
	_notice_state = now
	_notice_ready = true


func _notice_for(key: String) -> void:
	var kind := key.get_slice(":", 0)
	var what := key.substr(kind.length() + 1)
	match kind:
		"card", "knot":
			var title := String(runner.get_doc(what).get("title", ""))
			ui.notices.push(kind, tr("ui.notice." + kind).format({"title": title}))
		"track":
			ui.notices.push("track", tr("ui.notice.track").format({"track": ProtoDeck.NAMES[int(what)]}))


func _is_card_flag(flag: String) -> bool:
	if board == null:
		return false
	for card in board.cfg.get("cards", []):
		if String(card.get("flag", "")) == flag:
			return true
	return false


## A subtitle cue: on screen, and into the dialogue log.
func _play_cue(cue_id: String) -> void:
	var lines := runner.play_cue(cue_id)
	ui.play_cue(lines)
	for line in lines:
		backlog.add_line(_play_count(), _tape_at(), String(line["attrs"].get("display_name", "")), String(line.get("text", "")), "caption")


## The journal and the log open during play (also mid-dialogue), not over a document or a menu.
func _menus_allowed() -> bool:
	return phase in [Phase.HUB, Phase.TAPE] and not ui.doc_open() and not _paused and not ui.credits_running() \
		and not (board != null and board.is_open())


func _open_journal(from: String) -> void:
	_menu_return = from
	if from == "pause":
		ui.hide_title()
	journal.open()


func _open_log(from: String) -> void:
	_menu_return = from
	if from == "pause":
		ui.hide_title()
	backlog.open(_play_count())


func _on_menu_closed() -> void:
	if _menu_return == "pause" and _paused:
		_draw_pause()
	_menu_return = ""
	if phase == Phase.HUB and ui.hub_text() != "":
		_show_hub_prompt()


## The journal asked to read a document full size: the journal steps aside until it is closed.
func _read_from_journal(doc_id: String) -> void:
	journal.visible = false
	_journal_reading = true
	_show_doc(doc_id, func():
		_journal_reading = false
		journal.visible = true)


## The bot's walk through the journal (every tab, read one document full size) and the log.
func _bot_journal() -> void:
	_bot_tried_journal = true
	_open_journal("")
	for t in journal.tab_count():
		for cmd in ["menu_down", "menu_up", "tab_next"]:
			journal.command(cmd)
	journal.command("accept")
	if not _journal_reading or not ui.doc_open():
		push_error("journal: accept did not open the document")
	_close_doc()
	if not journal.is_open():
		push_error("journal: closing the document did not come back to the journal")
	journal.command("cancel")
	_open_log("")
	if backlog.row_count() == 0 and int(_stats["lines"]) > 0:
		push_error("log: lines were shown but the log is empty")
	for cmd in ["menu_up", "menu_left", "menu_right", "tab_prev", "tab_next", "accept", "cancel"]:
		backlog.command(cmd)
	if journal.is_open() or backlog.is_open() or _journal_reading:
		push_error("journal or log did not close")
	_log("journal %d docs, log %d rows" % [journal.docs_in_tab(0).size(), backlog.row_count()])


## The development status line at the top of the screen, with `-- --debug-hud` (never in reels).
func _update_hud(tc: String) -> void:
	var names := ["HI-FI", "LINEAR", "MIX"]
	var mode := ""
	if director.mode != ScareDirector.Mode.DEFAULT or director.photosafe:
		mode = "  SCARES %s%s" % [["DEFAULT", "SOFT", "OFF"][int(director.mode)], " PHOTOSAFE" if director.photosafe else ""]
	ui.set_hud("%s %s  TC %s  PLAY %d%s%s\n[Z]LIN [X]HIFI [C]MIX [R]REC [F]FF [M]SCARES [P]PHOTOSAFE [Esc]OPTIONS" % [
		"REC" if player.recording else "   ", names[mixer.get_track()], tc,
		int(runner.get_flag("sys.loop_count")), "  FF x%d" % int(ff) if ff > 1.0 else "", mode])


# --- Escorts, tape speed, tracks by name ---------------------------------------------------


func _track_named(track_name: String) -> TrackMixer.Track:
	return {"hifi": TrackMixer.Track.HIFI, "linear": TrackMixer.Track.LINEAR, "mix": TrackMixer.Track.MIX}.get(track_name, TrackMixer.Track.HIFI)


## "tape": {"slow": [{"requires": [...], "scale": 0.25}]} slows the tape while the flags hold
## (the last matching rule wins).
func _tape_scale() -> float:
	var scale := 1.0
	for rule in data.get("tape", {}).get("slow", []):
		if _requirements_met(rule):
			scale = float(rule.get("scale", 1.0))
	return scale


func _build_escorts() -> void:
	for cfg in data.get("escorts", []):
		var path: Array = cfg.get("path", [])
		if path.size() < 2:
			continue
		var ribbon := Line2D.new()
		var rib: Dictionary = cfg.get("ribbon", {})
		ribbon.width = float(rib.get("width", 6.0))
		ribbon.default_color = Color.html(String(rib.get("color", "d8d8d0")))
		for pt in path:
			ribbon.add_point(Vector2(float(pt[0]), float(pt[1])))
		ribbon.visible = false
		level.add_child(ribbon)
		var node := Node2D.new()
		node.visible = false
		var spec: Dictionary = cfg.get("sprite", {})
		var tex := art.frame(String(spec.get("sheet", "")), String(spec.get("frame", ""))) if art.enabled() and not spec.is_empty() else null
		if tex != null:
			var sprite := Sprite2D.new()
			sprite.texture = tex
			sprite.offset = Vector2(0, -tex.get_height() / 2.0)
			sprite.scale = Vector2.ONE * float(spec.get("scale", 1.0))
			node.add_child(sprite)
		else:
			var box := ColorRect.new()
			box.color = Color(0.86, 0.84, 0.78)
			box.size = Vector2(20, 14)
			box.position = Vector2(-10, -14)
			node.add_child(box)
		level.add_child(node)
		_escorts.append({"cfg": cfg, "node": node, "ribbon": ribbon, "index": 1, "done": false})
	_reset_escorts()


func _reset_escorts() -> void:
	for e in _escorts:
		var start: Array = e["cfg"]["path"][0]
		e["node"].position = Vector2(float(start[0]), float(start[1]))
		e["node"].visible = false
		e["ribbon"].visible = false
		e["index"] = 1
		e["done"] = false


## Moves each active escort along its path while the player keeps within "max_gap" pixels (it waits
## otherwise); at the end it sets "done_flag".
func _update_escorts(delta: float) -> void:
	for e in _escorts:
		var cfg: Dictionary = e["cfg"]
		var active: bool = _requirements_met(cfg) and not e["done"]
		e["ribbon"].visible = active or e["done"]
		e["node"].visible = active
		if not active or runner.is_running():
			continue
		var node: Node2D = e["node"]
		if absf(player.global_position.x - node.position.x) > float(cfg.get("max_gap", 180.0)):
			continue
		var path: Array = cfg["path"]
		var goal := Vector2(float(path[e["index"]][0]), float(path[e["index"]][1]))
		node.position = node.position.move_toward(goal, float(cfg.get("speed", 40.0)) * delta)
		if node.position.distance_to(goal) < 0.5:
			e["index"] += 1
			if e["index"] >= path.size():
				e["done"] = true
				node.visible = false
				if cfg.has("done_flag"):
					runner.set_flag(String(cfg["done_flag"]), true)
				_log("escort " + String(cfg.get("id", "")) + " done")


func _escort_x(id: String) -> float:
	for e in _escorts:
		if String(e["cfg"].get("id", "")) == id:
			return e["node"].position.x
	return player.global_position.x


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
				_choose(_bot_choice())
		return
	if phase == Phase.HUB and not _bot_tried_settings:
		# Exercise the settings screen once: move, change a value and change it back, close.
		_bot_tried_settings = true
		settings.open()
		# Every tab: move down, change a value and change it back, next tab (back to the first).
		for t in settings.tab_count():
			for cmd in ["menu_down", "menu_right", "menu_left", "tab_next"]:
				settings.command(cmd)
		# The tab bar: up from the first row, left to the last tab (controls), down into it.
		for cmd in ["menu_up", "menu_left", "menu_down"]:
			settings.command(cmd)
		if settings.current_tab() != settings.tab_index("controls"):
			push_error("settings: the tab bar did not reach the controls tab")
		# The controls screen: open it, start rebinding the first action and cancel, go back.
		for i in settings.remap_row_index():
			settings.command("menu_down")
		for cmd in ["accept", "menu_down", "accept", "cancel", "cancel", "cancel"]:
			settings.command(cmd)
		# And the pause menu: open it, move down and up, resume.
		# (The journal and the dialogue log are walked once there is a document: _bot_journal.)
		_open_pause()
		for cmd in ["menu_down", "menu_up", "accept"]:
			_pause_cmd([cmd])
		return
	if phase == Phase.HUB and not _bot_tried_journal and journal.has_docs():
		_bot_journal()
		return
	if _board_ready() and _bot_board_seen != _board_state():
		# Exercise the board whenever something new is on it: every card, then the other rows.
		_bot_tried_board = true
		_bot_board_seen = _board_state()
		_open_board()
		var cmds: Array = []
		for i in board.cfg.get("cards", []).size():
			cmds.append("menu_right")
		cmds.append("menu_left")
		for row in 2:
			cmds += ["menu_down", "menu_right", "menu_right", "menu_left"]
		for cmd in cmds + ["menu_up", "board"]:
			board.handle([cmd])
		return
	if phase == Phase.HUB:
		for action in _hub_actions_ready():
			if bool(action.get("bot", false)) and not _bot_actions.has(action.get("key", "")):
				_bot_actions[action.get("key", "")] = true
				_hub_action(action)
				return
		if not director.is_busy() and _bot_timer > 0.2:
			_bot_timer = 0.0
			_on_play()
		return
	if phase != Phase.TAPE:
		return
	player.recording = true
	# Optional route in the level data: stand at `x` during a tape-time window, optionally on a
	# given track ("requires" works as for triggers). Otherwise the bot listens to HI-FI once it can.
	var t := mixer.tape_time()
	var target := -1.0
	var route_track := ""
	var route_ff := float(data.get("bot_ff", 20.0))
	for r in data.get("bot_route", []):
		if t >= float(r["from"]) and t <= float(r["to"]) and _requirements_met(r):
			target = _escort_x(String(r["follow"])) if r.has("follow") else float(r["x"])
			route_track = String(r.get("track", ""))
			route_ff = float(r.get("ff", data.get("bot_ff", 20.0)))
	ff = route_ff
	if route_track != "":
		_bot_track(route_track)
	elif _hifi_unlocked() and mixer.get_track() != TrackMixer.Track.HIFI:
		_set_track(TrackMixer.Track.HIFI)
	if _prompt_here != "":
		_interact_pressed = true
	if target >= 0.0:
		var dx := target - player.global_position.x
		player.bot_axis = signf(dx) if absf(dx) > 16.0 else 0.0
	else:
		# "bot_patrol": [x_min, x_max] keeps the wandering bot out of parts it cannot use yet.
		var patrol: Array = data.get("bot_patrol", [80.0, level.size.x - 80.0])
		if player.global_position.x > float(patrol[1]):
			_bot_dir = -1.0
		elif player.global_position.x < float(patrol[0]):
			_bot_dir = 1.0
		player.bot_axis = _bot_dir
	if _bot_jump_timer > 1.1 and player.bot_axis != 0.0:
		_bot_jump_timer = 0.0
		player.bot_jump = true


## The first enabled option the bot has not taken yet in this menu; once all are taken, the last
## enabled one (usually "leave"). Menus that loop back (pick a knot, show a card) cannot trap it.
func _bot_choice() -> int:
	# "bot_prefer": [choice line ids] the bot takes whenever they are offered (an ending, a route).
	var prefer: Array = data.get("bot_prefer", [])
	for i in _choices.size():
		if _choices[i]["enabled"] and prefer.has(String(_choices[i].get("line_id", ""))):
			return i
	var key := runner.current_dialogue()
	for c in _choices:
		key += "|" + String(c["text"])
	var taken: Array = _bot_menus.get(key, [])
	var pick := -1
	for i in _choices.size():
		if _choices[i]["enabled"] and not taken.has(i):
			pick = i
			break
	if pick < 0:
		for i in range(_choices.size() - 1, -1, -1):
			if _choices[i]["enabled"]:
				pick = i
				break
	taken.append(pick)
	_bot_menus[key] = taken
	return maxi(pick, 0)


func _board_state() -> String:
	return "%d/%d/%s" % [board.found_count(), board.knot_count(), str(board.has_knots())]


func _log(what: String) -> void:
	if _trace:
		print("trace: f%d tape %d loop %d %s" % [_stats["frames"], int(mixer.tape_time()), int(runner.get_flag("sys.loop_count")), what])


func _bot_track(track_name: String) -> void:
	var want: TrackMixer.Track = {"hifi": TrackMixer.Track.HIFI, "linear": TrackMixer.Track.LINEAR, "mix": TrackMixer.Track.MIX}.get(track_name, mixer.get_track())
	if mixer.get_track() != want:
		_set_track(want)


func _finish_bot(reason: String) -> void:
	if _finished:
		return
	_finished = true
	var flags: PackedStringArray = []
	for f in data.get("report_flags", []):
		flags.append("%s=%s" % [f, str(runner.get_flag(String(f)))])
	var board_text := ""
	if board != null:
		board_text = ", board %d/%d%s%s" % [board.found_count(), board.cfg.get("cards", []).size(),
			" knots %d/%d" % [board.knot_count(), board.cfg.get("knots", {}).get("slots", []).size()] if board.has_knots() else "",
			"" if _bot_tried_board else " unopened"]
	print("prototype: %d frames, %d loops, %d dialogues, %d lines, %d scares, %d triggers, %d docs%s (%s) %s" % [
		_stats["frames"], _stats["loops"], _stats["dialogues"], _stats["lines"], _stats["scares"],
		_stats["triggers"], _stats["docs"], board_text, reason, " ".join(flags)])
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

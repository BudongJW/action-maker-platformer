## Optional sound for the prototype, described by the level's "audio" block.
##
## Ambience per track plays on the "HiFi" and "Linear" buses, which TrackMixer crossfades and
## which send into "Ambience" (the bus ScareDirector ducks before a scare). "hub" ambience plays
## in the workroom. Loops (generator, drums) follow tape time and stop on a timeline event.
## Stinger files replace ProtoFX's generated noise; one-shot sounds play on "SFX".
## Paths are relative to the project root; tools/build_prototype.py copies them into the build.
class_name ProtoAudio
extends Node

const AMBIENCE_BUS := "Ambience"
const HIFI_BUS := "HiFi"
const LINEAR_BUS := "Linear"
const SFX_BUS := "SFX"
const STINGER_BUS := "Stinger"
const UI_BUS := "UI"
const POOL := 6

var cfg: Dictionary = {}
var rng := RandomNumberGenerator.new()
var _ambience: Dictionary = {}
var _loops: Array = []
var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _streams: Dictionary = {}
var _warned: Dictionary = {}


func setup(audio: Dictionary) -> bool:
	cfg = audio
	if cfg.is_empty():
		return false
	for bus in [AMBIENCE_BUS, HIFI_BUS, LINEAR_BUS, SFX_BUS, STINGER_BUS, UI_BUS]:
		_ensure_bus(bus)
	for bus in [HIFI_BUS, LINEAR_BUS]:
		AudioServer.set_bus_send(AudioServer.get_bus_index(bus), AMBIENCE_BUS)
	var amb: Dictionary = cfg.get("ambience", {})
	for key in amb:
		var bus := HIFI_BUS if key == "hifi" else (LINEAR_BUS if key == "linear" else AMBIENCE_BUS)
		_ambience[key] = _player(String(amb[key]), bus, float(cfg.get("ambience_db", -6.0)), true)
	for spec in cfg.get("loops", []):
		var p := _player(String(spec.get("file", "")), AMBIENCE_BUS, float(spec.get("db", -6.0)), true)
		_loops.append({"spec": spec, "player": p, "done": false})
	for i in POOL:
		var p := AudioStreamPlayer.new()
		p.bus = SFX_BUS
		add_child(p)
		_pool.append(p)
	return true


func enabled() -> bool:
	return not cfg.is_empty()


## Ambience volume setting: shifts the ambience and loop players by `db` from their configured gain
## (the Ambience bus itself belongs to the scare director's ducking).
func set_ambience_offset(db: float) -> void:
	for key in _ambience:
		var p: AudioStreamPlayer = _ambience[key]
		if p != null:
			p.volume_db = float(cfg.get("ambience_db", -6.0)) + db
	for loop in _loops:
		var p: AudioStreamPlayer = loop["player"]
		if p != null:
			p.volume_db = float(loop["spec"].get("db", -6.0)) + db


## The workroom between loops: only the "hub" ambience.
func enter_hub() -> void:
	for key in _ambience:
		_set_playing(_ambience[key], key == "hub")
	for loop in _loops:
		_set_playing(loop["player"], false)


## Tape playback: both track ambiences run; TrackMixer sets which one is heard.
func enter_tape() -> void:
	for key in _ambience:
		_set_playing(_ambience[key], key != "hub")
	for loop in _loops:
		loop["done"] = false


## Starts and stops the loops for the current tape time; `events` holds timeline events so far.
func update(tape_time: float, events: Dictionary) -> void:
	for loop in _loops:
		var spec: Dictionary = loop["spec"]
		var player: AudioStreamPlayer = loop["player"]
		var until: String = String(spec.get("until_event", ""))
		if until != "" and events.has(until):
			if not loop["done"]:
				loop["done"] = true
				if player != null and player.playing:
					player.stop()
					if spec.has("stop"):
						play_file(String(spec["stop"]), AMBIENCE_BUS, float(spec.get("db", -6.0)))
			continue
		var on := tape_time >= float(spec.get("from", 0.0)) and tape_time < float(spec.get("to", INF))
		_set_playing(player, on)


## Plays a named sound from "sfx": a path, a list of paths (one picked at random), or
## {"file": path or list, "db": gain}.
func play(sound: String, bus: String = SFX_BUS) -> void:
	var entry: Variant = cfg.get("sfx", {}).get(sound, null)
	if entry == null:
		return
	var db := 0.0
	if typeof(entry) == TYPE_DICTIONARY:
		db = float(entry.get("db", 0.0))
		entry = entry.get("file", "")
	if typeof(entry) == TYPE_ARRAY:
		entry = entry[rng.randi_range(0, entry.size() - 1)] if entry.size() > 0 else ""
	play_file(String(entry), bus, db)


func play_file(path: String, bus: String, db: float = 0.0) -> void:
	var s := stream(path)
	if s == null or _pool.is_empty():
		return
	var p := _pool[_next]
	_next = (_next + 1) % _pool.size()
	p.stop()
	p.stream = s
	p.bus = bus
	p.volume_db = db
	p.play()


## The stinger file for a scare id, or null (ProtoFX then generates noise).
func stinger(scare_id: String) -> AudioStream:
	var path: String = String(cfg.get("stingers", {}).get(scare_id, ""))
	return stream(path) if path != "" else null


func stream(path: String, loop: bool = false) -> AudioStream:
	if path == "":
		return null
	var key := path + ("#loop" if loop else "")
	if not _streams.has(key):
		var res := "res://" + path
		var s: AudioStream = load(res) as AudioStream if ResourceLoader.exists(res) else null
		if s == null:
			_warn("missing sound %s" % path)
		elif loop:
			s = s.duplicate() as AudioStream
			if s is AudioStreamWAV:
				var wav := s as AudioStreamWAV
				wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
				wav.loop_begin = 0
				wav.loop_end = int(round(wav.get_length() * wav.mix_rate))
			elif s is AudioStreamOggVorbis:
				(s as AudioStreamOggVorbis).loop = true
		_streams[key] = s
	return _streams[key]


func stop_all() -> void:
	for p in _all_players():
		p.stop()
		p.stream = null


func _exit_tree() -> void:
	for p in _all_players():
		p.stop()
		p.stream = null
	_streams.clear()


func _all_players() -> Array:
	var out: Array = []
	for key in _ambience:
		if _ambience[key] != null:
			out.append(_ambience[key])
	for loop in _loops:
		if loop["player"] != null:
			out.append(loop["player"])
	out.append_array(_pool)
	return out


func _player(path: String, bus: String, db: float, loop: bool) -> AudioStreamPlayer:
	var s := stream(path, loop)
	if s == null:
		return null
	var p := AudioStreamPlayer.new()
	p.stream = s
	p.bus = bus
	p.volume_db = db
	add_child(p)
	return p


func _set_playing(p: AudioStreamPlayer, on: bool) -> void:
	if p == null:
		return
	if on and not p.playing:
		p.play()
	elif not on and p.playing:
		p.stop()


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)


func _warn(message: String) -> void:
	if not _warned.has(message):
		_warned[message] = true
		push_warning("ProtoAudio: " + message)

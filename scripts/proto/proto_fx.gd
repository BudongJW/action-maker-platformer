## Placeholder scare effects for the prototype: generated stinger noise, an ambience bed on its
## own bus (so ScareDirector can duck it), flash, camera shake, and either a frame from the
## level's art block ("scares": {id: {"sheet", "frame", "anchor"}}) or graybox glitch blocks.
## Real sound replaces the noise; the timing comes from ScareDirector either way.
class_name ProtoFX
extends Node

const MIX_RATE := 22050
const BED_BUS := "Ambience"
const SFX_BUS := "Stinger"

var ui: ProtoUI
var camera: Camera2D
var art: ProtoArt
var _stinger: AudioStreamPlayer
var _bed: AudioStreamPlayer
var _glitch: Control
var _shake_left := 0.0
var _shake_amount := 0.0
var _glitch_left := 0.0
var _cache: Dictionary = {}
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	_ensure_bus(BED_BUS)
	_ensure_bus(SFX_BUS)
	_bed = AudioStreamPlayer.new()
	_bed.bus = BED_BUS
	_bed.stream = _noise(2.0, 400.0, 0.0, 0.08, true)
	_bed.volume_db = -18.0
	add_child(_bed)
	_stinger = AudioStreamPlayer.new()
	_stinger.bus = SFX_BUS
	add_child(_stinger)
	_glitch = Control.new()
	_glitch.anchor_right = 1.0
	_glitch.anchor_bottom = 1.0
	_glitch.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _exit_tree() -> void:
	for player in [_bed, _stinger]:
		player.stop()
		player.stream = null
	_cache.clear()


func attach(layer: CanvasLayer) -> void:
	layer.add_child(_glitch)


func start_bed() -> void:
	if not _bed.playing:
		_bed.play()


## Draws and plays one onset from ScareDirector.scare_onset's `id` and `info`.
func onset(id: String, info: Dictionary) -> void:
	var rise: float = float(info.get("rise_ms", 2.0))
	var body: float = float(info.get("body_ms", 500.0))
	var key := "%d_%d" % [int(rise), int(body)]
	if not _cache.has(key):
		_cache[key] = _noise(body / 1000.0, rise, 0.1, 0.9, false)
	_stinger.stream = _cache[key]
	# Stingers are normalized to +20 LU over dialogue; level_lu sets the gain below that.
	_stinger.volume_db = float(info.get("level_lu", 12.0)) - 20.0
	_stinger.play()
	if bool(info.get("flash", false)) and ui != null:
		ui.flash(0.6)
	_shake_amount = float(info.get("shake", 0.0)) * 18.0
	_shake_left = 0.4 if _shake_amount > 0.0 else 0.0
	if art != null and art.enabled():
		_spawn_art(art.cfg.get("scares", {}).get(id, {}), body / 1000.0)
	else:
		_spawn_glitch(float(info.get("area", 0.2)), body / 1000.0)


func _process(delta: float) -> void:
	if camera != null:
		if _shake_left > 0.0:
			_shake_left -= delta
			camera.offset = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * _shake_amount
		else:
			camera.offset = Vector2.ZERO
	if _glitch_left > 0.0:
		_glitch_left -= delta
		if _glitch_left <= 0.0:
			for c in _glitch.get_children():
				c.queue_free()


## anchor: "left", "right", "center" or "full" (stretched to the screen).
func _spawn_art(spec: Dictionary, seconds: float) -> void:
	for c in _glitch.get_children():
		c.queue_free()
	if spec.is_empty():
		return
	var tex := art.frame(String(spec.get("sheet", "")), String(spec.get("frame", "")))
	if tex == null:
		return
	var vp := Vector2(1280, 720)
	var k := art.ui_scale(vp)
	var r := TextureRect.new()
	r.texture = tex
	r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_SCALE
	var size := tex.get_size() * k
	match String(spec.get("anchor", "center")):
		"full":
			size = vp
			r.position = Vector2.ZERO
		"left":
			r.position = Vector2(0, (vp.y - size.y) / 2.0)
		"right":
			r.position = Vector2(vp.x - size.x, (vp.y - size.y) / 2.0)
		_:
			r.position = (vp - size) / 2.0
	r.size = size
	_glitch.add_child(r)
	_glitch_left = maxf(float(spec.get("min_seconds", 0.15)), seconds)


func _spawn_glitch(area: float, seconds: float) -> void:
	for c in _glitch.get_children():
		c.queue_free()
	# Blocks stay inside a band along one screen edge whose area is `area` of the screen,
	# so the scare never covers more than that (photosensitivity guidance: <= 20-25%).
	var vp := Vector2(1280, 720)
	var band := clampf(area, 0.0, 0.25) * vp.x
	var left_edge := rng.randf() < 0.5
	var budget := band * vp.y * 0.6
	while budget > 0.0 and band > 8.0:
		var r := ColorRect.new()
		var w := rng.randf_range(minf(20.0, band), band)
		var h := rng.randf_range(6, 26)
		r.size = Vector2(w, h)
		var x := rng.randf_range(0.0, band - w)
		r.position = Vector2(x if left_edge else vp.x - band + x, rng.randf_range(0, vp.y - h))
		r.color = Color(0.88, 0.5, 0.78, rng.randf_range(0.5, 0.9))
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_glitch.add_child(r)
		budget -= w * h
	_glitch_left = maxf(0.15, seconds)


func _noise(seconds: float, rise_ms: float, release_s: float, amp: float, loop: bool) -> AudioStreamWAV:
	var n := int(seconds * MIX_RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	var attack := maxf(1.0, rise_ms / 1000.0 * MIX_RATE)
	var release := maxf(1.0, release_s * MIX_RATE)
	var brown := 0.0
	for i in n:
		var env := minf(1.0, float(i) / attack)
		if not loop and i > n - release:
			env *= float(n - i) / release
		var white := rng.randf_range(-1.0, 1.0)
		var s := white
		if loop:
			brown = clampf(brown + white * 0.05, -1.0, 1.0)
			s = brown
		var v := int(clampf(s * env * amp, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, v)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = data
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = n
	return wav


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

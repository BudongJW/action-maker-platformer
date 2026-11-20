## Screen effects over the tape picture, under the UI: the VHS texture of the camera that shot
## the tape, and the MIX picture where the LINEAR and HI-FI recordings lie over each other.
##
## VHS (shaders/vhs.gdshader) is on while the level's art has a "viewfinder" (the camera) or a
## "vhs" block, and goes away for good once the camera is switched off: the "vhs" block's
## "off_flag", or else the viewfinder's. "vhs": {"enabled": false} turns it off; "scanlines",
## "chroma", "chroma_blur", "noise" and "band" tune it (shader uniforms of the same names);
## "scanlines" is capped at 0.08, the contrast photosensitivity guidance allows. With reduced
## flashing the grain stands still and the tracking band and the scanlines are gone. The player's
## "VHS texture" setting (set_strength) turns it off or halves it.
##
## Last comes the brightness setting (shaders/brightness.gdshader, set_brightness): a gamma curve
## over the whole picture, still under the UI.
##
## MIX (shaders/track_mix.gdshader) needs the art's "linear" and "hifi" palettes. The world is
## drawn a second time into a SubViewport that shares the World2D: canvas cull masks keep the
## HI-FI-only nodes out of the main view and the LINEAR-only nodes out of the second one, and
## the shader alternates the two views in a checkerboard of art pixels, the HI-FI one pushed
## "mix": {"shift"} art pixels (default 3) to the right and recoloured with the HI-FI palette.
class_name ProtoScreen
extends CanvasLayer

## Canvas visibility layers (CanvasItem.visibility_layer bits): nodes on both tracks keep the
## default first bit; the root of a track-only node gets one of the other two.
const LAYER_HIFI := 1 << 1
const LAYER_LINEAR := 1 << 2
const ALL_LAYERS := 0xFFFFFFFF
const VIEW := Vector2(1280, 720)
## Scanline contrast above 10% over a fifth of the screen fails platform photosensitivity checks.
const MAX_SCANLINE := 0.08
const VHS_SHADER := "res://shaders/vhs.gdshader"
const MIX_SHADER := "res://shaders/track_mix.gdshader"
const BRIGHTNESS_SHADER := "res://shaders/brightness.gdshader"
## Brightness setting 0..10 (5 = as drawn) to gamma: 0.6 .. 1.4.
const GAMMA_STEP := 0.08
## Shader defaults of the uniforms the strength setting scales (shaders/vhs.gdshader).
const VHS_DEFAULTS := {"chroma": 0.5, "noise": 0.04, "band": 0.6}

## The flag that switches the camera off for good ("" if nothing does).
var vhs_off_flag := ""
var _vhs: ColorRect
var _vhs_mat: ShaderMaterial
var _mix: ColorRect
var _mix_mat: ShaderMaterial
var _hifi_view: SubViewport
var _vhs_on := false
var _mix_on := false
var _still := false
var _scanline := MAX_SCANLINE
## The level's own values of VHS_DEFAULTS' uniforms, before the strength setting.
var _base: Dictionary = VHS_DEFAULTS.duplicate()
## 0 off, 1 soft (half), 2 as the level sets it.
var _strength := 2
## On as far as the story is concerned (the camera has not been switched off).
var _story_vhs := false
var _clock := 0.0
var _gamma: ColorRect
var _gamma_mat: ShaderMaterial
var _gamma_on := false


func _ready() -> void:
	# Above the world and its backdrop (layer -10), below the UI (layer 10).
	layer = 5
	_mix = _full_rect()
	# The VHS pass reads the screen again, after the MIX picture is on it.
	var copy := BackBufferCopy.new()
	copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	add_child(copy)
	_vhs = _full_rect()
	var copy_again := BackBufferCopy.new()
	copy_again.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	add_child(copy_again)
	_gamma = _full_rect()
	if ResourceLoader.exists(BRIGHTNESS_SHADER):
		_gamma_mat = ShaderMaterial.new()
		_gamma_mat.shader = load(BRIGHTNESS_SHADER)
		_gamma.material = _gamma_mat
	visible = false
	RenderingServer.frame_pre_draw.connect(_sync_views)


func _exit_tree() -> void:
	if RenderingServer.frame_pre_draw.is_connected(_sync_views):
		RenderingServer.frame_pre_draw.disconnect(_sync_views)
	if _mix_on:
		get_viewport().canvas_cull_mask = ALL_LAYERS


## Reads the art block. Call after the level is built (track-only nodes are in their groups).
func setup(art: ProtoArt, level: ProtoLevel, mixer: TrackMixer) -> void:
	if art == null or not art.enabled():
		return
	var vhs: Dictionary = art.cfg.get("vhs", {})
	if (art.cfg.has("viewfinder") or art.cfg.has("vhs")) and bool(vhs.get("enabled", true)) \
			and ResourceLoader.exists(VHS_SHADER):
		_vhs_mat = ShaderMaterial.new()
		_vhs_mat.shader = load(VHS_SHADER)
		_vhs_mat.set_shader_parameter("view_size", VIEW)
		_vhs_mat.set_shader_parameter("lines", ProtoArt.SCREEN.y)
		_scanline = clampf(float(vhs.get("scanlines", MAX_SCANLINE)), 0.0, MAX_SCANLINE)
		for key in ["chroma", "chroma_blur", "noise", "band"]:
			if vhs.has(key):
				_vhs_mat.set_shader_parameter(key, float(vhs[key]))
				if _base.has(key):
					_base[key] = float(vhs[key])
		_apply_strength()
		_vhs.material = _vhs_mat
		vhs_off_flag = String(vhs.get("off_flag", art.cfg.get("viewfinder", {}).get("off_flag", "")))
		set_vhs(true)
	var from := art.lut("linear")
	var to := art.lut("hifi")
	if from != null and to != null and ResourceLoader.exists(MIX_SHADER):
		_hifi_view = SubViewport.new()
		_hifi_view.world_2d = get_viewport().world_2d
		_hifi_view.size = Vector2i(VIEW)
		_hifi_view.disable_3d = true
		_hifi_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		_hifi_view.canvas_cull_mask = ALL_LAYERS & ~LAYER_LINEAR
		_hifi_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
		add_child(_hifi_view)
		# The backdrop is a CanvasLayer of the main view; the second view needs its own copy.
		level.mirror_backdrop(_hifi_view)
		# A canvas item is drawn only if it and all its parents share a layer with the view's
		# cull mask, so marking the group's root is enough.
		for node in get_tree().get_nodes_in_group(mixer.hifi_group):
			if node is CanvasItem:
				(node as CanvasItem).visibility_layer = LAYER_HIFI
		for node in get_tree().get_nodes_in_group(mixer.linear_group):
			if node is CanvasItem:
				(node as CanvasItem).visibility_layer = LAYER_LINEAR
		# Each track's own nodes are whole in their own view; the checkerboard already halves them.
		mixer.mix_alpha = 1.0
		_mix_mat = ShaderMaterial.new()
		_mix_mat.shader = load(MIX_SHADER)
		_mix_mat.set_shader_parameter("view_size", VIEW)
		_mix_mat.set_shader_parameter("hifi_layer", _hifi_view.get_texture())
		_mix_mat.set_shader_parameter("from_lut", from)
		_mix_mat.set_shader_parameter("to_lut", to)
		_mix_mat.set_shader_parameter("palette_size", art.palette_size())
		_mix_mat.set_shader_parameter("shift", float(art.cfg.get("mix", {}).get("shift", 3.0)))
		_mix.material = _mix_mat


## True when MIX is drawn as two pictures (track-only nodes then need no transparency).
func mix_available() -> bool:
	return _hifi_view != null


func set_vhs(on: bool) -> void:
	_story_vhs = on
	on = on and _vhs_mat != null and _strength > 0
	if on == _vhs_on:
		return
	_vhs_on = on
	_vhs.visible = on
	_update_visible()


## Reduced flashing: the grain stands still, and the tracking band and the scanlines are gone.
func set_still(still: bool) -> void:
	if still == _still or _vhs_mat == null:
		return
	_still = still
	_vhs_mat.set_shader_parameter("moving", 0.0 if still else 1.0)
	_apply_strength()


## The player's setting: 0 turns the texture off, 1 halves the scanlines, colour bleed, grain and
## tracking band, 2 leaves them as the level sets them.
func set_strength(level: int) -> void:
	_strength = clampi(level, 0, 2)
	_apply_strength()
	set_vhs(_story_vhs)


func _apply_strength() -> void:
	if _vhs_mat == null:
		return
	var k := 0.5 if _strength == 1 else 1.0
	_vhs_mat.set_shader_parameter("scanline", 0.0 if _still else _scanline * k)
	for key in _base:
		_vhs_mat.set_shader_parameter(key, float(_base[key]) * k)


func set_mix(on: bool) -> void:
	on = on and _hifi_view != null
	if on == _mix_on:
		return
	_mix_on = on
	_mix.visible = on
	_hifi_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS if on else SubViewport.UPDATE_DISABLED
	get_viewport().canvas_cull_mask = ALL_LAYERS & ~LAYER_HIFI if on else ALL_LAYERS
	_update_visible()
	_sync_views()


## The brightness setting, 0..10; 5 leaves the picture as drawn (and the pass off).
func set_brightness(level: int) -> void:
	var gamma := gamma_for(level)
	_gamma_on = _gamma_mat != null and not is_equal_approx(gamma, 1.0)
	if _gamma_mat != null:
		_gamma_mat.set_shader_parameter("gamma", gamma)
	_gamma.visible = _gamma_on
	_update_visible()


## The gamma the brightness pass uses for a setting (the calibration marks use it too).
static func gamma_for(level: int) -> float:
	return 1.0 + (clampi(level, 0, 10) - 5) * GAMMA_STEP


func _update_visible() -> void:
	visible = _vhs_on or _mix_on or _gamma_on


func _process(delta: float) -> void:
	if _vhs_on:
		_clock += delta
		_vhs_mat.set_shader_parameter("clock", _clock)


## Right before drawing (after the camera has moved): the second view and the checkerboard
## follow the main view's camera.
func _sync_views() -> void:
	if not _mix_on or not is_inside_tree():
		return
	var t := get_viewport().canvas_transform
	_hifi_view.canvas_transform = t
	_mix_mat.set_shader_parameter("grid_origin", t.origin)
	_mix_mat.set_shader_parameter("art_pixel", maxf(t.x.x, 0.001))


func _full_rect() -> ColorRect:
	var r := ColorRect.new()
	r.anchor_right = 1.0
	r.anchor_bottom = 1.0
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.visible = false
	add_child(r)
	return r

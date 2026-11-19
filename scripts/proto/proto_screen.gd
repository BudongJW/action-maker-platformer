## Screen effects over the tape picture, under the UI: the VHS texture of the camera that shot
## the tape, and the MIX picture where the LINEAR and HI-FI recordings lie over each other.
##
## VHS (shaders/vhs.gdshader) is on while the level's art has a "viewfinder" (the camera) or a
## "vhs" block, and goes away for good once the camera is switched off: the "vhs" block's
## "off_flag", or else the viewfinder's. "vhs": {"enabled": false} turns it off; "scanlines",
## "chroma", "chroma_blur", "noise" and "band" tune it (shader uniforms of the same names). With
## reduced flashing the grain stands still and the tracking band is gone.
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
const VHS_SHADER := "res://shaders/vhs.gdshader"
const MIX_SHADER := "res://shaders/track_mix.gdshader"

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
var _clock := 0.0


func _ready() -> void:
	# Above the world and its backdrop (layer -10), below the UI (layer 10).
	layer = 5
	_mix = _full_rect()
	# The VHS pass reads the screen again, after the MIX picture is on it.
	var copy := BackBufferCopy.new()
	copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	add_child(copy)
	_vhs = _full_rect()
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
		var tuning := {"scanlines": "scanline", "chroma": "chroma", "chroma_blur": "chroma_blur",
			"noise": "noise", "band": "band"}
		for key in tuning:
			if vhs.has(key):
				_vhs_mat.set_shader_parameter(tuning[key], float(vhs[key]))
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
	on = on and _vhs_mat != null
	if on == _vhs_on:
		return
	_vhs_on = on
	_vhs.visible = on
	visible = _vhs_on or _mix_on


## Reduced flashing: the grain stands still and the tracking band is gone.
func set_still(still: bool) -> void:
	if still == _still or _vhs_mat == null:
		return
	_still = still
	_vhs_mat.set_shader_parameter("moving", 0.0 if still else 1.0)


func set_mix(on: bool) -> void:
	on = on and _hifi_view != null
	if on == _mix_on:
		return
	_mix_on = on
	_mix.visible = on
	_hifi_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS if on else SubViewport.UPDATE_DISABLED
	get_viewport().canvas_cull_mask = ALL_LAYERS & ~LAYER_HIFI if on else ALL_LAYERS
	visible = _vhs_on or _mix_on
	_sync_views()


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

## Optional pixel art for the prototype, described by the level's "art" block.
##
## Paths in the block are relative to the project root (for example
## "assets/original/art/tiles/tiles_exterior.png"). tools/build_prototype.py copies the files it
## finds there into the build and writes res://assets/art_atlas.json with each sheet's frame size,
## columns and frame names, taken from the pixel-art sources. Without an "art" block the prototype
## stays a graybox.
##
## Art drawn with the base palette (night-school.pal keys) is recoloured per track with
## shaders/palette_swap.gdshader; the lookup strips are built here from the .pal files.
class_name ProtoArt
extends RefCounted

const ATLAS := "res://assets/art_atlas.json"
const SHADER := "res://shaders/palette_swap.gdshader"
const SCREEN := Vector2(320, 180)

var cfg: Dictionary = {}
var atlas: Dictionary = {}
## Shared by every node drawn with the base palette; set_palette() changes it for all of them.
var world_material: ShaderMaterial
var _keys: PackedStringArray = []
var _luts: Dictionary = {}
var _textures: Dictionary = {}
var _missing: Dictionary = {}


func setup(art: Dictionary) -> bool:
	cfg = art
	if cfg.is_empty():
		return false
	if FileAccess.file_exists(ATLAS):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ATLAS))
		if typeof(parsed) == TYPE_DICTIONARY:
			atlas = parsed
	_build_palettes()
	return true


func enabled() -> bool:
	return not cfg.is_empty()


## Camera zoom for the world (the art is drawn for a 320x180 screen).
func zoom() -> float:
	return float(cfg.get("zoom", 1.0))


## Screen pixels per art pixel for screen-space art (viewfinder, inserts, scare frames).
func ui_scale(viewport: Vector2) -> float:
	return viewport.y / SCREEN.y


func texture(path: String) -> Texture2D:
	if path == "":
		return null
	if not _textures.has(path):
		var res := "res://" + path
		_textures[path] = load(res) as Texture2D if ResourceLoader.exists(res) else null
		if _textures[path] == null:
			_warn("missing art file %s" % path)
	return _textures[path]


## One frame of a sheet. An empty frame name (or a file without atlas data) means the whole image.
func frame(path: String, frame_name: String = "") -> Texture2D:
	var tex := texture(path)
	if tex == null:
		return null
	var info: Dictionary = atlas.get(path, {})
	if frame_name == "" or info.is_empty():
		return tex
	var frames: Array = info.get("frames", [])
	var index := frames.find(frame_name)
	if index < 0:
		_warn("no frame %s in %s" % [frame_name, path])
		return null
	var size: Array = info.get("size", [tex.get_width(), tex.get_height()])
	var w := float(size[0])
	var h := float(size[1])
	var cols := int(info.get("columns", frames.size()))
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2((index % cols) * w, (index / cols) * h, w, h)
	return at


## A frame as a standalone texture, so it can repeat (tiled floors, water, ladders).
func tile(path: String, frame_name: String) -> Texture2D:
	var at := frame(path, frame_name) as AtlasTexture
	if at == null:
		return null
	var img := at.atlas.get_image()
	if img == null:
		return null
	if img.is_compressed():
		img.decompress()
	return ImageTexture.create_from_image(img.get_region(Rect2i(at.region)))


## A frame enlarged `factor` times with nearest-neighbour scaling, for nine-slice UI panels drawn
## in screen pixels (a StyleBoxTexture does not scale its borders).
func scaled(path: String, frame_name: String, factor: int) -> Texture2D:
	var tex := frame(path, frame_name)
	if tex == null:
		return null
	var img: Image
	if tex is AtlasTexture:
		var at := tex as AtlasTexture
		img = at.atlas.get_image()
		if img != null:
			if img.is_compressed():
				img.decompress()
			img = img.get_region(Rect2i(at.region))
	else:
		img = tex.get_image()
		if img != null and img.is_compressed():
			img.decompress()
	if img == null:
		return null
	img.resize(img.get_width() * factor, img.get_height() * factor, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(img)


## A nine-slice style box from a frame: {"frame": name, "margin": art pixels}.
func stylebox(path: String, spec: Dictionary, factor: int) -> StyleBoxTexture:
	var tex := scaled(path, String(spec.get("frame", "")), factor)
	if tex == null:
		return null
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	var m := float(spec.get("margin", 4)) * factor
	sb.texture_margin_left = m
	sb.texture_margin_right = m
	sb.texture_margin_top = m
	sb.texture_margin_bottom = m
	var pad := m + float(spec.get("padding", 4))
	sb.content_margin_left = pad
	sb.content_margin_right = pad
	sb.content_margin_top = pad
	sb.content_margin_bottom = pad
	return sb


## {"sheet": path, "fps": 6, "anims": {"idle": ["idle_0", "idle_1"], ...}}
func sprite_frames(spec: Dictionary) -> SpriteFrames:
	var sf := SpriteFrames.new()
	var sheet: String = String(spec.get("sheet", ""))
	var fps := float(spec.get("fps", 6.0))
	var anims: Dictionary = spec.get("anims", {})
	for anim in anims:
		if not sf.has_animation(anim):
			sf.add_animation(anim)
		sf.set_animation_speed(anim, fps)
		sf.set_animation_loop(anim, true)
		for frame_name in anims[anim]:
			var f := frame(sheet, String(frame_name))
			if f != null:
				sf.add_frame(anim, f)
	if sf.has_animation("default") and sf.get_frame_count("default") == 0 and anims.size() > 0:
		sf.remove_animation("default")
	return sf


## An animated sprite whose bottom centre sits on the node's origin (feet on the ground).
func make_sprite(spec: Dictionary, recolour: bool = true) -> AnimatedSprite2D:
	var s := AnimatedSprite2D.new()
	s.sprite_frames = sprite_frames(spec)
	var names := s.sprite_frames.get_animation_names()
	if names.size() > 0:
		var start := "idle" if s.sprite_frames.has_animation("idle") else String(names[0])
		s.animation = start
		var first := s.sprite_frames.get_frame_texture(start, 0) if s.sprite_frames.get_frame_count(start) > 0 else null
		if first != null:
			s.offset = Vector2(0, -first.get_height() / 2.0)
		s.play(start)
	if recolour:
		s.material = world_material
	return s


# --- Palettes ----------------------------------------------------------------------------


## Recolours every node that uses `world_material`. `palette_name` is a key of the art block's
## "palettes" (for example "linear" or "hifi"); "" restores the base colours.
func set_palette(palette_name: String, amount: float = 1.0) -> void:
	if world_material == null:
		return
	if palette_name == "" or not _luts.has(palette_name):
		world_material.set_shader_parameter("amount", 0.0)
		return
	world_material.set_shader_parameter("swap_lut", _luts[palette_name])
	world_material.set_shader_parameter("amount", amount)


func _build_palettes() -> void:
	var base_path: String = String(cfg.get("base_palette", ""))
	if base_path == "" or not ResourceLoader.exists(SHADER):
		return
	var base := _read_palette(base_path)
	if base.is_empty():
		return
	_keys = PackedStringArray(base.keys())
	world_material = ShaderMaterial.new()
	world_material.shader = load(SHADER)
	world_material.set_shader_parameter("base_lut", _lut(base, base))
	world_material.set_shader_parameter("palette_size", _keys.size())
	world_material.set_shader_parameter("amount", 0.0)
	var palettes: Dictionary = cfg.get("palettes", {})
	for palette_name in palettes:
		var target := _read_palette(String(palettes[palette_name]))
		if not target.is_empty():
			_luts[palette_name] = _lut(base, target)


## Reads "KEY RRGGBB name" lines; keeps the file's key order.
func _read_palette(path: String) -> Dictionary:
	var res := "res://" + path
	if not FileAccess.file_exists(res):
		_warn("missing palette %s" % path)
		return {}
	var out: Dictionary = {}
	for raw in FileAccess.get_file_as_string(res).split("\n"):
		var line := raw.strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var parts := line.split(" ", false)
		if parts.size() >= 2 and parts[1].length() == 6:
			out[parts[0]] = Color.html("#" + parts[1])
	return out


func _lut(base: Dictionary, target: Dictionary) -> ImageTexture:
	var img := Image.create(_keys.size(), 1, false, Image.FORMAT_RGBA8)
	for i in _keys.size():
		img.set_pixel(i, 0, target.get(_keys[i], base[_keys[i]]))
	return ImageTexture.create_from_image(img)


func _warn(message: String) -> void:
	if not _missing.has(message):
		_missing[message] = true
		push_warning("ProtoArt: " + message)

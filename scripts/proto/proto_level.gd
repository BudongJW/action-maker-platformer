## Builds the prototype level from a JSON description: graybox shapes, or pixel art when the
## level has an "art" block (see ProtoArt and prototype/README.md).
##
## Shapes are [x, y, w, h] in pixels. Track-only shapes join the TrackMixer groups so the mixer
## can show, hide and disable them. Triggers are data for ProtoGame; the level only draws them
## (graybox only).
class_name ProtoLevel
extends Node2D

const COLOR_SOLID := Color(0.42, 0.42, 0.40)
const COLOR_HIFI := Color(0.25, 0.62, 0.70)
const COLOR_LINEAR := Color(0.62, 0.32, 0.56)
const COLOR_LADDER := Color(0.75, 0.66, 0.30)
const COLOR_WATER := Color(0.16, 0.30, 0.38, 0.85)
const COLOR_TRIGGER := Color(1, 1, 1, 0.08)
const TILE := 16.0

var data: Dictionary = {}
var size := Vector2(4000, 900)
var ladders: Array[Rect2] = []
var font: Font
var art: ProtoArt
## NPC sprites by their "sprite" key, so the game can change poses.
var npc_sprites: Dictionary = {}
## Props shown only while a flag is on ("flag") or off ("unless_flag"): [{node, flag, negate}].
var flag_props: Array = []
## Water that rises in one stretch of the level ("rising_water"): [{cfg, node}].
var water_zones: Array = []
var _backdrop: Sprite2D
var _backdrop_parallax := 0.2
var _tiles: Dictionary = {}


func build(level: Dictionary, label_font: Font = null, level_art: ProtoArt = null) -> void:
	data = level
	font = label_font
	art = level_art if level_art != null and level_art.enabled() else null
	var s: Array = level.get("size", [4000, 900])
	size = Vector2(float(s[0]), float(s[1]))
	if art != null:
		_build_backdrop()
	var water: Dictionary = level.get("water", {})
	if not water.is_empty():
		# "gaps": [[x0, x1], ...] leave room for rising-water zones.
		var wy := float(water.get("y", size.y))
		var x := 0.0
		var cuts: Array = water.get("gaps", []).duplicate()
		cuts.append([size.x, size.x])
		for gap in cuts:
			var wr := Rect2(x, wy, float(gap[0]) - x, size.y - wy + 200.0)
			if wr.size.x > 0.0 and not _art_rect(wr, "water", self, 0.9):
				_rect_visual(wr, COLOR_WATER, self)
			x = float(gap[1])
	for zone in level.get("rising_water", []):
		var holder := Node2D.new()
		var x0 := float(zone["x0"])
		var x1 := float(zone["x1"])
		holder.position = Vector2(x0, float(zone.get("linear_y", zone.get("base_y", size.y))))
		var wr := Rect2(0, 0, x1 - x0, size.y + 400.0)
		if not _art_rect(wr, "water", holder, 0.9):
			_rect_visual(wr, COLOR_WATER, holder)
		add_child(holder)
		water_zones.append({"cfg": zone, "node": holder})
	if art != null:
		_build_props()
	for r in level.get("solids", []):
		_solid(_rect(r), COLOR_SOLID, "", "solid")
	for r in level.get("hifi_only", []):
		_solid(_rect(r), COLOR_HIFI, "track_hifi_only", "hifi_only")
	for r in level.get("linear_only", []):
		_solid(_rect(r), COLOR_LINEAR, "track_linear_only", "linear_only")
	for r in level.get("ladders", []):
		var rect := _rect(r)
		ladders.append(rect)
		var strip := Rect2(rect.position.x + (rect.size.x - TILE) / 2.0, rect.position.y, TILE, rect.size.y)
		if not _art_rect(strip, "ladder", self):
			_rect_visual(rect, COLOR_LADDER, self)
	if art == null:
		for t in level.get("triggers", []):
			if t.has("rect"):
				_rect_visual(_rect(t["rect"]), COLOR_TRIGGER, self)
	for npc in level.get("npcs", []):
		var p := Vector2(float(npc["x"]), float(npc["y"]))
		var key: String = String(npc.get("sprite", ""))
		var spec: Dictionary = art.cfg.get("npcs", {}).get(key, {}) if art != null else {}
		if not spec.is_empty():
			var sprite := art.make_sprite(spec)
			sprite.position = p
			sprite.flip_h = bool(npc.get("flip", false))
			add_child(sprite)
			npc_sprites[key] = sprite
			_label(String(npc.get("label", "")), p + Vector2(-16, -52))
		else:
			_rect_visual(Rect2(p - Vector2(12, 44), Vector2(24, 44)), Color(0.85, 0.82, 0.74), self)
			_label(String(npc.get("label", "")), p + Vector2(-30, -64))
	for lb in level.get("labels", []):
		_label(String(lb[2]), Vector2(float(lb[0]), float(lb[1])))


## True if `point` is inside a ladder.
func on_ladder(point: Vector2) -> bool:
	for r in ladders:
		if r.has_point(point):
			return true
	return false


## Shows or hides flag props; `is_on` maps a flag name to true or false.
func update_flag_props(is_on: Callable) -> void:
	for entry in flag_props:
		entry["node"].visible = bool(is_on.call(entry["flag"])) != bool(entry["negate"])


## Puts the water of rising zone `index` at height `y`.
func set_zone_water(index: int, y: float) -> void:
	water_zones[index]["node"].position.y = y


## Scrolls the backdrop with the camera (call every frame).
func update_backdrop(camera_x: float, camera_zoom: float) -> void:
	if _backdrop == null:
		return
	var region := _backdrop.region_rect
	region.position.x = camera_x * _backdrop_parallax * camera_zoom / _backdrop.scale.x
	_backdrop.region_rect = region


static func to_rect(r: Variant) -> Rect2:
	return Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3]))


func _rect(r: Variant) -> Rect2:
	return ProtoLevel.to_rect(r)


func _solid(rect: Rect2, color: Color, group: String, tile_key: String) -> void:
	var body := StaticBody2D.new()
	body.position = rect.position + rect.size / 2.0
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.add_child(shape)
	if not _art_rect(Rect2(-rect.size / 2.0, rect.size), tile_key, body):
		_rect_visual(Rect2(-rect.size / 2.0, rect.size), color, body)
	if group != "":
		body.add_to_group(group)
	add_child(body)


# --- Art -----------------------------------------------------------------------------------


func _build_backdrop() -> void:
	var spec: Dictionary = art.cfg.get("backdrop", {})
	var tex := art.frame(String(spec.get("texture", "")), String(spec.get("frame", "")))
	if tex == null:
		return
	var layer := CanvasLayer.new()
	layer.layer = -10
	add_child(layer)
	_backdrop = Sprite2D.new()
	_backdrop.centered = false
	_backdrop.texture = tex
	_backdrop.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_backdrop.region_enabled = true
	_backdrop.region_rect = Rect2(Vector2.ZERO, tex.get_size())
	_backdrop.scale = Vector2.ONE * art.ui_scale(get_viewport_rect().size if is_inside_tree() else Vector2(1280, 720))
	_backdrop.material = art.world_material
	_backdrop_parallax = float(spec.get("parallax", 0.2))
	layer.add_child(_backdrop)


## Fills `rect` with the art block's tiles for `key`: ["top_frame", "fill_frame"] or one frame.
func _art_rect(rect: Rect2, key: String, parent: Node, alpha: float = 1.0) -> bool:
	if art == null:
		return false
	var tiles: Dictionary = art.cfg.get("tiles", {})
	if not tiles.has(key):
		return false
	var names: Array = tiles[key] if typeof(tiles[key]) == TYPE_ARRAY else [tiles[key], tiles[key]]
	var sheet: String = String(tiles.get("sheet", ""))
	var top := _tile_tex(sheet, String(names[0]))
	var fill := _tile_tex(sheet, String(names[min(1, names.size() - 1)]))
	if top == null or fill == null:
		return false
	var top_h := minf(TILE, rect.size.y)
	_tiled(Rect2(rect.position, Vector2(rect.size.x, top_h)), top, parent, alpha)
	if rect.size.y > top_h:
		_tiled(Rect2(rect.position + Vector2(0, top_h), Vector2(rect.size.x, rect.size.y - top_h)), fill, parent, alpha)
	return true


func _tile_tex(sheet: String, frame_name: String) -> Texture2D:
	var key := sheet + ":" + frame_name
	if not _tiles.has(key):
		_tiles[key] = art.tile(sheet, frame_name)
	return _tiles[key]


func _tiled(rect: Rect2, tex: Texture2D, parent: Node, alpha: float) -> void:
	var tr := TextureRect.new()
	tr.texture = tex
	tr.stretch_mode = TextureRect.STRETCH_TILE
	tr.position = rect.position
	tr.size = rect.size
	tr.modulate.a = alpha
	tr.material = art.world_material
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(tr)


## Decoration: {"sheet": path, "frame": name, "at": [x, ground_y]} or a block of tiles named
## "<block>_<col>_<row>" with "block", "w" and "h". Optional "repeat" (copies side by side,
## "step" pixels apart, default the piece's width) and "track": "hifi" or "linear".
func _build_props() -> void:
	for prop in art.cfg.get("props", []):
		var sheet: String = String(prop.get("sheet", art.cfg.get("tiles", {}).get("sheet", "")))
		var at: Array = prop.get("at", [0, 0])
		var holder := Node2D.new()
		holder.position = Vector2(float(at[0]), float(at[1]))
		holder.material = art.world_material if bool(prop.get("recolour", true)) else null
		var repeat := maxi(1, int(prop.get("repeat", 1)))
		if prop.has("block"):
			var w := int(prop.get("w", 1))
			var h := int(prop.get("h", 1))
			var step := float(prop.get("step", w * TILE))
			for i in repeat:
				for row in h:
					for col in w:
						_prop_sprite(holder, art.frame(sheet, "%s_%d_%d" % [prop["block"], col, row]),
							Vector2(i * step + col * TILE, (row - h) * TILE))
		else:
			var tex := art.frame(sheet, String(prop.get("frame", "")))
			if tex != null:
				var step := float(prop.get("step", tex.get_width()))
				for i in repeat:
					_prop_sprite(holder, tex, Vector2(i * step, -tex.get_height()))
		match String(prop.get("track", "")):
			"hifi":
				holder.add_to_group("track_hifi_only")
			"linear":
				holder.add_to_group("track_linear_only")
		if prop.has("flag") or prop.has("unless_flag"):
			flag_props.append({"node": holder, "flag": String(prop.get("flag", prop.get("unless_flag", ""))),
				"negate": prop.has("unless_flag")})
			holder.visible = prop.has("unless_flag")
		add_child(holder)


func _prop_sprite(holder: Node2D, tex: Texture2D, top_left: Vector2) -> void:
	if tex == null:
		return
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.position = top_left
	s.use_parent_material = true
	holder.add_child(s)


# --- Graybox -------------------------------------------------------------------------------


func _rect_visual(rect: Rect2, color: Color, parent: Node) -> void:
	var cr := ColorRect.new()
	cr.position = rect.position
	cr.size = rect.size
	cr.color = color
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(cr)


func _label(text: String, at: Vector2) -> void:
	if text == "":
		return
	var l := Label.new()
	l.text = text
	l.position = at
	if font != null:
		l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", 14)
	l.modulate = Color(1, 1, 1, 0.75)
	if art != null and art.zoom() > 1.0:
		# Keep labels at their screen size when the camera zooms in on pixel art.
		l.scale = Vector2.ONE / art.zoom()
		l.add_theme_constant_override("outline_size", 4)
		l.add_theme_color_override("font_outline_color", Color.BLACK)
	add_child(l)

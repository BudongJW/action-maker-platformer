## Builds a graybox level from a JSON description (prototype only).
##
## Shapes are [x, y, w, h] in pixels. Track-only shapes join the TrackMixer groups so the mixer
## can show, hide and disable them. Triggers are data for ProtoGame; the level only draws them.
class_name ProtoLevel
extends Node2D

const COLOR_SOLID := Color(0.42, 0.42, 0.40)
const COLOR_HIFI := Color(0.25, 0.62, 0.70)
const COLOR_LINEAR := Color(0.62, 0.32, 0.56)
const COLOR_LADDER := Color(0.75, 0.66, 0.30)
const COLOR_WATER := Color(0.16, 0.30, 0.38, 0.85)
const COLOR_TRIGGER := Color(1, 1, 1, 0.08)

var data: Dictionary = {}
var size := Vector2(4000, 900)
var ladders: Array[Rect2] = []
var font: Font


func build(level: Dictionary, label_font: Font = null) -> void:
	data = level
	font = label_font
	var s: Array = level.get("size", [4000, 900])
	size = Vector2(float(s[0]), float(s[1]))
	var water: Dictionary = level.get("water", {})
	if not water.is_empty():
		_rect_visual(Rect2(0, float(water.get("y", size.y)), size.x, size.y), COLOR_WATER, self)
	for r in level.get("solids", []):
		_solid(_rect(r), COLOR_SOLID, "")
	for r in level.get("hifi_only", []):
		_solid(_rect(r), COLOR_HIFI, "track_hifi_only")
	for r in level.get("linear_only", []):
		_solid(_rect(r), COLOR_LINEAR, "track_linear_only")
	for r in level.get("ladders", []):
		var rect := _rect(r)
		ladders.append(rect)
		_rect_visual(rect, COLOR_LADDER, self)
	for t in level.get("triggers", []):
		if t.has("rect"):
			_rect_visual(_rect(t["rect"]), COLOR_TRIGGER, self)
	for npc in level.get("npcs", []):
		var p := Vector2(float(npc["x"]), float(npc["y"]))
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


static func to_rect(r: Variant) -> Rect2:
	return Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3]))


func _rect(r: Variant) -> Rect2:
	return ProtoLevel.to_rect(r)


func _solid(rect: Rect2, color: Color, group: String) -> void:
	var body := StaticBody2D.new()
	body.position = rect.position + rect.size / 2.0
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.add_child(shape)
	_rect_visual(Rect2(-rect.size / 2.0, rect.size), color, body)
	if group != "":
		body.add_to_group(group)
	add_child(body)


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
	add_child(l)

## Prototype dialogue window, captions, bark bubble, HUD and hub overlay, plus optional
## screen art: the camera viewfinder, a hub backdrop and the track badge.
##
## Shows whatever StoryRunner sends; it contains no dialogue text. Labels the prototype itself
## needs (REC, track names, key hints) are short English placeholders, not game text.
class_name ProtoUI
extends CanvasLayer

var font: Font
var _window: PanelContainer
var _name: Label
var _text: Label
var _choices: Label
var _caption: Label
var _bubble: Label
var _hud: Label
var _toast: Label
var _hub: Label
var _flash: ColorRect
var _dark: ColorRect
var _backdrop: TextureRect
var _viewfinder: TextureRect
var _badge: TextureRect
var _timecode: Label
var _vf_rec: Texture2D
var _vf_standby: Texture2D
var _captions: Array = []
var _caption_clock := 0.0
var _bubble_left := 0.0
var _toast_left := 0.0


func _ready() -> void:
	layer = 10
	_dark = _full_rect(Color(0, 0, 0, 0))
	_backdrop = _full_texture()
	_backdrop.visible = false
	_viewfinder = _full_texture()
	_badge = TextureRect.new()
	_badge.position = Vector2(64, 92)
	_badge.scale = Vector2(2, 2)
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_badge)
	# Below the dialogue window, so the window covers it like the rest of the viewfinder.
	_timecode = _anchored_label(0.835, 0.955, 0.875, 0.935, 22)
	_timecode.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var tc_box := StyleBoxFlat.new()
	tc_box.bg_color = Color(0.05, 0.04, 0.07, 1.0)
	_timecode.add_theme_stylebox_override("normal", tc_box)
	_timecode.visible = false
	_flash = _full_rect(Color(1, 1, 1, 0))
	_window = PanelContainer.new()
	_window.anchor_left = 0.08
	_window.anchor_right = 0.92
	_window.anchor_top = 0.70
	_window.anchor_bottom = 0.96
	var box := VBoxContainer.new()
	_window.add_child(box)
	_name = _label(18, Color(0.95, 0.85, 0.55))
	_text = _label(20, Color.WHITE)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_choices = _label(18, Color(0.75, 0.92, 1.0))
	box.add_child(_name)
	box.add_child(_text)
	box.add_child(_choices)
	add_child(_window)
	_window.visible = false
	_caption = _anchored_label(0.1, 0.9, 0.86, 0.93, 20)
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bubble = _anchored_label(0.3, 0.7, 0.18, 0.26, 18)
	_bubble.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud = _anchored_label(0.01, 0.6, 0.01, 0.08, 16)
	_toast = _anchored_label(0.6, 0.99, 0.01, 0.08, 16)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hub = _anchored_label(0.1, 0.9, 0.35, 0.6, 22)
	_hub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


## Draws the camera viewfinder over the world (REC and standby frames, 320x180 art).
func set_viewfinder(rec: Texture2D, standby: Texture2D) -> void:
	_vf_rec = rec
	_vf_standby = standby
	_viewfinder.texture = standby
	# The art has a placeholder timecode; the live one is drawn over it (see _process).
	_hud.anchor_top = 0.15 if rec != null else 0.01
	_hud.anchor_bottom = 0.22 if rec != null else 0.08


func set_recording(on: bool) -> void:
	if _vf_rec != null:
		_viewfinder.texture = _vf_rec if on else _vf_standby


func set_timecode(text: String) -> void:
	_timecode.text = text


func set_badge(tex: Texture2D) -> void:
	_badge.texture = tex


## Full-screen picture behind the hub text (for example the workroom); null hides it.
func set_backdrop(tex: Texture2D) -> void:
	_backdrop.texture = tex
	_backdrop.visible = tex != null
	_viewfinder.visible = tex == null
	_badge.visible = tex == null


func show_line(speaker: String, text: String) -> void:
	_window.visible = true
	_name.text = speaker
	_text.text = text
	_choices.text = "[Enter]"


func show_choices(options: Array) -> void:
	_window.visible = true
	var lines: PackedStringArray = []
	for i in options.size():
		var o: Dictionary = options[i]
		lines.append("%d. %s%s" % [i + 1, o["text"], "" if o["enabled"] else " (x)"])
	_choices.text = "\n".join(lines)


func hide_window() -> void:
	_window.visible = false


## Plays subtitle cue lines ({text, attrs.at, attrs.dur, attrs.display_name}).
func play_cue(lines: Array) -> void:
	_captions = lines
	_caption_clock = 0.0


func bubble(text: String, seconds: float = 3.0) -> void:
	_bubble.text = text
	_bubble_left = seconds


func toast(text: String, seconds: float = 2.0) -> void:
	_toast.text = text
	_toast_left = seconds


func set_hud(text: String) -> void:
	_hud.text = text


func set_hub(text: String) -> void:
	_hub.text = text
	_hub.visible = text != ""


func set_darkness(alpha: float) -> void:
	_dark.color.a = alpha


func flash(alpha: float) -> void:
	_flash.color.a = alpha


func _process(delta: float) -> void:
	_flash.color.a = maxf(0.0, _flash.color.a - delta * 8.0)
	_caption_clock += delta
	_timecode.visible = _vf_rec != null and not _backdrop.visible
	var shown: PackedStringArray = []
	for line in _captions:
		var at: float = float(line["attrs"].get("at", 0.0))
		var dur: float = float(line["attrs"].get("dur", 2.0))
		if _caption_clock >= at and _caption_clock < at + dur:
			var who: String = String(line["attrs"].get("display_name", ""))
			shown.append((who + ": " if who != "" else "") + String(line.get("text", "")))
	_caption.text = "\n".join(shown)
	# Captions sit above the dialogue window while it is open, so the two never overlap.
	_caption.anchor_top = 0.60 if _window.visible else 0.86
	_caption.anchor_bottom = 0.68 if _window.visible else 0.93
	_bubble_left -= delta
	if _bubble_left <= 0.0:
		_bubble.text = ""
	_toast_left -= delta
	if _toast_left <= 0.0:
		_toast.text = ""


func _full_texture() -> TextureRect:
	var r := TextureRect.new()
	r.anchor_right = 1.0
	r.anchor_bottom = 1.0
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


func _full_rect(color: Color) -> ColorRect:
	var r := ColorRect.new()
	r.anchor_right = 1.0
	r.anchor_bottom = 1.0
	r.color = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


func _label(size_px: int, color: Color) -> Label:
	var l := Label.new()
	if font != null:
		l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	return l


func _anchored_label(left: float, right: float, top: float, bottom: float, size_px: int) -> Label:
	var l := _label(size_px, Color.WHITE)
	l.anchor_left = left
	l.anchor_right = right
	l.anchor_top = top
	l.anchor_bottom = bottom
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 4)
	add_child(l)
	return l

## Prototype dialogue window with a choice list, document viewer, captions, bark bubble, HUD and
## hub overlay, plus optional screen art: nine-slice panels (apply_skin), the camera viewfinder,
## a hub backdrop, the track badge and a voice waveform.
##
## Shows whatever StoryRunner sends; it contains no dialogue text. Labels the prototype itself
## needs (REC, track names, key hints) are short English placeholders, not game text.
class_name ProtoUI
extends CanvasLayer

var font: Font
var _window: PanelContainer
var _name: Label
var _text: Label
var _hint: Label
var _choice_box: VBoxContainer
var _choice_style: StyleBox
var _cursor: Texture2D
var _doc: PanelContainer
var _doc_title: Label
var _doc_body: Label
var _caption: Label
var _bubble: Label
var _hud: Label
var _toast: Label
var _prompt: Label
var _hub: Label
var _flash: ColorRect
var _dark: ColorRect
var _backdrop: TextureRect
var _viewfinder: TextureRect
var _cut: TextureRect
var _cut_back: ColorRect
var _camera_off := false
var _badge: TextureRect
var _timecode: Label
var _vf_rec: Texture2D
var _vf_standby: Texture2D
var _wave: Control
var _wave_color := Color(0.5, 0.88, 0.82)
var _wave_time := 0.0
var _captions: Array = []
var _text_scale := 1.0
var _captions_on := true
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
	# A picture for one dialogue (art "cuts"): over the world and the viewfinder, fitted into
	# the space above the dialogue window so the window never covers it.
	_cut_back = _full_rect(Color(0.02, 0.02, 0.03, 1.0))
	_cut_back.visible = false
	_cut = _full_texture()
	_cut.anchor_bottom = 0.69
	_cut.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_cut.visible = false
	_flash = _full_rect(Color(1, 1, 1, 0))
	_window = PanelContainer.new()
	_window.anchor_left = 0.08
	_window.anchor_right = 0.92
	_window.anchor_top = 0.70
	_window.anchor_bottom = 0.96
	# Taller content (choices) grows the window upward, never off the bottom of the screen.
	_window.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var box := VBoxContainer.new()
	_window.add_child(box)
	_name = _label(18, Color(0.95, 0.85, 0.55))
	_text = _label(20, Color.WHITE)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_choice_box = VBoxContainer.new()
	_hint = _label(16, Color(0.75, 0.92, 1.0))
	box.add_child(_name)
	box.add_child(_text)
	box.add_child(_choice_box)
	box.add_child(_hint)
	add_child(_window)
	_window.visible = false
	_wave = Control.new()
	_wave.anchor_left = 0.08
	_wave.anchor_right = 0.36
	_wave.anchor_top = 0.62
	_wave.anchor_bottom = 0.69
	_wave.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wave.visible = false
	_wave.draw.connect(_draw_wave)
	add_child(_wave)
	_caption = _anchored_label(0.1, 0.9, 0.86, 0.93, 20)
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bubble = _anchored_label(0.3, 0.7, 0.18, 0.26, 18)
	_bubble.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud = _anchored_label(0.01, 0.6, 0.01, 0.08, 16)
	_toast = _anchored_label(0.6, 0.99, 0.01, 0.08, 16)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hub = _anchored_label(0.1, 0.9, 0.35, 0.6, 22)
	_hub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt = _anchored_label(0.3, 0.7, 0.62, 0.68, 20)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Last, so a document covers the HUD and captions while it is open.
	_build_doc()


## Draws the camera viewfinder over the world (REC and standby frames, 320x180 art).
func set_viewfinder(rec: Texture2D, standby: Texture2D) -> void:
	_vf_rec = rec
	_vf_standby = standby
	_viewfinder.texture = standby
	# The art has a placeholder timecode; the live one is drawn over it (see _process).
	_hud.anchor_top = 0.15 if rec != null else 0.01
	_hud.anchor_bottom = 0.22 if rec != null else 0.08


## A soft waveform above the dialogue window for a voice with no body on screen.
func set_voice(on: bool) -> void:
	_wave.visible = on


func set_voice_color(color: Color) -> void:
	_wave_color = color


## Once the camera is off for good: no viewfinder, badge or timecode.
func set_camera_off(off: bool) -> void:
	if off == _camera_off:
		return
	_camera_off = off
	_viewfinder.visible = not off and not _backdrop.visible
	_badge.visible = not off and not _backdrop.visible


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
	_viewfinder.visible = tex == null and not _camera_off
	_badge.visible = tex == null and not _camera_off


## Shows a full-screen picture while a dialogue plays (null hides it).
func set_cut(tex: Texture2D) -> void:
	_cut.texture = tex
	_cut.visible = tex != null
	_cut_back.visible = tex != null
	# The workroom text would sit on top of the picture during a hub dialogue.
	_hub.visible = tex == null and _hub.text != ""


## Nine-slice panels from the art block's "ui" entry:
## {"sheet", "scale", "window", "nametag", "choice", "paper": {"frame", "margin"}, "cursor": frame}.
func apply_skin(art: ProtoArt) -> void:
	if art == null or not art.enabled():
		return
	var cfg: Dictionary = art.cfg.get("ui", {})
	if cfg.is_empty():
		return
	var sheet: String = String(cfg.get("sheet", ""))
	var k := int(cfg.get("scale", 3))
	var sb: StyleBoxTexture = art.stylebox(sheet, cfg.get("window", {}), k)
	if sb != null:
		_window.add_theme_stylebox_override("panel", sb)
		_window.self_modulate.a = float(cfg.get("window_alpha", 0.92))
	sb = art.stylebox(sheet, cfg.get("nametag", {}), k)
	if sb != null:
		_name.add_theme_stylebox_override("normal", sb)
	_choice_style = art.stylebox(sheet, cfg.get("choice", {}), k)
	if cfg.has("cursor"):
		_cursor = art.scaled(sheet, String(cfg["cursor"]), 2)
	sb = art.stylebox(sheet, cfg.get("paper", {}), k)
	if sb != null:
		_doc.add_theme_stylebox_override("panel", sb)


func show_line(speaker: String, text: String) -> void:
	_window.visible = true
	_name.text = speaker
	_name.visible = speaker != ""
	_text.text = text
	_clear_choices()
	_hint.text = "[Enter]"


## Lists the options; `selected` is highlighted (arrow keys move it, Enter picks it).
func show_choices(options: Array, selected: int = 0) -> void:
	_window.visible = true
	_hint.text = "[Up/Down] [Enter]  [1-4]"
	_clear_choices()
	for i in options.size():
		var o: Dictionary = options[i]
		var row := PanelContainer.new()
		var on := i == selected
		row.add_theme_stylebox_override("panel", _choice_style if on and _choice_style != null else _choice_blank())
		var line := HBoxContainer.new()
		var mark := TextureRect.new()
		mark.custom_minimum_size = Vector2(32, 0)
		mark.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		mark.texture = _cursor if on else null
		line.add_child(mark)
		var label := _label(18, Color(0.75, 0.92, 1.0) if o["enabled"] else Color(0.5, 0.55, 0.6))
		label.text = "%d. %s%s" % [i + 1, o["text"], "" if o["enabled"] else " (x)"]
		if on and _cursor == null:
			label.text = "> " + label.text
		line.add_child(label)
		row.add_child(line)
		_choice_box.add_child(row)


## The document viewer: title and paragraphs drawn over the paper panel.
func show_doc(doc: Dictionary) -> void:
	_doc_title.text = ProtoUI.keep_words(String(doc.get("title", "")))
	_doc_title.visible = _doc_title.text != ""
	_doc_body.text = ProtoUI.keep_words("\n\n".join(PackedStringArray(doc.get("paragraphs", []))))
	_doc.visible = true


## Korean wraps between words, not between syllables (CSS "word-break: keep-all"): the line
## breaker may split Hangul anywhere, so a word joiner (U+2060) goes between the letters of a word.
static func keep_words(text: String) -> String:
	var out := PackedStringArray()
	var prev := 0
	for i in text.length():
		var c := text.unicode_at(i)
		if i > 0 and not _is_space(prev) and not _is_space(c) and (_is_hangul(prev) or _is_hangul(c)):
			out.append(char(0x2060))
		out.append(char(c))
		prev = c
	return "".join(out)


static func _is_hangul(c: int) -> bool:
	return (c >= 0xAC00 and c <= 0xD7A3) or (c >= 0x1100 and c <= 0x11FF) or (c >= 0x3130 and c <= 0x318F)


static func _is_space(c: int) -> bool:
	return c == 0x20 or c == 0x0A or c == 0x09 or c == 0x3000


func hide_doc() -> void:
	_doc.visible = false


func doc_open() -> bool:
	return _doc.visible


## Same padding as the highlight, so moving the cursor does not shift the list.
func _choice_blank() -> StyleBox:
	var sb := StyleBoxEmpty.new()
	if _choice_style != null:
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			sb.set_content_margin(side, _choice_style.get_content_margin(side))
	return sb


func _clear_choices() -> void:
	for c in _choice_box.get_children():
		_choice_box.remove_child(c)
		c.queue_free()


func _build_doc() -> void:
	_doc = PanelContainer.new()
	# Centred and as tall as its text (a short note should not sit on a full page).
	_doc.anchor_left = 0.2
	_doc.anchor_right = 0.8
	_doc.anchor_top = 0.5
	_doc.anchor_bottom = 0.5
	_doc.grow_vertical = Control.GROW_DIRECTION_BOTH
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color(0.85, 0.85, 0.82)
	paper.set_content_margin_all(28)
	_doc.add_theme_stylebox_override("panel", paper)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	_doc.add_child(box)
	var ink := Color(0.1, 0.1, 0.13)
	_doc_title = _label(24, ink)
	_doc_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_doc_body = _label(19, ink)
	_doc_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var hint := _label(15, Color(0.35, 0.35, 0.4))
	hint.text = "[Enter]"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	box.add_child(_doc_title)
	box.add_child(_doc_body)
	box.add_child(hint)
	_doc.visible = false
	add_child(_doc)


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


## Interaction prompt (for example "hang the lantern [E]"); "" hides it.
func set_prompt(text: String) -> void:
	_prompt.text = text


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
	if _wave.visible:
		_wave_time += delta
		_wave.queue_redraw()
	_timecode.visible = _vf_rec != null and not _backdrop.visible and not _camera_off
	var shown: PackedStringArray = []
	for line in _captions:
		var at: float = float(line["attrs"].get("at", 0.0))
		var dur: float = float(line["attrs"].get("dur", 2.0))
		if _caption_clock >= at and _caption_clock < at + dur:
			var who: String = String(line["attrs"].get("display_name", ""))
			shown.append((who + ": " if who != "" else "") + String(line.get("text", "")))
	_caption.text = "\n".join(shown) if _captions_on else ""
	# Captions sit above the dialogue window while it is open, so the two never overlap.
	_caption.anchor_top = 0.60 if _window.visible else 0.86
	_caption.anchor_bottom = 0.68 if _window.visible else 0.93
	_bubble_left -= delta
	if _bubble_left <= 0.0:
		_bubble.text = ""
	_toast_left -= delta
	if _toast_left <= 0.0:
		_toast.text = ""


func _draw_wave() -> void:
	var size := _wave.size
	var mid := size.y / 2.0
	var points := PackedVector2Array()
	var steps := 96
	# Small and gentle on purpose: the voice is not a threat.
	var level := 0.35 + 0.25 * sin(_wave_time * 2.3) * sin(_wave_time * 0.7)
	for i in steps + 1:
		var x := size.x * float(i) / steps
		var u := float(i) / steps
		var taper := sin(u * PI)
		var y := sin(u * 23.0 + _wave_time * 5.0) * 0.6 + sin(u * 41.0 - _wave_time * 7.0) * 0.4
		points.append(Vector2(x, mid + y * taper * level * mid))
	var faded := _wave_color
	faded.a = 0.8
	_wave.draw_polyline(points, faded, 2.0, true)


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


## Text size setting: scales every label created by this UI (dialogue, choices, captions, docs).
func set_text_scale(scale: float) -> void:
	_text_scale = scale
	_rescale(self)


func set_captions(on: bool) -> void:
	_captions_on = on


## The skin's panels, shared with the settings screen.
func window_style() -> StyleBox:
	return _window.get_theme_stylebox("panel") if _window.has_theme_stylebox_override("panel") else null


func choice_style() -> StyleBox:
	return _choice_style


func cursor_texture() -> Texture2D:
	return _cursor


func _rescale(node: Node) -> void:
	for c in node.get_children():
		if c is Label and c.has_meta("base_size"):
			c.add_theme_font_size_override("font_size", int(round(int(c.get_meta("base_size")) * _text_scale)))
		_rescale(c)


func _label(size_px: int, color: Color) -> Label:
	var l := Label.new()
	if font != null:
		l.add_theme_font_override("font", font)
	l.set_meta("base_size", size_px)
	l.add_theme_font_size_override("font_size", int(round(size_px * _text_scale)))
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

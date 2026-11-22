## The tape deck panel (docs/ui-ux.md P0-3), in place of the development status line: the three
## track switches (LINEAR, HI-FI, MIX; the current one pressed in, a locked one with a padlock),
## the play counter and the fast-forward mark, each with its key for the current input device.
##
## Folded it shows only the current track, and the fast-forward mark while the tape runs fast. It
## opens for a few seconds when the track or the speed changes (or a locked track is tried), and
## stays open in the workroom (always_open). ProtoUI places it.
##
## Flat boxes and drawn glyphs stand in until the deck art (mbs_ui_deck) exists. Track names are
## the deck's own labels; the counter and messages come from the UI strings (ui.deck.*).
class_name ProtoDeck
extends PanelContainer

## Seconds the panel stays open after a change.
const HOLD := 3.0
## Seconds a locked switch keeps its warning border (a steady colour, not a blink).
const WARN := 1.5
const ORDER := [TrackMixer.Track.LINEAR, TrackMixer.Track.HIFI, TrackMixer.Track.MIX]
const NAMES := {TrackMixer.Track.LINEAR: "LINEAR", TrackMixer.Track.HIFI: "HI-FI", TrackMixer.Track.MIX: "MIX"}
const ACTIONS := {TrackMixer.Track.LINEAR: "track_linear", TrackMixer.Track.HIFI: "track_hifi", TrackMixer.Track.MIX: "track_mix"}
## Close to the track badges' colours; the names are always written too.
const COLORS := {TrackMixer.Track.LINEAR: Color(1.0, 0.37, 0.68), TrackMixer.Track.HIFI: Color(0.37, 0.88, 0.82), TrackMixer.Track.MIX: Color(0.78, 0.71, 1.0)}
const KEY_COLOR := Color(0.75, 0.92, 1.0)
const WARN_COLOR := Color(0.96, 0.72, 0.32)

var font: Font
var input: ProtoInput
## The workroom keeps the panel open.
var always_open := false
var _track := -1
var _ff := 1.0
var _play := 0
## Track -> "" (free), "locked" (not unlocked yet) or "held" (a lock rule keeps the player off it).
var _blocked: Dictionary = {}
var _open_left := 0.0
var _warn_track := -1
var _warn_left := 0.0
## What is drawn now, so the row is rebuilt only when something changes.
var _shown := ""
var _row: HBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var back := StyleBoxFlat.new()
	back.bg_color = Color(0.04, 0.04, 0.06, 0.82)
	back.border_color = Color(0.28, 0.29, 0.34)
	back.set_border_width_all(1)
	back.set_content_margin_all(5)
	add_theme_stylebox_override("panel", back)
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", 6)
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_row)


## The game's state each frame: the track (TrackMixer.Track), why each track is blocked, the play
## count and the tape speed. A new track or a change of speed opens the panel.
func show_state(track: int, blocked: Dictionary, play: int, ff: float) -> void:
	if _track != -1 and (track != _track or (ff > 1.0) != (_ff > 1.0)):
		open()
	_track = track
	_blocked = blocked
	_play = play
	_ff = ff


## Opens the panel for HOLD seconds.
func open() -> void:
	_open_left = HOLD


## A locked track was tried: open the panel and mark that switch for a moment.
func warn(track: int) -> void:
	_warn_track = track
	_warn_left = WARN
	open()


func is_open() -> bool:
	return always_open or _open_left > 0.0


## Open because something just changed (not only because the workroom keeps it open).
func recently_changed() -> bool:
	return _open_left > 0.0


func _process(delta: float) -> void:
	_open_left = maxf(0.0, _open_left - delta)
	_warn_left = maxf(0.0, _warn_left - delta)
	if _track == -1:
		return
	var device := input.device if input != null else ""
	var state := "%d|%s|%d|%s|%s|%d|%s" % [_track, str(_blocked), _play, str(_ff > 1.0), str(is_open()),
		_warn_track if _warn_left > 0.0 else -1, device]
	if state != _shown:
		_shown = state
		_rebuild()


func _rebuild() -> void:
	for c in _row.get_children():
		_row.remove_child(c)
		c.queue_free()
	var full := is_open()
	for t in ORDER:
		if full or t == _track:
			_row.add_child(_switch(t, full))
	if full:
		var counter := _label(18, Color(0.86, 0.87, 0.9))
		counter.text = tr("ui.deck.counter").format({"n": _play})
		_row.add_child(_spaced(counter))
	if full or _ff > 1.0:
		_row.add_child(_ff_mark(full))


func _switch(t: int, full: bool) -> Control:
	var on := t == _track
	# The track playing is never shown locked (a story trigger may switch to a locked one).
	var block: String = "" if on else String(_blocked.get(t, ""))
	var sb := StyleBoxFlat.new()
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	sb.set_border_width_all(1)
	if on:
		# Pressed in: tinted, a heavier top edge.
		sb.bg_color = (COLORS[t] as Color).darkened(0.6)
		sb.border_color = COLORS[t]
		sb.border_width_top = 3
	else:
		# Standing out: dark, a heavier bottom edge.
		sb.bg_color = Color(0.09, 0.09, 0.11)
		sb.border_color = Color(0.34, 0.35, 0.4)
		sb.border_width_bottom = 3
	if t == _warn_track and _warn_left > 0.0:
		sb.border_color = WARN_COLOR
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", sb)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 5)
	if block != "":
		line.add_child(_Glyph.new("lock", Color(0.6, 0.62, 0.66)))
	var name_label := _label(18, Color.WHITE if on else (Color(0.5, 0.52, 0.56) if block != "" else Color(0.8, 0.82, 0.86)))
	name_label.text = String(NAMES[t])
	line.add_child(name_label)
	if full:
		var key := _key_hint(String(ACTIONS[t]))
		if key != null:
			line.add_child(key)
	box.add_child(line)
	return box


func _ff_mark(full: bool) -> Control:
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 5)
	var running := _ff > 1.0
	line.add_child(_Glyph.new("ff", Color(1.0, 0.93, 0.7) if running else Color(0.45, 0.47, 0.52)))
	if running:
		var speed := _label(18, Color(1.0, 0.93, 0.7))
		speed.text = "x%d" % int(_ff)
		line.add_child(speed)
	if full:
		var key := _key_hint("ff")
		if key != null:
			line.add_child(key)
	return _spaced(line)


func _key_hint(action: String) -> Label:
	if input == null:
		return null
	var key := input.label(action)
	if key == "":
		return null
	var l := _label(15, KEY_COLOR)
	l.text = "[%s]" % key
	return l


## A little room on the left, between the switches and the counter or the speed.
func _spaced(c: Control) -> Control:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 6)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.add_child(c)
	return m


func _label(size_px: int, color: Color) -> Label:
	var l := Label.new()
	if font != null:
		l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l


## Small square-pixel glyphs: a padlock and the fast-forward mark (two triangles).
class _Glyph extends Control:
	var kind := ""
	var color := Color.WHITE

	func _init(glyph_kind: String, glyph_color: Color) -> void:
		kind = glyph_kind
		color = glyph_color
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		custom_minimum_size = Vector2(10, 14) if kind == "lock" else Vector2(16, 10)

	func _draw() -> void:
		if kind == "lock":
			# Shackle, then the body with a dark keyhole.
			draw_rect(Rect2(2, 0, 6, 2), color)
			draw_rect(Rect2(2, 0, 2, 6), color)
			draw_rect(Rect2(6, 0, 2, 6), color)
			draw_rect(Rect2(0, 6, 10, 8), color)
			draw_rect(Rect2(4, 8, 2, 3), Color(0.05, 0.05, 0.07))
		else:
			for x in [0.0, 8.0]:
				draw_colored_polygon(PackedVector2Array([Vector2(x, 0), Vector2(x + 8, 5), Vector2(x, 10)]), color)

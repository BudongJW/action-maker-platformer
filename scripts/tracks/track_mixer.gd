## Switches between two recordings of the same night and keeps the tape clock.
##
## A VHS Hi-Fi deck stores two audio tracks. An audio dub rewrites only the linear track, so
## the two tracks are identical except inside the dubbed segments. The mixer models that:
## - three listening modes (HIFI, LINEAR, MIX) with an audio crossfade between two buses,
## - node groups that exist only in one track (visible and colliding only in that mode),
## - "edit segments" on the tape timeline where the two tracks diverge, with a ramp so the
##   difference grows as the playhead approaches a segment,
## - timeline events (for example a power cut at a given tape time) that fire once per pass.
## Docs: docs/scare-director.md, section "Track mixer".
class_name TrackMixer
extends Node

enum Track { HIFI, LINEAR, MIX }

signal track_changed(track: int)
signal timeline_event(event_name: String)
signal segment_entered(index: int)
signal segment_exited(index: int)

## Tape seconds per real second (a two-hour tape played in twelve minutes is 10.0).
var time_scale: float = 10.0
## Seconds for the audio crossfade between tracks.
var crossfade: float = 0.25
## Tape seconds over which the tracks start to diverge before and after a segment.
var divergence_ramp: float = 10.0
## Audio buses; empty names are ignored.
var hifi_bus: String = ""
var linear_bus: String = ""
## Node groups that exist only in one track.
var hifi_group: String = "track_hifi_only"
var linear_group: String = "track_linear_only"
## Opacity of track-only nodes in MIX mode.
var mix_alpha: float = 0.5
## Flag written to the bound StoryRunner when the track changes (true only in HIFI).
var hifi_flag: String = "loop.track_hifi"
## Call tick() from _process(). Turn off in tests.
var auto_process: bool = true
## Stop the clock (for example while a dialogue is open).
var paused: bool = false

var _track: Track = Track.LINEAR
var _tape: float = 0.0
var _gains := Vector2(0.0, 1.0)
var _segments: Array = []
var _inside: Dictionary = {}
var _events: Array = []
var _story: Node = null


func _process(delta: float) -> void:
	if auto_process:
		tick(delta)


## Connects a StoryRunner so the track and timeline events become story flags.
func bind_story(runner: Node) -> void:
	_story = runner
	_write_flag(hifi_flag, _track == Track.HIFI)


func set_track(track: Track) -> void:
	if track == _track:
		return
	_track = track
	_write_flag(hifi_flag, track == Track.HIFI)
	track_changed.emit(track)


func get_track() -> Track:
	return _track


## Target (hifi, linear) linear-amplitude gains for the current track. MIX keeps equal power.
func target_gains() -> Vector2:
	match _track:
		Track.HIFI:
			return Vector2(1.0, 0.0)
		Track.LINEAR:
			return Vector2(0.0, 1.0)
	return Vector2(sqrt(0.5), sqrt(0.5))


## Current (hifi, linear) gains after the crossfade.
func gains() -> Vector2:
	return _gains


func tape_time() -> float:
	return _tape


## Moves the playhead. Events before the new position count as fired; events after it are re-armed.
func seek(tape_seconds: float) -> void:
	_tape = maxf(0.0, tape_seconds)
	for ev in _events:
		ev["fired"] = float(ev["at"]) < _tape
	_update_segments()


## Rewinds to the start and re-arms every event (a new loop).
func rewind() -> void:
	seek(0.0)


## Segments are [start, end] pairs in tape seconds.
func set_segments(segments: Array) -> void:
	_segments.clear()
	for s in segments:
		_segments.append(Vector2(float(s[0]), float(s[1])))
	_inside.clear()
	_update_segments()


## Index of the segment that contains `tape_seconds`, or -1.
func segment_at(tape_seconds: float) -> int:
	for i in _segments.size():
		var s: Vector2 = _segments[i]
		if tape_seconds >= s.x and tape_seconds <= s.y:
			return i
	return -1


## 0 where both tracks are identical, 1 inside a dubbed segment, ramping in between.
func divergence(tape_seconds: float = -1.0) -> float:
	var t: float = _tape if tape_seconds < 0.0 else tape_seconds
	var best := 0.0
	for s in _segments:
		var seg: Vector2 = s
		var d := 0.0
		if t >= seg.x and t <= seg.y:
			d = 1.0
		elif divergence_ramp > 0.0:
			var gap: float = minf(absf(t - seg.x), absf(t - seg.y))
			d = clampf(1.0 - gap / divergence_ramp, 0.0, 1.0)
		best = maxf(best, d)
	return best


## Fires `timeline_event(event_name)` once per pass when the playhead reaches `tape_seconds`.
## If `flag` is set, it is also written to the bound StoryRunner as true.
func add_event(tape_seconds: float, event_name: String, flag: String = "") -> void:
	_events.append({"at": tape_seconds, "name": event_name, "flag": flag, "fired": tape_seconds < _tape})
	_events.sort_custom(func(a, b): return float(a["at"]) < float(b["at"]))


## Visibility, opacity and collision for track-only nodes under `root`.
func apply_layers(root: Node) -> void:
	for node in _collect(root, hifi_group):
		_apply_node(node, _track == Track.HIFI, _track == Track.MIX)
	for node in _collect(root, linear_group):
		_apply_node(node, _track == Track.LINEAR, _track == Track.MIX)


## Advances the tape clock and the crossfade.
func tick(delta: float) -> void:
	var dt: float = maxf(0.0, delta)
	var target := target_gains()
	var step: float = 1.0 if crossfade <= 0.0 else dt / crossfade
	_gains = Vector2(move_toward(_gains.x, target.x, step), move_toward(_gains.y, target.y, step))
	_apply_bus(hifi_bus, _gains.x)
	_apply_bus(linear_bus, _gains.y)
	if paused:
		return
	_tape += dt * time_scale
	for ev in _events:
		if not ev["fired"] and float(ev["at"]) <= _tape:
			ev["fired"] = true
			if String(ev["flag"]) != "":
				_write_flag(String(ev["flag"]), true)
			timeline_event.emit(String(ev["name"]))
	_update_segments()


func _update_segments() -> void:
	for i in _segments.size():
		var seg: Vector2 = _segments[i]
		var now_inside: bool = _tape >= seg.x and _tape <= seg.y
		var was: bool = _inside.get(i, false)
		if now_inside and not was:
			_inside[i] = true
			segment_entered.emit(i)
		elif was and not now_inside:
			_inside[i] = false
			segment_exited.emit(i)


func _apply_node(node: Node, active: bool, mixed: bool) -> void:
	if node is CanvasItem:
		var item := node as CanvasItem
		item.visible = active or mixed
		var c := item.modulate
		c.a = mix_alpha if mixed else 1.0
		item.modulate = c
	# Only the active track collides; in MIX nothing track-only is solid.
	node.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED


func _collect(root: Node, group: String) -> Array:
	var out: Array = []
	if root.is_in_group(group):
		out.append(root)
	for child in root.get_children():
		out.append_array(_collect(child, group))
	return out


func _apply_bus(bus: String, gain: float) -> void:
	if bus == "":
		return
	var idx := AudioServer.get_bus_index(bus)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(gain, 0.0001)))


func _write_flag(flag: String, value: bool) -> void:
	if _story != null and flag != "" and _story.has_method("set_flag"):
		_story.call("set_flag", flag, value)

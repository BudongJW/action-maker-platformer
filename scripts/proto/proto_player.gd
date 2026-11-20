## Graybox platformer body for the prototype: run, jump, ladders, and a REC toggle.
##
## Input comes from the keyboard, or from `bot_axis` / `bot_jump` when a bot drives it.
## Drawn as a box, or as an animated sprite (idle, walk, jump, climb, caught) given by set_art().
## ACTION GAME MAKER G will replace this with its own player object; only the hooks the
## prototype needs (position, `recording`, `frozen`) matter.
class_name ProtoPlayer
extends CharacterBody2D

const SPEED := 230.0
const CLIMB_SPEED := 160.0
const JUMP_VELOCITY := -520.0
const GRAVITY := 1400.0

## Set by ProtoGame: the level, for ladder checks.
var level: ProtoLevel
## Camera REC is on (evidence is recorded while this is true).
var recording := false
## No movement while a dialogue or a scare onset holds the player.
var frozen := false
## Bot control: -1, 0 or 1 horizontal, and a jump request.
var bot := false
var bot_axis := 0.0
var bot_jump := false
## Forces an animation (for example "caught") while not empty.
var pose_override := ""

var _climbing := false
var _camera: Camera2D
var _body: ColorRect
var _sprite: AnimatedSprite2D


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(20, 40)
	shape.shape = box
	shape.position = Vector2(0, -20)
	add_child(shape)
	_body = ColorRect.new()
	_body.color = Color(0.55, 0.85, 1.0)
	_body.position = Vector2(-10, -40)
	_body.size = Vector2(20, 40)
	add_child(_body)
	_camera = Camera2D.new()
	_camera.position = Vector2(0, -60)
	add_child(_camera)
	_camera.make_current()


## Replaces the box with an animated sprite whose feet are at the origin.
func set_art(sprite: AnimatedSprite2D) -> void:
	if sprite == null:
		return
	_sprite = sprite
	_body.visible = false
	add_child(_sprite)


func set_camera_zoom(zoom: float, offset_y: float) -> void:
	_camera.zoom = Vector2.ONE * zoom
	_camera.position = Vector2(0, offset_y)


func set_camera_limits(size: Vector2) -> void:
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = int(size.x)
	_camera.limit_bottom = int(size.y)


func camera() -> Camera2D:
	return _camera


func _physics_process(delta: float) -> void:
	if frozen:
		velocity = Vector2.ZERO
		_animate(0.0, 0.0)
		return
	# Input actions from ProtoInput (keyboard, d-pad or left stick).
	var axis := bot_axis if bot else _axis("move_left", "move_right")
	var vertical := 0.0 if bot else _axis("move_up", "move_down")
	var jump := bot_jump if bot else (InputMap.has_action("jump") and Input.is_action_pressed("jump"))
	bot_jump = false
	var on_ladder := level != null and level.on_ladder(global_position + Vector2(0, -20))
	if on_ladder and vertical != 0.0:
		_climbing = true
	if not on_ladder:
		_climbing = false
	if _climbing:
		velocity = Vector2(axis * SPEED * 0.5, vertical * CLIMB_SPEED)
		if bot:
			velocity.y = -CLIMB_SPEED
	else:
		velocity.x = axis * SPEED
		velocity.y += GRAVITY * delta
		if jump and is_on_floor():
			velocity.y = JUMP_VELOCITY
	move_and_slide()
	_animate(axis, vertical)


func _animate(axis: float, vertical: float) -> void:
	if _sprite == null:
		return
	var anim := "idle"
	if pose_override != "":
		anim = pose_override
	elif _climbing:
		anim = "climb"
	elif not is_on_floor():
		anim = "jump"
	elif absf(velocity.x) > 1.0:
		anim = "walk"
	if not _sprite.sprite_frames.has_animation(anim):
		anim = "idle"
	if _sprite.animation != anim:
		_sprite.play(anim)
	if anim == "climb":
		_sprite.speed_scale = 1.0 if (vertical != 0.0 or bot) else 0.0
	else:
		_sprite.speed_scale = 1.0
	if axis != 0.0:
		_sprite.flip_h = axis < 0.0


## -1..1 from two actions; a stick past its dead zone counts as fully pressed (pixel movement).
func _axis(negative: String, positive: String) -> float:
	if not InputMap.has_action(negative) or not InputMap.has_action(positive):
		return 0.0
	return signf(Input.get_axis(negative, positive))

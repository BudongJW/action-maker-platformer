## Graybox platformer body for the prototype: run, jump, ladders, and a REC toggle.
##
## Input comes from the keyboard, or from `bot_axis` / `bot_jump` when a bot drives it.
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

var _climbing := false
var _camera: Camera2D


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(20, 40)
	shape.shape = box
	shape.position = Vector2(0, -20)
	add_child(shape)
	var body := ColorRect.new()
	body.color = Color(0.55, 0.85, 1.0)
	body.position = Vector2(-10, -40)
	body.size = Vector2(20, 40)
	add_child(body)
	_camera = Camera2D.new()
	_camera.position = Vector2(0, -60)
	add_child(_camera)
	_camera.make_current()


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
		return
	var axis := bot_axis if bot else _axis(KEY_A, KEY_D, KEY_LEFT, KEY_RIGHT)
	var vertical := 0.0 if bot else _axis(KEY_W, KEY_S, KEY_UP, KEY_DOWN)
	var jump := bot_jump if bot else (Input.is_key_pressed(KEY_SPACE))
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


func _axis(neg_a: Key, pos_a: Key, neg_b: Key, pos_b: Key) -> float:
	var v := 0.0
	if Input.is_key_pressed(neg_a) or Input.is_key_pressed(neg_b):
		v -= 1.0
	if Input.is_key_pressed(pos_a) or Input.is_key_pressed(pos_b):
		v += 1.0
	return v

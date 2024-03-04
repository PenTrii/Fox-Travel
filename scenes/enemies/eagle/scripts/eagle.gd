extends CharacterBody2D

@export_category("Locomotion")
@export var _speed : float = 8
@export var _acceleration : float = 16
@export var _deceleration : float = 32

@export_category("Jump")
@export var _jump_height : float = 2.5
@export var _air_control : float = 0.5
@export var _jump_dust : PackedScene
var _jump_velocity : float
var _was_on_floor : bool

@export_category("Sprite")
@export var _is_facing_left : bool
@export var _sprites_face_left : bool
@onready var _sprite : Sprite2D = $Sprite2D
var was_on_floor: bool

@export_category("Combat")
@export_range(0, 1) var _attack_damage : int = 1
@export var _want_to_attack: bool
@export var _is_hit: bool
@export var _is_dead: bool
@onready var _hurt_box: Area2D = $HurtBox
@onready var _hit_box: Area2D = $HitBox

signal changed_direction(is_facing_left: bool)
signal landed(floor_height: float)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var _direction : float

func _ready():
	_speed *= Global.ppt
	_acceleration *= Global.ppt
	_deceleration *= Global.ppt
	_jump_height *= Global.ppt
	_jump_velocity = sqrt(_jump_height * gravity * 2) * -1
	face_left() if _is_facing_left else face_right()
	_hit_box.monitoring = false

func face_left():
	_is_facing_left = true
	_sprite.flip_h = true
	changed_direction.emit(_is_facing_left)

func face_right():
	_is_facing_left = false
	_sprite.flip_h = false
	changed_direction.emit(_is_facing_left)
	
func attack():
	_want_to_attack = true

func _physics_process(delta):
	if not _is_facing_left && sign(_direction) == -1:
		face_left()
	elif _is_facing_left && sign(_direction) == 1:
		face_right()
	
	was_on_floor = is_on_floor()
	move_and_slide()
	if not was_on_floor && is_on_floor():
		_landed()

func _landed():
	landed.emit(position.y)


func take_damage(amount : int, direction : Vector2):
	velocity = direction * Global.ppt * 5
	_is_hit = true

func _on_hit_box_area_entered(area: Area2D):
	velocity = (area.global_position - global_position).normalized() * Global.ppt * 5
	_is_hit = false
	#area.get_parent().take_damage(_attack_damage, (area.global_position - global_position).normalized())


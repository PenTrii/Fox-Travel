class_name Character extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_category("Locomotion")
@export var _speed: float = 8
@export var _acceleration: float = 16
@export var _deceleration: float = 32

@export_category("Jump")
@export var _jump_height: float = 2.5
@export var air_control: float = 0.5
@export var _jump_dust: PackedScene
var jump_velocity: float

@export_category("Sprite")
@export var _is_facing_left: bool
@export var _sprites_face_left: bool
@onready var _sprite: Sprite2D = $Sprite2D
var was_on_floor: bool

@export_category("Combat")
@export var _want_to_attack: bool
@export var _is_hit: bool
@export var _is_dead: bool
@export var _is_attacking : bool
@onready var _hurt_box: Area2D = $HurtBox
@onready var _hit_box: Area2D = get_node_or_null("HitBox")

var _direction: float

signal changed_direction(is_facing_left: bool)
signal landed(floor_height: float)
signal died()

func _ready():
	_speed *= Global.ppt
	_acceleration *= Global.ppt
	_deceleration *= Global.ppt
	_jump_height *= Global.ppt
	jump_velocity = sqrt(_jump_height * gravity * 2) * -1
	face_left() if _is_facing_left else face_right()
	#if _hit_box:
		#_hit_box.monitoring = false
	_is_attacking = false

#region
func face_left():
	if _is_dead || _is_attacking:
		return
	_is_facing_left = true
	_sprite.flip_h = not _sprites_face_left
	if _hit_box:
		_hit_box.scale.x = 1 if _sprites_face_left else -1
	changed_direction.emit(_is_facing_left)

func face_right():
	if _is_dead || _is_attacking:
		return
	_is_facing_left = false
	_sprite.flip_h = _sprites_face_left
	if _hit_box:
		_hit_box.scale.x = -1 if _sprites_face_left else 1
	changed_direction.emit(_is_facing_left)

func run(direction: float):
	if _is_dead || _is_attacking:
		_direction = 0
	else:
		_direction = direction

func jump():
	if _is_dead:
		return
	if is_on_floor():
		velocity.y = jump_velocity
		_spawn_dust(_jump_dust)

func stop_jump():
	if _is_dead:
		return
	if velocity.y < 0:
		velocity.y = 0
#endregion

func _physics_process(delta):
	if not _is_facing_left && sign(_direction) == -1:
		face_left()
	elif _is_facing_left && sign(_direction) == 1:
		face_right()
	
	if is_on_floor():
		_ground_physics(delta)
	else:
		_air_physics(delta)
	
	was_on_floor = is_on_floor()
	move_and_slide()
	if not was_on_floor && is_on_floor():
		_landed()

func _ground_physics(delta: float):
	if _direction == 0:
		velocity.x = move_toward(velocity.x, 0,  _deceleration * delta)
	elif velocity.x == 0 || sign(_direction) == velocity.x:
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, _direction * _speed, _deceleration * delta)

func _air_physics(delta: float):
	velocity.y += gravity * delta
	if _direction:
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * air_control * delta)

func _landed():
	landed.emit(position.y)

func _spawn_dust(dust: PackedScene):
	var _dust = dust.instantiate()
	_dust.position = position
	_dust.flip_h = _sprite.flip_h
	get_parent().add_child(_dust)

func _take_damage(direction : Vector2, area: Area2D):
	print_debug("take_down 1 ", area.global_position.y)
	print_debug("take_down 2 ", global_position.y)
	if area.global_position.y >= global_position.y:
		_die()
	else:
		_is_hit = true

func _die():
	_is_dead = true
	died.emit()
	_hurt_box.set_deferred("monitorable", false)
	collision_layer = 0
	collision_mask = 1
	_direction = 0

func _on_hit_box_area_entered(area : Area2D):
	print_debug("is attack")
	if not _is_dead:
		area.get_parent()._take_damage((area.global_position - global_position).normalized(), area)

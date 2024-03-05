class_name Eagle extends Character

@onready var _time = $Sprite2D/Timer

func _physics_process(delta):
	was_on_floor = false
	move_and_slide()

func _die():
	super._die()
	_time.start()
	await _time.timeout
	queue_free()

func _on_hit_box_area_entered(area):
	super._on_hit_box_area_entered(area)
	var animation_tree =  $Sprite2D/AnimationPlayer/AnimationTree
	var state_machine = animation_tree.get("parameters/playback")
	var current_animation = state_machine.get_current_node()
	print_debug("Eagle is dead:", _is_dead)
	print_debug("Eagle Current animation:", current_animation)

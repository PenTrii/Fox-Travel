class_name Fox extends Character

@onready var _hurt_time = $Sprite2D/AnimationPlayer/HurtTime

func _on_hit_box_area_entered(area):
	super._on_hit_box_area_entered(area)
	var animation_tree =  $Sprite2D/AnimationPlayer/AnimationTree
	var state_machine = animation_tree.get("parameters/playback")
	var current_animation = state_machine.get_current_node()
	print_debug("Fox is dead:", _is_dead)
	print_debug("Fox Current animation:", current_animation)

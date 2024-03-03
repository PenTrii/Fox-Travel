extends AnimatedSprite2D

func _ready():
	print_debug("call _ready")
	play()

func _on_animation_finished():
	print_debug("call finshed")
	queue_free()

extends Node2D

var push_direction := Vector2.ZERO
var push_speed := 0.0
var push_time := 0.0

func _process(delta):
	if push_time <- 0:
		return
		
	global_position += push_direction * push_speed * delta

	push_time -= delta
	

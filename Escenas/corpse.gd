extends Node2D

# variables del corpse
var push_direction := Vector2.ZERO
var push_speed := 0.0
var push_time := 0.0

# impulso al corpse
func _process(delta):
	if push_time <- 0:
		return
		
	global_position += push_direction * push_speed * delta

	push_time -= delta
	

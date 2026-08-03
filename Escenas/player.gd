extends CharacterBody2D

# velocidad base
@export var speed := 300.0

# referencia al shapeCast2d
@onready var phase_check: ShapeCast2D = $PhaseCheck

# movimiento base
func _physics_process(_delta):
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed
	move_and_slide()
	
	if Input.is_action_just_pressed("phase_shift"):
		var phase_manager := get_tree().get_first_node_in_group("phase_manager")
		
		if phase_manager != null:
			phase_manager.change_phase()
		else:
			push_warning("No se encontrò el PhaseMananager.")
			
#Función para chequear si hay un objeto antes del cambio de fase
func is_phase_blocked(target_mask: int) -> bool:
	phase_check.collision_mask = target_mask
	phase_check.force_shapecast_update()
	
	return phase_check.is_colliding()

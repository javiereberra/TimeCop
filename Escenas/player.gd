extends CharacterBody2D

# velocidad base
@export var speed := 300.0
# crosshair
@export var crosshair_texture: Texture2D
# variables para la cámara espía
@export var peek_distance: = 200.0
@export var dead_zone: = 200.0

# referencia al shapeCast2d
@onready var phase_check: ShapeCast2D = $PhaseCheck
# referencia a cámara pivot
@onready var camera_pivot: Node2D = $CameraPivot
# referencia al aimpivot
@onready var aim_pivot: Node2D = $AimPivot
# referencia al muzzle
@onready var muzzle: Marker2D = $AimPivot/Muzzle

func _ready() -> void:
	# Aplicar el cursor personalizado
	Input.set_custom_mouse_cursor(
		crosshair_texture,
		Input.CURSOR_ARROW,
		Vector2(
			crosshair_texture.get_width() / 2.0,
			crosshair_texture.get_height() / 2.0
		)
	)

# movimiento base
func _physics_process(delta):
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed
	move_and_slide()
	
	#mirar la posición del mouse
	aim_pivot.look_at(get_global_mouse_position())
	#actualiza la cámara al espiar
	update_peek_camera(delta)
	
	# cambio de fase para llamar a su funciòn
	if Input.is_action_just_pressed("phase_shift"):
		var phase_manager := get_tree().get_first_node_in_group("phase_manager")
		
		if phase_manager != null:
			phase_manager.change_phase()
		else:
			push_warning("No se encontrò el PhaseMananager.")
			
	if Input.is_action_just_pressed("shoot"):
		shoot()
#Función para chequear si hay un objeto antes del cambio de fase
func is_phase_blocked(target_mask: int) -> bool:
	phase_check.collision_mask = target_mask
	phase_check.force_shapecast_update()
	
	return phase_check.is_colliding()
	
	# Función para espiar nivel
func update_peek_camera(delta):
	var target_position := Vector2.ZERO
	
	# si presionamos shift, primero calculamos si el cursor está fuera de la zona muerta
	# y calcula la nueva posición de la cámara
	if Input.is_action_pressed("peek"):
		var viewport_center := get_viewport_rect().size / 2
		var mouse_position := get_viewport().get_mouse_position()
		var mouse_offset := mouse_position - viewport_center
				
		if mouse_offset.length() > dead_zone:
			target_position = mouse_offset.normalized() * peek_distance
			
	# dezplaza la cámara suavemente
	camera_pivot.position = camera_pivot.position.lerp(
		target_position,
		1.0 - exp(-12.0 * delta)
	)
	
func shoot():
	#??
	print("bang")
	var space_state := get_world_2d().direct_space_state
	
	# crear consulta para lanzar disparo
	var query := PhysicsRayQueryParameters2D.create(
		muzzle.global_position,
		get_global_mouse_position()		
	)
	# Fijar la consulta sólo en la timeline activa
	query.collision_mask = collision_mask
	
	# Evitar que el disparo choque con el player
	query.exclude = [self]
	
	# Obtener el primer objeto que intercepta
	var result := space_state.intersect_ray(query)
	
	# Si no golpeò nada, termina
	if result.is_empty():
		return
		
	# Guardar el impacto
	var collider = result["collider"]
	
	#Si el objeto tiene die(), eliminar
	if collider.has_method("die"):
		collider.die()
	

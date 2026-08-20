extends CharacterBody2D

# velocidad base
@export var speed := 300.0
# variables para la cámara espía
@export var peek_distance: = 200.0
@export var dead_zone: = 200.0
# referencia a la mira
@onready var crosshair: Sprite2D = $Crosshair
# referencia al shapeCast2d
@onready var phase_check: ShapeCast2D = $PhaseCheck
# referencia a cámara pivot
@onready var camera_pivot: Node2D = $CameraPivot
# referencia al aimpivot
@onready var aim_pivot: Node2D = $AimPivot
# referencia al muzzle
@onready var muzzle: Marker2D = $AimPivot/Muzzle
# Distancia fija para el crosshair con gamepad
@export var gamepad_crosshair_distance := 150.0
# Rango máximo del disparo
@export var shoot_range := 2000.0

# variable para direcciòn de apuntado
var aim_direction := Vector2.RIGHT

# variable para chequear quien controla la mira
var using_gamepad_aim := false

func _ready() -> void:
	#ocultar cursor mouse
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _input(event):
	if event is InputEventMouseMotion:
		using_gamepad_aim = false
		
func _process(_delta):
	# la mira toma posición del mouse
	if not using_gamepad_aim:
		crosshair.global_position = get_global_mouse_position()

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
	
	var gamepad_aim := Input.get_vector(
		"aim_left",
		"aim_right",
		"aim_up",
		"aim_down"
	)
	
	if gamepad_aim.length() > 0.2:
		using_gamepad_aim = true
		aim_direction = gamepad_aim.normalized()
		aim_pivot.rotation = aim_direction.angle()
		
		crosshair.global_position = global_position + aim_direction * gamepad_crosshair_distance
	else:
		#mirar la posición del mouse
		aim_pivot.look_at(crosshair.global_position)
	
	
	
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
	
	var shoot_direction := (
		crosshair.global_position - muzzle.global_position
		).normalized()
	
	var shoot_end := muzzle.global_position + shoot_direction * shoot_range
	# crear consulta para lanzar disparo
	var query := PhysicsRayQueryParameters2D.create(
		muzzle.global_position,
		shoot_end
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
	

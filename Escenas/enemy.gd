extends CharacterBody2D

# VARIABLES EXPORTABLES
@export var patrol_speed := 100.0
@export var chase_speed := 200.0
# REFERENCIAS A NODOS
@onready var obstacle_check: RayCast2D = $ObstacleCheck
@onready var patrol_timer: Timer = $PatrolTimer
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
# VARIABLES DE DETECCIÓN
@export var vision_distance := 500.0
@export var vision_angle := 90.0
# VARIABLES DE CHASE
@export var attack_distance := 50

var last_seen_position := Vector2.ZERO

#  ---ESTADOS DE LA IA----
enum State {
	PATROL,
	CHASE
}

var current_state = State.PATROL

# Variable de PATROL
var is_waiting := false

#Asigna capa de colisión correspondiente al detector de paredes
func _ready():
	obstacle_check.collision_mask = collision_layer

# PROCESAR LOS ESTADOS
func _physics_process(_delta):
	if can_see_player():
		print("VEO AL PLAYER")
	
	if current_state == State.PATROL:
		patrol()
	elif current_state == State.CHASE:
		chase()
	
# FUNCIÒN DEL ESTADO PATROL
func patrol():
	# si ve al jugador, guarda posicion y pasa a CHASE
	if can_see_player():
		last_seen_position = player.global_position
		current_state = State.CHASE
		return
		
	# Si hay una pared delante y no espera, gira 90 grados.
	if obstacle_check.is_colliding() and not is_waiting:
		rotation += deg_to_rad(90)
		# espera, inicia timer
		is_waiting = true
		patrol_timer.start()
		
	# Avanza hacia delante siempre que no espere.
	if is_waiting:
		velocity = Vector2.ZERO
	else:
		velocity = transform.x * patrol_speed	
		
	move_and_slide()
	


#   ESTADO CHASE  
func chase():
	
	#mientras vea al jugador, recordar su posicion
	if not can_see_player():
		current_state = State.PATROL
		velocity = Vector2.ZERO
		return
		
	last_seen_position = player.global_position
		
	#calculamos la distancia entre el enemigo y jugador	
	var distance_to_player := global_position.distance_to(player.global_position)
	
	if can_see_player() and distance_to_player <= attack_distance:
		velocity = Vector2.ZERO
		print("ATTACK")
		return
	
	#se determina direcciòn del player
	var direction_to_target := (
		last_seen_position - global_position
	).normalized()
	
	# el enemigo debe mirar al player
	rotation = direction_to_target.angle()
	
	#lo persigue con la velocidad de chase
	velocity = direction_to_target * chase_speed
	
	move_and_slide()
	
# chequea si están a distancia de la visión del enemigo
func can_see_player():
	# distancia entre enemigo y jugador
	var distance_to_player := global_position.distance_to(player.global_position)
	# si no està a distancia no lo ve
	if distance_to_player > vision_distance:
		return false
	# calcular si el angulo de vision ve al jugador
	var direction_to_player := (player.global_position - global_position).normalized()
	var forward_direction := transform.x.normalized()
	
	var angle_to_player := rad_to_deg(
		acos(forward_direction.dot(direction_to_player))
	)
	
	if angle_to_player > vision_angle / 2:
		return false
		
	# raycast para ver si hay una pared en el medio
	var space_state := get_world_2d().direct_space_state
	
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)
	# la capa del rayo debe ser la misma del enemigo (timeline)
	query.collision_mask = collision_layer | (1 << 2)
	query.exclude = [self]
	# guarda el primer impacto
	var result := space_state.intersect_ray(query)
	
	# si no golpea nada, no ve al player
	if result.is_empty():
		return false
	
	# si golpea algo que no es el player, da falso
	if result["collider"] != player:
		return false
	
	return true
	
# Elinimar al enemigo
func die():
	queue_free()
	

# cuando el timer termina, deja de esperar
func _on_patrol_timer_timeout():
	is_waiting = false

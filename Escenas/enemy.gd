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

#variable exportable de corpse
@export var corpse_scene: PackedScene
#variable de impacto
@export var corpse_push_distance := 12.0
# variable para chequear paredes
@export var corpse_push_check_distance := 25.0
# variable parr un cooldown
@export var shoot_cooldown := 0.5
# temporizador para el disparo
var shoot_timer := 0.0
#Referencia al sonido de disparo
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound

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
func _physics_process(delta):
	print(name, " procesando | layer: ", collision_layer)
	if shoot_timer > 0:
		shoot_timer -= delta
	
	if can_see_player():
		print("VEO AL PLAYER")
	
	if current_state == State.PATROL:
		patrol()
	elif current_state == State.CHASE:
		chase()
	
# ------------- ESTADO PATROL-----------------------
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
	


#   ------------ESTADO CHASE -------------- 
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
		shoot()
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
	# no ve al jugador si esta muerto
	if player.is_dead:
		return false
	
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
func die(impact_direction: Vector2):
	# ----Comprobamos si hay una pared cerca en la dirección del impacto----
	var space_state := get_world_2d().direct_space_state
	
	var check_end := global_position + impact_direction * corpse_push_check_distance
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		check_end
	)
	
	query.collision_mask = collision_layer
	query.exclude = [self]
	
	var result := space_state.intersect_ray(query)
	
	# ----creamos el cadaver y lo posicionamos en rotación al origen del impacto----
	var corpse := corpse_scene.instantiate()
	
	get_parent().add_child(corpse)
	
	corpse.global_position = global_position
	corpse.global_rotation = impact_direction.angle() + deg_to_rad(180)
	
	# ---comprobamos si hay espacio para el empuje ---
	if result.is_empty():
		corpse.push_direction = impact_direction
		corpse.push_speed = 150.0
		corpse.push_time = 0.10		
	else:
		print("no hay espacio")
	
	queue_free()
	
func shoot():
	
	if shoot_timer > 0:
		return
		
	shoot_timer = shoot_cooldown
	shoot_sound.play()
	print("DISPARA: ", name, " | Layer: ", collision_layer)
	
	var shoot_direction := (
		player.global_position - global_position
	).normalized()

	var shoot_end := global_position + shoot_direction * vision_distance

	var space_state := get_world_2d().direct_space_state
	
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		shoot_end
	)
	
	query.collision_mask = collision_layer | (1 << 2)
	query.exclude = [self]
	
	var result := space_state.intersect_ray(query)
	
	if result.is_empty():
		return
		
	var collider = result["collider"]
	
	if collider == player:
		print("PLAYER IMPACTADO")
		player.die(shoot_direction)
		


# cuando el timer termina, deja de esperar
func _on_patrol_timer_timeout():
	is_waiting = false

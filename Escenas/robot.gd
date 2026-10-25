extends CharacterBody2D

# VARIABLES EXPORTABLES
@export var acceleration := 500.0
@export var max_speed := 450.0

# REFERENCIAS A NODOS
@onready var patrol_timer: Timer = $PatrolTimer
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

# referencia a Area2d
@onready var detection_area: Area2D = $DetectionArea
# variable para la rotaciòn lenta
@export var rotation_speed := 2.0

#  ---ESTADOS DE LA IA----
enum State {
	DORMANT,
	ACTIVATING,
	ATTACK
}
# empezamos con dormant
var current_state = State.DORMANT



# PROCESAR LOS ESTADOS
func _physics_process(delta):
		
	if current_state == State.DORMANT:
		dormant()
	elif current_state == State.ACTIVATING:
		activating(delta)
	elif current_state == State.ATTACK:
		attack(delta)
	
# ------------- ESTADO DORMANT-----------------------
func dormant():
	# el robot permanece inmovil
	velocity = Vector2.ZERO
	
	# si ve al jugador, guarda posicion y pasa a ATTACK
	if can_see_player():		
		current_state = State.ACTIVATING
		return
		
#  --------ESTADO ACTIVACION -----------
func activating(delta):
	# calculamos la direccion hacia el player
	var direction_to_target := (
		player.global_position - global_position
	).normalized()
	
	#el robot gira lientamente hacia el player
	rotation = rotate_toward(
		rotation,
		direction_to_target.angle(),
		rotation_speed * delta
	)
	
	#calcular cuanto falta para mirar al player
	var angle_diff: float = abs(
		angle_difference(rotation, direction_to_target.angle())
	)
	
	# si està orientado hacia el player, comienza el ataque
	if angle_diff < deg_to_rad(5.0):
		current_state = State.ATTACK
	
#   ------------ESTADO ATTACK -------------- 
func attack(delta):
			
	# calculamos la direccón hacia el player
	var direction_to_target := (
		player.global_position - global_position
	).normalized()
	
	# El robot mira hacia el Player
	rotation = direction_to_target.angle()
	
	
	
	# Aceleramos progresivamente hacia el Player
	velocity = velocity.move_toward(
		direction_to_target * max_speed,
		acceleration * delta
	)
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		
		if collision.get_collider() == player:
			player.die(velocity.normalized())
	
# chequea si están a distancia de la visión del enemigo
func can_see_player():
	# no ve al jugador si esta muerto
	if player.is_dead:
		return false
	
	# comprueba si el player està en el area de detecciòn
	if not detection_area.get_overlapping_bodies().has(player):
		return false
	# comprueba que estè en la timeline B
	if not player.get_collision_mask_value(2):
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
	

# Funciòn para reiniciar el robot cuando se desactiva la timeline
func deactivate():
	current_state = State.DORMANT
	velocity = Vector2.ZERO

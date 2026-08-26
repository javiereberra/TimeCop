extends CharacterBody2D

# VARIABLES EXPORTABLES
@export var speed := 100.0
# REFERENCIAS A NODOS
@onready var obstacle_check: RayCast2D = $ObstacleCheck
@onready var patrol_timer: Timer = $PatrolTimer
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
# VARIABLES DE DETECCIÓN
@export var vision_distance := 500.0
@export var vision_angle := 90.0

#  ---ESTADOS DE LA IA----
enum State {
	PATROL,
	ALERT
}

var current_state = State.PATROL

# Variable de PATROL
var is_waiting := false

#Asigna capa de colisión correspondiente al detector de paredes
func _ready():
	obstacle_check.collision_mask = collision_layer

# PROCESAR LOS ESTADOS
func _physics_process(_delta):
	if current_state == State.PATROL:
		patrol()
	elif current_state == State.ALERT:
		alert()
	
# FUNCIÒN DEL ESTADO PATROL
func patrol():
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
		velocity = transform.x * speed	
		
	move_and_slide()

#   ESTADOALERT  
func alert():
	pass
	
func can_see_player():
	var distance_to_player := global_position.distance_to(player.global_position)
	
	if distance_to_player > vision_distance:
		return false
	
	return true
	
# Elinimar al enemigo
func die():
	queue_free()
	

# cuando el timer termina, deja de esperar
func _on_patrol_timer_timeout():
	is_waiting = false

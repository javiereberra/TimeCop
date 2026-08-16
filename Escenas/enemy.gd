extends CharacterBody2D

@export var speed := 100.0

@onready var obstacle_check: RayCast2D = $ObstacleCheck

@onready var patrol_timer: Timer = $PatrolTimer

#Lista de Estados
enum State {
	PATROL
}

var current_state = State.PATROL
var is_waiting := false

func _ready():
	obstacle_check.collision_mask = collision_layer
	
func _physics_process(_delta):
	if current_state == State.PATROL:
		patrol()
	
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
	
# Elinimar al enemigo
func die():
	queue_free()
	

# cuando el timer termina, deja de esperar
func _on_patrol_timer_timeout():
	is_waiting = false

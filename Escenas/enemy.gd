extends CharacterBody2D

@export var speed := 100.0

@onready var obstacle_check: RayCast2D = $ObstacleCheck

#Lista de Estados
enum State {
	PATROL
}

var current_state = State.PATROL

func _ready():
	obstacle_check.collision_mask = collision_layer
	
func _physics_process(_delta):
	if current_state == State.PATROL:
		patrol()
	
func patrol():
	# Si hay una pared delante, gira 90 grados.
	if obstacle_check.is_colliding():
		rotation += deg_to_rad(90)
		
	# Avanza siempre hacia delante.
	velocity = transform.x * speed	
	move_and_slide()
	
# Elinimar al enemigo
func die():
	queue_free()
	

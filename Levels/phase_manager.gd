extends Node

# referencias las timelines
@onready var timeline_a: Node2D = $"../Floor01/TimelineA"
@onready var timeline_b: Node2D = $"../Floor01/TimelineB"
# variable para timeline activa
var timeline_a_active: bool = true

# referencia al jugador
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

func change_phase() -> void:
	print("Cambio de fase solicitado")
	#cambiar timeline activa
	timeline_a_active = not timeline_a_active
	
	#cambiar visibilidad
	timeline_a.visible = timeline_a_active
	timeline_b.visible = not timeline_a_active
	
	#cambiar capas de colisiòn del player
	if timeline_a_active:
		player.collision_mask = 1
	else:
		player.collision_mask = 2

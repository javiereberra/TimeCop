extends Node2D

@onready var spawn_point: Marker2D = $Floor01/SpawnPoint

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")

	if player == null:
		push_warning("No se encontró un nodo en el grupo 'player'.")
		return

	player.global_position = spawn_point.global_position

extends Node

#Referencia al Piso 1
@onready var floor: Node2D = $"../Floor01"
#Referencia al Player
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
#Referencia al SpawnPoint
@onready var spawn_point: Marker2D = $"../Floor01/SpawnPoint"


func restart_floor():
	print("REINICIAR PISO")
	player.remove_corpse()
	
	player.global_position = spawn_point.global_position
	player.is_dead = false
	player.show()
	player.velocity = Vector2.ZERO

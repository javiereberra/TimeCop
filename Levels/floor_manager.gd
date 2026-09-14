extends Node

#Referencia al Piso 1
@onready var floor: Node2D = $"../Floor01"
#Referencia al Player
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
#Referencia al SpawnPoint
@onready var spawn_point: Marker2D = $"../Floor01/SpawnPoint"
#Referencia a las timelines
@onready var timeline_a: Node2D = $"../Floor01/TimelineA"
@onready var timeline_b: Node2D = $"../Floor01/TimelineB"

# Ficha para los enemigos
var enemy_data :=[]

func _ready():		
	register_enemies_in_timeline(timeline_a, "A")
	register_enemies_in_timeline(timeline_b, "B")
	
	print(enemy_data)


func register_enemies_in_timeline(timeline: Node2D, timeline_name: String):
	for child in timeline.get_children():
		if child.is_in_group("enemy"):
			var data := {
				"scene": child.scene_file_path,
				"position": child.global_position,
				"rotation": child.global_rotation,
				"timeline": timeline_name,
				"collision_layer": child.collision_layer,
				"collision_mask": child.collision_mask
			}
			
			enemy_data.append(data)

func remove_current_enemies():
	for child in timeline_a.get_children():
		if child.is_in_group("enemy"):
			child.queue_free()
			
	for child in timeline_b.get_children():
		if child.is_in_group("enemy"):
			child.queue_free()
			
func remove_corpses():
	for corpse in get_tree().get_nodes_in_group("corpse"):
		corpse.queue_free()
		

func respawn_enemies():
	
	for data in enemy_data:
		var enemy_scene: PackedScene = load(data["scene"])
		var enemy: Node2D = enemy_scene.instantiate()
				
		if data["timeline"] == "A":
			timeline_a.add_child(enemy)
		else:
			timeline_b.add_child(enemy)
			
		enemy.collision_layer = data["collision_layer"]
		enemy.collision_mask = data["collision_mask"]
		print(
			"Timeline: ", data["timeline"],
			" | Layer: ", enemy.collision_layer,
			" | Mask: ", enemy.collision_mask
		)
		
		enemy.global_position = data["position"]
		enemy.global_rotation = data["rotation"]
		

func restart_floor():
	print("REINICIAR PISO")
	
	remove_current_enemies()
	remove_corpses()
	respawn_enemies()
	
	player.remove_corpse()
	
	player.global_position = spawn_point.global_position
	player.is_dead = false
	player.show()
	player.velocity = Vector2.ZERO

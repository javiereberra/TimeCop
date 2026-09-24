extends Node


#Referencia al Player
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
#Referencia al SpawnPoint
@onready var spawn_point: Marker2D = $"../Floor01/SpawnPoint"
#Referencia a las timelines
@onready var timeline_a: Node2D = $"../Floor01/TimelineA"
@onready var timeline_b: Node2D = $"../Floor01/TimelineB"
#Referencia al phase manager
@onready var phase_manager: Node = get_tree().get_first_node_in_group("phase_manager")

# Ficha para los enemigos
var enemy_data :=[]

func _ready():		
	# Registramos los enemigos de cada timeline
	register_enemies_in_timeline(timeline_a, "A")
	register_enemies_in_timeline(timeline_b, "B")
	
	

# recorremos todos los enemigos de las timelines
func register_enemies_in_timeline(timeline: Node2D, timeline_name: String):
	for child in timeline.get_children():
		if child.is_in_group("enemy"):
			# guarda lo nedesario para reconstruirlos
			var data := {
				"scene": child.scene_file_path,
				"position": child.global_position,
				"rotation": child.global_rotation,
				"timeline": timeline_name,
				"collision_layer": child.collision_layer,
				"collision_mask": child.collision_mask
			}
			# guardamos info en enemy data
			enemy_data.append(data)

# eliminamos todos los enemigos
func remove_current_enemies():
	for child in timeline_a.get_children():
		if child.is_in_group("enemy"):
			child.queue_free()
			
	for child in timeline_b.get_children():
		if child.is_in_group("enemy"):
			child.queue_free()
			
# eliminamos todos los cuerpos
func remove_corpses():
	for corpse in get_tree().get_nodes_in_group("corpse"):
		corpse.queue_free()
		
# recreamos los enemigos usando el enemy data
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
		
		
		enemy.global_position = data["position"]
		enemy.global_rotation = data["rotation"]
		
# reiniciamos el piso
func restart_floor():
	
	# removemos cuerpos y enemigos
	remove_current_enemies()
	remove_corpses()
	# recontruimos los enemigos
	respawn_enemies()
	
	# eliminamos el cuerpo del player si lo hubiere
	player.remove_corpse()
	# reseteamos las condiciones del player para iniciar el piso
	player.global_position = spawn_point.global_position
	player.is_dead = false
	player.show()
	player.velocity = Vector2.ZERO
	# regresamos a la timeline a
	phase_manager.reset_to_timeline_a()

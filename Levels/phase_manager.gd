extends Node

# referencias las timelines
@onready var timeline_a: Node2D = $"../Floor01/TimelineA"
@onready var timeline_b: Node2D = $"../Floor01/TimelineB"
# variable para timeline activa
var timeline_a_active: bool = true

# referencia al jugador
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

func _ready():
	# Timeline a comienza activa
	timeline_a_active = true
	# Configuración visual inicial
	timeline_a.visible = true
	timeline_b.visible = false
	
	# Configuración de procesamiento inicial
	timeline_a.process_mode = Node.PROCESS_MODE_INHERIT
	timeline_b.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Configurar colisiones
	player.collision_mask = 1

#CAMBIO DE FASE
func change_phase() -> void:
		
	#Averiguar a qué máscara vamos cambiar
	var target_mask: int	
	if timeline_a_active:
		target_mask = 2
	else:
		target_mask = 1
		
	if player.is_phase_blocked(target_mask):
		# AGREGAR ADVERTENCIA VISUAL??
		print("Cambio de fase bloqueado")
		return
		
	#cambiar timeline activa
	timeline_a_active = not timeline_a_active
	
	#cambiar visibilidad
	timeline_a.visible = timeline_a_active
	timeline_b.visible = not timeline_a_active
	
	#cambiar capas de colisiòn del player
	if timeline_a_active:
		player.collision_mask = 1
		
		# Reiniciar los robots antes de desactivar TimelineB
		for child in timeline_b.get_children():
			if child.has_method("deactivate"):
				child.deactivate()
		
		timeline_a.process_mode = Node.PROCESS_MODE_INHERIT
		timeline_b.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		player.collision_mask = 2
		timeline_a.process_mode = Node.PROCESS_MODE_DISABLED
		timeline_b.process_mode = Node.PROCESS_MODE_INHERIT

# para volver a la timeline a cuando hagamos reset
func reset_to_timeline_a():
	# Timeline A Activa
	timeline_a_active = true
	
	# Visibilidad
	timeline_a.visible = true
	timeline_b.visible = false
	
	# Procesamiento
	timeline_a.process_mode = Node.PROCESS_MODE_INHERIT
	timeline_b.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Colisiones del player
	player.collision_mask = 1

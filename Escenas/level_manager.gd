extends Node

# Variable arreglo para las escenas de los niveles disponibles.
@export var levels: Array[PackedScene]

# Referencia Nodo donde se instancia el nivel activo.
@onready var level_active: Node2D = $"../LevelActivo"

# Variable del Índice del nivel actualmente cargado.
var current_level_index: int = 0

# Referencia (vacia) a la instancia del nivel actual.
var current_level: Node = null

# Cargar nivel actual
func _ready() -> void:
	print("1. LevelManager inició")
	
	load_level(current_level_index)

# Función para cargar el nivel
func load_level(level_index: int) -> void:
	# Evita intentar cargar una posición inexistente.
	if level_index < 0 or level_index >= levels.size():
		push_warning("El índice del nivel no es válido.")
		return

	# Elimina el nivel anterior, si existe.
	if is_instance_valid(current_level):
		current_level.queue_free()

	# Actualiza el índice e instancia el nuevo nivel.
	current_level_index = level_index
	current_level = levels[current_level_index].instantiate()

	# Coloca el nivel dentro de LevelActivo.
	level_active.add_child(current_level)


# Se llamará cuando el nivel actual sea superado.
# func complete_current_level() -> void:
#     load_next_level()


# Cargará el nivel siguiente de la lista.
# func load_next_level() -> void:
#     var next_level_index := current_level_index + 1
#
#     if next_level_index < levels.size():
#         load_level(next_level_index)
#     else:
#         finish_game()


# Reiniciará completamente el nivel actual.
# func restart_current_level() -> void:
#     load_level(current_level_index)


# Se ejecutará después de completar el último nivel.
# func finish_game() -> void:
#     pass

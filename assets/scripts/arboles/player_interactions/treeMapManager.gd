extends Control

@onready var MapSubviewport = %SubViewport

@onready var button_izq: Button = %ButtonIzquierda
@onready var button_ctr: Button = %ButtonCentro
@onready var button_der: Button = %ButtonDerecha


var arbol_visual: Control

func _ready():
	# Setup game through controller
	Global.treeMap.setup_game()
	
	# Connect to game events
	Global.treeMap.player_moved.connect(_on_player_moved)
	Global.treeMap.game_over.connect(_on_game_over)
	
	# Setup visual tree CON VisibilityTracker
	arbol_visual = preload("res://scenes/tree/ArbolVisual.tscn").instantiate()
	arbol_visual.nodo_escena = preload("res://scenes/tree/NodoVisual.tscn")
	
	# PASAR EL VISIBILITY TRACKER AL VISUALIZER
	arbol_visual.mostrar_arbol(Global.treeMap.tree, Global.treeMap.visibility)
	
	# Conectar señal de revelación para efectos adicionales
	if arbol_visual.has_signal("node_visual_revealed"):
		arbol_visual.node_visual_revealed.connect(_on_node_revealed)
	
	MapSubviewport.add_child(arbol_visual)
	
	# Initial button state update
	_update_button_states()

func _on_player_moved(node: TreeNode):
	_update_button_states()
	# Refrescar visibilidad del árbol visual
	if arbol_visual.has_method("refresh_visibility"):
		arbol_visual.refresh_visibility()
	
	# Update current node highlight if method exists
	if arbol_visual.has_method("update_current_node"):
		arbol_visual.update_current_node(node)

func _on_node_revealed(_node: TreeNode):
	#print("🎨 Visual node revealed: ", node.tipo)
	# Aquí agregar efectos de sonido, partículas, etc.
	pass

func _update_button_states():
	# Verificar navegación hacia abajo (evitar duplicar la comprobación)
	var can_go_down = Global.treeMap.can_navigate_down()
	var can_go_left = Global.treeMap.can_navigate_left()
	var can_go_right = Global.treeMap.can_navigate_right()
	
	# Botones laterales
	button_izq.disabled = not can_go_down
	button_der.disabled = not can_go_down
	
	# Cambiar texto según si hay uno o dos hijos (XOR!)
	if can_go_down:
		if can_go_left != can_go_right:  # Solo un hijo (XOR)
			button_izq.text = "↓"
			button_der.text = "↓"
		else:  # Dos hijos o ninguno
			button_izq.text = "←"
			button_der.text = "→"
	
	# Botón centro (subir)
	button_ctr.disabled = not Global.treeMap.can_navigate_up()

func _on_game_over(win: bool):
	if win:
		print("🎉 You won! Score: ", Global.treeMap.score)
	else:
		print("💀 Game Over! Score: ", Global.treeMap.score)

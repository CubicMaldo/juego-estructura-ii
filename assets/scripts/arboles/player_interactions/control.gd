extends Control

@onready var MapSubviewport = %SubViewport

@onready var button_izq: Button = $VBoxContainer/HBoxContainer/ButtonIzquierda
@onready var button_ctr: Button = $VBoxContainer/HBoxContainer/ButtonCentro
@onready var button_der: Button = $VBoxContainer/HBoxContainer/ButtonDerecha



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
	print("moved")
	# Refrescar visibilidad del árbol visual
	if arbol_visual.has_method("refresh_visibility"):
		arbol_visual.refresh_visibility()
	
	# Update current node highlight if method exists
	if arbol_visual.has_method("update_current_node"):
		arbol_visual.update_current_node(node)

func _on_node_revealed(node: TreeNode):
	print("🎨 Visual node revealed: ", node.tipo)
	# Aquí puedes agregar efectos de sonido, partículas, etc.

func _update_button_states():
	button_izq.disabled = not Global.treeMap.can_navigate_left()

	button_der.disabled = not Global.treeMap.can_navigate_right()
	
	button_ctr.disabled = not Global.treeMap.can_navigate_up()

func _on_game_over(win: bool):
	if win:
		print("🎉 You won! Score: ", Global.treeMap.score)
	else:
		print("💀 Game Over! Score: ", Global.treeMap.score)

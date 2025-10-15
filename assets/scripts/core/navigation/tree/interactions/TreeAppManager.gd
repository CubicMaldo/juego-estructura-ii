extends Control

@onready var MapSubviewport = %SubViewport

@onready var button_izq: Button = %ButtonIzquierda
@onready var button_ctr: Button = %ButtonCentro
@onready var button_der: Button = %ButtonDerecha

@onready var navigation_message: PanelContainer = %NavigationMessage
@onready var node_name_label: Label = %NodeNameLabel
@onready var node_description_label: Label = %NodeDescriptionLabel

@export var setSeed = -1

var arbol_visual: Control
var message_timer: Timer

# Diccionario de nombres descriptivos para cada tipo de nodo
var node_names := {
	TreeNode.NodosJuego.INICIO: "Nodo de Inicio",
	TreeNode.NodosJuego.DESAFIO: "Nodo de Desafío",
	TreeNode.NodosJuego.PISTA: "Nodo de Pista",
	TreeNode.NodosJuego.FINAL: "Nodo Central Seguro"
}

# Diccionario de descripciones para cada tipo de nodo
var node_descriptions := {
	TreeNode.NodosJuego.INICIO: "Punto de partida de tu aventura.",
	TreeNode.NodosJuego.DESAFIO: "Has accedido a un desafío de ciberseguridad.",
	TreeNode.NodosJuego.PISTA: "Nodo de ayuda con pistas disponibles.",
	TreeNode.NodosJuego.FINAL: "¡Has llegado al objetivo final! Completa el último desafío."
}

# Descripciones personalizadas por app
var app_descriptions := {
	"password cracker": "Estás en el Servidor de Contraseñas. Sistema de autenticación detectado.",
	"network defender": "Estás en el Firewall Perimetral. Analizando tráfico de red.",
	"email phishing detector": "Has accedido al Servidor de Correo. Detecta amenazas de phishing.",
	"entrenador de phishing": "Has accedido al Servidor de Correo. Detecta amenazas de phishing.",
	"port scanner defender": "Estás en el Sistema de Detección de Intrusos. Vigilando puertos de red.",
	"entrenador de contraseñas": "Has llegado al Centro de Capacitación. Aprende sobre contraseñas seguras.",
	"sql injection defender": "Estás en la Base de Datos Principal. Protege contra inyecciones SQL."
}

func _enter_tree() -> void:
	Global.ensure_tree_map()

func _ready():
	# Setup game through controller
	var controller := Global.ensure_tree_map()
	controller.setup_game(setSeed)
	
	# Connect to game events
	controller.player_moved.connect(_on_player_moved)
	controller.game_over.connect(_on_game_over)
	controller.challenge_started.connect(_on_challenge_started)
	controller.challenge_finished.connect(_on_challenge_finished)
	
	# Setup visual tree CON VisibilityTracker
	arbol_visual = preload("res://scenes/tree/ArbolVisual.tscn").instantiate()
	arbol_visual.nodo_escena = preload("res://scenes/tree/NodoVisual.tscn")
	
	# PASAR EL VISIBILITY TRACKER AL VISUALIZER
	arbol_visual.mostrar_arbol(controller.tree, controller.visibility)
	
	# Conectar señal de revelación para efectos adicionales
	if arbol_visual.has_signal("node_visual_revealed"):
		arbol_visual.node_visual_revealed.connect(_on_node_revealed)
	
	MapSubviewport.add_child(arbol_visual)
	
	# Setup message timer
	_setup_message_timer()
	
	# Initial button state update
	_update_button_states()
	
	# Show initial node message (defer to next frame to ensure UI is ready)
	call_deferred("_show_node_message", controller.navigator.current_node)

func _setup_message_timer():
	message_timer = Timer.new()
	message_timer.one_shot = true
	message_timer.wait_time = 3.0  # Mostrar mensaje por 3 segundos
	message_timer.timeout.connect(_hide_navigation_message)
	add_child(message_timer)

func _show_node_message(node: TreeNode):
	if node == null or navigation_message == null:
		return
	
	# Verificar que los labels existan
	if node_name_label == null or node_description_label == null:
		push_warning("Navigation message labels not found")
		return
	
	# Obtener el nombre del nodo
	var node_type_name = node_names.get(node.tipo, "Nodo Desconocido")
	
	# Si el nodo tiene un recurso de app, usar su nombre
	if node.has_app_resource() and node.app_resource != null:
		var custom_name = _get_custom_node_name(node)
		if custom_name != "":
			node_type_name = custom_name
	
	# Obtener la descripción
	var description = node_descriptions.get(node.tipo, "Has navegado a este nodo.")
	
	# Si el nodo tiene app, usar descripción personalizada
	if node.has_app_resource() and node.app_resource != null:
		var app_name_lower = node.app_resource.app_name.to_lower()
		if app_descriptions.has(app_name_lower):
			description = app_descriptions[app_name_lower]
	
	# Agregar emoji según el tipo
	var emoji = _get_node_emoji(node.tipo)
	
	# Actualizar labels
	node_name_label.text = emoji + " " + node_type_name
	node_description_label.text = description
	
	# Mostrar el mensaje
	navigation_message.visible = true
	
	# Reiniciar el timer
	if message_timer:
		message_timer.start()

func _get_custom_node_name(node: TreeNode) -> String:
	if not node.has_app_resource() or node.app_resource == null:
		return ""
	
	# Mapeo de nombres de apps a nombres descriptivos
	var app_name = node.app_resource.app_name
	
	match app_name.to_lower():
		"password cracker":
			return "Servidor de Contraseñas"
		"network defender":
			return "Firewall Perimetral"
		"email phishing detector", "entrenador de phishing":
			return "Servidor de Correo"
		"port scanner defender":
			return "Sistema de Detección de Intrusos"
		"entrenador de contraseñas":
			return "Centro de Capacitación"
		"sql injection defender":
			return "Base de Datos Principal"
		_:
			return app_name

func _get_node_emoji(tipo: int) -> String:
	match tipo:
		TreeNode.NodosJuego.INICIO:
			return "🏁"
		TreeNode.NodosJuego.DESAFIO:
			return "⚔️"
		TreeNode.NodosJuego.PISTA:
			return "💡"
		TreeNode.NodosJuego.FINAL:
			return "🎯"
		_:
			return "📍"

func _hide_navigation_message():
	if navigation_message:
		navigation_message.visible = false

func _on_player_moved(node: TreeNode):
	_update_button_states()
	
	# Mostrar mensaje de navegación
	_show_node_message(node)
	
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

func _on_challenge_started(_node: TreeNode) -> void:
	_update_button_states()

func _on_challenge_finished(_node: TreeNode, _win: bool) -> void:
	_update_button_states()

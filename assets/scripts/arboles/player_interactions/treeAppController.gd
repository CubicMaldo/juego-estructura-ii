class_name TreeAppController
extends Node
## Orchestrates the different systems without coupling them together
## This is the ONLY place where systems interact

signal player_moved(node: TreeNode)
signal game_over(win: bool)

var tree: Arbol
var navigator: PlayerNavigator
var visibility: VisibilityTracker

var score: int = 0
var _awaiting_challenge_input: bool = false


func _init():
	navigator = PlayerNavigator.new()
	visibility = VisibilityTracker.new()
	
	# Connect signals
	navigator.node_changed.connect(_on_player_moved)
	visibility.node_visited.connect(_on_node_visited)

func setup_game(seed_value: int = -1) -> void:
	tree = Arbol.new()
	tree.generar_arbol_controlado(seed_value)
	# Print tree stats
	#var stats = TreeDebugger.get_tree_stats(tree)
	#print("\n🌲 Tree Generated:")
	#print("  Total nodes: ", stats.total_nodes)
	#print("  Max depth: ", stats.max_depth)
	#print("  Pistas: ", stats.pista, " | Desafíos: ", stats.desafio)
	
	# Initialize player position
	navigator.set_current_node(tree.raiz)
	
	# Set up initial visibility
	visibility.visit_node(tree.raiz)
	visibility.reveal_children(tree.raiz)
	
	print("\n=== Initial State ===")
	TreeDebugger.print_tree_with_visibility(tree, visibility, navigator.current_node)

func navigate_left() -> bool:
	if _awaiting_challenge_input:
		print("⚠️ Debes responder el reto antes de moverte nuevamente.")
		return false
	if navigator.move_left():
		_handle_navigation()
		return true
	return false

func navigate_right() -> bool:
	if _awaiting_challenge_input:
		print("⚠️ Debes responder el reto antes de moverte nuevamente.")
		return false
	if navigator.move_right():
		_handle_navigation()
		return true
	return false

func navigate_up() -> bool:
	if _awaiting_challenge_input:
		print("⚠️ Debes responder el reto antes de moverte nuevamente.")
		return false
	if navigator.move_to_parent():
		_handle_navigation()
		return true
	return false

func navigate_down() -> bool:
	if _awaiting_challenge_input:
		print("⚠️ Debes responder el reto antes de moverte nuevamente.")
		return false
	if can_navigate_right():
		navigate_right()
		return true
	elif can_navigate_left():
		navigate_left()
		return true
	else: 
		return false

func _handle_navigation() -> void:
	var current = navigator.current_node
	
	# Mark as visited
	visibility.visit_node(current)
	
	# Reveal children
	visibility.reveal_children(current)
	
	# Check for game end
	if current.tipo == Arbol.NodosJuego.FINAL:
		game_over.emit(true)

	if current.tipo == 1:
		_trigger_challenge_prompt(current)
	
	player_moved.emit(current)

#JUGADOR MOVIMIENTO
func _on_player_moved(_old_node: TreeNode, new_node: TreeNode) -> void:
	visibility.move_to_node(new_node)
	#WIP Agregar clase que maneje juegos segun tipo aqui
	if new_node.tipo == 2:
		visibility.forced_discovery(tree.obtener_hoja_mas_profunda())
	TreeDebugger.print_tree_with_visibility(tree, visibility, navigator.current_node)
	if new_node.tipo == 1:
		_trigger_challenge_prompt(new_node)

func _on_node_visited(node: TreeNode) -> void:
	# Award points based on node type
	match node.tipo:
		Arbol.NodosJuego.PISTA:
			score += 10
		Arbol.NodosJuego.DESAFIO:
			score += 5
		Arbol.NodosJuego.FINAL:
			score += 50

func _node_type_name(node: TreeNode) -> String:
	if node == null:
		return "null"
	match node.tipo:
		Arbol.NodosJuego.INICIO: return "INICIO"
		Arbol.NodosJuego.DESAFIO: return "DESAFIO"
		Arbol.NodosJuego.PISTA: return "PISTA"
		Arbol.NodosJuego.FINAL: return "FINAL"
		_: return "UNKNOWN"

func get_current_node() -> TreeNode:
	return navigator.current_node

func can_navigate_left() -> bool:
	return navigator.can_move_left()

func can_navigate_right() -> bool:
	return navigator.can_move_right()

func can_navigate_up() -> bool:
	return navigator.can_move_to_parent()

func can_navigate_down() -> bool:
	return can_navigate_right() or can_navigate_left()

func is_node_visible(node: TreeNode) -> bool:
	return visibility.is_discovered(node)

func _trigger_challenge_prompt(node: TreeNode) -> void:
	if _awaiting_challenge_input:
		return

	_awaiting_challenge_input = true
	print("\n=== DESAFÍO ENCONTRADO ===")
	print("Nodo: ", node.nombre if node and node.has_method("get_nombre") else node)
	print("Debes responder en la consola para continuar.")
	var prompt := "Ingresa tu respuesta y presiona Enter: "
	if Engine.has_singleton("Console"):
		Engine.get_singleton("Console").request_input(prompt, _on_challenge_response)
	else:
		_print_and_capture_response(prompt)

func _print_and_capture_response(prompt: String) -> void:
	print(prompt)
	var response := get_console_input()
	_on_challenge_response(response)

func get_console_input() -> String:
	var input_line := ""
	if OS.is_debug_build():
		var stdin := Engine.get_singleton("STDIN") if Engine.has_singleton("STDIN") else null
		if stdin and stdin.has_method("get_line"):
			input_line = stdin.call("get_line").strip_edges()
		else:
			input_line = "respuesta"
	else:
		input_line = "respuesta"
	return input_line

func _on_challenge_response(response: String) -> void:
	print("Respuesta recibida: ", response)
	AwaitingChallengeTimer.new().defer_reset(self)

class AwaitingChallengeTimer:
	func defer_reset(controller: TreeAppController) -> void:
		controller._awaiting_challenge_input = false
		print("Puedes continuar explorando el árbol.\n")

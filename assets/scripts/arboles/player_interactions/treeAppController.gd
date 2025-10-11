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
	if navigator.move_left():
		_handle_navigation()
		return true
	return false

func navigate_right() -> bool:
	if navigator.move_right():
		_handle_navigation()
		return true
	return false

func navigate_up() -> bool:
	if navigator.move_to_parent():
		_handle_navigation()
		return true
	return false

func navigate_down() -> bool:
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
	
	player_moved.emit(current)

#JUGADOR MOVIMIENTO
func _on_player_moved(_old_node: TreeNode, new_node: TreeNode) -> void:
	visibility.move_to_node(new_node)
	#WIP Agregar clase que maneje juegos segun tipo aqui
	if new_node.tipo == 2:
		visibility.forced_discovery(tree.obtener_hoja_mas_profunda())
	TreeDebugger.print_tree_with_visibility(tree, visibility, navigator.current_node)

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

class_name TreeAppController
extends Node

const appDatabase = preload("res://assets/scripts/arboles/AppDatabase.gd")
const gameLauncher = preload("res://assets/scripts/arboles/player_interactions/GameLauncher.gd")
## Orchestrates the different systems without coupling them together
## This is the ONLY place where systems interact

signal player_moved(node: TreeNode)
signal game_over(win: bool)
signal challenge_started(node: TreeNode)
signal challenge_finished(node: TreeNode, win: bool)

var tree: Arbol
var navigator: PlayerNavigator
var visibility: VisibilityTracker
var _app_resources: Array[AppStats] = []
var app_database: AppDatabase
var game_launcher: GameLauncher
var _node_challenge_results: Dictionary = {}
var _challenge_active: bool = false
var _current_challenge_node: TreeNode = null
var _navigation_locked: bool = false

var score: int = 0


func _init():
	navigator = PlayerNavigator.new()
	visibility = VisibilityTracker.new()
	
	# Connect signals
	navigator.node_changed.connect(_on_player_moved)
	visibility.node_visited.connect(_on_node_visited)

func _ready():
	game_launcher = GameLauncher.new()
	add_child(game_launcher)
	if game_launcher.has_method("setup"):
		game_launcher.setup(self)
	print("[TreeAppController] Ready - launcher inicializado")


func setup_game(seed_value: int = -1, app_resources: Array[AppStats] = [], app_db: AppDatabase = null) -> void:
	print("[TreeAppController] setup_game llamado seed=%d" % seed_value)
	if game_launcher == null:
		game_launcher = GameLauncher.new()
		add_child(game_launcher)
		if game_launcher.has_method("setup"):
			game_launcher.setup(self)
	tree = Arbol.new()
	_node_challenge_results.clear()
	_challenge_active = false
	_current_challenge_node = null
	_navigation_locked = false
	var database_to_use: AppDatabase = app_db if app_db != null else app_database
	if database_to_use == null:
		database_to_use = _load_app_database()
	if database_to_use != null:
		print("[TreeAppController] Usando AppDatabase con %d desafios/%d pistas/%d meta" % [database_to_use.desafio_apps.size(), database_to_use.pista_apps.size(), database_to_use.meta_apps.size()])
		app_database = database_to_use
		tree.set_app_database(database_to_use)
		_app_resources.clear()
		if not app_resources.is_empty():
			push_warning("Se proporcionaron app_resources manualmente, pero AppDatabase tiene prioridad; se ignorarán.")
	else:
		print("[TreeAppController] Cargando recursos por defecto")
		var resources_to_use := app_resources
		if resources_to_use.is_empty():
			resources_to_use = _load_default_app_resources()
		tree.set_available_app_resources(resources_to_use)
		_app_resources = tree.get_available_app_resources()
	tree.generar_arbol_controlado(seed_value)
	
	# Initialize player position
	navigator.set_current_node(tree.raiz)
	
	# Set up initial visibility
	visibility.visit_node(tree.raiz)
	visibility.reveal_children(tree.raiz)
	print("[TreeAppController] Juego inicializado; nodo raíz visible")
	
	#print("\n=== Initial State ===")
	#TreeDebugger.print_tree_with_visibility(tree, visibility, navigator.current_node)

func _load_default_app_resources() -> Array[AppStats]:
	var results: Array[AppStats] = []
	var dir := DirAccess.open("res://resources/apps")
	if dir == null:
		print("[TreeAppController] No se pudo abrir directorio de apps")
		push_warning("No se pudo abrir res://resources/apps para cargar AppStats.")
		return results
	var files: Array[String] = []
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue
		if not dir.current_is_dir() and entry.to_lower().ends_with(".tres"):
			files.append(entry)
		entry = dir.get_next()
	dir.list_dir_end()
	files.sort()
	for file_name in files:
		var resource := ResourceLoader.load("res://resources/apps/%s" % file_name)
		if resource is AppStats:
			results.append(resource)
		else:
			print("[TreeAppController] Archivo %s no es AppStats" % file_name)
			push_warning("El recurso %s no es de tipo AppStats." % file_name)
	return results

func _load_app_database() -> AppDatabase:
	var resource := ResourceLoader.load("res://resources/apps/AppDatabase.tres")
	if resource is AppDatabase:
		print("[TreeAppController] AppDatabase cargado correctamente")
		return resource
	if resource != null:
		print("[TreeAppController] AppDatabase.tres no es AppDatabase")
		push_warning("El recurso AppDatabase cargado no es de tipo AppDatabase.")
	return null

func navigate_left() -> bool:
	if _navigation_locked:
		print("[TreeAppController] Movimiento bloqueado hasta completar el reto actual")
		return false
	if navigator.move_left():
		print("[TreeAppController] Navegación izquierda exitosa")
		_handle_navigation()
		return true
	return false

func navigate_right() -> bool:
	if _navigation_locked:
		print("[TreeAppController] Movimiento bloqueado hasta completar el reto actual")
		return false
	if navigator.move_right():
		print("[TreeAppController] Navegación derecha exitosa")
		_handle_navigation()
		return true
	return false

func navigate_up() -> bool:
	if _navigation_locked:
		print("[TreeAppController] Movimiento bloqueado hasta completar el reto actual")
		return false
	if navigator.move_to_parent():
		print("[TreeAppController] Navegación hacia arriba exitosa")
		_handle_navigation()
		return true
	return false

func navigate_down() -> bool:
	if _navigation_locked:
		print("[TreeAppController] Movimiento bloqueado hasta completar el reto actual")
		return false
	if can_navigate_right():
		print("[TreeAppController] Navegación hacia abajo -> derecha")
		navigate_right()
		return true
	elif can_navigate_left():
		print("[TreeAppController] Navegación hacia abajo -> izquierda")
		navigate_left()
		return true
	else: 
		print("[TreeAppController] Navegación hacia abajo falló; no hay hijos")
		return false

func _handle_navigation() -> void:
	var current = navigator.current_node
	print("[TreeAppController] Manejo de navegación: nodo actual %s" % [_node_type_name(current)])
	
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
	print("[TreeAppController] Player moved a %s" % [_node_type_name(new_node)])
	visibility.move_to_node(new_node)
	#WIP Agregar clase que maneje juegos segun tipo aqui
	if new_node.tipo == 2:
		visibility.forced_discovery(tree.obtener_hoja_mas_profunda())
	_launch_node_app(new_node)
	#TreeDebugger.print_tree_with_visibility(tree, visibility, navigator.current_node)

func _launch_node_app(node: TreeNode) -> void:
	print("[TreeAppController] Intentando lanzar app para nodo %s" % [node])
	if game_launcher == null:
		print("[TreeAppController] GameLauncher no disponible")
		return
	if node == null or not node.has_app_resource():
		print("[TreeAppController] Nodo sin app asociada; nada que lanzar")
		return
	var node_id: int = node.get_instance_id()
	if _node_challenge_results.has(node_id):
		print("[TreeAppController] Nodo ya resuelto anteriormente; no relanzar")
		return
	if node.challenge_completed:
		print("[TreeAppController] Nodo marcado como completado; no relanzar")
		return
	if _challenge_active:
		print("[TreeAppController] Ya hay reto activo; esperar a que termine")
		return
	if game_launcher.has_active_session():
		print("[TreeAppController] GameLauncher reporta sesión activa; no lanzar")
		return
	if game_launcher.launch_node_app(node):
		print("[TreeAppController] Lanzamiento aprobado; iniciando reto")
		_begin_challenge_for_node(node)

func _on_node_visited(node: TreeNode) -> void:
	# Award points based on node type
	print("[TreeAppController] Nodo visitado: %s" % [_node_type_name(node)])
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
	return not _navigation_locked and navigator.can_move_left()

func can_navigate_right() -> bool:
	return not _navigation_locked and navigator.can_move_right()

func can_navigate_up() -> bool:
	return not _navigation_locked and navigator.can_move_to_parent()

func can_navigate_down() -> bool:
	return not _navigation_locked and (navigator.can_move_right() or navigator.can_move_left())

func is_node_visible(node: TreeNode) -> bool:
	return visibility.is_discovered(node)

func is_challenge_active() -> bool:
	return _challenge_active

func get_active_challenge_node() -> TreeNode:
	return _current_challenge_node

func get_challenge_result(node: TreeNode):
	if node == null:
		return null
	var node_id: int = node.get_instance_id()
	return _node_challenge_results.get(node_id, null)

func report_challenge_result(win: bool) -> void:
	if not _challenge_active:
		print("[TreeAppController] Reporte de resultado sin reto activo")
		push_warning("Se intentó reportar el resultado de un minijuego, pero no hay reto activo.")
		return
	print("[TreeAppController] Recibido resultado de reto: win=%s" % [win])
	_finalize_challenge(win)

func _begin_challenge_for_node(node: TreeNode) -> void:
	print("[TreeAppController] Iniciando reto para nodo %s" % [node])
	_challenge_active = true
	_current_challenge_node = node
	_navigation_locked = true
	challenge_started.emit(node)

func _finalize_challenge(win: bool) -> void:
	print("[TreeAppController] Finalizando reto; win=%s" % [win])
	if _current_challenge_node != null:
		var node_id: int = _current_challenge_node.get_instance_id()
		if win:
			_node_challenge_results[node_id] = true
		else:
			_node_challenge_results.erase(node_id)
		_current_challenge_node.challenge_completed = win
		_current_challenge_node.challenge_result = win
	var finished_node := _current_challenge_node
	_challenge_active = false
	if win:
		_navigation_locked = false
	if game_launcher != null and game_launcher.has_method("on_challenge_resolved"):
		print("[TreeAppController] Notificando GameLauncher de resolución")
		game_launcher.on_challenge_resolved(_current_challenge_node, win)
	_current_challenge_node = null
	challenge_finished.emit(finished_node, win)
	if not win and finished_node != null:
		call_deferred("_retry_challenge_for_node", finished_node)

func _retry_challenge_for_node(node: TreeNode) -> void:
	print("[TreeAppController] Reintentando reto para nodo %s" % [node])
	if node == null:
		return
	if game_launcher == null:
		print("[TreeAppController] No hay GameLauncher para reintentar")
		return
	if game_launcher.has_active_session():
		print("[TreeAppController] GameLauncher aún tiene sesión activa; reintento cancelado")
		return
	await get_tree().process_frame
	if game_launcher.has_active_session():
		print("[TreeAppController] GameLauncher reporta sesión activa tras esperar; se pospone relanzamiento")
		call_deferred("_retry_challenge_for_node", node)
		return
	if node.challenge_completed:
		print("[TreeAppController] Nodo ya marcado como completado; no se relanza")
		return
	_launch_node_app(node)

# TreeVisualizer.gd
extends Control

@export_category("Dependencies")
@export var nodo_escena: PackedScene
@export var layout_engine: TreeLayout
@export var camera_controller: TreeCamera

@export_category("Tree Layout Settings")
@export var node_spacing: float = 500.0
@export var level_spacing: float = 120.0
@export var subtree_spacing: float = 0.0

@export_category("Visual Settings")
@export var animation_duration: float = 0.5
@export var auto_center_on_ready: bool = true

enum Nodos { INICIO = 0, DESAFIO = 1, PISTA = 2, FINAL = 3 }

# Señales
signal tree_centered()
signal zoom_changed(new_zoom: float)
signal view_reset()
signal tree_loaded()

var tree: Arbol
var lineas: Array[Array] = []

# Referencias a contenedores
var nodos_container: Control
var lineas_node: Node2D

func _ready() -> void:
	_setup_containers()
	_initialize_dependencies()
	
	if is_inside_tree():
		await get_tree().process_frame
	queue_redraw()

func _setup_containers() -> void:
	# Crear o obtener contenedores
	nodos_container = _get_or_create_control("NodosContainer")
	lineas_node = _get_or_create_node2d("Lineas")
	move_child(lineas_node, 0)

func _get_or_create_control(node_name: String) -> Control:
	var node: Control = get_node_or_null(node_name)
	if node == null:
		node = Control.new()
		node.name = node_name
		add_child(node)
	return node

func _get_or_create_node2d(node_name: String) -> Node2D:
	var node: Node2D = get_node_or_null(node_name)
	if node == null:
		node = Node2D.new()
		node.name = node_name
		add_child(node)
	return node

func _initialize_dependencies() -> void:
	# Crear instancias si no fueron asignadas via @export
	if layout_engine == null:
		layout_engine = TreeLayout.new()
	
	if camera_controller == null:
		camera_controller = TreeCamera.new()
		camera_controller.setup(self, nodos_container, lineas_node)

# ========== API PÚBLICA ==========

func mostrar_arbol(arbol: Arbol) -> void:
	if arbol == null or arbol.raiz == null:
		push_warning("Árbol vacío o nulo")
		return
	
	_ensure_containers_ready()
	_initialize_dependencies() # Asegurar que las dependencias estén inicializadas
	_clear_tree_visual()
	tree = arbol
	
	# Calcular layout
	var positions = layout_engine.calculate_tree_layout(
		tree.raiz, 
		node_spacing, 
		level_spacing, 
		subtree_spacing
	)
	
	# Dibujar árbol
	_draw_tree_with_positions(positions)
	
	# Centrar si es necesario
	if auto_center_on_ready and is_inside_tree():
		await get_tree().process_frame
		center_tree()
	
	tree_loaded.emit()

func center_tree() -> void:
	if camera_controller == null:
		push_error("Camera controller not initialized")
		return
	
	var bounds = _get_tree_bounds()
	if bounds.size == Vector2.ZERO:
		return
	
	var viewport_center = size / 2.0
	var tree_center = bounds.get_center()
	var offset = viewport_center - tree_center
	
	camera_controller.center_on_position(offset, animation_duration)
	
	if is_inside_tree():
		await get_tree().create_timer(animation_duration).timeout
	tree_centered.emit()

func fit_to_view() -> void:
	if camera_controller == null:
		push_error("Camera controller not initialized")
		return
	
	var bounds = _get_tree_bounds()
	if bounds.size == Vector2.ZERO:
		return
	
	camera_controller.fit_to_bounds(bounds, size)

func reset_view() -> void:
	if camera_controller == null:
		push_error("Camera controller not initialized")
		return
	
	camera_controller.reset_view(animation_duration)
	view_reset.emit()

func set_zoom(new_zoom: float) -> void:
	if camera_controller == null:
		push_error("Camera controller not initialized")
		return
	
	camera_controller.set_target_zoom(new_zoom)

func get_current_zoom() -> float:
	if camera_controller == null:
		return 1.0
	return camera_controller.get_current_zoom()

# ========== FUNCIONES INTERNAS ==========

func _ensure_containers_ready() -> void:
	if nodos_container == null or lineas_node == null:
		_setup_containers()

func _clear_tree_visual() -> void:
	lineas.clear()
	
	if nodos_container:
		for child in nodos_container.get_children():
			child.queue_free()
	
	# Resetear contenedores directamente en lugar de usar camera_controller
	_reset_containers_directly()

func _reset_containers_directly() -> void:
	# Resetear contenedores sin depender de camera_controller
	if nodos_container:
		nodos_container.position = Vector2.ZERO
		nodos_container.scale = Vector2.ONE
	
	if lineas_node:
		lineas_node.position = Vector2.ZERO
		lineas_node.scale = Vector2.ONE
	
	# También resetear variables de cámara si el controller existe
	if camera_controller:
		camera_controller.reset_containers()
	else:
		# Reset manual si el controller no está disponible
		
		camera_controller.camera_offset = Vector2.ZERO
		camera_controller.zoom_factor = 1.0
		camera_controller.target_zoom = 1.0

func _draw_tree_with_positions(positions: Dictionary) -> void:
	if positions.is_empty():
		return
	
	var offset = _calculate_drawing_offset(positions)
	_draw_nodes_and_lines(positions, offset)
	_update_lineas_node()

func _calculate_drawing_offset(positions: Dictionary) -> Vector2:
	var bounds = _calculate_tree_bounds(positions)
	var viewport_center = size / 2.0
	return Vector2(viewport_center.x - bounds.get_center().x, 50 - bounds.position.y)

func _calculate_tree_bounds(positions: Dictionary) -> Rect2:
	if positions.is_empty():
		return Rect2()
	
	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)
	
	for pos in positions.values():
		min_pos = min_pos.min(pos)
		max_pos = max_pos.max(pos)
	
	return Rect2(min_pos, max_pos - min_pos)

func _draw_nodes_and_lines(positions: Dictionary, offset: Vector2) -> void:
	lineas.clear()
	
	# Dibujar nodos
	for nodo in positions:
		var pos = positions[nodo] + offset
		_create_visual_node(nodo, pos)
	
	# Dibujar conexiones después de que todos los nodos existan
	for nodo in positions:
		_create_connections(nodo, positions, offset)

func _create_visual_node(nodo: Nodo, position: Vector2) -> void:
	if not nodo_escena:
		push_error("nodo_escena no está asignado")
		return
	
	var nodo_visual = nodo_escena.instantiate()
	nodo_visual.position = position
	nodos_container.add_child(nodo_visual)
	
	# Configurar tipo de nodo
	_configure_visual_node(nodo_visual, nodo)

func _configure_visual_node(nodo_visual: Node, nodo: Nodo) -> void:
	if nodo_visual.has_method("set_tipo"):
		if nodo_visual.set_tipo is Callable:
			nodo_visual.set_tipo.call_deferred(nodo.tipo)
		else:
			nodo_visual.set_tipo(nodo.tipo)

func _create_connections(nodo: Nodo, positions: Dictionary, offset: Vector2) -> void:
	var start_pos = positions[nodo] + offset
	
	if nodo.izquierdo and positions.has(nodo.izquierdo):
		var end_pos = positions[nodo.izquierdo] + offset
		lineas.append([start_pos, end_pos])
	
	if nodo.derecho and positions.has(nodo.derecho):
		var end_pos = positions[nodo.derecho] + offset
		lineas.append([start_pos, end_pos])

func _update_lineas_node() -> void:
	if lineas_node and lineas_node.has_method("actualizar_lineas"):
		lineas_node.actualizar_lineas(lineas)

func _get_tree_bounds() -> Rect2:
	if nodos_container == null or nodos_container.get_child_count() == 0:
		return Rect2()
	
	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)
	
	for child in nodos_container.get_children():
		if child is Control or child is Node2D:
			var pos = child.position
			min_pos = min_pos.min(pos)
			max_pos = max_pos.max(pos)
	
	return Rect2(min_pos, max_pos - min_pos)

# ========== INPUT DELEGATION ==========

func _input(event: InputEvent) -> void:
	if camera_controller != null:
		camera_controller.handle_input(event)

func _process(delta: float) -> void:
	if camera_controller != null:
		camera_controller.process_camera(delta)

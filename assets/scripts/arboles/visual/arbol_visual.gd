extends Control

@export var nodo_escena: PackedScene

@export_category("Tree Layout")
@export var node_spacing: float = 50000.0  # Distancia mínima entre nodos hermanos
@export var level_spacing: float = 120.0  # Distancia vertical entre niveles
@export var subtree_spacing: float = 0.0  # Distancia mínima entre subárboles

@export_category("Camera Controls")
@export var zoom_min: float = 0.2
@export var zoom_max: float = 3.0
@export var zoom_step: float = 0.1
@export var zoom_smooth_speed: float = 10.0
@export var pan_with_right_click: bool = true

enum Nodos { INICIO = 0, DESAFIO = 1, PISTA = 2, FINAL = 3 }

var tree: Arbol
var lineas: Array[Array] = []

# Camera/Viewport
var drag_active: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var camera_offset: Vector2 = Vector2.ZERO
var zoom_factor: float = 1.0
var target_zoom: float = 1.0

# Referencias a nodos
var nodos_container: Control = null
var lineas_node: Node2D = null

# Clase para almacenar información del nodo durante el layout
class TreeNode:
	var nodo: Nodo  # Referencia al nodo original del árbol
	var children: Array[TreeNode] = []
	var parent: TreeNode = null
	
	# Propiedades del algoritmo Reingold-Tilford
	var x: float = 0.0  # Posición X final
	var y: float = 0.0  # Posición Y final (nivel)
	var prelim: float = 0.0  # Posición preliminar
	var modifier: float = 0.0  # Modificador acumulativo
	var left_sibling: TreeNode = null
	var thread: TreeNode = null  # Para conectar contornos
	var ancestor: TreeNode = null  # Ancestro para apportion
	var number: int = 0  # Número del hijo (0-based)
	var change: float = 0.0  # Cambio acumulativo
	var shift: float = 0.0  # Shift acumulativo
	
	func _init(n: Nodo):
		nodo = n
		ancestor = self
	
	func is_leaf() -> bool:
		return children.is_empty()
	
	func get_left_sibling() -> TreeNode:
		return left_sibling
	
	func get_leftmost_child() -> TreeNode:
		return children[0] if not children.is_empty() else null
	
	func get_rightmost_child() -> TreeNode:
		return children[-1] if not children.is_empty() else null

func _ready() -> void:
	_setup_containers()
	if is_inside_tree():
		await get_tree().process_frame
	queue_redraw()

func _setup_containers() -> void:
	if not has_node("NodosContainer"):
		nodos_container = Control.new()
		nodos_container.name = "NodosContainer"
		add_child(nodos_container)
	else:
		nodos_container = $NodosContainer
	
	if not has_node("Lineas"):
		lineas_node = Node2D.new()
		lineas_node.name = "Lineas"
		add_child(lineas_node)
		move_child(lineas_node, 0)
	else:
		lineas_node = $Lineas
		move_child(lineas_node, 0)

func mostrar_arbol(arbol: Arbol) -> void:
	if arbol == null or arbol.raiz == null:
		push_warning("Árbol vacío o nulo")
		return
	
	if nodos_container == null or lineas_node == null:
		_setup_containers()
	
	_clear_tree_visual()
	tree = arbol
	
	# Construir estructura TreeNode
	var root_tree_node = _build_tree_structure(tree.raiz, null)
	
	# Aplicar algoritmo Reingold-Tilford
	_calculate_initial_positions(root_tree_node)
	_calculate_final_positions(root_tree_node, 0.0)
	
	# Obtener posiciones finales
	var positions = {}
	_collect_positions(root_tree_node, positions)
	
	# Dibujar el árbol
	_draw_tree_with_positions(positions)
	
	# Actualizar las líneas
	if lineas_node != null and lineas_node.has_method("actualizar_lineas"):
		lineas_node.actualizar_lineas(lineas)
	
	# Centrar automáticamente
	if is_inside_tree():
		await get_tree().process_frame
		center_tree()

# Construir la estructura de TreeNode desde el árbol original
func _build_tree_structure(nodo: Nodo, parent: TreeNode) -> TreeNode:
	if nodo == null:
		return null
	
	var tree_node = TreeNode.new(nodo)
	tree_node.parent = parent
	
	var child_number = 0
	
	# Hijo izquierdo
	if nodo.izquierdo != null:
		var left_child = _build_tree_structure(nodo.izquierdo, tree_node)
		left_child.number = child_number
		tree_node.children.append(left_child)
		child_number += 1
	
	# Hijo derecho
	if nodo.derecho != null:
		var right_child = _build_tree_structure(nodo.derecho, tree_node)
		right_child.number = child_number
		tree_node.children.append(right_child)
		
		# Establecer hermano izquierdo
		if nodo.izquierdo != null:
			right_child.left_sibling = tree_node.children[0]
	
	return tree_node

# Primera pasada: Calcular posiciones preliminares (post-order)
func _calculate_initial_positions(node: TreeNode) -> void:
	for child in node.children:
		_calculate_initial_positions(child)
	
	if node.is_leaf():
		# Si es hoja, posicionar relativo al hermano izquierdo
		if node.left_sibling != null:
			node.prelim = node.left_sibling.prelim + node_spacing
		else:
			node.prelim = 0.0
	else:
		# Si tiene hijos, centrar sobre ellos
		var leftmost = node.get_leftmost_child()
		var rightmost = node.get_rightmost_child()
		var mid = (leftmost.prelim + rightmost.prelim) / 2.0
		
		if node.left_sibling != null:
			node.prelim = node.left_sibling.prelim + node_spacing
			node.modifier = node.prelim - mid
			_apportion(node)
		else:
			node.prelim = mid

# Distribuir espacio entre subárboles (apportion)
func _apportion(node: TreeNode) -> void:
	var left_sibling = node.left_sibling
	if left_sibling == null:
		return
	
	# Recorrer contornos
	var inside_right = node.get_leftmost_child()
	var outside_right = node
	var inside_left = left_sibling.get_rightmost_child()
	var outside_left = inside_right.left_sibling if inside_right else null
	
	var inside_right_mod = inside_right.modifier if inside_right else 0.0
	var outside_right_mod = outside_right.modifier
	var inside_left_mod = inside_left.modifier if inside_left else 0.0
	var outside_left_mod = outside_left.modifier if outside_left else 0.0
	
	while inside_left != null and inside_right != null:
		inside_left = _next_right(inside_left)
		inside_right = _next_left(inside_right)
		outside_left = _next_left(outside_left) if outside_left else null
		outside_right = _next_right(outside_right)
		
		if outside_right and inside_left:
			outside_right.ancestor = node
		
		if inside_left and inside_right:
			var shift = (inside_left.prelim + inside_left_mod) - (inside_right.prelim + inside_right_mod) + subtree_spacing
			
			if shift > 0:
				var subtree_ancestor = _get_ancestor(inside_left, node)
				_move_subtree(subtree_ancestor, node, shift)
				inside_right_mod += shift
				outside_right_mod += shift
		
		# Actualizar modificadores para siguiente iteración
		if inside_left:
			inside_left_mod += inside_left.modifier
		if inside_right:
			inside_right_mod += inside_right.modifier
		if outside_left:
			outside_left_mod += outside_left.modifier
		if outside_right:
			outside_right_mod += outside_right.modifier

# Siguiente nodo en el contorno izquierdo
func _next_left(node: TreeNode) -> TreeNode:
	if not node.children.is_empty():
		return node.get_leftmost_child()
	else:
		return node.thread

# Siguiente nodo en el contorno derecho
func _next_right(node: TreeNode) -> TreeNode:
	if not node.children.is_empty():
		return node.get_rightmost_child()
	else:
		return node.thread

# Mover subárbol
func _move_subtree(left_node: TreeNode, right_node: TreeNode, shift: float) -> void:
	var subtrees = right_node.number - left_node.number
	if subtrees <= 0:
		return
	
	right_node.change -= shift / subtrees
	right_node.shift += shift
	left_node.change += shift / subtrees
	right_node.prelim += shift
	right_node.modifier += shift

# Obtener ancestro común
func _get_ancestor(node: TreeNode, default_ancestor: TreeNode) -> TreeNode:
	if node.ancestor and node.ancestor.parent == default_ancestor.parent:
		return node.ancestor
	else:
		return default_ancestor

# Segunda pasada: Calcular posiciones finales (pre-order)
func _calculate_final_positions(node: TreeNode, modsum: float) -> void:
	node.x = node.prelim + modsum
	node.y = node.number if node.parent else 0.0  # Nivel basado en profundidad
	
	var child_modsum = modsum + node.modifier
	for child in node.children:
		_calculate_final_positions(child, child_modsum)

# Recolectar posiciones en un diccionario
func _collect_positions(tree_node: TreeNode, positions: Dictionary) -> void:
	if tree_node == null:
		return
	
	# Calcular nivel (profundidad)
	var level = 0
	var current = tree_node
	while current.parent != null:
		level += 1
		current = current.parent
	
	positions[tree_node.nodo] = Vector2(tree_node.x, level * level_spacing)
	
	for child in tree_node.children:
		_collect_positions(child, positions)

func _draw_tree_with_positions(positions: Dictionary) -> void:
	if positions.is_empty():
		return
	
	# Encontrar los límites
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	
	for pos in positions.values():
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
	
	# Centrar en viewport
	var viewport_center = size / 2.0
	var tree_width = max_x - min_x
	var offset = Vector2(viewport_center.x - tree_width / 2.0 - min_x, 50 - min_y)
	
	# Dibujar nodos recursivamente
	_draw_nodes_recursive(tree.raiz, positions, offset)

func _draw_nodes_recursive(nodo: Nodo, positions: Dictionary, offset: Vector2) -> void:
	if nodo == null or not positions.has(nodo):
		return
	
	var pos = positions[nodo] + offset
	
	# Crear el nodo visual
	var nodo_visual = nodo_escena.instantiate()
	if nodo_visual == null:
		push_error("No se pudo instanciar el nodo_escena")
		return
	
	nodo_visual.position = pos
	nodos_container.add_child(nodo_visual)
	
	if nodo_visual.has_method("set_tipo"):
		nodo_visual.set_tipo.call_deferred(nodo.tipo)
	
	# Dibujar líneas a los hijos
	if nodo.izquierdo != null and positions.has(nodo.izquierdo):
		var child_pos = positions[nodo.izquierdo] + offset
		lineas.append([pos, child_pos])
		_draw_nodes_recursive(nodo.izquierdo, positions, offset)
	
	if nodo.derecho != null and positions.has(nodo.derecho):
		var child_pos = positions[nodo.derecho] + offset
		lineas.append([pos, child_pos])
		_draw_nodes_recursive(nodo.derecho, positions, offset)

func _clear_tree_visual() -> void:
	lineas.clear()
	
	if nodos_container == null or lineas_node == null:
		return
	
	for child in nodos_container.get_children():
		child.queue_free()
	
	nodos_container.position = Vector2.ZERO
	nodos_container.scale = Vector2.ONE
	lineas_node.position = Vector2.ZERO
	lineas_node.scale = Vector2.ONE
	
	camera_offset = Vector2.ZERO
	zoom_factor = 1.0
	target_zoom = 1.0

func _process(delta: float) -> void:
	if abs(target_zoom - zoom_factor) > 0.001:
		_apply_smooth_zoom(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and drag_active:
		_handle_mouse_drag(event)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT:
			if event.button_index == MOUSE_BUTTON_RIGHT and not pan_with_right_click:
				return
			if event.pressed:
				drag_active = true
				last_mouse_pos = event.position
			else:
				drag_active = false
		
		MOUSE_BUTTON_WHEEL_UP:
			_change_zoom(1)
		
		MOUSE_BUTTON_WHEEL_DOWN:
			_change_zoom(-1)
		
		MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_reset_view()

func _handle_mouse_drag(event: InputEventMouseMotion) -> void:
	if nodos_container == null or lineas_node == null:
		return
	
	var delta = event.position - last_mouse_pos
	last_mouse_pos = event.position
	camera_offset += delta
	
	nodos_container.position += delta
	lineas_node.position += delta

func _change_zoom(direction: int) -> void:
	target_zoom = clamp(
		target_zoom + direction * zoom_step,
		zoom_min,
		zoom_max
	)

func _apply_smooth_zoom(delta: float) -> void:
	var old_zoom = zoom_factor
	zoom_factor = lerp(zoom_factor, target_zoom, zoom_smooth_speed * delta)
	
	if abs(target_zoom - zoom_factor) < 0.001:
		zoom_factor = target_zoom
	
	var zoom_ratio = zoom_factor / old_zoom
	
	# Zoom hacia el centro del viewport
	var viewport_center = size / 2.0
	var offset_before = nodos_container.position - viewport_center
	
	nodos_container.scale = Vector2.ONE * zoom_factor
	lineas_node.scale = Vector2.ONE * zoom_factor
	
	var offset_after = offset_before * zoom_ratio
	nodos_container.position = viewport_center + offset_after
	lineas_node.position = nodos_container.position

func _reset_view() -> void:
	if nodos_container == null or lineas_node == null:
		return
		
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	target_zoom = 1.0
	
	var viewport_center = size / 2.0
	tween.tween_property(nodos_container, "position", viewport_center - Vector2(viewport_center.x, 0), 0.5)
	tween.tween_property(lineas_node, "position", viewport_center - Vector2(viewport_center.x, 0), 0.5)
	tween.tween_property(nodos_container, "scale", Vector2.ONE, 0.5)
	tween.tween_property(lineas_node, "scale", Vector2.ONE, 0.5)
	
	if is_inside_tree():
		await tween.finished
	zoom_factor = 1.0
	camera_offset = Vector2.ZERO

func _get_tree_bounds() -> Rect2:
	if nodos_container == null or nodos_container.get_child_count() == 0:
		return Rect2()
	
	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)
	
	for child in nodos_container.get_children():
		if child is Control or child is Node2D:
			var pos = child.position
			min_pos.x = min(min_pos.x, pos.x)
			min_pos.y = min(min_pos.y, pos.y)
			max_pos.x = max(max_pos.x, pos.x)
			max_pos.y = max(max_pos.y, pos.y)
	
	return Rect2(min_pos, max_pos - min_pos)

func center_tree() -> void:
	if nodos_container == null or lineas_node == null:
		return
		
	var bounds = _get_tree_bounds()
	if bounds.size == Vector2.ZERO:
		return
	
	var viewport_center = size / 2.0
	var tree_center = bounds.get_center()
	
	var offset = viewport_center - tree_center
	
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(nodos_container, "position", offset, 0.5)
	tween.tween_property(lineas_node, "position", offset, 0.5)

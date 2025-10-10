extends Node
class_name TreeLayout

## ------------------------------------------------------------
## Layout de árbol jerárquico optimizado (Reingold–Tilford mejorado)
## Compatible con orientación vertical u horizontal
## Usa directamente TreeNode sin wrapper adicional
## ------------------------------------------------------------

# Orientación y espaciado básico
@export_enum("vertical", "horizontal") var orientation := "vertical"
@export var node_spacing: float = 140.0
@export var subtree_spacing: float = 100.0
@export var level_spacing: float = 120.0

# Tamaño de nodos
@export_group("Tamaño de Nodos")
@export var node_width: float = 60.0
@export var node_height: float = 40.0
@export var use_node_size_in_spacing: bool = true

# Escalado y adaptación
@export_group("Escalado")
@export var vertical_scale_factor: float = 0.1
@export var use_adaptive_vertical_spacing: bool = true
@export var min_level_spacing: float = 80.0
@export var max_level_spacing: float = 200.0
@export_range(0.5, 2.0) var aspect_ratio: float = 2.0

# Espaciado entre hermanos
@export_group("Espaciado")
@export_range(0.1, 3.0) var sibling_spacing_multiplier: float = 2.0
@export_range(0.0, 1.0) var apportion_smoothing: float = 0.7
@export var compact_mode: bool = false
@export_range(0.5, 1.5) var compact_factor: float = 0.9

# Centrado y alineación
@export_group("Alineación")
@export_enum("center", "left", "right", "weighted_leaves", "weighted_children") var centering_mode := "weighted_leaves"
@export var align_leaf_nodes: bool = false

# Márgenes
@export_group("Márgenes")
@export var margin_top: float = 20.0
@export var margin_left: float = 20.0
@export var margin_bottom: float = 20.0
@export var margin_right: float = 20.0

# Balance
@export_group("Balance")
@export var balance_subtrees: bool = true

# ------------------------------------------------------------
# DATOS DE LAYOUT ALMACENADOS POR NODO
# ------------------------------------------------------------

var _layout_data: Dictionary = {}  # TreeNode -> Dictionary con datos de layout

func _get_layout(node: TreeNode) -> Dictionary:
	if not _layout_data.has(node):
		_layout_data[node] = {
			"prelim": 0.0,
			"modifier": 0.0,
			"x": 0.0,
			"left_sibling": null,
			"leaf_count": 0,
			"level": 0
		}
	return _layout_data[node]

func _set_prelim(node: TreeNode, value: float) -> void:
	_get_layout(node)["prelim"] = value

func _get_prelim(node: TreeNode) -> float:
	return _get_layout(node)["prelim"]

func _set_modifier(node: TreeNode, value: float) -> void:
	_get_layout(node)["modifier"] = value

func _get_modifier(node: TreeNode) -> float:
	return _get_layout(node)["modifier"]

func _set_x(node: TreeNode, value: float) -> void:
	_get_layout(node)["x"] = value

func _get_x(node: TreeNode) -> float:
	return _get_layout(node)["x"]

func _set_left_sibling(node: TreeNode, sibling: TreeNode) -> void:
	_get_layout(node)["left_sibling"] = sibling

func _get_left_sibling(node: TreeNode) -> TreeNode:
	return _get_layout(node)["left_sibling"]

# ------------------------------------------------------------
# FUNCIÓN PRINCIPAL DE LAYOUT
# ------------------------------------------------------------

func calculate_layout(root: TreeNode) -> Dictionary:
	if root == null:
		return {}

	# Limpiar datos anteriores
	_layout_data.clear()

	if subtree_spacing <= 0.0:
		subtree_spacing = node_spacing * 0.8

	# Preparar estructura (hermanos, metadatos)
	_prepare_tree_structure(root)
	
	var effective_node_spacing = node_spacing * sibling_spacing_multiplier
	var effective_subtree_spacing = subtree_spacing
	
	if compact_mode:
		effective_node_spacing *= compact_factor
		effective_subtree_spacing *= compact_factor
	
	_calculate_initial_positions(root, effective_node_spacing, effective_subtree_spacing)
	_finalize_positions(root, 0.0)

	var positions := {}
	_collect_positions(root, positions, 0, level_spacing)
	
	if align_leaf_nodes:
		_align_leaves(positions, root)
	
	positions = _normalize_positions(positions)
	positions = _apply_margins(positions)
	positions = _center_tree(positions)
	
	return positions

# ------------------------------------------------------------
# PREPARACIÓN DEL ÁRBOL
# ------------------------------------------------------------

func _prepare_tree_structure(node: TreeNode, parent: TreeNode = null, level: int = 0) -> void:
	var layout = _get_layout(node)
	layout["level"] = level
	
	var children = node.get_children()
	
	# Establecer hermanos izquierdos
	var prev_child: TreeNode = null
	for child in children:
		if child is TreeNode:
			_set_left_sibling(child, prev_child)
			_prepare_tree_structure(child, node, level + 1)
			prev_child = child
	
	# Calcular metadata
	layout["leaf_count"] = _count_leaves(node)

# ------------------------------------------------------------
# HELPERS PARA NODOS
# ------------------------------------------------------------

func _is_leaf(node: TreeNode) -> bool:
	if node == null:
		return false
	return node.izquierdo == null and node.derecho == null

func _get_leftmost_child(node: TreeNode) -> TreeNode:
	if node.izquierdo != null:
		return node.izquierdo
	return node.derecho

func _get_rightmost_child(node: TreeNode) -> TreeNode:
	if node.derecho != null:
		return node.derecho
	return node.izquierdo

# ------------------------------------------------------------
# POSICIONAMIENTO INICIAL
# ------------------------------------------------------------

func _calculate_initial_positions(node: TreeNode, node_spacing: float, subtree_spacing: float) -> void:
	if node == null:
		return
	
	# Procesar hijos primero
	var children = node.get_children()
	for child in children:
		_calculate_initial_positions(child, node_spacing, subtree_spacing)

	if _is_leaf(node):
		var effective_spacing = node_spacing
		if use_node_size_in_spacing:
			effective_spacing = max(node_spacing, node_width * 1.5)
		
		var left_sib = _get_left_sibling(node)
		if left_sib:
			_set_prelim(node, _get_prelim(left_sib) + effective_spacing)
		else:
			_set_prelim(node, 0.0)
	else:
		_position_internal_node(node, node_spacing, subtree_spacing)

# ------------------------------------------------------------

func _position_internal_node(node: TreeNode, node_spacing: float, _subtree_spacing: float) -> void:
	var leftmost := _get_leftmost_child(node)
	var rightmost := _get_rightmost_child(node)
	if leftmost == null or rightmost == null:
		return

	var mid := 0.0
	match centering_mode:
		"center":
			mid = (_get_prelim(leftmost) + _get_prelim(rightmost)) / 2.0
		"left":
			mid = _get_prelim(leftmost)
		"right":
			mid = _get_prelim(rightmost)
		"weighted_leaves":
			mid = _get_weighted_midpoint_leaves(node)
		"weighted_children":
			mid = _get_weighted_midpoint_children(node)
		_:
			mid = _get_weighted_midpoint_leaves(node)

	var left_sib = _get_left_sibling(node)
	if left_sib != null:
		_set_prelim(node, _get_prelim(left_sib) + node_spacing)
		_set_modifier(node, _get_prelim(node) - mid)
		if balance_subtrees:
			_apportion(node, _subtree_spacing)
	else:
		_set_prelim(node, mid)

# ------------------------------------------------------------

func _apportion(node: TreeNode, _subtree_spacing: float) -> void:
	var leftmost := _get_leftmost_child(node)
	if leftmost == null:
		return

	var left_neighbor := _get_left_sibling(leftmost)
	if left_neighbor == null:
		return

	var min_spacing = _subtree_spacing
	if use_node_size_in_spacing:
		min_spacing = max(_subtree_spacing, node_width * 2.0)

	# calcula solapamiento real
	var overlap : float = (_get_prelim(left_neighbor) + _get_subtree_width(left_neighbor) + min_spacing) - _get_prelim(leftmost)

	if overlap > 0.0:
		overlap = lerpf(overlap, overlap * apportion_smoothing, 1.0)
		_shift_subtree(node, overlap)


func _shift_subtree(node: TreeNode, shift: float) -> void:
	if node == null:
		return
	
	_set_prelim(node, _get_prelim(node) + shift)
	_set_modifier(node, _get_modifier(node) + shift)
	
	# Mover hijos recursivamente
	var children = node.get_children()
	for child in children:
		_shift_subtree(child, shift)

func _get_subtree_width(node: TreeNode) -> float:
	if _is_leaf(node):
		return node_width
	var left := _get_leftmost_child(node)
	var right := _get_rightmost_child(node)
	if left == null or right == null:
		return node_width
	return abs(_get_prelim(right) - _get_prelim(left)) + node_width

# ------------------------------------------------------------
# CÁLCULO DE POSICIONES FINALES
# ------------------------------------------------------------

func _finalize_positions(node: TreeNode, mod_sum: float) -> void:
	if node == null:
		return
	
	_set_x(node, _get_prelim(node) + mod_sum)
	
	var children = node.get_children()
	for child in children:
		_finalize_positions(child, mod_sum + _get_modifier(node))

# ------------------------------------------------------------
# RECOLECCIÓN DE POSICIONES
# ------------------------------------------------------------

func _collect_positions(node: TreeNode, positions: Dictionary, level: int, level_spacing: float) -> void:
	if node == null:
		return

	var vertical_scale := 1.0
	if use_adaptive_vertical_spacing:
		vertical_scale = 1.0 + vertical_scale_factor * float(_count_levels(node))
	
	var effective_level_spacing = level_spacing * vertical_scale
	effective_level_spacing = clamp(effective_level_spacing, min_level_spacing, max_level_spacing)
	
	var pos: Vector2
	if orientation == "vertical":
		pos = Vector2(_get_x(node) * aspect_ratio, float(level) * effective_level_spacing)
	else:
		pos = Vector2(float(level) * effective_level_spacing, _get_x(node) * aspect_ratio)
	
	positions[node] = pos

	var children = node.get_children()
	for child in children:
		_collect_positions(child, positions, level + 1, level_spacing)

# ------------------------------------------------------------
# ALINEACIÓN DE HOJAS
# ------------------------------------------------------------

func _align_leaves(positions: Dictionary, root: TreeNode) -> void:
	var max_depth := _count_levels(root)
	var leaves := _collect_leaves(root)
	
	for leaf in leaves:
		if leaf in positions:
			var pos = positions[leaf]
			if orientation == "vertical":
				var target_y = (max_depth - 1) * level_spacing
				positions[leaf] = Vector2(pos.x, target_y)
			else:
				var target_x = (max_depth - 1) * level_spacing
				positions[leaf] = Vector2(target_x, pos.y)

func _collect_leaves(node: TreeNode) -> Array:
	var leaves := []
	if _is_leaf(node):
		leaves.append(node)
	else:
		var children = node.get_children()
		for child in children:
			leaves.append_array(_collect_leaves(child))
	return leaves

# ------------------------------------------------------------
# FUNCIONES AUXILIARES
# ------------------------------------------------------------

func _get_weighted_midpoint_leaves(node: TreeNode) -> float:
	var total_weight := 0.0
	var weighted_sum := 0.0
	var children = node.get_children()
	
	for child in children:
		var leaves := _count_leaves(child)
		total_weight += leaves
		weighted_sum += _get_prelim(child) * leaves
	return weighted_sum / total_weight if total_weight > 0 else 0.0

func _get_weighted_midpoint_children(node: TreeNode) -> float:
	var total := 0.0
	var children = node.get_children()
	var count = 0
	
	for child in children:
		total += _get_prelim(child)
		count += 1
	
	return total / count if count > 0 else 0.0

func _count_leaves(node: TreeNode) -> int:
	if node == null:
		return 0
	if _is_leaf(node):
		return 1
	var count := 0
	var children = node.get_children()
	for child in children:
		count += _count_leaves(child)
	return count

func _count_levels(node: TreeNode) -> int:
	if node == null:
		return 0
	if _is_leaf(node):
		return 1
	var max_level := 0
	var children = node.get_children()
	for child in children:
		max_level = max(max_level, _count_levels(child))
	return max_level + 1

func _normalize_positions(positions: Dictionary) -> Dictionary:
	if positions.is_empty():
		return positions
	
	var min_x := INF
	var min_y := INF
	
	for pos in positions.values():
		min_x = minf(min_x, pos.x)
		min_y = minf(min_y, pos.y)
	
	if min_x < 0.0 or min_y < 0.0:
		for key in positions.keys():
			var pos = positions[key]
			positions[key] = Vector2(
				pos.x - (min_x if min_x < 0.0 else 0.0),
				pos.y - (min_y if min_y < 0.0 else 0.0)
			)
	
	return positions

func _apply_margins(positions: Dictionary) -> Dictionary:
	var offset := Vector2(margin_left, margin_top)
	for key in positions.keys():
		positions[key] += offset
	return positions

func _center_tree(positions: Dictionary) -> Dictionary:
	if positions.is_empty():
		return positions
	var min_x := INF
	var max_x := -INF
	for pos in positions.values():
		min_x = minf(min_x, pos.x)
		max_x = maxf(max_x, pos.x)
	var center_offset := -(max_x - min_x) / 2.0
	for key in positions.keys():
		positions[key].x += center_offset + margin_left
	return positions

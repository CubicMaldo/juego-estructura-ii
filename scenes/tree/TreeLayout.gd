extends Node
class_name TreeLayout

## ------------------------------------------------------------
## Layout de árbol jerárquico optimizado (Reingold–Tilford mejorado)
## Compatible con orientación vertical u horizontal
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

func calculate_layout(root: Nodo) -> Dictionary:
	if root == null:
		return {}

	if subtree_spacing <= 0.0:
		subtree_spacing = node_spacing * 0.8

	var tree_root := _build_tree_structure(root)
	
	var effective_node_spacing = node_spacing * sibling_spacing_multiplier
	var effective_subtree_spacing = subtree_spacing
	
	if compact_mode:
		effective_node_spacing *= compact_factor
		effective_subtree_spacing *= compact_factor
	
	_calculate_initial_positions(tree_root, effective_node_spacing, effective_subtree_spacing)
	_finalize_positions(tree_root, 0.0)

	var positions := {}
	_collect_positions(tree_root, positions, 0, level_spacing)
	
	if align_leaf_nodes:
		_align_leaves(positions, tree_root)
	
	positions = _normalize_positions(positions)
	positions = _apply_margins(positions)
	positions = _center_tree(positions)
	
	return positions

# ------------------------------------------------------------
# ESTRUCTURA INTERNA DEL ÁRBOL
# ------------------------------------------------------------

class TreeNode:
	var nodo: Nodo
	var parent: TreeNode
	var children: Array = []
	var x: float = 0.0
	var y: float = 0.0
	var prelim: float = 0.0
	var modifier: float = 0.0
	var left_sibling: TreeNode
	var metadata := {}

	func _init(_nodo: Nodo, _parent: TreeNode = null) -> void:
		nodo = _nodo
		parent = _parent

	func is_leaf() -> bool:
		return children.is_empty()

	func get_leftmost_child() -> TreeNode:
		return children.front() if not children.is_empty() else null

	func get_rightmost_child() -> TreeNode:
		return children.back() if not children.is_empty() else null

# ------------------------------------------------------------
# CONSTRUCCIÓN DEL ÁRBOL
# ------------------------------------------------------------

func _build_tree_structure(nodo: Nodo, parent: TreeNode = null) -> TreeNode:
	var tree_node := TreeNode.new(nodo, parent)
	var children : Array = nodo.get_children()

	var prev_child: TreeNode = null
	for child in children:
		if child is Nodo:
			var child_tree := _build_tree_structure(child, tree_node)
			child_tree.left_sibling = prev_child
			tree_node.children.append(child_tree)
			prev_child = child_tree

	tree_node.metadata["leaf_count"] = _count_leaves(tree_node)
	tree_node.metadata["child_count"] = tree_node.children.size()
	tree_node.metadata["level"] = _get_node_level(tree_node)
	
	return tree_node

# ------------------------------------------------------------
# POSICIONAMIENTO INICIAL
# ------------------------------------------------------------

func _calculate_initial_positions(node: TreeNode, node_spacing: float, subtree_spacing: float) -> void:
	for child in node.children:
		_calculate_initial_positions(child, node_spacing, subtree_spacing)

	if node.is_leaf():
		var effective_spacing = node_spacing
		if use_node_size_in_spacing:
			effective_spacing = max(node_spacing, node_width * 1.5)
		node.prelim = node.left_sibling.prelim + effective_spacing if node.left_sibling else 0.0
	else:
		_position_internal_node(node, node_spacing, subtree_spacing)

# ------------------------------------------------------------

func _position_internal_node(node: TreeNode, node_spacing: float, _subtree_spacing: float) -> void:
	var leftmost := node.get_leftmost_child()
	var rightmost := node.get_rightmost_child()
	if leftmost == null or rightmost == null:
		return

	var mid := 0.0
	match centering_mode:
		"center":
			mid = (leftmost.prelim + rightmost.prelim) / 2.0
		"left":
			mid = leftmost.prelim
		"right":
			mid = rightmost.prelim
		"weighted_leaves":
			mid = _get_weighted_midpoint_leaves(node)
		"weighted_children":
			mid = _get_weighted_midpoint_children(node)
		_:
			mid = _get_weighted_midpoint_leaves(node)

	if node.left_sibling != null:
		node.prelim = node.left_sibling.prelim + node_spacing
		node.modifier = node.prelim - mid
		if balance_subtrees:
			_apportion(node, _subtree_spacing)
	else:
		node.prelim = mid

# ------------------------------------------------------------

func _apportion(node: TreeNode, _subtree_spacing: float) -> void:
	var leftmost := node.get_leftmost_child()
	if leftmost == null:
		return

	var left_neighbor := leftmost.left_sibling
	if left_neighbor == null:
		return

	var min_spacing = _subtree_spacing
	if use_node_size_in_spacing:
		min_spacing = max(_subtree_spacing, node_width * 2.0)

	# calcula solapamiento real
	var overlap : float = (left_neighbor.prelim + _get_subtree_width(left_neighbor) + min_spacing) - leftmost.prelim

	if overlap > 0.0:
		overlap = lerpf(overlap, overlap * apportion_smoothing, 1.0)
		_shift_subtree(node, overlap)


func _shift_subtree(node: TreeNode, shift: float) -> void:
	# Mueve todo el subárbol hacia la derecha (o abajo si horizontal)
	for child in node.children:
		child.prelim += shift
		child.modifier += shift
		_shift_subtree(child, shift)

func _get_subtree_width(node: TreeNode) -> float:
	if node.is_leaf():
		return node_width
	var left := node.get_leftmost_child()
	var right := node.get_rightmost_child()
	return abs(right.prelim - left.prelim) + node_width

# ------------------------------------------------------------
# CÁLCULO DE POSICIONES FINALES
# ------------------------------------------------------------

func _finalize_positions(node: TreeNode, mod_sum: float) -> void:
	node.x = node.prelim + mod_sum
	for child in node.children:
		_finalize_positions(child, mod_sum + node.modifier)

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
		pos = Vector2(node.x * aspect_ratio, float(level) * effective_level_spacing)
	else:
		pos = Vector2(float(level) * effective_level_spacing, node.x * aspect_ratio)
	
	positions[node.nodo] = pos

	for child in node.children:
		_collect_positions(child, positions, level + 1, level_spacing)

# ------------------------------------------------------------
# ALINEACIÓN DE HOJAS
# ------------------------------------------------------------

func _align_leaves(positions: Dictionary, root: TreeNode) -> void:
	var max_depth := _count_levels(root)
	var leaves := _collect_leaves(root)
	
	for leaf in leaves:
		if leaf.nodo in positions:
			var pos = positions[leaf.nodo]
			if orientation == "vertical":
				var target_y = (max_depth - 1) * level_spacing
				positions[leaf.nodo] = Vector2(pos.x, target_y)
			else:
				var target_x = (max_depth - 1) * level_spacing
				positions[leaf.nodo] = Vector2(target_x, pos.y)

func _collect_leaves(node: TreeNode) -> Array:
	var leaves := []
	if node.is_leaf():
		leaves.append(node)
	else:
		for child in node.children:
			leaves.append_array(_collect_leaves(child))
	return leaves

# ------------------------------------------------------------
# FUNCIONES AUXILIARES
# ------------------------------------------------------------

func _get_weighted_midpoint_leaves(node: TreeNode) -> float:
	var total_weight := 0.0
	var weighted_sum := 0.0
	for child in node.children:
		var leaves := _count_leaves(child)
		total_weight += leaves
		weighted_sum += child.prelim * leaves
	return weighted_sum / total_weight if total_weight > 0 else 0.0

func _get_weighted_midpoint_children(node: TreeNode) -> float:
	var total := 0.0
	for child in node.children:
		total += child.prelim
	return total / node.children.size() if node.children.size() > 0 else 0.0

func _count_leaves(node: TreeNode) -> int:
	if node.is_leaf():
		return 1
	var count := 0
	for child in node.children:
		count += _count_leaves(child)
	return count

func _count_levels(node: TreeNode) -> int:
	if node.is_leaf():
		return 1
	var max_level := 0
	for child in node.children:
		max_level = max(max_level, _count_levels(child))
	return max_level + 1

func _get_node_level(node: TreeNode) -> int:
	var level := 0
	var current := node
	while current.parent != null:
		level += 1
		current = current.parent
	return level

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

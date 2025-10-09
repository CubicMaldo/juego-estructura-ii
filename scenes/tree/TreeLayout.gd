# TreeLayout.gd
class_name TreeLayout
extends Control

# Clase interna para el algoritmo
class TreeNode:
	var nodo: Nodo
	var children: Array[TreeNode] = []
	var parent: TreeNode = null
	var x: float = 0.0
	var y: float = 0.0
	var prelim: float = 0.0
	var modifier: float = 0.0
	var left_sibling: TreeNode = null
	var thread: TreeNode = null
	var ancestor: TreeNode = null
	var number: int = 0
	var change: float = 0.0
	var shift: float = 0.0
	
	func _init(n: Nodo):
		nodo = n
		ancestor = self
	
	func is_leaf() -> bool:
		return children.is_empty()
	
	func get_leftmost_child() -> TreeNode:
		return children[0] if not children.is_empty() else null
	
	func get_rightmost_child() -> TreeNode:
		return children[-1] if not children.is_empty() else null

# ========== API PÚBLICA ==========

func calculate_tree_layout(root_nodo: Nodo, node_spacing: float, 
						 level_spacing: float, subtree_spacing: float) -> Dictionary:
	if root_nodo == null:
		return {}
	
	# Construir estructura del árbol
	var root_tree_node = _build_tree_structure(root_nodo, null)
	
	# Aplicar algoritmo Reingold-Tilford
	_calculate_initial_positions(root_tree_node, node_spacing, subtree_spacing)
	_calculate_final_positions(root_tree_node, 0.0)
	
	# Recolectar posiciones
	var positions = {}
	_collect_positions(root_tree_node, positions, 0, level_spacing)
	
	return positions

# ========== ALGORITMO REINGOLD-TILFORD ==========

func _build_tree_structure(nodo: Nodo, parent: TreeNode) -> TreeNode:
	if nodo == null:
		return null
	
	var tree_node = TreeNode.new(nodo)
	tree_node.parent = parent
	
	var child_number = 0
	
	# Procesar hijo izquierdo
	if nodo.izquierdo != null:
		var left_child = _build_tree_structure(nodo.izquierdo, tree_node)
		left_child.number = child_number
		tree_node.children.append(left_child)
		child_number += 1
	
	# Procesar hijo derecho
	if nodo.derecho != null:
		var right_child = _build_tree_structure(nodo.derecho, tree_node)
		right_child.number = child_number
		tree_node.children.append(right_child)
		
		# Establecer hermano izquierdo
		if nodo.izquierdo != null:
			right_child.left_sibling = tree_node.children[0]
	
	return tree_node

func _calculate_initial_positions(node: TreeNode, node_spacing: float, subtree_spacing: float) -> void:
	# Post-order traversal
	for child in node.children:
		_calculate_initial_positions(child, node_spacing, subtree_spacing)
	
	if node.is_leaf():
		# Nodo hoja
		if node.left_sibling != null:
			node.prelim = node.left_sibling.prelim + node_spacing
		else:
			node.prelim = 0.0
	else:
		# Nodo con hijos
		var leftmost = node.get_leftmost_child()
		var rightmost = node.get_rightmost_child()
		var mid = (leftmost.prelim + rightmost.prelim) / 2.0
		
		if node.left_sibling != null:
			node.prelim = node.left_sibling.prelim + node_spacing
			node.modifier = node.prelim - mid
			_apportion(node, subtree_spacing)
		else:
			node.prelim = mid

func _apportion(node: TreeNode, subtree_spacing: float) -> void:
	var left_sibling = node.left_sibling
	if left_sibling == null:
		return
	
	var inside_right = node.get_leftmost_child()
	var outside_right = node
	var inside_left = left_sibling.get_rightmost_child()
	var outside_left = inside_right.left_sibling if inside_right else null
	
	var mod_sums = {
		"inside_right": inside_right.modifier if inside_right else 0.0,
		"outside_right": outside_right.modifier,
		"inside_left": inside_left.modifier if inside_left else 0.0,
		"outside_left": outside_left.modifier if outside_left else 0.0
	}
	
	while inside_left != null and inside_right != null:
		inside_left = _next_right(inside_left)
		inside_right = _next_left(inside_right)
		outside_left = _next_left(outside_left) if outside_left else null
		outside_right = _next_right(outside_right)
		
		if outside_right and inside_left:
			outside_right.ancestor = node
		
		var shift = _calculate_shift(inside_left, inside_right, mod_sums, subtree_spacing)
		if shift > 0:
			_apply_shift(node, inside_left, inside_right, shift, mod_sums)
		
		_update_mod_sums(inside_left, inside_right, outside_left, outside_right, mod_sums)

func _calculate_shift(inside_left: TreeNode, inside_right: TreeNode, 
					 mod_sums: Dictionary, subtree_spacing: float) -> float:
	if not inside_left or not inside_right:
		return 0.0
	
	return (inside_left.prelim + mod_sums.inside_left) - \
		   (inside_right.prelim + mod_sums.inside_right) + subtree_spacing

func _apply_shift(node: TreeNode, inside_left: TreeNode, inside_right: TreeNode,
				 shift: float, mod_sums: Dictionary) -> void:
	var subtree_ancestor = _get_ancestor(inside_left, node)
	_move_subtree(subtree_ancestor, node, shift)
	
	mod_sums.inside_right += shift
	mod_sums.outside_right += shift

func _move_subtree(left_node: TreeNode, right_node: TreeNode, shift: float) -> void:
	var subtrees = right_node.number - left_node.number
	if subtrees <= 0:
		return
	
	right_node.change -= shift / subtrees
	right_node.shift += shift
	left_node.change += shift / subtrees
	right_node.prelim += shift
	right_node.modifier += shift

func _get_ancestor(node: TreeNode, default_ancestor: TreeNode) -> TreeNode:
	if node.ancestor and node.ancestor.parent == default_ancestor.parent:
		return node.ancestor
	else:
		return default_ancestor

func _update_mod_sums(inside_left: TreeNode, inside_right: TreeNode,
					 outside_left: TreeNode, outside_right: TreeNode,
					 mod_sums: Dictionary) -> void:
	if inside_left:
		mod_sums.inside_left += inside_left.modifier
	if inside_right:
		mod_sums.inside_right += inside_right.modifier
	if outside_left:
		mod_sums.outside_left += outside_left.modifier
	if outside_right:
		mod_sums.outside_right += outside_right.modifier

func _calculate_final_positions(node: TreeNode, modsum: float) -> void:
	node.x = node.prelim + modsum
	
	for child in node.children:
		_calculate_final_positions(child, modsum + node.modifier)

func _collect_positions(node: TreeNode, positions: Dictionary, level: int, level_spacing: float) -> void:
	if node == null:
		return
	
	positions[node.nodo] = Vector2(node.x, level * level_spacing)
	
	for child in node.children:
		_collect_positions(child, positions, level + 1, level_spacing)

# ========== FUNCIONES DE UTILIDAD ==========

func _next_left(node: TreeNode) -> TreeNode:
	if not node.children.is_empty():
		return node.get_leftmost_child()
	else:
		return node.thread

func _next_right(node: TreeNode) -> TreeNode:
	if not node.children.is_empty():
		return node.get_rightmost_child()
	else:
		return node.thread

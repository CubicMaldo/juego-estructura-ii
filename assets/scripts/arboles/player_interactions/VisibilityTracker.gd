extends Node
class_name VisibilityTracker

signal node_discovered(node: TreeNode)
signal node_visited(node: TreeNode)
signal current_node_changed(new_node: TreeNode, old_node: TreeNode)

# 🎯 FUENTE DE VERDAD
var current_node: TreeNode = null
var discovered_nodes: Dictionary = {}
var visited_nodes: Dictionary = {}

func move_to_node(node: TreeNode) -> void:
	"""Mueve al jugador a un nuevo nodo"""
	if node == null or node == current_node:
		return

	var old_node = current_node
	current_node = node  #Actualizar fuente de verdad

	# Descubrir nodo
	if not discovered_nodes.has(node):
		discover_node(node)

	# Marcar como visitado
	if not visited_nodes.has(node):
		visited_nodes[node] = true
		node_visited.emit(node)

	# Notificar cambio
	current_node_changed.emit(current_node, old_node)

func discover_node(node: TreeNode) -> void:
	if node == null:
		return
	
	if not is_discovered(node):
		discovered_nodes[node] = true
		node_discovered.emit(node)

func visit_node(node: TreeNode) -> void:
	if node == null:
		return
	
	discover_node(node)
	
	if not is_visited(node):
		visited_nodes[node] = true
		node_visited.emit(node)

func reveal_children(node: TreeNode) -> void:
	if node == null:
		return
	
	if node.izquierdo != null:
		discover_node(node.izquierdo)
	
	if node.derecho != null:
		discover_node(node.derecho)

func is_discovered(node: TreeNode) -> bool:
	return discovered_nodes.has(node)

func is_visited(node: TreeNode) -> bool:
	return visited_nodes.has(node)

func get_discovered_count() -> int:
	return discovered_nodes.size()

func get_visited_count() -> int:
	return visited_nodes.size()

func reset() -> void:
	discovered_nodes.clear()
	visited_nodes.clear()

func forced_discovery(node : TreeNode)->void:
	while node.padre:
		discover_node(node)
		node = node.padre

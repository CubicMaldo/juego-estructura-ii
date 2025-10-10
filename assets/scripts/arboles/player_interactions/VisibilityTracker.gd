class_name VisibilityTracker
extends Node

## Tracks which nodes have been discovered/visited
## Independent of both tree structure and player navigation

signal node_discovered(node: TreeNode)
signal node_visited(node: TreeNode)

var discovered_nodes: Dictionary = {}  # TreeNode -> bool
var visited_nodes: Dictionary = {}     # TreeNode -> bool

func discover_node(node: TreeNode) -> void:
	if node == null:
		return
	
	if not is_discovered(node):
		discovered_nodes[node] = true
		emit_signal("node_discovered", node)

func visit_node(node: TreeNode) -> void:
	if node == null:
		return
	
	discover_node(node)
	
	if not is_visited(node):
		visited_nodes[node] = true
		emit_signal("node_visited", node)

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

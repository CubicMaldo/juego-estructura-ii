class_name TreeNode

## Pure data structure - no game logic
## Only represents tree node relationships and type
enum NodosJuego { INICIO = 0, DESAFIO = 1, PISTA = 2, FINAL = 3}
var tipo: int
var padre: TreeNode
var izquierdo: TreeNode
var derecho: TreeNode

func _init(_tipo: int, _padre: TreeNode = null):
	self.tipo = _tipo
	self.padre = _padre

func get_children() -> Array[TreeNode]:
	var children: Array[TreeNode] = []
	if izquierdo != null:
		children.append(izquierdo)
	if derecho != null:
		children.append(derecho)
	return children

func is_leaf() -> bool:
	return izquierdo == null and derecho == null

func get_depth() -> int:
	var depth = 0
	var current = self
	while current.padre != null:
		depth += 1
		current = current.padre
	return depth

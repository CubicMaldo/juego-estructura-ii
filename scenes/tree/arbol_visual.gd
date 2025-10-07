extends Node2D  # o Control si lo metes dentro de UI

@export var nodo_escena: PackedScene
var tree: Arbol
var lineas: Array = []


func _clear_tree_visual():
	lineas.clear()
	if has_node("NodosContainer"):
		$NodosContainer.queue_free()
		var contenedor = Node2D.new()
		contenedor.name = "NodosContainer"
		add_child(contenedor)

func _dibujar_nodo(nodo: Nodo, x: float, y: float, offset_x: float):
	if nodo == null:
		return

	var nodo_visual = nodo_escena.instantiate()
	nodo_visual.position = Vector2(x, y)
	nodo_visual.set_tipo(nodo.tipo)
	add_child(nodo_visual)

	# Izquierdo
	if nodo.izquierdo != null:
		var x_izq = x - offset_x
		var y_izq = y + 100
		lineas.append([Vector2(x, y), Vector2(x_izq, y_izq)])
		_dibujar_nodo(nodo.izquierdo, x_izq, y_izq, offset_x * 0.6)

	# Derecho
	if nodo.derecho != null:
		var x_der = x + offset_x
		var y_der = y + 100
		lineas.append([Vector2(x, y), Vector2(x_der, y_der)])
		_dibujar_nodo(nodo.derecho, x_der, y_der, offset_x * 0.6)

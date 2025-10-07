extends Control

@export var nodo_escena: PackedScene
var tree: Arbol
var lineas: Array = []

func _ready():
	# Aseguramos que rect_size ya existe
	await get_tree().process_frame
	queue_redraw()


func mostrar_arbol(arbol: Arbol):
	tree = arbol

	if tree.raiz == null:
		return

	
	_dibujar_nodo(tree.raiz, 0, 0, 150)
	queue_redraw()


func _clear_tree_visual():
	lineas.clear()

	if has_node("NodosContainer"):
		$NodosContainer.queue_free()

	var nuevo_contenedor = Control.new()
	nuevo_contenedor.name = "NodosContainer"
	add_child(nuevo_contenedor)


func _dibujar_nodo(nodo: Nodo, x: float, y: float, offset_x: float):
	if nodo == null:
		return

	# Crear el nodo visual y colocarlo
	var nodo_visual = nodo_escena.instantiate()
	nodo_visual.position = Vector2(x, y)
	$NodosContainer.add_child(nodo_visual)
	nodo_visual.ready.connect(func(): nodo_visual.set_tipo(nodo.tipo))
	
	# Izquierdo
	if nodo.izquierdo != null:
		var x_izq = x - offset_x
		var y_izq = y + 30
		lineas.append([Vector2(x + 15, y + 15), Vector2(x_izq + 15, y_izq + 15)])
		_dibujar_nodo(nodo.izquierdo, x_izq, y_izq, offset_x * 0.6)

	# Derecho
	if nodo.derecho != null:
		var x_der = x + offset_x
		var y_der = y + 30
		lineas.append([Vector2(x + 15, y + 15), Vector2(x_der + 15, y_der + 15)])
		_dibujar_nodo(nodo.derecho, x_der, y_der, offset_x * 0.6)


func _draw():
	for linea in lineas:
		draw_line(linea[0], linea[1], Color.WHITE, 2)

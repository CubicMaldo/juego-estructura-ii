extends Control

@export var nodo_escena: PackedScene
@onready var _lineasNode : Control = $Lineas

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
	_dibujar_nodo(tree.raiz, 0, 0, 180)
	$Lineas.actualizar_lineas(lineas)


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
		lineas.append([Vector2(x, y), Vector2(x_izq, y_izq)])
		_dibujar_nodo(nodo.izquierdo, x_izq, y_izq, offset_x * 0.8)

	# Derecho
	if nodo.derecho != null:
		var x_der = x + offset_x
		var y_der = y + 30
		lineas.append([Vector2(x, y), Vector2(x_der, y_der)])
		_dibujar_nodo(nodo.derecho, x_der, y_der, offset_x * 0.8)


var drag_active := false
var last_mouse_pos := Vector2.ZERO
var camera_offset := Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Empieza el arrastre
				drag_active = true
				last_mouse_pos = event.position
			else:
				# Suelta el botón
				drag_active = false

	elif event is InputEventMouseMotion and drag_active:
		# Calcular el movimiento del ratón
		var delta = event.position - last_mouse_pos
		last_mouse_pos = event.position
		
		# Mueve el contenido del árbol (todo el panel de nodos)
		camera_offset += delta
		$NodosContainer.position += delta
		$Lineas.position += delta  # Asegúrate de mover las líneas también

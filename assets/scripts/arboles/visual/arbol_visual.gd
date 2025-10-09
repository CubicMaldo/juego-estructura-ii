extends Control

@export var nodo_escena: PackedScene

var tree: Arbol
var lineas: Array = []
const x_offset := 500
const y_offset := 120

func _ready():
	# Aseguramos que rect_size ya existe
	await get_tree().process_frame
	queue_redraw()
	


func mostrar_arbol(arbol: Arbol):
	tree = arbol

	if tree.raiz == null:
		return
	_dibujar_nodo(tree.raiz, 0, 0, x_offset,y_offset)
	$Lineas.actualizar_lineas(lineas)


func _clear_tree_visual():
	lineas.clear()

	if has_node("NodosContainer"):
		$NodosContainer.queue_free()

	var nuevo_contenedor = Control.new()
	nuevo_contenedor.name = "NodosContainer"
	add_child(nuevo_contenedor)


func _dibujar_nodo(nodo: Nodo, x: float, y: float, offset_x: float, offset_y : float):
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
		var y_izq = y + offset_y
		lineas.append([Vector2(x, y), Vector2(x_izq, y_izq)])
		_dibujar_nodo(nodo.izquierdo, x_izq, y_izq, offset_x * 0.8,offset_y)

	# Derecho
	if nodo.derecho != null:
		var x_der = x + offset_x
		var y_der = y + 120
		lineas.append([Vector2(x, y), Vector2(x_der, y_der)])
		_dibujar_nodo(nodo.derecho, x_der, y_der, offset_x * 0.8,offset_y)


var drag_active := false
var last_mouse_pos := Vector2.ZERO
var camera_offset := Vector2.ZERO
var zoom_factor := 1.0
const ZOOM_MIN := 0.4
const ZOOM_MAX := 3
const ZOOM_STEP := 0.1

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_active = true
				last_mouse_pos = event.position
			else:
				drag_active = false

		# --- ZOOM con la rueda del mouse ---
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(-1)

	elif event is InputEventMouseMotion and drag_active:
		var _delta = event.position - last_mouse_pos
		last_mouse_pos = event.position
		camera_offset += _delta
		$NodosContainer.position += _delta
		$Lineas.position += _delta


func _apply_zoom(direction: int):
	# direction: +1 = acercar, -1 = alejar
	var new_zoom = clamp(zoom_factor + direction * ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
	if new_zoom == zoom_factor:
		return

	var zoom_ratio = new_zoom / zoom_factor
	zoom_factor = new_zoom

	# Escalar ambos contenedores
	$NodosContainer.scale *= zoom_ratio
	$Lineas.scale *= zoom_ratio

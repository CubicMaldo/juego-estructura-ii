extends Control
class_name PanelDragger

## Script para mover un panel desde un nodo hijo
## Adjuntar este script al nodo que será el área de arrastre

@export_group("Target Settings")
@export var panel_path: NodePath = "../.."  # Ruta al panel a mover
@export var auto_detect_panel: bool = true  # Buscar automáticamente el Panel padre

@export_group("Drag Settings")
@export var enable_drag: bool = true
@export var drag_button: MouseButton = MOUSE_BUTTON_LEFT
@export var only_drag_on_this_control: bool = true  # Solo arrastra si el mouse está sobre este Control

var drag_active: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var panel: Panel = null

func _ready() -> void:
	# Intentar obtener el panel
	if auto_detect_panel:
		panel = _find_parent_panel()
	else:
		panel = get_node_or_null(panel_path)
	
	if panel == null:
		push_error("PanelDragger: No se pudo encontrar el Panel. Verifica el panel_path o activa auto_detect_panel")
		return
	
	# Asegurar que este Control capture eventos
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	#print("PanelDragger: Panel encontrado en: ", panel.get_path())

func _find_parent_panel() -> Panel:
	var current_node = get_parent()
	while current_node != null:
		if current_node is Panel:
			return current_node
		current_node = current_node.get_parent()
	return null

func _input(event: InputEvent) -> void:
	if not enable_drag or panel == null:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == drag_button:
			if event.pressed:
				# Solo iniciar drag si el mouse está sobre este control
				if only_drag_on_this_control and _is_mouse_over():
					_start_drag(event.position)
				elif not only_drag_on_this_control:
					_start_drag(event.position)
			else:
				_stop_drag()
	
	elif event is InputEventMouseMotion and drag_active:
		_update_drag(event.position)

func _start_drag(mouse_pos: Vector2) -> void:
	drag_active = true
	last_mouse_pos = mouse_pos

func _stop_drag() -> void:
	drag_active = false

func _update_drag(mouse_pos: Vector2) -> void:
	var delta: Vector2 = mouse_pos - last_mouse_pos
	last_mouse_pos = mouse_pos
	panel.position += delta

func _is_mouse_over() -> bool:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var rect: Rect2 = get_global_rect()
	return rect.has_point(mouse_pos)

## Debug: Mostrar información del panel
func get_panel_info() -> String:
	if panel:
		return "Panel: %s, Position: %s" % [panel.name, panel.position]
	return "Panel no encontrado"

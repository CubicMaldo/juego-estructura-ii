class_name Card
extends ButtonVisualEffects

signal put_back()
signal destroyed(card: Card)

@export var color: Color:
	set(value):
		color = value
		%Card.self_modulate = value
	get:
		return color

@export var threshold: float = 100.0
@export var threshold_speed: float = 200.0
@export var use_speed: bool = true
@export var lock_put_back: bool = false  # 👈 Evita que la carta vuelva atrás al soltarla

var picked_up: bool = false
var offset: Vector2 = Vector2.ZERO
var is_3D: bool = true
var is_active: bool = false
var last_speed: float = 0.0

var tween_grab: Tween
var tween_movement: Tween
var tween_destroy: Tween

@onready var original_position: Vector2 = global_position
@onready var viewport_material: ShaderMaterial = $SubViewportContainer.material
@onready var card_sprite = $SubViewportContainer/SubViewport/Card

# ============================================================
# LIFECYCLE
# ============================================================

func _ready() -> void:
	set_process(false)
	call_deferred("_update_pivot")  # Asegura que el tamaño esté listo antes de centrar el pivot

func _update_pivot() -> void:
	pivot_offset = size * 0.5

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	global_position = get_global_mouse_position() + offset

# ============================================================
# 3D ROTATION HANDLERS
# ============================================================

func set_3D_rotation_x(x: float) -> void:
	viewport_material.set_shader_parameter("x_rot", x)

func set_3D_rotation_y(y: float) -> void:
	viewport_material.set_shader_parameter("y_rot", y)

# ============================================================
# INPUT HANDLING
# ============================================================

func _on_button_down() -> void:
	if Engine.is_editor_hint():
		return
	
	offset = global_position - get_global_mouse_position()
	picked_up = true
	set_process(true)
	_kill_tween(tween_grab)
	
	tween_grab = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_grab.tween_property(self, "scale", Vector2.ONE * 1.1, 0.15)

func _on_button_up() -> void:
	if Engine.is_editor_hint():
		return
	
	picked_up = false
	set_process(false)
	_kill_tween(tween_movement)
	
	var dist: float = abs(original_position.y - global_position.y)
	var should_emit: bool = (use_speed and last_speed <= -threshold_speed) or (not use_speed and dist > threshold)
	
	# 👇 Si está bloqueada, no vuelve atrás ni emite señal
	if lock_put_back:
		_reset_scale()
		return
	
	if should_emit:
		put_back.emit()
	else:
		_reset_position()

func _on_gui_input(event: InputEvent) -> void:
	if picked_up and event is InputEventMouseMotion:
		last_speed = event.velocity.y

# ============================================================
# DESTRUCTION / DISSOLVE
# ============================================================

func destroy() -> void:
	$SubViewportContainer.use_parent_material = true
	lock_put_back = true
	_kill_tween(tween_destroy)

	tween_destroy = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_destroy.tween_property(material, "shader_parameter/dissolve_value", 0.0, 2.0).from(1.0)
	
	
	tween_destroy.finished.connect(func():
		destroyed.emit()
		queue_free()
	)

# ============================================================
# HELPERS
# ============================================================

func _kill_tween(tween: Tween) -> void:
	if tween and tween.is_running():
		if is_instance_valid(tween):
			tween.kill()

func _reset_position() -> void:
	_reset_scale()
	tween_movement = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_movement.tween_property(self, "global_position", original_position, 0.3)

func _reset_scale() -> void:
	_kill_tween(tween_grab)
	tween_grab = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_grab.tween_property(self, "scale", Vector2.ONE, 0.15)

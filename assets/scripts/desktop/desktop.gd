extends Control
@onready var app_desktop_container: GridContainer = $ColorRect/MarginContainer/AppContainer
@onready var taskbar_container: Container = %TaskBar
@export var app_panel_scene : PackedScene

func _ready():
	# Conectamos dinámicamente TODOS los iconos del contenedor
	for icon in app_desktop_container.get_children():
		if icon.has_signal("open_app"):
			icon.connect("open_app", Callable(self, "_on_icon_opened").bind(icon))

func _on_icon_opened(app_ref: PackedScene, appStats : AppStats, source_icon: Node):
	var app_id := _get_app_id(appStats, app_ref)
	var existing_panel := _find_open_app_panel(app_id)
	if existing_panel:
		print("App '%s' ya está abierta; no se abrirá otra instancia." % appStats.app_name)
		return

	var app_panel := app_panel_scene.instantiate()
	var app_inside := app_ref.instantiate()

	app_panel.set_meta("app_id", app_id)
	app_panel._setAppStat(appStats)
	app_panel.find_child("SubViewport").add_child(app_inside)
	self.add_child(app_panel)

	# Duplicar el icono en la barra de tareas para indicar que está abierto
	_ensure_taskbar_icon(app_id, source_icon)
	
	# 🔹 Animación de aparición (tween suave tipo pop-in)
	app_panel.scale = Vector2(0.8, 0.8)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(app_panel, "scale", Vector2(1, 1), 0.4)

func _get_app_id(appStats: AppStats, app_ref: PackedScene) -> String:
	if appStats and appStats.app_name != "":
		return appStats.app_name
	if app_ref:
		return app_ref.resource_path
	return "unknown_app"

func _find_open_app_panel(app_id: String) -> Node:
	for child in get_children():
		if child.has_meta("app_id") and child.get_meta("app_id") == app_id:
			return child
	return null

func _ensure_taskbar_icon(app_id: String, source_icon: Node) -> void:
	if not _is_taskbar_ready(source_icon):
		return

	_remove_existing_taskbar_icon(app_id)
	var task_icon: Node = _create_taskbar_icon(source_icon)
	if task_icon == null:
		return

	_prepare_taskbar_icon(task_icon, app_id)
	taskbar_container.add_child(task_icon)
	_configure_taskbar_icon_connections(task_icon)

func _find_taskbar_icon(app_id: String) -> Node:
	if taskbar_container == null:
		return null
	for child in taskbar_container.get_children():
		if child.has_meta("app_id") and child.get_meta("app_id") == app_id:
			return child
	return null

func _is_taskbar_ready(source_icon: Node) -> bool:
	return taskbar_container != null and source_icon != null

func _remove_existing_taskbar_icon(app_id: String) -> void:
	var existing_icon := _find_taskbar_icon(app_id)
	if existing_icon:
		existing_icon.queue_free()

func _create_taskbar_icon(source_icon: Node) -> Node:
	var instance := _instantiate_icon_copy(source_icon)
	if instance != null:
		return instance
	var duplicate_flags: int = Node.DUPLICATE_SIGNALS | Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS
	return source_icon.duplicate(duplicate_flags)

func _prepare_taskbar_icon(task_icon: Node, app_id: String) -> void:
	task_icon.name = "%s_TaskIcon" % app_id
	task_icon.set_meta("app_id", app_id)
	if task_icon is Control:
		_configure_taskbar_icon_layout(task_icon)
		_configure_taskbar_texture(task_icon)

func _configure_taskbar_icon_layout(task_icon: Control) -> void:
	task_icon.custom_minimum_size = Vector2(64, 64)
	task_icon.size = Vector2(64, 64)
	task_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	task_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	task_icon.pivot_offset = Vector2(32, 32)
	task_icon.set_anchors_preset(Control.PRESET_CENTER)
	task_icon.offset_left = -32.0
	task_icon.offset_top = -32.0
	task_icon.offset_right = 32.0
	task_icon.offset_bottom = 32.0

func _configure_taskbar_texture(task_icon: Node) -> void:
	var texture_rect := task_icon.find_child("AppTexture") as TextureRect
	if texture_rect == null:
		return
	texture_rect.expand = true
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.set_anchors_preset(Control.PRESET_CENTER)
	texture_rect.offset_left = -32.0
	texture_rect.offset_top = -32.0
	texture_rect.offset_right = 32.0
	texture_rect.offset_bottom = 32.0
	texture_rect.custom_minimum_size = Vector2(64, 64)
	texture_rect.pivot_offset = Vector2(32, 32)

func _instantiate_icon_copy(source_icon: Node) -> Node:
	if source_icon == null:
		return null
	if source_icon.scene_file_path == "":
		return null
	var icon_scene := load(source_icon.scene_file_path)
	if icon_scene is PackedScene:
		var instance := (icon_scene as PackedScene).instantiate()
		if instance is AppButton and source_icon is AppButton:
			instance.appStats = source_icon.appStats
			instance.position = Vector2.ZERO
		return instance
	return null

func _configure_taskbar_icon_connections(task_icon: Node) -> void:
	if task_icon == null:
		return
	if task_icon.has_signal("open_app") and not task_icon.is_connected("open_app", Callable(self, "_on_icon_opened")):
		task_icon.connect("open_app", Callable(self, "_on_icon_opened").bind(task_icon))

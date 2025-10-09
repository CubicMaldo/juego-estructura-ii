extends Control
@onready var app_desktop_container: GridContainer = $ColorRect/MarginContainer/AppContainer

@export var app_panel_scene : PackedScene

func _ready():
	# Conectamos dinámicamente TODOS los iconos del contenedor
	for icon in app_desktop_container.get_children():
		if icon.has_signal("open_app"):
			icon.connect("open_app", Callable(self, "_on_icon_opened"))

func _on_icon_opened(app_ref: PackedScene):
	
	var app_panel := app_panel_scene.instantiate()
	var app_inside := app_ref.instantiate()
	
	app_panel.find_child("SubViewport").add_child(app_inside)
	self.add_child(app_panel)
	

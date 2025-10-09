extends Control
@onready var app_container: GridContainer = $ColorRect/MarginContainer/AppContainer

func _ready():
	# Conectamos dinámicamente TODOS los iconos del contenedor
	for icon in app_container.get_children():
		if icon.has_signal("open_app"):
			
			icon.connect("open_app", Callable(self, "_on_icon_opened"))
			
			var connections = icon.get_signal_connection_list("open_app")
			print("🔗 Conexiones de", icon.name, ":", connections)

func _on_icon_opened(app_ref: PackedScene):
	print("connected")

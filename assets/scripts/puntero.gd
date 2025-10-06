extends Button

@export_enum("Izquierda", "Derecha") var direccion: String = "Izquierda"

func _ready() -> void:
	Global.connect("puntero_actualizado", Callable(self, "_on_nodo_actualizado"))

func _on_pressed() -> void:
	Global.cambiarPuntero(direccion)

func _on_nodo_actualizado(nodo : Nodo) -> void:
	# Verifica si el nodo actual tiene hijo hacia la dirección del botón
	var existe_hijo := false

	match direccion:
		"Izquierda":
			existe_hijo = nodo.izquierdo != null
		"Derecha":
			existe_hijo = nodo.derecho != null

	# Desactiva el botón si no hay nodo hijo en esa dirección
	disabled = not existe_hijo

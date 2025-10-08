extends Button

@export_enum("Izquierda", "Centrol", "Derecha") var direccion: String = "Izquierda"

func _ready() -> void:
	Global.connect("puntero_actualizado", Callable(self, "_on_nodo_actualizado"))

func _on_pressed() -> void:
	Global.cambiarPuntero(direccion)

func _on_nodo_actualizado(nodo: Nodo) -> void:
	var tiene_izquierdo := nodo.izquierdo != null
	var tiene_derecho := nodo.derecho != null

	# Si este script está en un botón lateral, identificamos cuál es
	if direccion == "Izquierda":
		if not tiene_izquierdo:
			visible = false
			disabled = true
		else:
			visible = true
			disabled = false

	elif direccion == "Derecha":
		if not tiene_derecho:
			visible = false
			disabled = true
		else:
			visible = true
			disabled = false

	elif direccion == "Centro":
		# 🔹 El botón del medio nunca se oculta
		visible = true
		# Solo se desactiva si no hay padre (estás en la raíz)
		if nodo.padre == null:
			disabled = true
		else:
			disabled = false

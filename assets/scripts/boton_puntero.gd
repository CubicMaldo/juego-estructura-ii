extends Button

@export_enum("Izquierda", "Derecha") var direccion: String = "Izquierda"

func _ready() -> void:
	Global.connect("puntero_actualizado", Callable(self, "_on_nodo_actualizado"))

func _on_pressed() -> void:
	Global.cambiarPuntero(direccion)

func _on_nodo_actualizado(nodo : Nodo) -> void:
	# Verificar existencia de hijos
	var tiene_izquierdo := nodo.izquierdo != null
	var tiene_derecho := nodo.derecho != null

	# Caso 1: Ambos hijos existen → botones activos según dirección
	if tiene_izquierdo and tiene_derecho:
		visible = true
		disabled = false
		return

	# Caso 2: No hay ningún hijo → desactiva ambos
	if not tiene_izquierdo and not tiene_derecho:
		visible = false
		return

	# Caso 3: Solo uno de los dos existe → pasar automáticamente
	if tiene_izquierdo != tiene_derecho:
		# Ocultar ambos botones
		visible = false
		
		# Hacer que solo uno ejecute el paso automático
		if direccion == "Izquierda" and tiene_izquierdo:
			_paso_automatico("Izquierda")
		elif direccion == "Derecha" and tiene_derecho:
			_paso_automatico("Derecha")
		return

	# Si no entra en ningún caso anterior, desactivar por seguridad
	disabled = true


func _paso_automatico(dir : String) -> void:
	print("⚙️ Solo había un camino ('%s'), avanzando automáticamente..." % dir)
	Global.cambiarPuntero(dir)

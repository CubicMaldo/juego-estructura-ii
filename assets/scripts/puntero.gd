extends Button

@export_enum("Izquierda", "Derecha") var direccion: String = "Izquierda"
var arbol = Global.tree


func _on_pressed() -> void:
	if direccion == "Derecha" and Global.nodo_actual.derecho != null:
		Global.nodo_actual = Global.nodo_actual.derecho
	elif Global.nodo_actual.izquierdo != null:
		Global.nodo_actual = Global.nodo_actual.izquierdo
	Global.nodo_actual.dato -= 1
	
	Global.tree.imprimir_arbol()

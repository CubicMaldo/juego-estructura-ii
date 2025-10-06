extends Node

signal puntero_actualizado(nodo_actual : Nodo)

var tree : Arbol
var nodo_actual : Nodo
var puntaje : int

func cambiarPuntero(direccion: String):
	if direccion == "Derecha" and nodo_actual.derecho != null:
		nodo_actual = nodo_actual.derecho
	elif direccion == "Izquierda" and nodo_actual.izquierdo != null:
		nodo_actual = nodo_actual.izquierdo
	else:
		print("❌ No hay nodo en esa dirección")
		return
	
	nodo_actual.hijosVistos()

	tree.imprimir_arbol_vistos()
	emit_signal("puntero_actualizado", nodo_actual)

extends Node

signal puntero_actualizado(nodo_actual : Nodo)

var tree : Arbol
var nodo_actual : Nodo
var puntaje : int

func cambiarPuntero(direccion: String):
	match direccion:
		"Derecha":
			if nodo_actual.derecho != null:
				nodo_actual = nodo_actual.derecho
			else:
				print("❌ No hay nodo derecho.")
				return

		"Izquierda":
			if nodo_actual.izquierdo != null:
				nodo_actual = nodo_actual.izquierdo
			else:
				print("❌ No hay nodo izquierdo.")
				return

		"Centro":
			if nodo_actual.padre != null:
				nodo_actual = nodo_actual.padre
				print("⬆️  Volviste al nodo padre:", nodo_actual.tipo)
			else:
				print("❌ No hay nodo padre (ya estás en la raíz).")
				return

		_:
			print("⚠️ Dirección inválida:", direccion)
			return
			
	if direccion != "Centro":
		nodo_actual.hijosVistos()

	tree.imprimir_arbol_vistos()
	emit_signal("puntero_actualizado", nodo_actual)

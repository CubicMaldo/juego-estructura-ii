extends Node

func _ready():
	Global.tree = Arbol.new()
	Global.tree.generar_arbol_controlado()
	Global.tree.imprimir_arbol()
	Global.nodo_actual = Global.tree.raiz

extends Node

var tree : Arbol

func _ready():
	tree = Arbol.new()
	
	tree.generar_arbol_controlado()
	tree.imprimir_arbol()

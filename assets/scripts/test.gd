extends Node

var tree : Arbol

func _ready():
	tree = Arbol.new()
	
	tree.generar_arbol_aleatorio(10)
	
	tree.imprimir_arbol()
	tree.obtener_estadisticas()

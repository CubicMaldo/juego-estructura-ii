extends Control

@onready var MapSubviewport = %SubViewport
@onready var boton_izq = $"../Button"
@onready var boton_der = $"../Button2"
@onready var boton_ctr = $"../Button3"

var arbol_visual: Control
var arbol: Arbol

func _ready():
	arbol = Arbol.new()
	Global.tree = arbol
	Global.tree.generar_arbol_controlado(-1981898002738864403)
	Global.tree.imprimir_arbol()
	Global.tree.imprimir_arbol_vistos()
	Global.nodo_actual = Global.tree.raiz
	#Global.tree.imprimir_arbol()
	
	# Instanciamos el árbol visual
	arbol_visual = preload("res://scenes/tree/ArbolVisual.tscn").instantiate()
	arbol_visual.nodo_escena = preload("res://scenes/tree/NodoVisual.tscn")
	arbol_visual.mostrar_arbol(arbol)
	
	# Añadir al contenedor visual
	MapSubviewport.add_child(arbol_visual)
	#
	## Conectar botones
	#boton_izq.pressed.connect(func(): Global.cambiarPuntero("Izquierda"))
	#boton_der.pressed.connect(func(): Global.cambiarPuntero("Derecha"))
	#boton_ctr.pressed.connect(func(): Global.cambiarPuntero("Centro"))

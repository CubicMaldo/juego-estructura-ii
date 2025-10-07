extends Control

@onready var arbol_visual_contenedor = $Control/Panel/MarginContainer
@onready var boton_izq = $Button
@onready var boton_der = $Button2
@onready var boton_ctr = $Button3

var arbol_visual: Node2D
var arbol: Arbol

func _ready():
	arbol = Arbol.new()
	arbol.generar_arbol_controlado()
	
	# Instanciamos el árbol visual
	arbol_visual = preload("res://scenes/tree/ArbolVisual.tscn").instantiate()
	arbol_visual.nodo_escena = preload("res://scenes/tree/NodoVisual.tscn")
	arbol_visual.mostrar_arbol(arbol)
	
	# Añadir al contenedor visual
	arbol_visual_contenedor.add_child(arbol_visual)
	
	# Conectar botones
	boton_izq.pressed.connect(func(): Global.cambiarPuntero("Izquierda"))
	boton_der.pressed.connect(func(): Global.cambiarPuntero("Derecha"))
	boton_ctr.pressed.connect(func(): Global.cambiarPuntero("Centro"))

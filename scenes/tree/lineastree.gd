extends Control

var lineas: Array = []

func _draw():
	for linea in lineas:
		draw_line(linea[0], linea[1], Color.WHITE, 2)

func actualizar_lineas(nuevas_lineas: Array):
	lineas = nuevas_lineas
	queue_redraw()

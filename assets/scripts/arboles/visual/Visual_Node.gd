class_name NodoVisual
extends  Control
# Puedes usar Control si prefieres, pero Button te da interacción directa

enum NodosJuego { INICIO = 0, DESAFIO = 1, PISTA = 2, FINAL = 3}
var nodo: TreeNode  # Referencia al nodo lógico
@onready var label : Label = $Label  # Si tienes un Label hijo opcional

func _ready():
	# Opcional: tamaño estándar y estilo base
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	custom_minimum_size = Vector2(80, 40)

# 🔹 Configura el aspecto según el tipo del nodo
func set_tipo(tipo: int):
	if label == null:
		print("label no inicializado")
		return
	
	match tipo:
		NodosJuego.INICIO:
			label.set_text("Inicio")
			modulate = Color(0.2, 1.0, 0.2)  # Verde
		NodosJuego.DESAFIO:
			label.set_text("TreeNode")
			modulate = Color(0.8, 0.8, 0.8)
		NodosJuego.PISTA:
			label.set_text("Pista")
			modulate = Color(0.2, 0.6, 1.0)  # Azul
		NodosJuego.FINAL:
			label.set_text("Meta")
			modulate = Color(1.0, 0.8, 0.2)
			


# 🔹 Si el nodo está marcado como visto, cámbiale el estilo
func actualizar_estado_visto():
	if nodo != null and nodo.visto:
		modulate = Color(1.0, 1.0, 1.0)  # Blanco encendido
	else:
		modulate = Color(0.4, 0.4, 0.4)  # Atenuado


# 🔹 Detecta clics en el nodo (opcional)
func _pressed():
	if nodo != null:
		print("🟢 TreeNode presionado:", nodo.tipo)
		# Aquí podrías emitir una señal global para saltar a ese nodo

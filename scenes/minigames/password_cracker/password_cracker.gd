extends Control

## Minijuego de ciberseguridad: Password Cracker
## El jugador debe descifrar una contraseña usando pistas

const PASSWORD_CORRECTA = "SecurePass123"
const PISTAS = [
	"Empieza con 'S' mayúscula",
	"Contiene la palabra 'Pass'",
	"Termina con números del 1 al 3",
	"Tiene 13 caracteres en total",
	"Incluye la palabra 'Secure'"
]

@onready var input_password = $Panel/VBoxContainer/InputContainer/LineEdit
@onready var label_resultado = $Panel/VBoxContainer/ResultadoLabel
@onready var pistas_container = $Panel/VBoxContainer/PistasContainer
@onready var intentos_label = $Panel/VBoxContainer/HBoxContainer/IntentosLabel
@onready var timer_resultado = $Timer
@onready var btn_pista = $Panel/VBoxContainer/HBoxContainer/BtnPista
@onready var btn_enviar = $Panel/VBoxContainer/InputContainer/BtnEnviar

var intentos_restantes: int = 5
var pistas_reveladas: int = 0
var game_over: bool = false

func _ready():
	label_resultado.text = ""
	_actualizar_intentos()
	_inicializar_pistas()
	
func _inicializar_pistas():
	# Crear labels para cada pista (ocultas inicialmente)
	for i in range(PISTAS.size()):
		var pista_label = Label.new()
		pista_label.text = "🔒 Pista bloqueada"
		pista_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		pista_label.name = "Pista" + str(i)
		pistas_container.add_child(pista_label)

func _actualizar_intentos():
	intentos_label.text = "Intentos: " + str(intentos_restantes) + "/5"
	if intentos_restantes <= 2:
		intentos_label.add_theme_color_override("font_color", Color(1, 0, 0))
	elif intentos_restantes <= 3:
		intentos_label.add_theme_color_override("font_color", Color(1, 0.5, 0))
	else:
		intentos_label.add_theme_color_override("font_color", Color(1, 1, 1))

func _on_btn_enviar_pressed() -> void:
	if game_over:
		return
		
	var password_intento = input_password.text.strip_edges()
	
	if password_intento.is_empty():
		_mostrar_mensaje("❌ Debes escribir una contraseña", Color(1, 0.5, 0))
		return
	
	if password_intento == PASSWORD_CORRECTA:
		_password_correcta()
	else:
		_password_incorrecta()

func _password_correcta():
	game_over = true
	label_resultado.text = "✅ ¡ACCESO CONCEDIDO! 🎉"
	label_resultado.add_theme_color_override("font_color", Color(0, 1, 0))
	btn_enviar.disabled = true
	btn_pista.disabled = true
	input_password.editable = false
	
	# Animación de éxito
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(label_resultado, "scale", Vector2(1.2, 1.2), 0.5)

func _password_incorrecta():
	intentos_restantes -= 1
	_actualizar_intentos()
	
	if intentos_restantes <= 0:
		_game_over()
	else:
		_mostrar_mensaje("❌ Contraseña incorrecta. Intentos restantes: " + str(intentos_restantes), Color(1, 0, 0))
		
		# Efecto de sacudida en el input
		var tween = create_tween()
		var original_pos = input_password.position
		tween.tween_property(input_password, "position:x", original_pos.x + 10, 0.05)
		tween.tween_property(input_password, "position:x", original_pos.x - 10, 0.05)
		tween.tween_property(input_password, "position:x", original_pos.x + 5, 0.05)
		tween.tween_property(input_password, "position:x", original_pos.x, 0.05)

func _game_over():
	game_over = true
	label_resultado.text = "🔒 BLOQUEADO - Sin intentos\nLa contraseña era: " + PASSWORD_CORRECTA
	label_resultado.add_theme_color_override("font_color", Color(1, 0, 0))
	btn_enviar.disabled = true
	btn_pista.disabled = true
	input_password.editable = false

func _mostrar_mensaje(mensaje: String, color: Color):
	label_resultado.text = mensaje
	label_resultado.add_theme_color_override("font_color", color)
	timer_resultado.start()

func _on_btn_pista_pressed() -> void:
	if game_over or pistas_reveladas >= PISTAS.size():
		return
	
	# Revelar la siguiente pista
	var pista_label = pistas_container.get_child(pistas_reveladas)
	pista_label.text = "💡 " + PISTAS[pistas_reveladas]
	pista_label.add_theme_color_override("font_color", Color(0.2, 0.8, 1))
	
	# Animación de revelación
	var tween = create_tween()
	pista_label.modulate.a = 0
	tween.tween_property(pista_label, "modulate:a", 1.0, 0.5)
	
	pistas_reveladas += 1
	
	# Penalización: reducir un intento por usar pista
	if intentos_restantes > 1:
		intentos_restantes -= 1
		_actualizar_intentos()
		_mostrar_mensaje("⚠️ Pista revelada (-1 intento)", Color(1, 0.8, 0))
	
	if pistas_reveladas >= PISTAS.size():
		btn_pista.disabled = true
		btn_pista.text = "Sin pistas"

func _on_timer_timeout() -> void:
	if not game_over:
		label_resultado.text = ""
		label_resultado.remove_theme_color_override("font_color")

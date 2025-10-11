extends Control

## Minijuego de ciberseguridad: Password Cracker - Versión Mejorada
## El jugador debe descifrar contraseñas de diferentes niveles usando pistas y análisis

# Sistema de niveles con diferentes contraseñas
const NIVELES = [
	{
		"password": "SecurePass123",
		"dificultad": "Fácil",
		"pistas": [
			"Empieza con 'S' mayúscula y tiene 13 caracteres",
			"Contiene 'Pass' y termina con números del 1 al 3"
		]
	},
	{
		"password": "Cyb3r$ecurity",
		"dificultad": "Media",
		"pistas": [
			"Seguridad informática con símbolo '$'",
			"La 'e' está reemplazada por '3' (leetspeak)"
		]
	},
	{
		"password": "H@ck3rM1nd!2024",
		"dificultad": "Difícil",
		"pistas": [
			"'Hacker Mind' con símbolos @ y !",
			"Termina con 2024 y usa sustituciones"
		]
	}
]

@onready var input_password = $Panel/VBoxContainer/InputContainer/LineEdit
@onready var label_resultado = $Panel/VBoxContainer/ResultadoLabel
@onready var pistas_container = $Panel/VBoxContainer/PistasContainer
@onready var intentos_label = $Panel/VBoxContainer/HBoxContainer/IntentosLabel
@onready var nivel_label = $Panel/VBoxContainer/TopBar/NivelLabel
@onready var puntos_label = $Panel/VBoxContainer/TopBar/PuntosLabel
@onready var tiempo_label = $Panel/VBoxContainer/TopBar/TiempoLabel
@onready var similitud_label = $Panel/VBoxContainer/SimilitudContainer/SimilitudLabel
@onready var progreso_bar = $Panel/VBoxContainer/SimilitudContainer/ProgresoBar
@onready var timer_resultado = $Timer
@onready var timer_juego = $TimerJuego
@onready var timer_parpadeo = $TimerParpadeo
@onready var btn_pista = $Panel/VBoxContainer/HBoxContainer/BtnPista
@onready var btn_enviar = $Panel/VBoxContainer/InputContainer/BtnEnviar
@onready var btn_analizar = $Panel/VBoxContainer/InputContainer/BtnAnalizar
@onready var btn_reiniciar = $Panel/VBoxContainer/HBoxContainer/BtnReiniciar
@onready var audio_correct = $AudioCorrect
@onready var audio_wrong = $AudioWrong
@onready var audio_hint = $AudioHint

var nivel_actual: int = 0
var intentos_restantes: int = 6
var intentos_maximos: int = 6
var pistas_reveladas: int = 0
var game_over: bool = false
var puntos: int = 0
var tiempo_transcurrido: float = 0.0
var analisis_disponibles: int = 2
var password_actual: String = ""
var pistas_actuales: Array = []
var combo_racha: int = 0
var mejor_puntuacion: int = 0
var intentos_totales: int = 0
var analisis_usados: int = 0

func _ready():
	label_resultado.text = ""
	_cargar_nivel(nivel_actual)
	_actualizar_intentos()
	_actualizar_estadisticas()
	_inicializar_pistas()
	timer_juego.start()
	btn_reiniciar.visible = false
	_mostrar_bienvenida()
	
	# Conectar Enter key para enviar
	input_password.text_submitted.connect(_on_enter_pressed)

func _mostrar_bienvenida():
	label_resultado.text = "🎯 ¡Descifra las contraseñas!"
	label_resultado.add_theme_color_override("font_color", Color(0.2, 0.8, 1))
	await get_tree().create_timer(2.0).timeout
	if not game_over:
		label_resultado.text = ""

func _on_enter_pressed(_text: String):
	if not game_over and btn_enviar.disabled == false:
		_on_btn_enviar_pressed()

func _process(delta):
	if not game_over and timer_juego.time_left > 0:
		tiempo_transcurrido += delta
		_actualizar_tiempo()

func _cargar_nivel(indice: int):
	if indice >= NIVELES.size():
		_victoria_total()
		return
	
	var nivel = NIVELES[indice]
	password_actual = nivel["password"]
	pistas_actuales = nivel["pistas"]
	nivel_label.text = "Nivel " + str(indice + 1) + " - " + nivel["dificultad"]
	
	# Reiniciar valores
	intentos_restantes = intentos_maximos
	pistas_reveladas = 0
	analisis_disponibles = 2
	game_over = false
	input_password.text = ""
	input_password.editable = true
	btn_enviar.disabled = false
	btn_pista.disabled = false
	btn_analizar.disabled = false
	btn_analizar.text = "🔍 Analizar (" + str(analisis_disponibles) + ")"
	
	# Limpiar pistas anteriores
	for child in pistas_container.get_children():
		child.queue_free()
	
	# Esperar un frame para que se eliminen los nodos
	await get_tree().process_frame
	_inicializar_pistas()
	
func _inicializar_pistas():
	# Crear labels para cada pista (ocultas inicialmente)
	for i in range(pistas_actuales.size()):
		var pista_label = Label.new()
		pista_label.text = "🔒 Pista bloqueada"
		pista_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		pista_label.add_theme_font_size_override("font_size", 16)
		pista_label.name = "Pista" + str(i)
		pistas_container.add_child(pista_label)

func _actualizar_intentos():
	intentos_label.text = "❤️ Vidas: " + str(intentos_restantes) + "/" + str(intentos_maximos)
	if intentos_restantes <= 2:
		intentos_label.add_theme_color_override("font_color", Color(1, 0, 0))
	elif intentos_restantes <= 3:
		intentos_label.add_theme_color_override("font_color", Color(1, 0.5, 0))
	else:
		intentos_label.add_theme_color_override("font_color", Color(1, 1, 1))

func _actualizar_estadisticas():
	puntos_label.text = "⭐ Puntos: " + str(puntos)
	
func _actualizar_tiempo():
	var minutos = int(tiempo_transcurrido / 60)
	var segundos = int(tiempo_transcurrido) % 60
	tiempo_label.text = "⏱️ %02d:%02d" % [minutos, segundos]

func _on_btn_enviar_pressed() -> void:
	if game_over:
		return
		
	var password_intento = input_password.text.strip_edges()
	
	if password_intento.is_empty():
		_mostrar_mensaje("❌ Debes escribir una contraseña", Color(1, 0.5, 0))
		return
	
	intentos_totales += 1
	
	if password_intento == password_actual:
		_password_correcta()
	else:
		_password_incorrecta()
		
	# Limpiar input después de intentar
	input_password.text = ""

func _on_btn_analizar_pressed() -> void:
	if game_over or analisis_disponibles <= 0:
		return
		
	var password_intento = input_password.text.strip_edges()
	
	if password_intento.is_empty():
		_mostrar_mensaje("❌ Escribe algo para analizar", Color(1, 0.5, 0))
		return
	
	analisis_disponibles -= 1
	analisis_usados += 1
	btn_analizar.text = "🔍 Analizar (" + str(analisis_disponibles) + ")"
	
	if analisis_disponibles <= 0:
		btn_analizar.disabled = true
	
	var similitud = _calcular_similitud(password_intento, password_actual)
	var caracteres_correctos = _contar_caracteres_correctos(password_intento, password_actual)
	_mostrar_similitud(similitud, caracteres_correctos)
	
	# Bonus de puntos por usar análisis inteligentemente
	if similitud > 50:
		puntos += 10
		_actualizar_estadisticas()
		_mostrar_efecto_puntos("+10", Color(0, 1, 0.5))

func _calcular_similitud(intento: String, correcta: String) -> float:
	var coincidencias: int = 0
	var longitud_min = min(intento.length(), correcta.length())
	
	# Contar caracteres correctos en posición correcta
	for i in range(longitud_min):
		if intento[i] == correcta[i]:
			coincidencias += 1
	
	# Calcular porcentaje
	var porcentaje = (float(coincidencias) / float(correcta.length())) * 100.0
	return porcentaje

func _contar_caracteres_correctos(intento: String, correcta: String) -> int:
	var coincidencias: int = 0
	var longitud_min = min(intento.length(), correcta.length())
	
	for i in range(longitud_min):
		if intento[i] == correcta[i]:
			coincidencias += 1
	
	return coincidencias

func _mostrar_similitud(porcentaje: float, caracteres_correctos: int = 0):
	similitud_label.text = "Similitud: %.1f%% (%d caracteres correctos)" % [porcentaje, caracteres_correctos]
	progreso_bar.value = porcentaje
	
	# Color según el porcentaje
	if porcentaje >= 75:
		similitud_label.add_theme_color_override("font_color", Color(0, 1, 0))
	elif porcentaje >= 50:
		similitud_label.add_theme_color_override("font_color", Color(1, 0.8, 0))
	elif porcentaje >= 25:
		similitud_label.add_theme_color_override("font_color", Color(1, 0.5, 0))
	else:
		similitud_label.add_theme_color_override("font_color", Color(1, 0, 0))
	
	# Animación del progreso
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var original_scale = progreso_bar.scale
	tween.tween_property(progreso_bar, "scale", Vector2(1.05, 1.1), 0.2)
	tween.tween_property(progreso_bar, "scale", original_scale, 0.2)

func _password_correcta():
	# Incrementar combo
	combo_racha += 1
	
	# Calcular puntos por el nivel
	var bonus_intentos = intentos_restantes * 50
	var bonus_tiempo = max(0, 300 - int(tiempo_transcurrido)) * 2
	var bonus_pistas = (pistas_actuales.size() - pistas_reveladas) * 30
	var bonus_combo = combo_racha * 20
	var puntos_nivel = 500 + bonus_intentos + bonus_tiempo + bonus_pistas + bonus_combo
	
	puntos += puntos_nivel
	_actualizar_estadisticas()
	
	var mensaje_combo = ""
	if combo_racha > 1:
		mensaje_combo = "\n🔥 COMBO x%d! (+%d)" % [combo_racha, bonus_combo]
	
	label_resultado.text = "✅ ¡ACCESO CONCEDIDO! 🎉\n+%d puntos%s" % [puntos_nivel, mensaje_combo]
	label_resultado.add_theme_color_override("font_color", Color(0, 1, 0))
	
	# Efecto de partículas/estrellas
	_crear_efecto_victoria()
	
	# Animación de éxito
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(label_resultado, "scale", Vector2(1.2, 1.2), 0.5)
	
	# Pasar al siguiente nivel después de 2.5 segundos
	await get_tree().create_timer(2.5).timeout
	nivel_actual += 1
	_cargar_nivel(nivel_actual)

func _crear_efecto_victoria():
	# Efecto visual de victoria
	for i in range(3):
		var tween = create_tween()
		tween.tween_property($Panel, "modulate", Color(1, 1.2, 1), 0.15)
		tween.tween_property($Panel, "modulate", Color(1, 1, 1), 0.15)
		await tween.finished

func _mostrar_efecto_puntos(texto: String, color: Color):
	var label_temp = Label.new()
	label_temp.text = texto
	label_temp.add_theme_font_size_override("font_size", 24)
	label_temp.add_theme_color_override("font_color", color)
	label_temp.position = puntos_label.position + Vector2(80, -20)
	add_child(label_temp)
	
	var tween = create_tween()
	tween.tween_property(label_temp, "position:y", label_temp.position.y - 40, 1.0)
	tween.parallel().tween_property(label_temp, "modulate:a", 0.0, 1.0)
	await tween.finished
	label_temp.queue_free()

func _password_incorrecta():
	combo_racha = 0  # Resetear combo al fallar
	intentos_restantes -= 1
	_actualizar_intentos()
	
	if intentos_restantes <= 0:
		_game_over()
	else:
		var mensaje_extra = ""
		if intentos_restantes <= 2:
			mensaje_extra = " ⚠️ ¡Cuidado!"
		_mostrar_mensaje("❌ Contraseña incorrecta. Vidas: " + str(intentos_restantes) + mensaje_extra, Color(1, 0, 0))
		
		# Efecto de sacudida en el input
		var tween = create_tween()
		var original_pos = input_password.position
		tween.tween_property(input_password, "position:x", original_pos.x + 10, 0.05)
		tween.tween_property(input_password, "position:x", original_pos.x - 10, 0.05)
		tween.tween_property(input_password, "position:x", original_pos.x + 5, 0.05)
		tween.tween_property(input_password, "position:x", original_pos.x, 0.05)
		
		# Efecto de parpadeo rojo en el panel
		_efecto_error_panel()

func _game_over():
	game_over = true
	timer_juego.stop()
	
	var estadisticas = "\n\n📊 Estadísticas:\n"
	estadisticas += "Intentos totales: %d\n" % intentos_totales
	estadisticas += "Análisis usados: %d\n" % analisis_usados
	estadisticas += "Pistas usadas: %d" % pistas_reveladas
	
	label_resultado.text = "🔒 BLOQUEADO - Sin vidas\nLa contraseña era: " + password_actual + estadisticas
	label_resultado.add_theme_color_override("font_color", Color(1, 0, 0))
	btn_enviar.disabled = true
	btn_pista.disabled = true
	btn_analizar.disabled = true
	input_password.editable = false
	btn_reiniciar.visible = true
	
	# Efecto de pantalla roja
	var tween = create_tween()
	tween.tween_property($Panel, "modulate", Color(1, 0.5, 0.5), 0.3)
	tween.tween_property($Panel, "modulate", Color(1, 1, 1), 0.3)

func _efecto_error_panel():
	var tween = create_tween()
	tween.tween_property($Panel, "modulate", Color(1, 0.7, 0.7), 0.1)
	tween.tween_property($Panel, "modulate", Color(1, 1, 1), 0.1)

func _victoria_total():
	game_over = true
	timer_juego.stop()
	
	if puntos > mejor_puntuacion:
		mejor_puntuacion = puntos
	
	var calificacion = ""
	if puntos >= 2500:
		calificacion = "🏆 PERFECTO"
	elif puntos >= 2000:
		calificacion = "🥇 EXCELENTE"
	elif puntos >= 1500:
		calificacion = "🥈 MUY BIEN"
	else:
		calificacion = "🥉 COMPLETADO"
	
	var estadisticas = "\n\n📊 Estadísticas Finales:\n"
	estadisticas += "Intentos totales: %d\n" % intentos_totales
	estadisticas += "Análisis usados: %d\n" % analisis_usados
	estadisticas += "Precisión: %.1f%%\n" % ((3.0 / intentos_totales) * 100.0)
	estadisticas += "Calificación: %s" % calificacion
	
	label_resultado.text = "🏆 ¡TODOS LOS NIVELES COMPLETADOS! 🏆\nPuntuación Final: %d\nTiempo: %02d:%02d%s" % [puntos, int(tiempo_transcurrido / 60), int(tiempo_transcurrido) % 60, estadisticas]
	label_resultado.add_theme_color_override("font_color", Color(1, 0.84, 0))
	btn_enviar.disabled = true
	btn_pista.disabled = true
	btn_analizar.disabled = true
	input_password.editable = false
	btn_reiniciar.visible = true
	
	# Animación de victoria
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(label_resultado, "modulate", Color(1, 1, 0), 0.3)
	tween.tween_property(label_resultado, "modulate", Color(1, 1, 1), 0.3)

func _mostrar_mensaje(mensaje: String, color: Color):
	label_resultado.text = mensaje
	label_resultado.add_theme_color_override("font_color", color)
	timer_resultado.start()

func _on_btn_pista_pressed() -> void:
	if game_over or pistas_reveladas >= pistas_actuales.size():
		return
	
	# Revelar la siguiente pista
	var pista_label = pistas_container.get_child(pistas_reveladas)
	pista_label.text = "💡 " + pistas_actuales[pistas_reveladas]
	pista_label.add_theme_color_override("font_color", Color(0.2, 0.8, 1))
	
	# Animación de revelación
	var tween = create_tween()
	pista_label.modulate.a = 0
	tween.tween_property(pista_label, "modulate:a", 1.0, 0.5)
	
	pistas_reveladas += 1
	
	# Penalización: reducir puntos por usar pista
	puntos = max(0, puntos - 25)
	_actualizar_estadisticas()
	_mostrar_mensaje("⚠️ Pista revelada (-25 puntos)", Color(1, 0.8, 0))
	
	if pistas_reveladas >= pistas_actuales.size():
		btn_pista.disabled = true
		btn_pista.text = "Sin pistas"

func _on_btn_reiniciar_pressed() -> void:
	# Reiniciar todo el juego
	nivel_actual = 0
	puntos = 0
	tiempo_transcurrido = 0.0
	game_over = false
	combo_racha = 0
	intentos_totales = 0
	analisis_usados = 0
	btn_reiniciar.visible = false
	$Panel.modulate = Color(1, 1, 1)
	label_resultado.scale = Vector2(1, 1)
	_cargar_nivel(nivel_actual)
	_actualizar_estadisticas()
	timer_juego.start()
	_mostrar_bienvenida()

func _on_timer_timeout() -> void:
	if not game_over:
		label_resultado.text = ""
		label_resultado.remove_theme_color_override("font_color")

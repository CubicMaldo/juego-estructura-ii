extends Control

## Minijuego de ciberseguridad: Network Defender
## El jugador debe identificar y bloquear conexiones de red sospechosas

@export var level_database: NetworkLevelDatabase
var connections: Array[ConnectionResource] = []

@onready var connection_info_label = $Panel/VBoxContainer/ConnectionInfoContainer/ConnectionInfoLabel
@onready var hint_label = $Panel/VBoxContainer/HintContainer/HintLabel
@onready var resultado_label = $Panel/VBoxContainer/ResultadoLabel
@onready var vidas_label = $Panel/VBoxContainer/TopBar/VidasLabel
@onready var puntos_label = $Panel/VBoxContainer/TopBar/PuntosLabel
@onready var nivel_label = $Panel/VBoxContainer/TopBar/NivelLabel
@onready var tiempo_label = $Panel/VBoxContainer/TopBar/TiempoLabel
@onready var btn_permitir = $Panel/VBoxContainer/ButtonsContainer/BtnPermitir
@onready var btn_bloquear = $Panel/VBoxContainer/ButtonsContainer/BtnBloquear
@onready var btn_pista = $Panel/VBoxContainer/ButtonsContainer/BtnPista
@onready var btn_siguiente = $Panel/VBoxContainer/ButtonsContainer/BtnSiguiente
@onready var progress_bar = $Panel/VBoxContainer/ProgressContainer/ProgressBar
@onready var timer_juego = $TimerJuego
@onready var timer_resultado = $TimerResultado

var conexion_actual_index: int = 0
var vidas_restantes: int = 5
var vidas_maximas: int = 5
var puntos: int = 0
var nivel_actual: int = 1
var tiempo_transcurrido: float = 0.0
var game_over: bool = false
var pistas_usadas: int = 0
var conexiones_bloqueadas: int = 0
var conexiones_permitidas: int = 0
var aciertos: int = 0

func _ready():
	resultado_label.text = ""
	hint_label.text = ""
	btn_siguiente.visible = false
	
	connections = level_database.get_all_levels()
	
	if connections.is_empty():
		push_error("No hay conexiones cargadas en la base de datos")
		return
	
	_cargar_conexion()
	_actualizar_estadisticas()
	timer_juego.start()
	_mostrar_bienvenida()

func _mostrar_bienvenida():
	resultado_label.text = "🛡️ ¡Defiende la red de amenazas!"
	resultado_label.add_theme_color_override("font_color", Color(0.2, 0.8, 1))
	await get_tree().create_timer(2.0).timeout
	if not game_over:
		resultado_label.text = ""

func _process(delta):
	if not game_over and timer_juego.time_left > 0:
		tiempo_transcurrido += delta
		_actualizar_tiempo()

func _cargar_conexion():
	if conexion_actual_index >= connections.size():
		_victoria_total()
		return
	
	var conexion: ConnectionResource = connections[conexion_actual_index]
	connection_info_label.text = conexion.get_connection_info()
	hint_label.text = ""
	resultado_label.text = ""
	
	btn_permitir.disabled = false
	btn_bloquear.disabled = false
	btn_pista.disabled = false
	
	# Actualizar barra de progreso
	progress_bar.max_value = connections.size()
	progress_bar.value = conexion_actual_index + 1
	
	# Calcular nivel basado en el progreso
	nivel_actual = (conexion_actual_index / 5) + 1
	nivel_label.text = "🎯 Nivel " + str(nivel_actual)

func _actualizar_estadisticas():
	vidas_label.text = "❤️ Vidas: " + str(vidas_restantes) + "/" + str(vidas_maximas)
	puntos_label.text = "⭐ Puntos: " + str(puntos)
	
	if vidas_restantes <= 1:
		vidas_label.add_theme_color_override("font_color", Color(1, 0, 0))
	elif vidas_restantes <= 2:
		vidas_label.add_theme_color_override("font_color", Color(1, 0.5, 0))
	else:
		vidas_label.add_theme_color_override("font_color", Color(1, 1, 1))

func _actualizar_tiempo():
	var minutos = int(tiempo_transcurrido / 60)
	var segundos = int(tiempo_transcurrido) % 60
	tiempo_label.text = "⏱️ %02d:%02d" % [minutos, segundos]

func _on_btn_permitir_pressed() -> void:
	if game_over:
		return
	_verificar_decision(false)  # false = permitir (no es sospechosa)
	conexiones_permitidas += 1

func _on_btn_bloquear_pressed() -> void:
	if game_over:
		return
	_verificar_decision(true)  # true = bloquear (es sospechosa)
	conexiones_bloqueadas += 1

func _verificar_decision(decidio_bloquear: bool):
	var conexion: ConnectionResource = connections[conexion_actual_index]
	var es_correcta = decidio_bloquear == conexion.is_suspicious
	
	btn_permitir.disabled = true
	btn_bloquear.disabled = true
	btn_pista.disabled = true
	
	if es_correcta:
		aciertos += 1
		var puntos_ganados = 100
		if pistas_usadas == 0:
			puntos_ganados += 50  # Bonus por no usar pistas
		puntos += puntos_ganados
		
		resultado_label.text = "✅ ¡Correcto! +" + str(puntos_ganados) + " puntos"
		resultado_label.add_theme_color_override("font_color", Color(0, 1, 0))
		
		if conexion.is_suspicious:
			hint_label.text = "🚨 Razón: " + conexion.reason
		else:
			hint_label.text = "✓ Conexión legítima permitida"
		hint_label.add_theme_color_override("font_color", Color(0, 0.8, 1))
	else:
		vidas_restantes -= 1
		resultado_label.text = "❌ ¡Error! Perdiste una vida"
		resultado_label.add_theme_color_override("font_color", Color(1, 0, 0))
		
		hint_label.text = "💡 " + conexion.reason
		hint_label.add_theme_color_override("font_color", Color(1, 0.5, 0))
		
		_actualizar_estadisticas()
		
		if vidas_restantes <= 0:
			_game_over()
			return
	
	_actualizar_estadisticas()
	pistas_usadas = 0  # Resetear pistas para la siguiente conexión
	
	btn_siguiente.visible = true
	timer_resultado.start()

func _on_btn_pista_pressed() -> void:
	if game_over:
		return
	
	var conexion: ConnectionResource = connections[conexion_actual_index]
	hint_label.text = "💡 Pista: " + conexion.hint
	hint_label.add_theme_color_override("font_color", Color(1, 1, 0))
	pistas_usadas += 1
	btn_pista.disabled = true

func _on_btn_siguiente_pressed() -> void:
	conexion_actual_index += 1
	btn_siguiente.visible = false
	_cargar_conexion()

func _on_timer_resultado_timeout() -> void:
	if not game_over and btn_siguiente.visible:
		_on_btn_siguiente_pressed()

func _victoria_total():
	game_over = true
	btn_permitir.disabled = true
	btn_bloquear.disabled = true
	btn_pista.disabled = true
	btn_siguiente.visible = false
	timer_juego.stop()
	
	var precision = float(aciertos) / float(connections.size()) * 100
	
	resultado_label.text = "🏆 ¡VICTORIA TOTAL!"
	resultado_label.add_theme_color_override("font_color", Color(1, 0.8, 0))
	
	hint_label.text = "Precisión: %.1f%% | Puntos: %d | Tiempo: %s" % [
		precision, 
		puntos,
		tiempo_label.text.replace("⏱️ ", "")
	]
	hint_label.add_theme_color_override("font_color", Color(0, 1, 0))
	
	connection_info_label.text = "🎉 ¡Has protegido la red exitosamente!"
	
	# Reportar victoria al sistema global
	if Global.has_method("report_challenge_result"):
		Global.report_challenge_result(true)

func _game_over():
	game_over = true
	btn_permitir.disabled = true
	btn_bloquear.disabled = true
	btn_pista.disabled = true
	btn_siguiente.visible = false
	timer_juego.stop()
	
	resultado_label.text = "💀 GAME OVER"
	resultado_label.add_theme_color_override("font_color", Color(1, 0, 0))
	
	var precision = float(aciertos) / float(conexion_actual_index) * 100
	hint_label.text = "Conexiones analizadas: %d | Precisión: %.1f%%" % [conexion_actual_index, precision]
	connection_info_label.text = "⚠️ La red fue comprometida..."
	
	# Reportar derrota al sistema global
	if Global.has_method("report_challenge_result"):
		Global.report_challenge_result(false)

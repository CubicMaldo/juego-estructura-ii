extends Control

## Main Menu controller
## Handles navigation to game and quit functionality

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton

const GAME_SCENE_PATH := "res://principalGameScene.tscn"

func _ready() -> void:
	_connect_buttons()
	_focus_play_button()

func _connect_buttons() -> void:
	if play_button != null:
		play_button.pressed.connect(_on_play_pressed)
	if quit_button != null:
		quit_button.pressed.connect(_on_quit_pressed)

func _focus_play_button() -> void:
	if play_button != null:
		play_button.grab_focus()

func _on_play_pressed() -> void:
	print("[MainMenu] Iniciando juego...")
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_quit_pressed() -> void:
	print("[MainMenu] Saliendo del juego...")
	get_tree().quit()

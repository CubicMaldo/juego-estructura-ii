extends Control

@onready var panel: Panel = $Panel

func _setAppStat(appStats : AppStats):
	$Panel/VBoxContainer/MarginContainer/HBoxContainer/TextureRect.texture = appStats.icon
	$Panel/VBoxContainer/MarginContainer/HBoxContainer/Label.text = appStats.app_name
	$Panel.size = appStats.size

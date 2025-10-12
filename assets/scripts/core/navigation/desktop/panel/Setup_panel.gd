extends Control

@onready var panel: Panel = $Panel

func _setAppStat(appStats : AppStats):
	$Panel/VBoxContainer/MarginContainer/HBoxContainer/TextureRect.texture = appStats.icon
	$Panel/VBoxContainer/MarginContainer/HBoxContainer/Label.text = appStats.app_name
	$Panel.size = appStats.size
	$Panel.pivot_offset = appStats.size*0.5


func _on_minimize_pressed() -> void:
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "scale", Vector2(0.1, 0.1), 0.4)
	
	tween.finished.connect(func(): self.visible = false)


func _on_maximize_pressed() -> void:
	pass # Replace with function body.

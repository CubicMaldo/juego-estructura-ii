extends Button

@export_enum("Izquierda", "Centro", "Derecha") var direccion: String = "Izquierda"

func _ready() -> void:
	# Connect to game controller events
	Global.treeMap.player_moved.connect(_on_player_moved)
	# Initial state
	_update_state()

func _on_pressed() -> void:
	match direccion:
		"Izquierda":
			Global.treeMap.navigate_left()
		"Derecha":
			Global.treeMap.navigate_right()
		"Centro":
			Global.treeMap.navigate_up()

func _on_player_moved(node: TreeNode) -> void:
	_update_state()

func _update_state() -> void:
	match direccion:
		"Izquierda":
			var can_move = Global.treeMap.can_navigate_left()
			disabled = not can_move
		
		"Derecha":
			var can_move = Global.treeMap.can_navigate_right()
			disabled = not can_move
		
		"Centro":
			disabled = not Global.treeMap.can_navigate_up()

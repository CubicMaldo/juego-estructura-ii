extends Node

## Simplified global - only holds the game controller reference
## All game logic is now in GameController

var treeMap : GameController

func _ready():
	treeMap = GameController.new()
	add_child(treeMap)

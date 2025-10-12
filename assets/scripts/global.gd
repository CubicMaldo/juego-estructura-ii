extends Node

## Simplified global - only holds the game controller reference
## All game logic is now in TreeAppController

var treeMap : TreeAppController

func _ready():
	treeMap = TreeAppController.new()
	add_child(treeMap)

func report_challenge_result(win: bool) -> void:
	if treeMap == null:
		return
	treeMap.report_challenge_result(win)

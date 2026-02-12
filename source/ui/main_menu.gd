extends Control
class_name MainMenu


signal level_pick(level)


func _on_button_pressed() -> void:
	var level = load("res://source/levels/testing/level_testing.tscn")
	level_pick.emit(level)

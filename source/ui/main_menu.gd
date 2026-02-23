class_name MainMenu
extends Control

signal level_pick(level)


func _on_level_pick_pressed() -> void:
	var level = load("res://source/levels/testing/level_testing.tscn")
	level_pick.emit(level)


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	pass # Replace with function body.

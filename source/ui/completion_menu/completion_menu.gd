class_name CompletionMenu
extends Control

signal main_menu_requested
signal next_level_requested


func _on_next_level_pressed() -> void:
	next_level_requested.emit()


func _on_main_menu_pressed() -> void:
	main_menu_requested.emit()


func _on_exit_pressed() -> void:
	get_tree().quit()

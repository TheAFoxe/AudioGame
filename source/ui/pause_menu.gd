extends Control
class_name PauseMenu

signal exit
signal main_menu
signal settings


func _on_button_pressed() -> void:
	exit.emit()


func _on_main_menu_pressed() -> void:
	main_menu.emit()


func _on_settings_pressed() -> void:
	settings.emit()

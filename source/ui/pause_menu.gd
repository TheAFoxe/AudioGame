extends Control

signal exit()
signal main_menu()


func _on_button_pressed() -> void:
	exit.emit()


func _on_main_menu_pressed() -> void:
	main_menu.emit()

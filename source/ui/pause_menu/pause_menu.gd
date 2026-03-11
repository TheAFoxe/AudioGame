class_name PauseMenu
extends Control

signal open_submenu(menu: MainUI.Menu)
signal main_menu_requested
signal resume_requested


func _on_resume_pressed() -> void:
	resume_requested.emit()


func _on_main_menu_pressed() -> void:
	main_menu_requested.emit()


func _on_settings_pressed() -> void:
	open_submenu.emit(MainUI.Menu.SETTINGS)


func _on_exit_pressed() -> void:
	get_tree().quit()

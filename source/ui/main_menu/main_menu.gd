class_name MainMenu
extends Control


signal open_submenu(menu: MainUI.Menu)


func _on_level_pick_pressed() -> void:
	open_submenu.emit(MainUI.Menu.LEVEL_PICK)


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	open_submenu.emit(MainUI.Menu.SETTINGS)

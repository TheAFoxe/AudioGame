class_name SettingsMenu
extends Control

var _volume_label: Label
var _volume_value: float
var _volume_timer: Timer


func _ready() -> void:
	_volume_label = get_node(
		"PanelContainer/MarginContainer/VBoxContainer/Volume/HSlider/VolumeLable"
	)
	_volume_timer = Timer.new()
	_volume_timer.wait_time = 1
	_volume_timer.timeout.connect(_on_volume_timer_timeout)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(1))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0: #720p
			DisplayServer.window_set_size(Vector2i(1280, 720))
		1: #1080p
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		2: #1440p
			DisplayServer.window_set_size(Vector2i(2560, 1440))


func _on_antialiasing_set(index: int) -> void:
	var viewport_rid = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_msaa_3d(viewport_rid, index)


func _on_volume_change(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value/10))
	_volume_label.text = str(int(value))
	_volume_timer.start()


func _on_volume_timer_timeout() -> void:
	_volume_label.hide()


func _on_volume_drag_started() -> void:
	_volume_label.show()

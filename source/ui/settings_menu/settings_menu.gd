class_name SettingsMenu
extends Control

signal close_requested

const SETTINGS_PATH := "res://settings.cfg"

var _volume_label: Label
var _volume_timer: Timer

var _volume_slider: HSlider
var _resolution_option_button: OptionButton
var _anti_aliasing_option_button: OptionButton


func _ready() -> void:
	_volume_label = get_node(
		"PanelContainer/MarginContainer/VBoxContainer/Volume/ColorRect/HSlider/VolumeLable"
	)
	_volume_slider = get_node(
		"PanelContainer/MarginContainer/VBoxContainer/Volume/ColorRect/HSlider"
	)
	_resolution_option_button = get_node(
		"PanelContainer/MarginContainer/VBoxContainer/Resolution/OptionButton"
	)
	_anti_aliasing_option_button = get_node(
		"PanelContainer/MarginContainer/VBoxContainer/AA/OptionButton"
	)
	_volume_timer = Timer.new()
	add_child(_volume_timer)
	_volume_timer.wait_time = 0.7
	_volume_timer.timeout.connect(_on_volume_timer_timeout)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	load_settings()

func _on_save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", _volume_slider.value)
	config.set_value("video", "antialiasing", _anti_aliasing_option_button.selected)
	config.save(SETTINGS_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return  # no file yet, use defaults

	var volume: float = config.get_value("audio", "volume", 10.0)
	var antialiasing: int = config.get_value("video", "antialiasing", 0)

	_volume_slider.value = volume
	_on_volume_change(volume)
	_on_antialiasing_set(antialiasing)
	_anti_aliasing_option_button.selected = antialiasing


func _on_antialiasing_set(index: int) -> void:
	var viewport_rid = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_msaa_3d(viewport_rid, index)


func _on_volume_change(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 10))
	_volume_label.text = str(int(value))
	_volume_timer.start()


func _on_volume_drag_started() -> void:
	_volume_label.show()

func _on_volume_timer_timeout() -> void:
	_volume_label.hide()

func _on_close_pressed() -> void:
	close_requested.emit()

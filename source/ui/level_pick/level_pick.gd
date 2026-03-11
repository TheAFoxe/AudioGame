class_name LevelPickMenu
extends Control

signal level_load_request(index: int)

@export var level_database: LevelDatabase

@onready var _vbox: GridContainer = $PanelContainer/MarginContainer/GridContainer

func _ready() -> void:
	level_database = load("res://source/data/level_database.tres")
	print(level_database.levels)
	_populate()

func _populate() -> void:
	for i in level_database.levels.size():
		var data: LevelData = level_database.levels[i]
		var button := Button.new()
		button.text = data.title
		button.pressed.connect(func(): level_load_request.emit(i))
		_vbox.add_child(button)
		button.custom_minimum_size.x = 150
		#button.set_meta("id", i)
		#button.pressed.connect(_on_level_pick_pressed.bind(button))
#
#
#func _on_level_pick_pressed(button: Button) -> void:
	#level_pick_request.emit(button.get_meta("id"))

extends Node3D



@export var testing_scene: PackedScene
@export var player_scene: PackedScene

@onready var player: CharacterBody3D = player_scene.instantiate()
@onready var current_level_3d: Node3D = testing_scene.instantiate()
@onready var pause_menu: Control = $PauseMenu



func _ready():
	add_child(player)
	add_child(current_level_3d)
	connect("exit", _on_pause_menu_exit)
	
	pause_menu.hide()
	
	Engine.max_fps = 24
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		unpause()
	else:
		pause()

func pause() -> void:
	pause_menu.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func unpause() -> void:
	pause_menu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _on_pause_menu_exit() -> void:
	get_tree().quit()

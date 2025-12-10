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
	
	Engine.max_fps = 240
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			pause()
		else:
			unpause()


func _on_pause_menu_exit() -> void:
	get_tree().quit()


func pause():
	get_tree().paused = false
	pause_menu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func unpause():
	pause_menu.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

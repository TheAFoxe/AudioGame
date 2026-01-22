extends Node3D

enum GAME_STATUS {main_menu, pause_menu, running}

var game_status

var player_scene: PackedScene

var player: Player
var pause_menu: Control
var main_menu: Control
var current_level: Node3D


func _ready():
	pause_menu = $PauseMenu
	main_menu = $MainMenu
	
	player_scene = load("res://source/player/player.tscn")
	player = player_scene.instantiate()
	
	pause_menu.hide()
	main_menu.show()
	
	pause_menu.hide()
	add_child(player)
	player.can_move = false
	
	Engine.max_fps = 60
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match game_status:
			GAME_STATUS.running:
				pause_menu.show()
				pause()
			GAME_STATUS.main_menu:
				pass
			GAME_STATUS.pause_menu:
				pause_menu.hide()
				unpause()


func pause() -> void:
	game_status = GAME_STATUS.pause_menu
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func unpause() -> void:
	game_status = GAME_STATUS.running
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _on_pause_menu_exit() -> void:
	game_status = GAME_STATUS.pause_menu
	get_tree().quit()


func _on_pause_menu_main_menu() -> void:
	game_status = GAME_STATUS.main_menu
	player.can_move = false
	pause_menu.hide()
	main_menu.show()
	remove_child(current_level)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_main_menu_level_pick(level: Variant) -> void:
	game_status = GAME_STATUS.running
	main_menu.hide()
	
	current_level = level.instantiate()
	
	add_child(current_level)
	
	reset_player()
	player.can_move = true
	unpause()


func reset_player() -> void:
	player.global_position = current_level.spawn_point.global_position
	player.rotation = Vector3.ZERO
	player.camera_node.rotation = Vector3.ZERO

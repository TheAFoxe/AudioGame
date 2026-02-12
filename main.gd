extends Node3D

enum GameStatus {MAIN_MENU, PAUSE_MENU, RUNNING}

@export var max_fps: int = 60

var game_status: GameStatus

var _current_level: Level

@onready var _player: Player = $Player
@onready var _main_menu: MainMenu = $MainMenu
@onready var _pause_menu: PauseMenu = $PauseMenu


func _ready():
	_pause_menu = $PauseMenu
	_main_menu = $MainMenu
	
	_pause_menu.hide()
	_main_menu.show()
	
	_pause_menu.hide()
	_player.can_move = false
	
	Engine.max_fps = max_fps


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match game_status:
			GameStatus.RUNNING:
				_pause_menu.show()
				_pause()
			GameStatus.PAUSE_MENU:
				_pause_menu.hide()
				_unpause()


func _pause() -> void:
	game_status = GameStatus.PAUSE_MENU
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true


func _unpause() -> void:
	game_status = GameStatus.RUNNING
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false


func _on_pause_menu_exit() -> void:
	get_tree().quit()


func _on_pause_menu_main_menu() -> void:
	game_status = GameStatus.MAIN_MENU
	_player.can_move = false
	_pause_menu.hide()
	_main_menu.show()
	remove_child(_current_level)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_main_menu_level_pick(level: Variant) -> void:
	game_status = GameStatus.RUNNING
	_main_menu.hide()
	
	_current_level = level.instantiate()
	
	add_child(_current_level)
	
	_reset_player()
	_unpause()


func _reset_player() -> void:
	_player.global_position = _current_level.spawn_point.global_position
	_player.rotation = Vector3.ZERO
	_player.camera_node.rotation = Vector3.ZERO
	_player.can_move = true

extends Node3D

enum GameStatus { MAIN_MENU, PAUSE_MENU, SETTINGS_MENU, RUNNING }

@export var max_fps: int = 60

var game_status: GameStatus
var previous_game_status: GameStatus

var _current_level: Level

var _player: Player
var _main_menu: MainMenu
var _pause_menu: PauseMenu
var _settings_menu: Control


func _ready():
	_player = get_node("Player")
	_main_menu = get_node("MainMenu")
	_pause_menu = get_node("PauseMenu")
	_settings_menu = get_node("SettigsMenu")
	
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
			GameStatus.SETTINGS_MENU:
				_on_settings_close()
		for i in get_tree().get_nodes_in_group("menu"):
			i.leave()


func _pause() -> void:
	game_status = GameStatus.PAUSE_MENU
	_player._leave()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true


func _unpause() -> void:
	game_status = GameStatus.RUNNING
	_player._player_state = Player.PlayerState.FREE
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


func _on_settings_open() -> void:
	_settings_menu.show()
	previous_game_status = game_status
	game_status = GameStatus.SETTINGS_MENU


func _on_settings_close() -> void:
	_settings_menu.hide()
	game_status = previous_game_status

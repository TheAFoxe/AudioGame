class_name Main
extends Node3D

enum GameStatus { MAIN_MENU, LEVEL_PICK, PAUSE_MENU, SETTINGS_MENU, COMPLETE, RUNNING }

@export var max_fps: int = 60

var game_status: GameStatus = GameStatus.MAIN_MENU

var _debug: bool

var _current_level: Level
var _level_db: LevelDatabase
var _current_level_id: int
var _player: Player
var _main_ui: MainUI
var _fps: Label


func _ready() -> void:
	Engine.max_fps = max_fps

	_level_db = load("res://source/data/level_database.tres")

	_player = get_node("Player")
	_main_ui = get_node("MainUI")
	_fps = get_node("FPS")

	_main_ui.level_load_requested.connect(_on_level_load)
	_main_ui.main_menu_requested.connect(_on_go_to_main_menu)
	_main_ui.next_level_requested.connect(_on_go_to_next_level)
	_main_ui.resume_requested.connect(_on_resume)
	
	_debug = false
	GlobalSignals.debug_mode_switch.emit(_debug)
	_fps.hide()
	
	_set_main_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match game_status:
			GameStatus.RUNNING:
				_set_pause_menu()
			GameStatus.PAUSE_MENU:
				_on_resume()
	if event.is_action_pressed("change_debug_mode"):
		_debug_switch()


# -- State transitions --

func _set_main_menu() -> void:
	game_status = GameStatus.MAIN_MENU
	_player.can_move = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	_main_ui.show()
	_main_ui.show_main_menu()

func _set_pause_menu() -> void:
	game_status = GameStatus.PAUSE_MENU
	_player._leave()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	_main_ui.show()
	_main_ui.show_pause_menu()

func _set_running() -> void:
	game_status = GameStatus.RUNNING
	_player._player_state = Player.PlayerState.FREE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	_main_ui.hide()

func _set_completion_menu() -> void:
	game_status = GameStatus.COMPLETE
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	_main_ui.show()
	_main_ui.show_completion_menu()


func _debug_switch() -> void:
	_debug = not _debug
	GlobalSignals.debug_mode_switch.emit(_debug)
	if _debug:
		_fps.show()
	else:
		_fps.hide()


# -- Signal handlers --

## Unloads current level, loads level by id, resets player state
func _on_level_load(id: int) -> void:
	if _current_level:
		_current_level.level_complete.disconnect(_on_level_complete)
		remove_child(_current_level)
		_current_level.queue_free()

	if _level_db.levels.size() == id: # past last level — back to menu
		_set_main_menu()
		return

	var level := _level_db.levels[id].scene
	if not level:
		push_error("Level not available")
		return

	_current_level = level.instantiate()
	add_child(_current_level)
	_current_level_id = id

	_player.global_position = _current_level.spawn_point.global_position
	_player.velocity = Vector3.ZERO
	_player.rotation = _current_level.spawn_point.global_rotation
	_player.camera_node.rotation = Vector3.ZERO

	_set_running()
	_current_level.level_complete.connect(_on_level_complete)


func _on_go_to_next_level() -> void:
	_on_level_load(_current_level_id + 1)


func _on_resume() -> void:
	_set_running()


## Frees current level if any, then returns to main menu
func _on_go_to_main_menu() -> void:
	if _current_level:
		remove_child(_current_level)
		_current_level.queue_free()
		_current_level = null
	_set_main_menu()


func _on_level_complete() -> void:
	_current_level.level_complete.disconnect(_on_level_complete)
	_set_completion_menu()

extends Node3D

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


#func _on_pause_menu_main_menu() -> void:
	#player.can_move = false
	#pause_menu.hide()
	#main_menu.show()
	#current_level.queue_free()
	#player.queue_free()
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_main_menu_level_pick(level: Variant) -> void:
	main_menu.hide()
	#add_child(player)
	current_level = level.instantiate()
	add_child(current_level)
	
	player.can_move = true
	unpause()

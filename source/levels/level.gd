@abstract
class_name Level
extends Node

signal open_door
signal close_door
signal level_complete

var spawn_point: Marker3D
var _catchers: Array[AudioCatcher] = []
var _exit_door: CompletionExit
var _is_door_open: bool

func _ready() -> void:
	spawn_point = get_node("SpawnPoint")
	_exit_door = get_node("CompletionExit")
	_catchers = _find_catchers()
	_exit_door.level_complete.connect(_on_level_complete)
	for catcher in _catchers:
		catcher.activated.connect(_on_catcher_state_changed)
		catcher.deactivated.connect(_on_catcher_state_changed)

## Collects all AudioCatcher nodes in the level from group
func _find_catchers() -> Array[AudioCatcher]:
	var result: Array[AudioCatcher] = []
	for node in get_tree().get_nodes_in_group("audio_catcher"):
		if node is AudioCatcher:
			result.append(node)
	print(result)
	return result

## Opens door when all catchers active, closes it if any deactivate
func _on_catcher_state_changed() -> void:
	if _is_door_open:
		close_door.emit()
	if _catchers.all(func(c): return c._is_active):
		_on_all_catchers_activated()

func _on_all_catchers_activated() -> void:
	open_door.emit()
	_is_door_open = true


func _on_level_complete() -> void:
	level_complete.emit()

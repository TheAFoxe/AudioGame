extends Node
class_name Level

var spawn_point: Marker3D

func _ready() -> void:
	spawn_point = $SpawnPoint

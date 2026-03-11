class_name CompletionExit
extends Node3D

signal level_complete

var _door_collision: CollisionShape3D
var _activation_mesh: MeshInstance3D

func _ready() -> void:
	_door_collision = get_node("StaticBody3D/CollisionShape3D")
	_activation_mesh = get_node("ActivationMesh")
	var level := get_parent() as Level
	level.open_door.connect(_on_door_open)
	level.close_door.connect(_on_door_close)
	_on_door_close()


func _on_door_open() -> void:
	_activation_mesh.mesh.material.albedo_color = Color.WHITE
	_door_collision.disabled = true


func _on_door_close() -> void:
	_activation_mesh.mesh.material.albedo_color = Color.RED
	_door_collision.disabled = false


func _on_exit_entered(body: Node3D) -> void:
	if not body is Player: return
	if not _door_collision.disabled: return # door closed
	level_complete.emit()

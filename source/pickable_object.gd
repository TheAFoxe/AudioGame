extends Node3D
class_name InteractableObject

var is_picked: bool
var origin: Node3D
var _duplicated: PickableObject


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if is_picked:
		_is_picked()


func _is_picked() -> void:
	global_position = origin.global_position * Vector3(1, 0, 1)
	global_rotation.y = origin.global_rotation.y


func can_place() -> bool:
	return true


func pick(player_origin: Node3D):
	origin = player_origin
	origin.global_position  = self.global_position
	origin.global_rotation.y = self.global_rotation.y
	is_picked = true


func place() -> void:
	is_picked = false

extends Node3D
class_name PickableObject

var is_picked: bool
var origin: Node3D
var _duplicated: PickableObject
var collision: StaticBody3D


func _ready() -> void:
	if $Mesh:
		collision = $Mesh.get_child(1)
		print(collision.collision_layer)


func _process(delta: float) -> void:
	if is_picked:
		global_position = global_position.lerp(origin.global_position, .7)
		global_rotation.y = lerp_angle(global_rotation.y, origin.global_rotation.y, 0.5)


func can_place() -> bool:
	return true


func pick(player_origin: Node3D):
	origin = player_origin
	if $Mesh:
		collision = $Mesh.get_child(1)
		collision.collision_layer = 0
		
	is_picked = true


func place() -> void:
	if $Mesh:
		collision = $Mesh.get_child(1)
		collision.collision_layer = 1
	is_picked = false

@abstract
class_name PickableObject
extends Node3D

const FOLLOW_WEIGHT: float = 0.7
const ROTATION_WEIGHT: float = 0.5

var _is_held: bool
var _area_place: Area3D

var _player: Player
var _origin: Node3D
var _collision: StaticBody3D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_origin = _player.origin
	if not _player:
		push_error("No Player detected")
	if $AreaPlace:
		_area_place = $AreaPlace
	else: push_warning("No AreaPlace on object")
	if $Mesh:
		_collision = $Mesh.get_child(1)
	else: push_warning("No Mesh for collision on object")


func _process(delta: float) -> void:
	if not _is_held: return
	self.global_position = self.global_position.lerp(_origin.global_position, FOLLOW_WEIGHT)
	self.global_rotation.y = lerp_angle(self.global_rotation.y, _origin.global_rotation.y, ROTATION_WEIGHT)


func pick() -> bool:
	if _collision: _collision.collision_layer = 0
	_is_held = true
	return true


func place() -> bool:
	if _area_place.get_overlapping_areas(): return false
	if _collision: _collision.collision_layer = 1
	_is_held = false
	return true

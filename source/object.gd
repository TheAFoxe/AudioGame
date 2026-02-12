extends Node3D
class_name PickableObject

signal player(player: Player)

const LERP_SPEED: float = 0.7
const LERP_ANGLE_SPEED: float = 0.5

var _is_picked: bool
var _area_place: Area3D

var _player: Player
var _origin: Node3D
var _collision: StaticBody3D

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_origin = _player.origin
	if $AreaPlace:
		_area_place = $AreaPlace
	else: push_warning("No AreaPlace on object")
	if $Mesh:
		_collision = $Mesh.get_child(1)
	else: push_warning("No Mesh for collision on object")


func _process(delta: float) -> void:
	if not _is_picked: return
	self.global_position = self.global_position.lerp(_origin.global_position, LERP_SPEED)
	self.global_rotation.y = lerp_angle(self.global_rotation.y, _origin.global_rotation.y, LERP_ANGLE_SPEED)


func pick() -> bool:
	if _collision: _collision.collision_layer = 0
	_is_picked = true
	return true


func place() -> bool:
	if _area_place.get_overlapping_areas(): return false
	if _collision: _collision.collision_layer = 1
	_is_picked = false
	return true

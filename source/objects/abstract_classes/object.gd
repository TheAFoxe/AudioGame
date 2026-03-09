@abstract
class_name PickableObject
extends Node3D

const LERP_SPEED: float = 40.0
const LERP_ANGLE_SPEED: float = 20.0

var _is_picked: bool
var _area_place: Area3D

var _player: Player
var _origin: Node3D

var _inner_mesh: MeshInstance3D
var _outer_mesh: MeshInstance3D


func _ready() -> void:
	_inner_mesh = get_node("InnerMesh")
	_outer_mesh = get_node("OuterMesh")
	_player = get_tree().get_first_node_in_group("player")
	_origin = _player.origin
	if not _player:
		push_error("No Player detected")
	
	_area_place = get_node("AreaPlace")


func _physics_process(delta: float) -> void:
	if not _is_picked: return
	self.global_position = self.global_position.lerp(
		_origin_xz(), 1.0 - exp(-LERP_SPEED * delta)
		)
	self.global_rotation.y = lerp_angle(
		self.global_rotation.y, _origin.global_rotation.y, LERP_ANGLE_SPEED * delta
		)


func _origin_xz() -> Vector3:
	return Vector3(_origin.global_position.x, self.global_position.y, _origin.global_position.z)


func pick() -> bool:
	_is_picked = true
	_inner_mesh.hide()
	_outer_mesh.mesh.material.albedo_color.a = 0.2
	return true


func place() -> bool:
	if _area_place.get_overlapping_areas(): return false
	_is_picked = false
	_inner_mesh.show()
	_outer_mesh.mesh.material.albedo_color.a = 1
	return true

@abstract
class_name PickableObject
extends Node3D

## Speed of object lerping to origin position.
const LERP_SPEED: float = 40.0
## Speed of object lerping to origin rotation
const LERP_ANGLE_SPEED: float = 20.0

## Controls if object changes it's position on _physics_process.
var _is_picked: bool
## Area that checks if object can be placed here.
var _area_place: Area3D
## Player node.
var _player: Player
## Player's origin node. Controls position of picked object.
var _origin: Node3D

var _inner_mesh: MeshInstance3D
var _outter_mesh: MeshInstance3D


func _ready() -> void:
	# Setting nodes as corresponding variables values
	_inner_mesh = get_node("Mesh/InnerMesh")
	_outter_mesh = get_node("Mesh/OutterMesh")
	for i in _outter_mesh.mesh.get_surface_count():
		_outter_mesh.mesh.surface_get_material(i).transparency = BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA
	_area_place = get_node("AreaPlace")
	_player = get_tree().get_first_node_in_group("player")
	_origin = _player.origin


func _physics_process(delta: float) -> void:
	# Not active? -> skip
	if not _is_picked: return
	
	# Lerp to _origin
	self.global_position = self.global_position.lerp(
		_origin_xz(), 1.0 - exp(-LERP_SPEED * delta)
		)
	self.global_rotation.y = lerp_angle(
		self.global_rotation.y, _origin.global_rotation.y, LERP_ANGLE_SPEED * delta
		)


## Return value of _origin, Y-axis is set to self.global_position.y
func _origin_xz() -> Vector3:
	return Vector3(_origin.global_position.x, self.global_position.y, _origin.global_position.z)


## Make object active on picking. Controls Mesh material on pick.
## Return true on pick.
func pick() -> bool:
	_is_picked = true
	_inner_mesh.hide()
	_outter_mesh.mesh.surface_get_material(0).albedo_color.a = 0.2
	return true


## Places object. Return false if object can't be placed here.
## Returns materials of Mesh to default
func place() -> bool:
	if _area_place.get_overlapping_areas(): return false
	_is_picked = false
	_inner_mesh.show()
	_outter_mesh.mesh.surface_get_material(0).albedo_color.a = 1
	return true

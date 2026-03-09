class_name AudioRetranslator
extends PickableObject

var _ray_cast: RayCast
var is_active: bool
var activated_by: RayCast

var _activation_mesh: MeshInstance3D


func _ready() -> void:
	_ray_cast = get_node("RayCast")
	_ray_cast.self_area_ray = get_node("AreaRay").get_rid()
	_activation_mesh = get_node("ActivationMesh")
	if _activation_mesh:
		_activation_mesh.hide()
	super()


func activate(emitter: RayCast) -> bool:
	if is_active:
		return false
	activated_by = emitter
	is_active = true
	_ray_cast.activate(emitter)
	if _activation_mesh:
		_activation_mesh.show()
	return true


func deactivate(emitter: RayCast) -> void:
	if activated_by != emitter:
		return
	activated_by = null
	is_active = false
	_ray_cast.deactivate(emitter)
	if _activation_mesh:
		_activation_mesh.hide()


func receive_chord(new_chord: Chord, emitter: RayCast) -> void:
	if emitter == _ray_cast: return
	elif is_active:
		if emitter != activated_by: return
	_ray_cast.receive_chord(new_chord)

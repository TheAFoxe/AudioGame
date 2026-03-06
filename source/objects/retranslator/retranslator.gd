class_name AudioRetranslator
extends PickableObject

var _ray_cast: RayCast
var is_active: bool
var activated_by: RayCast

var _activation_sphere: MeshInstance3D


func _ready() -> void:
	_ray_cast = get_node("RayCast")
	_ray_cast.self_area_ray = get_node("AreaRay").get_rid()
	_activation_sphere = get_node("Activation")
	super()


func activate(emitter: RayCast) -> void:
	if is_active:
		return
	activated_by = emitter
	is_active = true
	_ray_cast.activate(emitter)
	if _activation_sphere:
		_activation_sphere.show()


func deactivate(emitter: RayCast) -> void:
	if activated_by != emitter:
		return
	activated_by = null
	is_active = false
	_ray_cast.deactivate(emitter)
	if _activation_sphere:
		_activation_sphere.hide()


func receive_chord(new_chord: Chord, emitter: RayCast) -> void:
	if emitter == _ray_cast: return
	elif emitter != activated_by: return
	_ray_cast.receive_chord(new_chord)

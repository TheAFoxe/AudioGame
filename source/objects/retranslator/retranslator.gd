class_name AudioRetranslator
extends PickableObject

var _ray_cast: RayCast
var is_active: bool
var activated_by: RayCast


func _ready() -> void:
	_ray_cast = get_node("RayCast")
	super()


func activate(emitter: RayCast) -> void:
	if is_active:
		return
	activated_by = emitter
	is_active = true
	_ray_cast.activate(emitter)


func deactivate(emitter: RayCast) -> void:
	if activated_by == emitter:
		return
	activated_by = null
	is_active = false
	_ray_cast.deactivate(emitter)


func receive_chord(chord: Chord, emitter: RayCast) -> void:
	if emitter == _ray_cast: return
	_ray_cast.receive_chord(chord)

@abstract
class_name AudioEmitter
extends PickableObject

var _ray_cast: RayCast
var _chord: Chord
var _activated_by: Node3D
var is_active: bool

func _ready() -> void:
	super()
	_ray_cast = get_node("RayCast")


func activate(emitter: Node3D) -> bool:
	if is_active: return false
	_activated_by = emitter
	_ray_cast.activate()
	return true


func deactivate(emitter: Node3D) -> void:
	if _activated_by == emitter:
		_ray_cast.deactivate(emitter)


func receive_chord(new_chord: Chord, emitter: Node3D) -> void:
	_chord = new_chord.duplicate()
	_chord.notes = new_chord.notes.duplicate()
	_ray_cast.receive_chord(_chord, emitter)

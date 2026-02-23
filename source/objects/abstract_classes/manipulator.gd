@abstract
class_name AudioManipulator
extends PickableObject

var is_active: bool

var _ray_cast: RayCast
var _chord: Chord

func _ready() -> void:
	_ray_cast = $RayCast
	deactivate(null)
	super()


func activate(chord: Chord) -> void:
	is_active = true
	_ray_cast.activate(chord)


func deactivate(emitter: Node3D) -> void:
	is_active = false
	_ray_cast.deactivate(emitter)

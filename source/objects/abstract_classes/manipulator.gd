@abstract
class_name AudioManipulator
extends PickableObject

var _ray_cast: RayCast

func _ready() -> void:
	super()
	_ray_cast = get_node("RayCast")
	deactivate(null)


func activate() -> void:
	_ray_cast.activate()


func deactivate(emitter: Node3D) -> void:
	_ray_cast.deactivate(emitter)


func set_chord(new_chord: Chord) -> void:
	_ray_cast.set_chord(new_chord)

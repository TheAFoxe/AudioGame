class_name Manipulator
extends PickableObject

@onready var _ray_cast: RayCast = $RayCast

func _ready() -> void:
	deactivate(null)
	super()

func activate(chord_resource: Chord) -> void:
	_ray_cast.activate(chord_resource)


func deactivate(emitter: Node3D) -> void:
	_ray_cast.deactivate(emitter)

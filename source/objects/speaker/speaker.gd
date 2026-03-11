## Self activated RayCast. Can't be modified, moved nor deactivated.
class_name Speaker
extends RayCast

@export var _chord_source: Chord

func _ready() -> void:
	super()
	activate()
	receive_chord(_chord_source)

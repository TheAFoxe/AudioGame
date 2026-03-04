class_name Speaker
extends RayCast

@export var _chord_source: Chord

func _ready() -> void:
	super()
	print(_chord_source.notes)
	activate(null)
	receive_chord(_chord_source)

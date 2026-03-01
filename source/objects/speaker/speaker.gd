class_name Speaker
extends AudioEmitter

@export var _chord_resource: Chord = load("res://source/sounds/chord.tres").duplicate()

func _ready() -> void:
	super()
	_chord_resource.make_notes()
	receive_chord(_chord_resource, null)
	activate(null)

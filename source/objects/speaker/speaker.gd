class_name Speaker
extends RayCast

@export var _chord_source: Chord = load("res://source/sounds/chord.tres")

func _ready() -> void:
	super()
	activate(null)
	receive_chord(_chord_source)

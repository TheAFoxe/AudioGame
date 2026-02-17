extends RayCast
class_name Speaker

@export var chord: Chord = load("res://source/sounds/chord.tres")

func _ready() -> void:
	super()
	activate(chord)

class_name Speaker
extends RayCast

@export var speaker_chord: Chord = load("res://source/sounds/chord.tres").duplicate()

func _ready() -> void:
	super()
	speaker_chord.make_notes()
	print(speaker_chord)
	set_chord(speaker_chord)
	activate()

class_name AudioSeparator
extends AudioManipulator

func _ready() -> void:
	super()
	connect("send_chord_mask", _set_chord_mask)


func _set_chord_mask(chord_mask) -> void:
	print(chord_mask)


func activate(chord: Chord) -> void:
	super.activate(chord)


func deactivate(emitter: Node3D) -> void:
	super.deactivate(emitter)

extends PickableObject
class_name Mixer

var _chord: Chord

@onready var _raycast: RayCast


func _ready() -> void:
	_chord.make_chord()


func activate(chord: Chord) -> void:
	if not _check_chord_collision(chord):
		push_error("Collision in chord detected")
		return
	_raycast.activate(chord)


func deactivate(emitter: Node3D) -> void:
	_raycast.deactivate(emitter)


func _check_chord_collision(chord: Chord) -> bool:
	var string = 0
	while string < 0:
		if chord.notes[string] and _chord.notes[string]:
			return false
		_chord.notes[string] = chord.notes[string]
	return true

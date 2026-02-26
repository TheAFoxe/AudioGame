class_name AudioMixer
extends AudioManipulator

var _chord: Chord

func _ready() -> void:
	super()


func _append_notes_to_chord(new_chord: Chord) -> void:
	var string := -1
	while string < 5:
		string += 1
		if new_chord.notes[string] == null:
			continue
		_chord.notes[string] = new_chord.notes[string]


func _check_chord_collision(new_chord: Chord) -> bool:
	if not _chord: return true
	for string in 6:
		if new_chord.notes[string] == null:
			continue
		elif new_chord.notes[string] and _chord.notes[string]:
			return false
	return true


func activate() -> void:
	super.activate()


func deactivate(emitter: Node3D) -> void:
	super.deactivate(emitter)


func set_chord(new_chord: Chord) -> void:
	if not _check_chord_collision(new_chord):
		print("Collision in chord detected")
		return
	_append_notes_to_chord(new_chord)
	super.set_chord(new_chord)

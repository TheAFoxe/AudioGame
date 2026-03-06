class_name AudioMixer
extends AudioProcessor

var _sources: Array[ChordEntry]

func _ready() -> void:
	super()


#func _append_notes_to_chord(chord: Chord) -> void:
	#var string := -1
	#while string < 5:
		#string += 1
		#if chord.notes[string] == null:
			#continue
		#_chord.notes[string] = chord.notes[string]
#
#
#func _check_chord_collision(chord: Chord) -> bool:
	#var string := -1
	#while string < 5:
		#string += 1
		#if chord.notes[string] == null:
			#continue
		#elif chord.notes[string] and _chord.notes[string]:
			#return false
	#return true


func _process_chord() -> Chord:
	return


func receive_chord(new_chord: Chord, emitter: RayCast) -> void:
	if emitter == _ray_cast: return
	for i in _sources:
		if emitter == i.source:
			return
	_sources.append()


func activate(emitter: RayCast) -> void:
	#if not _check_chord_collision(chord):
		#push_error("Collision in chord detected")
		#return
	#_append_notes_to_chord(chord)
	super.activate(emitter)


func deactivate(emitter: Node3D) -> void:
	super.deactivate(emitter)

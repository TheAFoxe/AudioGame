extends Resource
class_name Chord

enum Fret {OPEN, FIRST, SECOND, THIRD, FOURTH, NONE}
@export var lib_note: LibNote = load("res://source/sounds/lib_note.tres")

@export_category("Chord")
@export var s6: Fret
@export var s5: Fret
@export var s4: Fret
@export var s3: Fret
@export var s2: Fret
@export var s1: Fret


func make_chord(chord_in: Array):
	if not lib_note:
		push_error("No lib_note provided in resource: %s" % self)
		return []
	
	var chord_out: Array[AudioStream] = []
	var string_num = 6
	for fret_value in chord_in:
		var note = lib_note.get_audio_stream(string_num, fret_value)
		string_num -= 1
		chord_out.append(note)
	return chord_out

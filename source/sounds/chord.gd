extends Resource
class_name Chord

enum Fret {OPEN, FIRST, SECOND, THIRD, FOURTH, NONE}
@export var lib_note: LibNote = load("res://source/sounds/lib_note.tres").duplicate()

@export_category("Chord")
@export var s6: Fret = Fret.NONE
@export var s5: Fret = Fret.NONE
@export var s4: Fret = Fret.NONE
@export var s3: Fret = Fret.NONE
@export var s2: Fret = Fret.NONE
@export var s1: Fret = Fret.NONE

var strings: Array[Fret] = [s6, s5, s4, s3, s2, s1]
var notes: Array[AudioStream] = []


func _init() -> void:
	notes.clear()
	var string_num = 0
	while string_num < 6:
		var fret_value = strings[string_num]
		var note = lib_note.get_audio_stream(string_num, fret_value)
		notes.append(note)
		string_num += 1

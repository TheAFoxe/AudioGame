class_name Chord
extends Resource

enum Fret {OPEN, FIRST, SECOND, THIRD, FOURTH, NONE}

const MAX_NOTES: int = 6

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
	for string_num in MAX_NOTES:
		var fret_value = strings[string_num]
		var note = get_audio_stream(string_num, fret_value)
		notes.append(note)
		string_num += 1


func get_audio_stream(guitar_string: int, guitar_fret: int) -> AudioStream:
	var format_path = "res://source/sounds/notes/S%d_F%d_r%d.mp3"
	var path = format_path % [guitar_string, guitar_fret, 0]
	if not ResourceLoader.exists(path): 
		#push_error("No audio available on path: %s" % path)
		return
	var audio_stream: AudioStream = load(path)
	audio_stream.loop = true
	return audio_stream

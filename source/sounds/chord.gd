extends Resource
class_name Chord

enum Fret {OPEN, FIRST, SECOND, THIRD, FOURTH, NONE}

@export_category("Chord")
@export var s6: Fret
@export var s5: Fret
@export var s4: Fret
@export var s3: Fret
@export var s2: Fret
@export var s1: Fret

var strings: Array[Fret] = []
var notes: Array[AudioStream] = []


func make_notes() -> void:
	strings = [s6, s5, s4, s3, s2, s1]
	notes.clear()
	for string_num in 6:
		var note = get_audio_stream(6 - string_num, strings[string_num])
		notes.append(note)


func get_audio_stream(guitar_string: int, guitar_fret: int) -> AudioStream:
	var format_path = "res://source/sounds/notes/S%d_F%d_r%d.mp3"
	var path = format_path % [guitar_string, guitar_fret, 0]
	if not ResourceLoader.exists(path): 
		#push_error("No audio available on path: %s" % path)
		return
	var audio_stream: AudioStream = load(path)
	audio_stream.loop = true
	return audio_stream

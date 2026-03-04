class_name Chord
extends Resource

enum Fret {OPEN, FIRST, SECOND, THIRD, FOURTH, NONE}

const MAX_NOTES: int = 6

@export_category("Chord")
@export var s6: Fret
@export var s5: Fret
@export var s4: Fret
@export var s3: Fret
@export var s2: Fret
@export var s1: Fret

var notes: Array[AudioStream]:
	get:
		var strings: Array[Fret] = [s6, s5, s4, s3, s2, s1]
		var result: Array[AudioStream] = []
		for string_num in MAX_NOTES:
			var fret_value = strings[string_num]
			if fret_value == Fret.NONE:
				result.append(null)
				continue
			result.append(get_audio_stream(MAX_NOTES - string_num, fret_value))
		return result


func get_audio_stream(guitar_string: int, guitar_fret: int) -> AudioStream:
	var format_path = "res://source/sounds/notes/S%d_F%d_r%d.mp3"
	var path = format_path % [guitar_string, guitar_fret, 0]
	if not ResourceLoader.exists(path): 
		push_error("No audio available on path: %s" % path)
		return
	var audio_stream: AudioStream = load(path)
	#audio_stream.loop = true
	#audio_stream.loop_offset = 0.0
	return audio_stream

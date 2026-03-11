## Resource class containing values of individual strings and corresponding
## .MP3 files for playing audio.
class_name Chord
extends Resource

## Available Fret values.
enum Fret {OPEN, FIRST, SECOND, THIRD, FOURTH, NONE}

## Max available notes in single chord.
const MAX_NOTES: int = 6

@export_category("Chord")
@export var s6: Fret
@export var s5: Fret
@export var s4: Fret
@export var s3: Fret
@export var s2: Fret
@export var s1: Fret

## On accessing return Array of .MP3 files.
var notes: Array[AudioStream]:
	get:
		var result: Array[AudioStream] = []
		for string_num in MAX_NOTES:
			var fret_value = strings[string_num]
			if fret_value == Fret.NONE:
				result.append(null)
				continue
			result.append(get_audio_stream(MAX_NOTES - string_num, fret_value))
		return result

## On accessing return Array of Fret values on strings s6 to s1
var strings: Array[Fret]:
	get:
		return [s6, s5, s4, s3, s2, s1]


## Return .MP3 to corresponding string and fret value.
## Use random value for sound diversity.
func get_audio_stream(guitar_string: int, guitar_fret: int) -> AudioStream:
	var format_path = "res://source/sounds/notes/S%d_F%d_r%d.mp3"
	var path = format_path % [guitar_string, guitar_fret, 0]
	if not ResourceLoader.exists(path): 
		push_error("No audio available on path: %s" % path)
		return
	var audio_stream: AudioStream = load(path)
	return audio_stream

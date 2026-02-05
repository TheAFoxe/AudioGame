extends Resource
class_name LibNote

@export var notes: Array[Note]


func get_audio_stream(guitar_string: int, guitar_fret: int) -> AudioStream:
	var format_path = "res://source/sounds/S%d_F%d_r%d.mp3"
	var path = format_path % [guitar_string, guitar_fret, 0]
	if not ResourceLoader.exists(path): 
		#push_error("No audio available on path: %s" % path)
		printerr("No audio available on path: %s" % path)
	var audio_stream: AudioStream = load(path)
	if audio_stream:
		audio_stream.loop = true
	return audio_stream

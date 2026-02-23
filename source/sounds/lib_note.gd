extends Resource
class_name LibNote


func get_audio_stream(guitar_string: int, guitar_fret: int) -> AudioStream:
	var format_path = "res://source/sounds/notes/S%d_F%d_r%d.mp3"
	var path = format_path % [guitar_string, guitar_fret, 0]
	if not ResourceLoader.exists(path): 
		#push_error("No audio available on path: %s" % path)
		return
	var audio_stream: AudioStream = load(path)
	audio_stream.loop = true
	return audio_stream

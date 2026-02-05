extends AudioStreamPlayer3D
class_name AudioPlayer

@export_category("AudioStream")
@export var audio_max_distance: float
@export var audio_volume: float
@export var audio_max_volume: float
@export var audio_attenuation_model: AudioStreamPlayer3D.AttenuationModel
@export var chord: Chord
var chord_in: Array

func _ready() -> void:
	self.stream = AudioStreamPolyphonic.new()
	self.stream.polyphony = 6
	#chord_in = [chord.s6, chord.s5, chord.s4, chord.s3, chord.s2, chord.s1]
	play_chord()


func play_chord():
	if !self.playing: self.play()
	var audio_streams = chord.make_chord(chord_in)
	var polyphonic_stream_playback := self.get_stream_playback()
	for a in audio_streams:
		polyphonic_stream_playback.play_stream(a)
		await get_tree().create_timer(0.2).timeout

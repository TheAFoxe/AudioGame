class_name AudioPlayer
extends AudioStreamPlayer3D


@export_category("AudioStream")
@export var audio_max_distance: float
@export var audio_volume: float
@export var audio_max_volume: float
@export var audio_attenuation_model: AudioStreamPlayer3D.AttenuationModel

var chord_resource: Chord


func _ready() -> void:
	self.stream = AudioStreamPolyphonic.new()
	self.stream.polyphony = 6


func play_chord(chord: Chord):
	if !self.playing: self.play()
	chord.make_chord()
	var polyphonic_stream_playback := self.get_stream_playback()
	for n in chord.notes:
		polyphonic_stream_playback.play_stream(n)
		await get_tree().create_timer(0.2).timeout
	

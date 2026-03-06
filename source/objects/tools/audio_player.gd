class_name AudioPlayer
extends AudioStreamPlayer3D


const audio_max_distance: float = 3.5
const audio_volume: float = 0.0
const audio_max_volume: float = 0.0
const audio_attenuation_model := AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE


var _chord: Chord


func _ready() -> void:
	ConductorLoopReset._loop_reset.connect(_play)
	var polyphonic_stream := AudioStreamPolyphonic.new()
	polyphonic_stream.polyphony = Chord.MAX_NOTES
	self.max_distance = audio_max_distance
	self.max_db = audio_max_volume
	self.volume_db = audio_volume
	self.stream = polyphonic_stream


func play_chord(chord: Chord) -> void:
	_chord = chord.duplicate()
	return


func _play() -> void:
	if not _chord: return
	self.stop()
	self.play()
	var playback := self.get_stream_playback() as AudioStreamPlaybackPolyphonic
	if not playback:
		return
	for sound in _chord.notes:
		if sound:
			playback.play_stream(sound)
		await get_tree().create_timer(0.1).timeout

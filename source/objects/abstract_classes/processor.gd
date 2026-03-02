@abstract
class_name AudioProcessor
extends AudioRetranslator

var _input_chord: Chord
var _output_chord: Chord

func _ready() -> void:
	_ray_cast = $RayCast
	deactivate(null)
	super()


func receive_chord(new_chord: Chord, emitter: RayCast) -> void:
	if emitter == _ray_cast:
		return
	_input_chord = new_chord.duplicate()
	_output_chord = _process_chord()
	_ray_cast.receive_chord(_output_chord)


@abstract func _process_chord() -> Chord

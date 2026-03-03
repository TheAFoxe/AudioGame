@abstract
class_name AudioProcessor
extends AudioRetranslator

var _input_chord: Chord


func receive_chord(new_chord: Chord, emitter: RayCast) -> void:
	if emitter == _ray_cast:
		return
	_input_chord = new_chord.duplicate()
	_ray_cast.receive_chord(_process_chord())


func _update_chord() -> void:
	_ray_cast.receive_chord(_process_chord())


@abstract func _process_chord() -> Chord

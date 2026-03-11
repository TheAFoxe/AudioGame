@abstract
## Abstract class for objects that needs to manipulate chord state.
class_name AudioProcessor
extends AudioRetranslator

## Chord given on input.
var _input_chord: Chord


## Receives new chord. Save new chord as _input_chord.
## Processes chord and sends it down to RayCast.
func receive_chord(new_chord: Chord, emitter: RayCast) -> void:
	# If sended by own RayCast -> skip
	if emitter == _ray_cast:
		return
	
	_input_chord = new_chord.duplicate()
	_ray_cast.receive_chord(_process_chord())


## Inner call of updating chord. Don't check origin of chord and don't rewrites
## _input_chord. Processes chord and sends down to RayCast
func _update_chord() -> void:
	_ray_cast.receive_chord(_process_chord())


## Abstract function for children implementing.
## Controls how chord should be processed.
@abstract func _process_chord() -> Chord

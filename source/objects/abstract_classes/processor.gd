@abstract
class_name AudioProcessor
extends AudioEmitter


var _input_chord: Chord
var _output_chord: Chord


func receive_chord(new_chord: Chord, emitter: Node3D) -> void:
	if not new_chord:
		push_error("No new_chord on: " + str(emitter))
		return
	_input_chord = new_chord.duplicate()
	_input_chord.notes = new_chord.notes.duplicate()
	_process_chord(emitter)
	super.receive_chord(_output_chord, emitter)


func _process_chord(emitter: Node3D) -> void:
	if not _input_chord: return

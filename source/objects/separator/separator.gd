class_name AudioSeparator
extends AudioProcessor


var _chord_mask: Array[bool] # Masks chord; true/false
var _masked_chord: Chord


func _ready() -> void:
	super()
	var interaction_menu = get_node("InteractionObject").interaction_menu
	interaction_menu.receive_mask.connect(receive_mask)
	for i in 6:
		_chord_mask.append(false)


func receive_mask(mask: Array[bool], emitter: Node3D) -> void:
	_chord_mask = mask
	_process_chord(emitter)


func _process_chord(emitter: Node3D) -> void:
	super._process_chord(emitter)
	var output := _input_chord.duplicate()
	for i in 6:
		if _chord_mask[i]: continue
		output.notes[i] = null
	_output_chord = output
	return

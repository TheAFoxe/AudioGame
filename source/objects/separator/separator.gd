class_name AudioSeparator
extends AudioProcessor


var _chord_mask: Array[bool]


func _ready() -> void:
	super()
	var interaction_menu = get_node("InteractionObject").interaction_menu
	interaction_menu.send_chord_mask.connect(_set_chord_mask)
	for i in Chord.MAX_NOTES:
		_chord_mask.append(false)


func _process_chord() -> Chord:
	var output := _input_chord.duplicate()
	return output
	


func _set_chord_mask(input_mask: Array[bool]) -> void:
	for i in Chord.MAX_NOTES:
		if input_mask[i]:
			_chord_mask[i] = true
			continue
		_chord_mask[i]
	if is_active: 
		_update_chord()


func activate(emitter: RayCast) -> void:
	super.activate(emitter)


func deactivate(emitter: Node3D) -> void:
	super.deactivate(emitter)

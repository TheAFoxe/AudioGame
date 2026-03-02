class_name AudioSeparator
extends AudioProcessor


var _chord_mask: Array[bool]


func _ready() -> void:
	super()
	var interaction_menu = get_node("InteractionObject").interaction_menu
	interaction_menu.send_chord_mask.connect(_set_chord_mask)

	for i in 6:
		_chord_mask.append(null)


func _set_chord_mask(chord_mask) -> void:
	for i in _chord.notes.size():
		if chord_mask[i]: continue
		_chord.notes[i] = null
	print(_chord.notes)


func activate(emitter: RayCast) -> void:
	#_chord = chord
	#_set_chord_mask(_chord_mask)
	super.activate(emitter)


func deactivate(emitter: Node3D) -> void:
	super.deactivate(emitter)

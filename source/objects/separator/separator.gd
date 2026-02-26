class_name AudioSeparator
extends AudioManipulator


var _chord_mask: Array[bool]
var _masked_chord: Chord
var _chord: Chord


func _ready() -> void:
	super()
	var interaction_menu = get_node("InteractionObject").interaction_menu
	interaction_menu.send_chord_mask.connect(set_chord_mask)
	for i in 6:
		_chord_mask.append(false)


func _mask_chord() -> void:
	_masked_chord = _chord.duplicate()
	_masked_chord.make_notes()
	for i in _masked_chord.notes.size():
		if _chord_mask[i]: continue
		_masked_chord.notes[i] = null
	_ray_cast.set_chord(_masked_chord)


func set_chord_mask(chord_mask) -> void:
	_chord_mask = chord_mask
	if _ray_cast.is_active: activate()

func activate() -> void:
	_mask_chord()
	super.activate()


func deactivate(emitter: Node3D) -> void:
	super.deactivate(emitter)


func set_chord(new_chord: Chord) -> void:
	_chord = new_chord
	if _ray_cast.is_active: activate()

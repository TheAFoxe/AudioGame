## Separating notes from _input_chord. Sends new chord.
class_name AudioSeparator
extends AudioProcessor

## Controls which part of chord will be transmitted.
var _chord_mask: Array[bool]


func _ready() -> void:
	super()
	var interaction_menu = get_node("InteractionObject").interaction_menu
	interaction_menu.send_chord_mask.connect(_set_chord_mask)
	for i in Chord.MAX_NOTES:
		_chord_mask.append(false)


## Return new processed Chord based on _chord_mask.
func _process_chord() -> Chord:
	var output := _input_chord.duplicate()
	var notes: Array[AudioStream] = output.notes
	for i in _chord_mask.size():
		if not _chord_mask[i]:
			output.set("s%d" % (Chord.MAX_NOTES - i), Chord.Fret.NONE)
	return output


## Receive _chord_mask from interactive UI.
func _set_chord_mask(input_mask: Array[bool]) -> void:
	_chord_mask = input_mask
	if is_active: 
		_update_chord()

class_name AudioMixer
extends AudioProcessor


const GUITAR_STRINGS: int = 6
const SOURCE_SIZE: int = 2


var _sources: Array[ChordEntry] = [ChordEntry.new(), ChordEntry.new()]


func _process_chord(emitter: Node3D) -> void:
	var free_id = _get_free_source_id()
	if free_id == -1: return
	var free_source = _sources[free_id]
	var occupied_source = _sources[1 - free_id]
	free_source.set_source(emitter, _input_chord, _get_chord_mask(_input_chord))
	if occupied_source.is_empty():
		_output_chord = free_source.chord
		return
	if _check_chord_collision(free_source, occupied_source):
		push_warning("Detected collisions in chords")
		return
	_output_chord = _assemble_chord(free_source, occupied_source)


func _assemble_chord(chord_1: ChordEntry, chord_2: ChordEntry) -> Chord:
	var output := Chord.new()
	for i in GUITAR_STRINGS:
		if chord_1.mask[i]:
			output.notes[i] = chord_1.chord.notes[i]
		else:
			output.notes[i] = chord_2.chord.notes[i]
	return output


func _get_free_source_id() -> int:
	if _sources.size() > SOURCE_SIZE:
		push_error("Length of available sources for mixer > 2, resized")
		_sources.resize(SOURCE_SIZE)
	for i in SOURCE_SIZE:
		if _sources[i].is_empty():
			return i
	return -1


func _check_chord_collision(chord_1: ChordEntry, chord_2: ChordEntry) -> bool:
	for i in GUITAR_STRINGS:
		if chord_1.mask[i] and chord_2.mask[i]:
			return true
	return false


func _get_chord_mask(chord: Chord) -> Array[bool]:
	var mask: Array[bool] = []
	for i in GUITAR_STRINGS:
		mask.append(chord.notes[i] != null)
	return mask

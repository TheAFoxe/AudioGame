class_name ChordEntry
extends Resource

var source: RayCast
var chord: Chord

func set_entry(new_source: RayCast, new_chord: Chord) -> void:
	source = new_source
	chord = new_chord

class_name ChordEntry
extends Resource

var node: Node3D
var chord: Chord
var mask: Array[bool]


func _init() -> void:
	node = null
	chord = null
	for i in 6:
		mask.append(false)

func set_source(set_node: Node3D, set_chord: Chord, set_mask: Array[bool]) -> void:
	node = set_node
	chord = set_chord
	mask = set_mask


func is_empty() -> bool:
	return node == null

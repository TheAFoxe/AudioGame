## Catches audio signal. Checks if audio signal corresponding to inner Chord
## value. Emits signal on (de)activation.
class_name AudioCatcher
extends Node3D

## Emits on activation.
signal activated
## Emits on deactivation.
signal deactivated

## Inner chord value. Controls on what Chord value needs to activate.
@export var _chord: Chord
## Saves RayCast that activated it. Prevents deactivating with other RayCast.
var _activated_by: RayCast
## Controls inner active state. Prevents activating with other RayCast.
var _is_active: bool
## Mesh showing _is_active state of object.
var _activation_mesh: MeshInstance3D

var _billboard: Label3D


func _ready() -> void:
	_activation_mesh = get_node("ActivationMesh")
	_activation_mesh.hide()
	_billboard = get_node("Label3D")
	_billboard.text = build_chord_display()

## Activates catcher. Checks emitter and inner Chord value.
## Emits activated signal on activation.
func activate(emitter: RayCast, chord: Chord) -> bool:
	if _is_active:
		return false
	if not _chord.strings == chord.strings:
		return false
	
	_is_active = true
	_activated_by = emitter
	_activation_mesh.show()
	activated.emit()
	return true


## Deactivates catcher. Checks emitter. Emits deactivated signal on deactivation.
func deactivate(emitter: Node3D) -> void:
	if _activated_by != emitter: return
	_is_active = false
	deactivated.emit()
	_activation_mesh.hide()


func build_chord_display() -> String:
	var lines: Array[String] = []
	for i in Chord.MAX_NOTES:
		var fret: Chord.Fret = _chord.strings[i]
		var fret_name: String
		if fret == 5:
			fret_name = "X"
		else:
			fret_name = str(fret)
		lines.append("s%d: %s" % [i + 1, fret_name])
	return "\n".join(lines)

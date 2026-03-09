class_name AudioCatcher
extends PickableObject

@export var _chord: Chord

var _activated_by: RayCast
var _is_active: bool

var _outter: MeshInstance3D

var _activation_mesh: MeshInstance3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	super()
	global_position.y = 1
	_activation_mesh = get_node("ActivationMesh")
	_activation_mesh.hide()
	_outter = get_node("OuterSphere")


func activate(emitter: RayCast, chord: Chord) -> bool:
	if _is_active: return false
	if not _chord.strings == chord.strings:
		return false
	print(chord.strings)
	_is_active = true
	_activated_by = emitter
	_activation_mesh.show()
	return true


func deactivate(emitter: Node3D) -> void:
	if _activated_by != emitter: return
	print("deactivated")
	_is_active = false
	_activation_mesh.hide()

class_name AudioCatcher
extends PickableObject

var _activated_by: RayCast
var _is_active: bool

var _activation_sphere: MeshInstance3D
var _outter: MeshInstance3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	super()
	global_position.y = 1
	_activation_sphere = get_node("ActivationSphere")
	_outter = get_node("OuterSphere")


func activate(emitter: Node3D) -> void:
	if _is_active: return
	_is_active = true
	_activated_by = emitter
	_activation_sphere.mesh.material.albedo_color = Color.RED


func deactivate(emitter: Node3D) -> void:
	if _activated_by != emitter: return
	_is_active = false
	_activation_sphere.mesh.material.albedo_color = Color.BLACK

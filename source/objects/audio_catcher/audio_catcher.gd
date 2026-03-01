class_name AudioCatcher
extends PickableObject

signal catched_chord
signal lost_chord

var _mat = StandardMaterial3D.new()

@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	super()
	global_position.y = 1
	mesh.material_override = _mat


func activate() -> void:
	_mat.albedo_color = Color.RED


func deactivate() -> void:
	_mat.albedo_color = Color.WHITE

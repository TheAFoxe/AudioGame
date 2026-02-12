extends PickableObject
class_name AudioCatcher

var mat = StandardMaterial3D.new()


@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	super()
	global_position.y = 1
	mesh.material_override = mat

func activate() -> void:
	mat.albedo_color = Color.RED


func deactivate() -> void:
	mat.albedo_color = Color.WHITE

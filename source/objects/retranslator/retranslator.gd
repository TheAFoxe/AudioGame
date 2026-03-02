class_name AudioRetranslator
extends PickableObject

var _ray_cast: RayCast
var is_active: bool


func _ready() -> void:
	_ray_cast = get_node("RayCast")
	super()


func activate(emitter: RayCast) -> void:
	is_active = true
	_ray_cast.activate(emitter)


func deactivate(emitter: RayCast) -> void:
	is_active = false
	_ray_cast.deactivate(emitter)

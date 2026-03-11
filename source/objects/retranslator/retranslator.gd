## Breaks RayCast. Re-emits RayCast in new direction with same chord value.
class_name AudioRetranslator
extends PickableObject

## Self RayCast node
var _ray_cast: RayCast
## Inner active state.
var is_active: bool
## Saves by which RayCast was activated.
var activated_by: RayCast
## Mesh appeard on activation.
var _activation_mesh: MeshInstance3D


func _ready() -> void:
	_ray_cast = get_node("RayCast")
	_ray_cast.self_area_ray = get_node("AreaRay").get_rid()
	_activation_mesh = get_node("ActivationMesh")
	if _activation_mesh:
		_activation_mesh.hide()
	super()


## Makes AudioRetranslator active. Starts emitting RayCast.
func activate(emitter: RayCast) -> bool:
	if is_active:
		return false
	activated_by = emitter
	is_active = true
	_ray_cast.activate()
	if _activation_mesh:
		_activation_mesh.show()
	return true


## Makes AudioRetranslator inactive. Stops emitting RayCast.
func deactivate(emitter: RayCast) -> void:
	if activated_by != emitter:
		return
	activated_by = null
	is_active = false
	_ray_cast.deactivate()
	if _activation_mesh:
		_activation_mesh.hide()


## Receive new chord for casting.
func receive_chord(new_chord: Chord, emitter: RayCast) -> void:
	# Checks if not activated by own RayCast
	if emitter == _ray_cast: return
	# If active, checks if not received again from previously activated.
	elif is_active:
		if emitter != activated_by: return
	_ray_cast.receive_chord(new_chord)

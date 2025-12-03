extends Node3D

class_name AudioCast

@export var ray_length := 1000.0

var frame_count
var _result
var debug_line: ImmediateMesh
var _debug_line: MeshInstance3D
var debug_array: PackedVector3Array



@onready var root := $".."

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	cast()


func cast() -> void:
	debug_array.clear()
	var space_state := get_world_3d().direct_space_state
	var origin := self.global_position
	var end := (self.global_position + ray_length * Vector3.FORWARD).rotated(Vector3.UP, root.rotation.y)
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	query.collision_mask = 0x00001001
	var result := space_state.intersect_ray(query)
	
	if result:
		var direction = (result.position - origin).normalized()
		reflect(space_state, query, result, direction)
	
	#DEBUG
	if not result:
		debug_array.append(end)
	debug_array.append(origin)
	draw_debug()


func reflect(space_state, query, result, direction) -> void:
	query.from = result.position
	query.to = direction.bounce(result.normal) * ray_length + result.position
	result = space_state.intersect_ray(query)
	
	if result:
		reflect(space_state, query, result, direction)
	
	debug_array.append(query.to)
	debug_array.append(query.from)


func draw_debug():
	
	if _debug_line:
		_debug_line.queue_free()
	_debug_line = MeshInstance3D.new()
	debug_line = ImmediateMesh.new()
	
	
	for i in debug_array.size() - 1:
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color(1, 0, 0)
		debug_line.surface_begin(Mesh.PRIMITIVE_LINES, material)
		debug_line.surface_add_vertex(to_local(debug_array.get(i)))
		debug_line.surface_add_vertex(to_local(debug_array.get(i + 1)))
		debug_line.surface_end()
	_debug_line.mesh = debug_line
	add_child(_debug_line)

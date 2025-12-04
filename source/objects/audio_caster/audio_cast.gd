extends Node3D

class_name AudioCast

@export var ray_length := 1000.0
@export var max_bounces := 10
@export_flags_3d_physics var collision_mask: int


var debug_line: ImmediateMesh
var instance: MeshInstance3D

@onready var root := $".."
@onready var sphere := $"../DebugSphere"


func _ready() -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color.RED
	
	debug_line = ImmediateMesh.new()
	instance = MeshInstance3D.new()
	instance.material_override = mat
	instance.mesh = debug_line

	add_child(instance)


func _physics_process(delta: float) -> void:
	debug_line.clear_surfaces()
	cast()


func cast() -> void:
	debug_line.surface_begin(Mesh.PRIMITIVE_LINES)
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, collision_mask)
	var direction := Vector3.FORWARD.rotated(Vector3.UP, root.rotation.y)
	query.from = global_position
	query.to = query.from + direction * ray_length
	query.collide_with_areas = true
	var result := space_state.intersect_ray(query)
	
	for i in max_bounces:
		if not result: draw_debug(query.from, query.to); break
		if i == max_bounces: draw_debug(query.from, result.position); break
		draw_debug(query.from, result.position)
		
		if result.collider is Area3D:
			sound(query.from, query.to, result.collider.global_position, direction)
			query.from = result.position + direction * 0.1
			result = space_state.intersect_ray(query)
			if not result: draw_debug(query.from, query.to); break
			draw_debug(query.from, result.position)
		
		
		
		query.from = result.position
		direction = direction.bounce(result.normal)
		query.to = query.from + direction * ray_length
		result = space_state.intersect_ray(query)
	
	debug_line.surface_end()


func draw_debug(from, to) -> void:
	debug_line.surface_add_vertex(to_local(from))
	debug_line.surface_add_vertex(to_local(to))


func sound(line_start : Vector3, line_end : Vector3, point_position : Vector3, direction : Vector3):
	var line_direction := (line_start - line_end).normalized()
	var vector_to_object := point_position - line_start
	var distance := line_direction.dot(vector_to_object)
	var closest_position := line_start + distance * line_direction
	sphere.global_position = closest_position + direction.rotated(Vector3.UP, PI) * 2

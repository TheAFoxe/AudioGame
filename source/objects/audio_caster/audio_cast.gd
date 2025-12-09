extends Node3D

class_name AudioCast

@export var ray_length := 1000.0
@export var max_bounces := 10
@export_flags_3d_physics var collision_mask: int


var debug_line: ImmediateMesh
var instance: MeshInstance3D

var sphere_array: Array

@onready var root := $".."


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
	var direction := -global_transform.basis.z
	
	var query := PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, collision_mask)
	var current_start := global_position
	query.collide_with_areas = true
	query.hit_from_inside = true
	
	#var result := space_state.intersect_ray(query)
	
	for i in max_bounces + 1:
		query.from = current_start
		query.to = direction * ray_length
		
		var result := space_state.intersect_ray(query)
		
		if not result:
			draw_debug(query.from, query.to)
			break
		
		if result.collider is Area3D:
			sound(query.from, result.position, result.collider.global_position)
			query.exclude = result.rid
			continue
		
		direction = direction.bounce(result.normal)
		query.exclude = []
		current_start = result.position + (result.normal * 0.01)
	
	debug_line.surface_end()
	
	#for i in max_bounces + 1:
		#if not result: draw_debug(query.from, query.to); break
		#draw_debug(query.from, result.position)
		#
		#if result.collider is Area3D:
			#var player_position = result.collider.global_position
			#query.collide_with_areas = false
			#query.hit_from_inside = false
			#result = space_state.intersect_ray(query)
			#if not result:
				#draw_debug(query.from, query.to)
				#sound(query.from, query.to, player_position)
				#break
			#query.hit_from_inside = true
			#query.collide_with_areas = true
			#sound(query.from, result.position, player_position)
			#draw_debug(query.from, result.position)
		#
		#
		#
		#query.from = result.position
		#direction = direction.bounce(result.normal)
		#query.to = query.from + direction * ray_length
		#result = space_state.intersect_ray(query)
	
	debug_line.surface_end()


func draw_debug(from, to) -> void:
	debug_line.surface_add_vertex(to_local(from))
	debug_line.surface_add_vertex(to_local(to))


func sound(line_start : Vector3, line_end : Vector3, point_position : Vector3):
	var sphere = MeshInstance3D.new()
	sphere.mesh = SphereMesh.new()
	var line_direction := (line_start - line_end).normalized()
	var vector_to_object := point_position - line_start
	var distance := line_direction.dot(vector_to_object)
	var closest_position := line_start + distance * line_direction
	add_child(sphere)
	sphere.global_position = closest_position + line_direction
	sphere.global_position = clamp(sphere.global_position, Vector3(line_end), Vector3(line_start))
	sphere_array.append(sphere)
	

extends Node3D

class_name AudioCast

@export var ray_length := 20.0
@export var max_bounces := 10
@export var audio_streamer_amount := max_bounces
var audio_streamer_array := []
var audio_streamer: MeshInstance3D

@export var audio: AudioStream
@export_flags_3d_physics var collision_mask: int


var debug_line: ImmediateMesh
var instance: MeshInstance3D

var sphere_array: Array

@onready var root := $".."


func _ready() -> void:
	var position = 1
	for i in audio_streamer_amount:
		audio_streamer = MeshInstance3D.new()
		audio_streamer.mesh = SphereMesh.new()
		audio_streamer.mesh.radius = .1
		audio_streamer.mesh.height = .2
		add_child(audio_streamer)
		#audio_streamer.autoplay = true
		#audio_streamer.au
		audio_streamer.position.y = position
		position += 1
		audio_streamer_array.append(audio_streamer)
	
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
	for i in audio_streamer_array:
		i.hide()
	cast()


func cast() -> void:
	var player_hit_count: int = 0
	var player_hit: bool
	var player_position: Vector3
	debug_line.surface_begin(Mesh.PRIMITIVE_LINES)
	
	var space_state := get_world_3d().direct_space_state
	var direction := -global_transform.basis.z
	
	var query := PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, collision_mask)
	var current_start := global_position + Vector3(0, 1.25, 0)
	query.collide_with_areas = true
	query.hit_from_inside = true
	
	for i in max_bounces + 1:
		query.from = current_start
		query.to = query.from + direction * ray_length
		
		var result := space_state.intersect_ray(query)
		
		if player_hit:
			if not result:
				sound(query.from, query.to, player_position, player_hit_count)
			else:
				sound(query.from, result.position, player_position, player_hit_count)
			player_hit_count += 1
			player_hit = false
		
		if not result:
			draw_debug(query.from, query.to)
			break
		
		if result.collider is Area3D:
			player_hit = true
			player_position = result.collider.global_position
			query.exclude = [result.rid]
			continue
		
		
		query.exclude = []
		draw_debug(query.from, result.position)
		direction = direction.bounce(result.normal)
		current_start = result.position + (result.normal * 0.005)
	
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


func draw_debug(from, to) -> void:
	debug_line.surface_add_vertex(to_local(from))
	debug_line.surface_add_vertex(to_local(to))


func sound(line_start : Vector3, line_end : Vector3, point_position : Vector3, id : int):
	var line_direction := (line_start - line_end).normalized()
	var vector_to_object := point_position - line_start
	var distance := line_direction.dot(vector_to_object)
	var closest_position := line_start + distance * line_direction + line_direction
	audio_streamer = audio_streamer_array.get(id)
	audio_streamer.global_position = clamp(closest_position, line_end, line_start)
	audio_streamer.show()

extends Node3D

class_name AudioCast


var audio_debug_array := []
var audio_debug: MeshInstance3D
var audio_streamer_array := []


@export var debug: bool

@export_category("AudioStream")
@export var audio: AudioStream
@export var audio_max_distance: float
@export var audio_volume: float
@export var audio_max_volume: float
@export var audio_attenuation_model: AudioStreamPlayer3D.AttenuationModel

@export_category("RayQuery")
@export var ray_length := 20.0
@export var max_bounces := 5
@export_flags_3d_physics var collision_mask: int

var debug_line: ImmediateMesh
var instance: MeshInstance3D
var _active_audio_players: Array[int]

@onready var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, collision_mask)
@onready var root := $".."


func _ready() -> void:
	max_bounces += 1
	
	for i in max_bounces:
		audio_debug = MeshInstance3D.new()
		audio_debug.mesh = SphereMesh.new()
		audio_debug.mesh.radius = 0.1
		audio_debug.mesh.height = 0.2
		add_child(audio_debug)
		audio_debug.position.y = i + 0.2
		audio_debug_array.append(audio_debug)
	
	for i in max_bounces:
		var audio_stream = AudioStreamPlayer3D.new()
		add_child(audio_stream)
		audio_stream.stream = audio
		audio_stream.attenuation_model = audio_attenuation_model
		audio_stream.max_distance = audio_max_distance
		audio_stream.playing = true
		audio_stream.stream.loop = true
		audio_stream.stream_paused = true
		audio_stream.max_db = audio_max_volume
		audio_stream.volume_db = audio_volume
		audio_streamer_array.append(audio_stream)
	
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
	_active_audio_players.clear()
	for i in audio_debug_array:
		i.hide()
	cast()
	for i in _active_audio_players:
		audio_streamer_array.get(i).stream_paused = true


func cast() -> void:
	var player_hit_count: int = 0
	var player_hit: bool = false
	var player_position: Vector3
	
	var space_state := get_world_3d().direct_space_state
	var direction := -global_transform.basis.z
	var current_start := global_position + Vector3(0, 1.25, 0)
	
	query.exclude = []
	query.collide_with_areas = true
	query.hit_from_inside = true
	
	debug_line.surface_begin(Mesh.PRIMITIVE_LINES)
	var result: Dictionary
	
	for i in max_bounces:
		query.from = current_start
		query.to = query.from + direction * ray_length
		
		result = space_state.intersect_ray(query)
		
		if player_hit:
			if not result:
				sound(query.from, query.to, player_position, player_hit_count, direction)
			else:
				sound(query.from, result.position, player_position, player_hit_count, direction)
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
		
		draw_debug(query.from, result.position)
		
		query.exclude = []
		direction = direction.bounce(result.normal)
		current_start = result.position + (result.normal * 0.005)
	
	debug_line.surface_end()


func draw_debug(from, to) -> void:
	if not debug: return
	debug_line.surface_add_vertex(to_local(from))
	debug_line.surface_add_vertex(to_local(to))


func sound(line_start : Vector3, line_end : Vector3, point_position : Vector3, id : int, direction : Vector3):
	var audio_stream: AudioStreamPlayer3D = audio_streamer_array.get(id)
	
	var closest_position := Geometry3D.get_closest_point_to_segment(point_position - direction, line_start, line_end)
	audio_stream.global_position = closest_position
	_active_audio_players.append(id)
	
	if debug:
		audio_debug = audio_debug_array.get(id)
		audio_debug.global_position = audio_stream.global_position
		audio_debug.show()

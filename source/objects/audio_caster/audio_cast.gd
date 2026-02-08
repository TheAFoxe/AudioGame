extends PickableObject
class_name AudioCast

# Constants
const RAY_OFFSET_FROM_SURFACE: float = 0.005
const INACTIVE_AUDIO_HEIGHT: int = 50
const AUDIO_PLAYER_OFFSET: float = 1.0

# Exported values
@export var debug: bool

@export_category("Chord")
@export var chord_resource: Chord

@export_category("AudioStream")
@export var audio_max_distance: float
@export var audio_volume: float
@export var audio_max_volume: float
@export var audio_attenuation_model: AudioStreamPlayer3D.AttenuationModel

@export_category("RayQuery")
@export var ray_length: float
@export var max_bounces: int
@export_flags_3d_physics var collision_mask: int

# Public variables
var current_hit: Node3D
var chord: Array

# Private variables
var _debug_line_mesh: ImmediateMesh
var _debug_mesh_instance: MeshInstance3D
var _active_audio_player_indices: Array[int] = []
var _audio_debug_spheres: Array[MeshInstance3D] = []
var _audio_streamers: Array[AudioStreamPlayer3D] = []
var audio_debug: MeshInstance3D
var last_hit: Node3D
var _polyphonic_stream: AudioStreamPolyphonic

var _current_ray_hit_path: Array[Node3D] = []
var _last_ray_hit_path: Array[Node3D] = []

# Onready variables
@onready var _ray_query: PhysicsRayQueryParameters3D = (
	PhysicsRayQueryParameters3D.create(
		Vector3.ZERO,
		Vector3.ZERO,
		collision_mask
	)
)
@onready var _sound_timer: Timer = $Timer
@onready var _audio_caster: Marker3D = $AudioCast


func _ready() -> void:
	super()
	
	can_move = false
	global_position.y = 1
	player_camera_marker = $PlayerCameraMarker
	
	_current_ray_hit_path.resize(max_bounces)
	_last_ray_hit_path.resize(max_bounces)
	_current_ray_hit_path.fill(null)
	_last_ray_hit_path.fill(null)
	
	chord = [
		chord_resource.s6,
		chord_resource.s5,
		chord_resource.s4,
		chord_resource.s3,
		chord_resource.s2,
		chord_resource.s1
	]
	
	_sound_timer.one_shot = false
	_sound_timer.start()
	
	for i in max_bounces:
		_current_ray_hit_path.append(null)
		_last_ray_hit_path.append(null)
	
	chord = [chord_resource.s6, chord_resource.s5, chord_resource.s4, chord_resource.s3, chord_resource.s2, chord_resource.s1]
	
	_create_debug_visualization()
	_create_audio_players()


func _physics_process(delta: float) -> void:
	_debug_line_mesh.clear_surfaces()
	_active_audio_player_indices.clear()
	
	for i in _audio_debug_spheres:
		i.hide()
	
	cast()
	
	for i in _audio_streamers.size():
		if i not in _active_audio_player_indices:
			_audio_streamers.get(i).global_position = Vector3(0, INACTIVE_AUDIO_HEIGHT, 0)


func cast() -> void:
	var player_hitted: bool = false 
	var current_bounce: int = 0
	var result: Dictionary
	var space_state := get_world_3d().direct_space_state
	var direction := -global_transform.basis.z
	var current_start := global_position
	
	_current_ray_hit_path.fill(null)
	
	_ray_query.exclude = []
	_ray_query.collide_with_areas = true
	_ray_query.hit_from_inside = true
	
	if debug:
		_debug_line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	while current_bounce < max_bounces:
		var previous_hit_at_index: Node3D = _last_ray_hit_path[current_bounce]
		
		_ray_query.from = current_start
		_ray_query.to = _ray_query.from + direction * ray_length
		result = space_state.intersect_ray(_ray_query)
		
		if player_hitted:
			_place_audio_at_player(
				_ray_query.from,
				result.position if result else _ray_query.to,
				current_hit.position,
				current_bounce,
				direction
				)
			player_hitted = false
		
		if not result:
			_draw_debug_line(_ray_query.from, _ray_query.to)
			current_hit = null
			_current_ray_hit_path[current_bounce] = current_hit

			if previous_hit_at_index is AudioCatcher:
				previous_hit_at_index.deactivate()
			break
		
		var collider = result.collider
		current_hit = collider.owner if collider.owner else collider
		
		if current_hit is Player:
			_ray_query.exclude = [result.rid]
			player_hitted = true
			continue
		
		_current_ray_hit_path[current_bounce] = current_hit
		
		if current_hit != previous_hit_at_index:
			_update_audio_catcher_state(current_hit, previous_hit_at_index)
		
		if current_hit is AudioCatcher:
			_draw_debug_line(_ray_query.from, result.position)
			break
		
		_draw_debug_line(_ray_query.from, result.position)
		_ray_query.exclude = []
		direction = direction.bounce(result.normal)
		current_start = result.position + (result.normal * RAY_OFFSET_FROM_SURFACE)
		current_bounce += 1
	
	_last_ray_hit_path = _current_ray_hit_path.duplicate()
	
	if debug: _debug_line_mesh.surface_end()


func _create_debug_visualization() -> void:
	for i in max_bounces:
		var sphere := MeshInstance3D.new()
		sphere.mesh = SphereMesh.new()
		sphere.mesh.radius = 0.1
		sphere.mesh.height = 0.2
		add_child(sphere)
		_audio_debug_spheres.append(sphere)
		
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color.RED
	
	_debug_line_mesh = ImmediateMesh.new()
	_debug_mesh_instance = MeshInstance3D.new()
	_debug_mesh_instance.material_override = mat
	_debug_mesh_instance.mesh = _debug_line_mesh
	add_child(_debug_mesh_instance)


func _create_audio_players() -> void:
	for i in max_bounces:
		var audio_stream = AudioPlayer.new()
		audio_stream.stream = _polyphonic_stream
		audio_stream.chord = chord_resource
		audio_stream.max_distance = audio_max_distance
		audio_stream.max_db = audio_max_volume
		audio_stream.volume_db = audio_volume
		add_child(audio_stream)
		_audio_streamers.append(audio_stream)


func _update_audio_catcher_state(new_hit: Node3D, previous_hit: Node3D) -> void:
		if new_hit is AudioCatcher:
			new_hit.activate()
		if previous_hit is AudioCatcher:
			previous_hit.deactivate()


func _place_audio_at_player(line_start: Vector3, line_end: Vector3, player_position: Vector3, audio_id: int, ray_direction: Vector3) -> void:
	if audio_id >= _audio_streamers.size():
		push_warning(
			"Audio player ID %d exceeds array size %d" % [
				audio_id,
				_audio_streamers.size()
				]
			)
		return
	
	var audio_player: AudioStreamPlayer3D = _audio_streamers[audio_id]

	var closest_position := Geometry3D.get_closest_point_to_segment(
		player_position - ray_direction * AUDIO_PLAYER_OFFSET,
		line_start,
		line_end
		)
	audio_player.global_position = closest_position

	_active_audio_player_indices.append(audio_id)

	if debug:
		var debug_sphere := _audio_debug_spheres[audio_id]
		debug_sphere.global_position = audio_player.global_position
		debug_sphere.show()


func _draw_debug_line(from: Vector3, to: Vector3) -> void:
	if not debug: return
	_debug_line_mesh.surface_add_vertex(to_local(from))
	_debug_line_mesh.surface_add_vertex(to_local(to))

extends Node3D
class_name RayCast

enum RaycastStatus { BREAK, SKIP }

const RAY_OFFSET_FROM_SURFACE: float = 0.005
const AUDIO_PLAYER_OFFST_FROM_PLAYER: float = 1.0
const INACTIVE_AUDIO_PLAYER_POSITION: Vector3 = Vector3(0, 50, 0)

# Exported values
@export var debug: bool

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
var chord: Chord

# Private variables
var _is_active: bool = false

var _debug_line_mesh: ImmediateMesh
var _debug_mesh_instance: MeshInstance3D

var _audio_debug_spheres: Array[MeshInstance3D] = []
var _audio_streamers: Array[AudioStreamPlayer3D] = []
var _polyphonic_stream: AudioStreamPolyphonic
var _active_audio_streams: Array[AudioStreamPlayer3D] = []

var _ray_query: PhysicsRayQueryParameters3D
var _current_ray_hit_path: Array[Node3D]
var _previous_ray_hit_path: Array[Node3D]

func _ready() -> void:
	_create_ray_query()
	_create_audio_players()
	_create_debug_visualisation()


func _physics_process(delta: float) -> void:
	if not _is_active:
		_debug_line_mesh.clear_surfaces()
		return
	_debug_line_mesh.clear_surfaces()
	_active_audio_streams.fill(null)

	for i in _audio_debug_spheres:
		i.hide()

	_cast_ray()
	for i in _audio_streamers:
		if i not in _active_audio_streams:
			i.global_position = INACTIVE_AUDIO_PLAYER_POSITION


func _cast_ray() -> void:
	var current_bounce: int = 0
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var direction: Vector3 = -global_transform.basis.z
	var current_start: Vector3 = global_position
	var current_hit: Node3D = null
	var previous_hit: Node3D = null
	
	_current_ray_hit_path.fill(null)
	
	_ray_query.exclude = []
	 
	if debug: _debug_line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)

	while current_bounce < max_bounces:
		var result: Dictionary = _raycast_ignoring_player(current_start, direction, current_bounce, space_state)
		if not result:
			_draw_debug_line(_ray_query.from, _ray_query.to)
			_clean_remaining_path(current_bounce, null)
			break
		current_hit = _get_hit_owner(result)
		previous_hit = _previous_ray_hit_path[current_bounce]
		_current_ray_hit_path[current_bounce] = current_hit
		_draw_debug_line(_ray_query.from, result.position)
		match _handle_ray_hit(current_hit, previous_hit):
			RaycastStatus.BREAK:
				_clean_remaining_path(current_bounce, current_hit)
				break
			RaycastStatus.SKIP:
				pass
		_ray_query.exclude = []
		direction = direction.bounce(result.normal)
		current_start = result.position + result.normal * RAY_OFFSET_FROM_SURFACE
		current_bounce += 1
	_previous_ray_hit_path = _current_ray_hit_path.duplicate()
	if debug: _debug_line_mesh.surface_end()


func _handle_path_change(current_hit: Node3D, previous_hit: Node3D) -> void:
	if previous_hit is AudioCatcher:
		previous_hit.deactivate()
	elif previous_hit is Manipulator:
		previous_hit.deactivate(self)
	if current_hit is AudioCatcher:
		current_hit.activate()
	elif current_hit is Manipulator:
		current_hit.activate(chord)


func _handle_ray_hit(current_hit: Node3D, previous_hit: Node3D) -> RaycastStatus:
	if current_hit != previous_hit:
		_handle_path_change(current_hit, previous_hit)
	if current_hit is AudioReflector:
		return RaycastStatus.SKIP
#	if current_hit is AudioCatcher:
#		return RaycastStatus.BREAK
#	elif current_hit is Manipulator:
#		return RaycastStatus.BREAK
	return RaycastStatus.BREAK


func _clean_remaining_path(id: int, current_hit: Node3D) -> void:
	for i in range(id, max_bounces):
		var previous_hit = _previous_ray_hit_path[i]
		if previous_hit == null: continue
		elif current_hit is AudioCatcher: continue
		elif current_hit is Manipulator: continue
		elif previous_hit is AudioCatcher: previous_hit.deactivate()
		elif previous_hit is Manipulator: previous_hit.deactivate(self)


func _raycast_ignoring_player(from: Vector3, dir: Vector3, current_bounce: int,space_state: PhysicsDirectSpaceState3D) -> Dictionary:
	_ray_query.from = from
	_ray_query.to = from + dir * ray_length
	var result = space_state.intersect_ray(_ray_query)
	if result and _get_hit_owner(result) is Player:
		_on_player_hit(from, result.position, _get_hit_owner(result).global_position, current_bounce)
		_ray_query.exclude = [result.rid]
		result = space_state.intersect_ray(_ray_query)
	return result


func _get_hit_owner(result: Dictionary) -> Node3D:
	return result.collider.owner if result.collider.owner else result.collider


func _on_player_hit(from, to, player_position, id) -> void:
	if id >= _audio_streamers.size():
		push_warning("Max_bounces is greater then available of _audio_streamers")
		return
	var audio_stream = _audio_streamers[id]
	var closest_position = Geometry3D.get_closest_point_to_segment(
		player_position,
		from,
		to
		)
	audio_stream.global_position = closest_position
	
	_active_audio_streams[id] = audio_stream
	if debug:
		_audio_debug_spheres[id].global_position = closest_position
		_audio_debug_spheres[id].show()


func _draw_debug_line(from: Vector3, to: Vector3) -> void:
	if not debug: return
	_debug_line_mesh.surface_add_vertex(to_local(from))
	_debug_line_mesh.surface_add_vertex(to_local(to))


func _create_debug_visualisation() -> void:
	for i in max_bounces:
		var sphere := MeshInstance3D.new()
		sphere.mesh = SphereMesh.new()
		sphere.mesh.radius = 0.1
		sphere.mesh.height = 0.2
		add_child(sphere)
		_audio_debug_spheres.append(sphere)
	
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color.RED
	
	_debug_line_mesh = ImmediateMesh.new()
	_debug_mesh_instance = MeshInstance3D.new()
	_debug_mesh_instance.material_override = mat
	_debug_mesh_instance.mesh = _debug_line_mesh
	add_child(_debug_mesh_instance)


func _create_audio_players() -> void:
	_polyphonic_stream = AudioStreamPolyphonic.new()
	_polyphonic_stream.polyphony = 6
	for i in max_bounces:
		var audio_stream = AudioPlayer.new()
		audio_stream.stream = _polyphonic_stream
		audio_stream.max_distance = audio_max_distance
		audio_stream.max_db = audio_max_volume
		audio_stream.volume_db = audio_volume
		add_child(audio_stream)
		_audio_streamers.append(audio_stream)
		_active_audio_streams.append(null)


func _create_ray_query() -> void:
	_ray_query = PhysicsRayQueryParameters3D.create(
		Vector3.ZERO,
		Vector3.ZERO,
		collision_mask
		)
	
	_ray_query.collide_with_bodies = true
	_ray_query.collide_with_areas = true
	
	_current_ray_hit_path.resize(max_bounces)
	_previous_ray_hit_path = _current_ray_hit_path.duplicate()


func deactivate(emitter: Node3D) -> void:
	if emitter == self: return
	for i in _audio_streamers:
		i.global_position = INACTIVE_AUDIO_PLAYER_POSITION
	_is_active = false


func activate(chord_resource: Chord) -> void:
	for i in _audio_streamers:
		i.chord = chord_resource
	chord = chord_resource
	_is_active = true

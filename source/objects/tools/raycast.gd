class_name RayCast
extends Node3D

enum RaycastStatus { BREAK, SKIP }

const RAY_OFFSET_FROM_SURFACE: float = 0.005
const AUDIO_PLAYER_OFFSET_FROM_PLAYER: float = 1.0
const INACTIVE_AUDIO_PLAYER_POSITION: Vector3 = Vector3(0, 50, 0)

# Exported values
@export var debug: bool = true

@export_category("AudioStream")
@export var audio_max_distance: float
@export var audio_volume: float
@export var audio_max_volume: float
@export var audio_attenuation_model: AudioStreamPlayer3D.AttenuationModel

@export_category("RayQuery")
@export var ray_length: float = 50
@export var max_bounces: int = 10
@export_flags_3d_physics var collision_mask: int = 512

# Public variables
var self_area_ray: RID

# Private variables
var _is_active: bool = false
var _is_active_last_frame: bool = false

var _debug_line_mesh: ImmediateMesh
var _debug_mesh_instance: MeshInstance3D

var _audio_debug_spheres: Array[MeshInstance3D] = []
var _audio_streamers: Array[AudioStreamPlayer3D] = []
var _active_audio_streams: Array[AudioStreamPlayer3D] = []
var _chord: Chord
var _pending_chord: Chord
var _reactivate: bool

var _ray_query: PhysicsRayQueryParameters3D
var _previous_activation: Node3D

func _ready() -> void:
	ConductorLoopReset._loop_reset.connect(_on_conductor_loop_reset)
	_create_ray_query()
	_create_audio_players()
	_create_debug_visualisation()


func _physics_process(delta: float) -> void:
	if not _is_active:
		#if not _is_active_last_frame: return
		_clear()
		return
	if not _is_active_last_frame:
		_is_active_last_frame = true
	
	_debug_line_mesh.clear_surfaces()
	_active_audio_streams.fill(null)
	
	for i in _audio_debug_spheres:
		i.hide()
	
	_cast_ray()
	for i in _audio_streamers:
		if i not in _active_audio_streams:
			i.global_position = INACTIVE_AUDIO_PLAYER_POSITION


func _clear() -> void:
	_is_active_last_frame = false
	_debug_line_mesh.clear_surfaces()
	if _previous_activation:
		_previous_activation.deactivate(self)
		_previous_activation = null


func _cast_ray() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var direction: Vector3 = -global_transform.basis.z
	var current_start: Vector3 = global_position
	var new_activation: Node3D = null
	
	_ray_query.exclude = [self_area_ray]
	 
	if debug: _debug_line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	for bounce_id in max_bounces:
		_ray_query.from = current_start
		_ray_query.to = current_start + direction * ray_length
		var result: Dictionary = _raycast_ignoring_player(bounce_id, space_state, direction)
		
		if not result:
			_draw_debug_line(_ray_query.from, _ray_query.to)
			break
		
		_draw_debug_line(_ray_query.from, result.position)
		var current_hit: Node3D = _get_hit_owner(result)
		
		if not current_hit is AudioReflector:
			if current_hit is AudioBreaker:
				break
			new_activation = current_hit
			break
		
		_ray_query.exclude = [self_area_ray]
		direction = direction.bounce(result.normal)
		current_start = result.position + direction * RAY_OFFSET_FROM_SURFACE
	
	if new_activation != _previous_activation or _reactivate:
		if _previous_activation:
			_previous_activation.deactivate(self)
		if new_activation:
			if _on_ray_hit(new_activation):
				print(true)
				_previous_activation = new_activation
			else:
				_previous_activation = null
		else:
			_previous_activation = null
		#_previous_activation = new_activation
		_reactivate = false
	
	if debug: _debug_line_mesh.surface_end()


func _on_ray_hit(current_hit: Node3D) -> bool:
	var chord_to_send: Chord
	if _pending_chord: chord_to_send = _pending_chord
	elif _chord: chord_to_send = _chord
	else: return false
	
	if current_hit is AudioRetranslator:
		current_hit.receive_chord(chord_to_send, self)
		return current_hit.activate(self)
	elif current_hit is AudioCatcher:
		return current_hit.activate(self, chord_to_send)
	return false


func _raycast_ignoring_player(bounce_id: int, space_state: PhysicsDirectSpaceState3D, direction: Vector3) -> Dictionary:
	var result := space_state.intersect_ray(_ray_query)
	if result and _get_hit_owner(result) is Player:
		var player_pos = _get_hit_owner(result).global_position
		_ray_query.exclude = [self_area_ray, result.rid]
		result = space_state.intersect_ray(_ray_query)
		_on_player_hit(player_pos, bounce_id, result, direction)
	return result


func _get_hit_owner(result: Dictionary) -> Node3D:
	return result.collider.owner if result.collider.owner else result.collider


func _on_player_hit(player_pos: Vector3, bounce_id: int, result: Dictionary, direction: Vector3) -> void:
	if bounce_id >= _audio_streamers.size():
		push_warning("Max_bounces is greater then available of _audio_streamers")
		return
	var audio_stream = _audio_streamers[bounce_id]
	var from := _ray_query.from
	var to: Vector3 = result.get("position", _ray_query.to)
	var closest_position = Geometry3D.get_closest_point_to_segment(
		player_pos - direction * AUDIO_PLAYER_OFFSET_FROM_PLAYER, from, to
		)
	audio_stream.global_position = closest_position
	
	_active_audio_streams[bounce_id] = audio_stream
	if debug:
		_audio_debug_spheres[bounce_id].global_position = closest_position
		_audio_debug_spheres[bounce_id].show()


func _draw_debug_line(from: Vector3, to: Vector3) -> void:
	if not debug: return
	_debug_line_mesh.surface_add_vertex(to_local(from))
	_debug_line_mesh.surface_add_vertex(to_local(to))


func _create_debug_visualisation() -> void:
	var mat_sphere := StandardMaterial3D.new()
	mat_sphere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_sphere.albedo_color = Color.WHITE
	for i in max_bounces:
		var sphere := MeshInstance3D.new()
		sphere.mesh = SphereMesh.new()
		sphere.mesh.radius = 0.1
		sphere.mesh.height = 0.2
		sphere.mesh.material = mat_sphere
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
	for i in max_bounces:

		var audio_stream = AudioPlayer.new()
		add_child(audio_stream)
		_audio_streamers.append(audio_stream)
	_active_audio_streams.resize(max_bounces)


func _create_ray_query() -> void:
	_ray_query = PhysicsRayQueryParameters3D.create(
		Vector3.ZERO,
		Vector3.ZERO,
		collision_mask
		)
	_ray_query.collide_with_areas = true
	_ray_query.collide_with_bodies = true
	_ray_query.hit_back_faces = true
	_ray_query.hit_from_inside = true


func _on_conductor_loop_reset() -> void:
	if not _pending_chord:
		return
	for i in _audio_streamers:
		i.play_chord(_pending_chord.duplicate())
	_chord = _pending_chord.duplicate()
	_pending_chord = null
	_reactivate = true


func receive_chord(new_chord: Chord) -> void:
	_pending_chord = new_chord.duplicate()
	_reactivate = true


func deactivate(emitter: RayCast) -> void:
	for i in _audio_streamers:
		i.global_position = INACTIVE_AUDIO_PLAYER_POSITION
	_is_active = false


func activate(emitter: RayCast) -> void:
	_is_active = true
	_is_active_last_frame = true

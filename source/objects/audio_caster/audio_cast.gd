extends PickableObject
class_name AudioCast

@export var debug: bool

enum Fret {OPEN, FIRST, SECOND, THIRD, FOURTH, NONE}

@export_category("Chord")
@export var s6: Fret
@export var s5: Fret
@export var s4: Fret
@export var s3: Fret
@export var s2: Fret
@export var s1: Fret
var chord: Dictionary = {
	"6": null,
	"5": null,
	"4": null,
	"3": null,
	"2": null,
	"1": null
}

@export_category("AudioStream")
@export var audio_max_distance: float
@export var audio_volume: float
@export var audio_max_volume: float
@export var audio_attenuation_model: AudioStreamPlayer3D.AttenuationModel

@export_category("RayQuery")
@export var ray_length: float
@export var max_bounces: int
@export_flags_3d_physics var collision_mask: int

var debug_line: ImmediateMesh
var instance: MeshInstance3D
var _active_audio_players: Array[int]
var audio_debug_array := []
var audio_debug: MeshInstance3D
var audio_streamer_array := []
var current_hit: Node3D
var last_hit: Node3D

@onready var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, collision_mask)
@onready var root := $".."
@onready var sound_timer: Timer = $Timer
@onready var audio_caster: Marker3D = $AudioCast


func _ready() -> void:
	super()
	can_move = false
	global_position.y = 1
	player_camera_marker = $PlayerCameraMarker
	
	max_bounces = max_bounces + 1
	
	sound_timer.one_shot = false
	sound_timer.start()
	
	for i in max_bounces:
		audio_debug = MeshInstance3D.new()
		audio_debug.mesh = SphereMesh.new()
		audio_debug.mesh.radius = 0.1
		audio_debug.mesh.height = 0.2
		add_child(audio_debug)
		audio_debug.position.y = i + 0.2
		audio_debug_array.append(audio_debug)
	
	#var audio: AudioStreamMP3
	set_chord()
	#
	for i in max_bounces:
		var audio_stream = AudioStreamPlayer3D.new()
		add_child(audio_stream)
		audio_stream.stream = AudioStreamPolyphonic.new()
		audio_stream.max_polyphony = 6
		var sfx = "my_path"
		#var playback = (AudioStreamPlaybackPolyphonic)audio_stream.GetStreamPlayback();
		var playback = audio_stream.get_stream_playback()
		#playback.PlayStream(sfx, 0, volume, 1, 0, "SFX");
		playback.
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color.RED
	debug_line = ImmediateMesh.new()
	instance = MeshInstance3D.new()
	instance.material_override = mat
	instance.mesh = debug_line
	add_child(instance)
	print(audio_streamer_array)


func _physics_process(delta: float) -> void:
	debug_line.clear_surfaces()
	_active_audio_players.clear()
	
	for i in audio_debug_array:
		i.hide()
	
	cast()
	
	for i in audio_streamer_array.size():
		if i in _active_audio_players: continue
		audio_streamer_array.get(i).stream_paused = true


func set_chord() -> void:
	chord['6'] = s6
	chord['5'] = s5
	chord['4'] = s4
	chord['3'] = s3
	chord['2'] = s2
	chord['1'] = s1
	
	for c in chord:
		var fret_value = chord[c]
		if fret_value == Fret.NONE: continue
		var fret_name = Fret.keys()[fret_value].to_lower()
		var path = "res://source/sounds/" + c + "_" + fret_name + "_" + str(randi_range(0, 3)) + ".wav"
		chord[c] = load(path)
		print(chord[c])


func play_strum() -> void:
	pass


func cast() -> void:
	var player_hit_count: int = 0
	var player_hitted: bool = false
	var player_position: Vector3
	var current_bounce: int = 0
	var result: Dictionary
	
	var from: Vector3
	var to: Vector3
	var break_after: bool = false
	
	var space_state := get_world_3d().direct_space_state
	var direction := -global_transform.basis.z
	var current_start := global_position# + Vector3(0, audio_caster.global_position.y, 0)
	
	query.exclude = []
	query.collide_with_areas = true
	query.hit_from_inside = true
	
	if debug:
		debug_line.surface_begin(Mesh.PRIMITIVE_LINES)
	
	while current_bounce < max_bounces:
		query.from = current_start
		query.to = query.from + direction * ray_length
		result = space_state.intersect_ray(query)
		if not result:
			break_after = true
			from = query.from
			to = query.to
			current_hit = null
		else:
			from = query.from
			to = result.position
			current_hit = result.collider.owner
		draw_debug(from, to)
		if player_hitted:
			#sound(from, to, player_position, player_hit_count, direction)
			player_hit_count += 1
			player_hitted = false
		if not current_hit == last_hit:
			if current_hit is AudioCatcher:
				current_hit.activate()
			if last_hit is AudioCatcher:
				last_hit.deactivate()
			last_hit = current_hit
		if current_hit is AudioCatcher:
			break_after = true 
		if break_after: 
			break
		if current_hit is Player:
			player_hitted = true
			player_position = result.collider.global_position
			query.exclude = [result.rid]
			continue
		query.exclude = []
		direction = direction.bounce(result.normal)
		current_start = result.position + (result.normal * 0.005)
		current_bounce += 1
	
	if debug:
		debug_line.surface_end()


func draw_debug(from, to) -> void:
	if not debug: return
	debug_line.surface_add_vertex(to_local(from))
	debug_line.surface_add_vertex(to_local(to))


func sound(line_start: Vector3, line_end: Vector3, point_position: Vector3, id: int, direction: Vector3):
	var audio_stream: AudioStreamPlayer3D = audio_streamer_array.get(id)
	
	var closest_position := Geometry3D.get_closest_point_to_segment(point_position - direction, line_start, line_end)
	audio_stream.global_position = closest_position
	
	var sync_time = sound_timer.wait_time - sound_timer.time_left
	if abs(audio_stream.get_playback_position() - sync_time) > 0.1:
		audio_stream.seek(sync_time)
	
	audio_stream.stream_paused = false
	_active_audio_players.append(id)
	
	if debug:
		audio_debug = audio_debug_array.get(id)
		audio_debug.global_position = audio_stream.global_position
		audio_debug.show()

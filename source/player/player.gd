class_name Player
extends CharacterBody3D

enum PlayerState {FREE, PAUSE, INTERACT}
var _player_state: PlayerState
var _current_interaction: InteractionObject

const SPEED: float = 5.0

@export var mouse_sens: float = 0.001

var ray_pick: RayCast3D
var ray_interact: RayCast3D
var origin: Node3D
var camera: Camera3D
var camera_node: Node3D

var can_move: bool = true

var _is_helding: bool = false
var _pick_collider: Node3D


func _ready() -> void:
	camera_node = get_node("CameraNode")
	ray_pick = get_node("CameraNode/RayPick")
	ray_interact = get_node("CameraNode/RayInteract")
	camera = get_node("CameraNode/Camera")
	origin = get_node("PickOrigin")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: _rotate_camera(event.relative)
	if event.is_action_pressed("grab"):
		if _is_helding: _object_release()
		else: _object_pick()
	if event.is_action_pressed("interact"):
		if _player_state == PlayerState.INTERACT:
			_leave()
		else:
			_interact()


func _physics_process(delta: float) -> void:
	if not _player_state == PlayerState.FREE:
		return
	
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()


func _object_pick() -> void:
	if not ray_pick.is_colliding(): return
	_pick_collider = ray_pick.get_collider().owner
	if _pick_collider is PickableObject:
		_is_helding = _pick_collider.pick()


func _object_release() -> void:
	if not _pick_collider: return
	_is_helding = not(_pick_collider.place()) # Return not(true) if can place


func _rotate_camera(event: Vector2) -> void:
	rotate_y(-event.x * mouse_sens)
	camera_node.rotate_x(-event.y * mouse_sens)
	camera_node.rotation.x = clamp(camera_node.rotation.x, -PI/2, PI/2)


func _interact() -> void:
	if _current_interaction: _leave(); return
	if not ray_interact.get_collider(): return
	if not ray_interact.get_collider().get_parent() is InteractionObject: return
	_current_interaction = ray_interact.get_collider().get_parent()
	_current_interaction.enter()
	_player_state = PlayerState.INTERACT
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _leave() -> void:
	if not _current_interaction: return
	_current_interaction.leave()
	_current_interaction = null
	_player_state = PlayerState.FREE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

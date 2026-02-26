class_name Player
extends CharacterBody3D

enum PlayerState {FREE, PAUSE, INTERACT}
var _player_state: PlayerState
var _current_interaction: InteractionObject


const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

@export var mouse_sens: float = 0.001

@onready var raycast: RayCast3D = $CameraNode/Camera3D/RayCast3D
@onready var origin: Node3D = $Origin
@onready var camera: Camera3D = $CameraNode/Camera3D
@onready var camera_node: Node3D = $CameraNode

var can_move: bool = true

var _held_object: Node3D
var _is_picking: bool


func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: _rotate_camera(event.relative)
	if event.is_action_pressed("grab"):
		if _is_picking: _object_release()
		else: _object_pick()
	if event.is_action_pressed("interact"):
		_interact()


func _physics_process(delta: float) -> void:
	if not _player_state == PlayerState.FREE: return
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
	if not raycast.is_colliding(): return
	_held_object = raycast.get_collider().owner
	if _held_object is PickableObject:
		_is_picking = _held_object.pick()


func _object_release() -> void:
	if not _held_object: return
	_is_picking = not(_held_object.place()) # Return not(true) if can place


func _rotate_camera(event: Vector2) -> void:
	rotate_y(-event.x * mouse_sens)
	camera_node.rotate_x(-event.y * mouse_sens)
	camera_node.rotation.x = clamp(camera_node.rotation.x, -PI/2, PI/2)


func _interact() -> void:
	if _current_interaction: _leave(); return
	if not raycast.get_held_object(): return
	if not raycast.get_held_object().owner is InteractionObject: return
	_current_interaction = raycast.get_held_object().owner
	_current_interaction.enter()
	_player_state = PlayerState.INTERACT
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _leave() -> void:
	if not _current_interaction: return
	_current_interaction.leave()
	_current_interaction = null
	_player_state = PlayerState.FREE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

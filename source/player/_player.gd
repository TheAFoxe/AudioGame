extends CharacterBody3D
class_name Player

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

@export var mouse_sens: float = 0.001

@onready var raycast: RayCast3D = $CameraNode/Camera3D/RayCast3D
@onready var origin: Node3D = $Origin
@onready var camera: Camera3D = $CameraNode/Camera3D
@onready var camera_node: Node3D = $CameraNode

var can_move: bool = true

var _collider: Node3D
var _is_picking: bool


func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: _rotate_camera(event.relative)
	if event.is_action_pressed("grab"):
		if _is_picking: _object_release()
		else: _object_pick()


func _physics_process(delta: float) -> void:
	if not can_move: return
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
	_collider = raycast.get_collider().owner
	if _collider is PickableObject:
		_is_picking = _collider.pick()


func _object_release() -> void:
	if not _collider: return
	_is_picking = not(_collider.place()) # Return not(true) if can place


func _rotate_camera(event: Vector2) -> void:
	rotate_y(-event.x * mouse_sens)
	camera_node.rotate_x(-event.y * mouse_sens)
	camera_node.rotation.x = clamp(camera_node.rotation.x, -PI/2, PI/2)

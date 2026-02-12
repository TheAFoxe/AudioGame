extends CharacterBody3D
class_name Player

var collider: Node3D
var speed = 5.0
var jump_velocity = 4.5
var is_picking: bool = false

var can_move: bool = true

@export var sens = 0.001

@onready var raycast: RayCast3D = $CameraNode/Camera3D/RayCast3D
@onready var origin: Node3D = $Origin
@onready var camera: Camera3D = $CameraNode/Camera3D
@onready var camera_node: Node3D = $CameraNode

func _ready() -> void:
	emit_signal("player", self)


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sens)
		camera_node.rotate_x(-event.relative.y * sens)
	
	if event.is_action_pressed("grab"):
		if is_picking:
			object_release()
		else:
			object_grab()


func _physics_process(delta: float) -> void:
	if not can_move: return
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()


func lock_movement():
	can_move = false


func object_grab() -> void:
	if not raycast.is_colliding():
		return
	collider = raycast.get_collider().owner
	if collider is PickableObject:
		collider.pick(self)
	is_picking = true


func object_release() -> void:
	if not collider or not collider.can_place: return
	collider.place()
	can_move = true
	collider = null
	is_picking = false
	camera.global_position = camera_node.global_position

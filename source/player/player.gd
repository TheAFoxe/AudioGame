extends CharacterBody3D

class_name Player

var collider: Node3D
var speed = 5.0
var jump_velocity = 4.5
var is_picking: bool = false

@export var sens = 0.001

@onready var raycast: RayCast3D = $Node3D/Camera3D/RayCast3D
@onready var origin: Node3D = $Origin
@onready var camera: Camera3D = $Node3D/Camera3D

func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sens)
		$"Node3D".rotate_x(-event.relative.y * sens)
	
	if event.is_action_pressed("grab"):
		if is_picking:
			object_release()
		else:
			object_grab()
	
	#if event.is_action("rotate_left"):
		#origin.global_rotation.y += deg_to_rad(2)
	#if event.is_action("rotate_right"):
		#origin.global_rotation.y -= deg_to_rad(2)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()


func object_grab() -> void:
	if not raycast.is_colliding():
		return
	collider = raycast.get_collider().owner
	if collider is PickableObject:
		collider.pick(origin)
	is_picking = true


func object_release() -> void:
	if not collider.can_place: return
	collider.place()
	collider = null
	is_picking = false

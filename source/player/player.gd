extends CharacterBody3D

class_name Player

enum character_states {
	IDLE,
	ROTATING,
}
var current_character_state := character_states.IDLE
var collider: Node3D
var speed = 5.0
var jump_velocity = 4.5

@export var sens = 0.001

@onready var raycast: RayCast3D = $Node3D/Camera3D/RayCast3D
@onready var origin: Node3D = $Node3D/Camera3D/RayCast3D/Node3D
@onready var camera: Camera3D = $Node3D/Camera3D


func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sens)
		$"Node3D".rotate_x(-event.relative.y * sens)
	
	if event.is_action("grab"):
		if event.is_pressed():
			object_grab()
		if event.is_released():
			object_release()
	
	elif event.is_action("rotate"):
		if event.is_pressed() and collider:
			current_character_state = character_states.ROTATING
		if event.is_released():
			current_character_state = character_states.IDLE


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


func object_grab():
	if not raycast.is_colliding():
		return
	collider = raycast.get_collider().owner
	if collider is PickableObject:
		collider.pick(origin)


func object_release():
	collider.place()
	collider = null

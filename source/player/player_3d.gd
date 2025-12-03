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

@onready var raycast: RayCast3D = $"Node3D/Camera3D/RayCast3D"
@onready var origin: Node3D = $Node3D/Camera3D/RayCast3D/Node3D
@onready var camera: Camera3D = $Node3D/Camera3D


func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		match current_character_state:
			character_states.IDLE:
				rotate_y(-event.relative.x * sens)
				$"Node3D".rotate_x(-event.relative.y * sens)
				object_move()
			character_states.ROTATING:
				object_rotate(event)
	
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
	
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	#elif Input.is_action_just_pressed("jump"):
		#velocity.y = jump_velocity
	
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	object_move()


func object_grab():
	if not raycast.is_colliding():
		return
	collider = raycast.get_collider().get_parent().get_parent()
	origin.global_position = collider.global_position
	origin.global_rotation = collider.global_rotation
	collider.add_to_group("Active")


func object_release():
	if collider:
		collider.remove_from_group("Active")
	collider = null


func object_move() -> void:
	if not collider:
		return
	collider.global_rotation.y = origin.global_rotation.y
	collider.global_position = Vector3(origin.global_position.x, 0, origin.global_position.z)



func object_rotate(event):
	origin.rotate_y(event.relative.x * sens)
	#origin.rotate_x(event.relative.y * sens)

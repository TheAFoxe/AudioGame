extends CharacterBody3D
class_name Player

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

@export var mouse_sens: float = 0.001

@onready var raycast: RayCast3D = $CameraNode/Camera3D/RayCast3D
@onready var origin: Node3D = $Origin
@onready var camera: Camera3D = $CameraNode/Camera3D
@onready var camera_node: Node3D = $CameraNode

var _collider: Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

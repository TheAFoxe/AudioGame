extends Node3D
class_name OldPickable

var is_picked: bool
varsens = 0.001 origin: Node3D
var collision: StaticBody3D

var area_place: Area3D
var can_move: bool
var can_rotate: bool
var can_place: bool

var player: CharacterBody3D

var player_camera: Camera3D
var player_camera_marker: Marker3D


func _ready() -> void:
	can_move = true
	can_rotate = true
	can_place = true
	area_place = $AreaPlace
	area_place.area_entered.connect(_on_area_entered)
	area_place.area_exited.connect(_on_area_exited)
	if $Mesh:
		collision = $Mesh.get_child(1)
	

func _process(delta: float) -> void:
	if not is_picked: return
	if can_move:
		var global_y =  global_position.y
		global_position = global_position.lerp(origin.global_position, .7)
		global_position.y = global_y
	else: 
		player_camera.global_position = player_camera.global_position.lerp(player_camera_marker.global_position, 0.7)
	if can_rotate:
		global_rotation.y = lerp_angle(global_rotation.y, origin.global_rotation.y, 0.5)


func _on_area_exited(area):
	if area_place.get_overlapping_areas():
		return
	can_place = true



func _on_area_entered(area):
	can_place = false


func pick(player: Node3D):
	origin = player.origin
	player_camera = player.camera
	if $Mesh:
		collision = $Mesh.get_child(1)
		collision.collision_layer = 0
	if not can_move: 
		player.can_move = false
	is_picked = true


func place() -> void:
	if $Mesh:
		collision = $Mesh.get_child(1)
		collision.collision_layer = 1
	is_picked = false

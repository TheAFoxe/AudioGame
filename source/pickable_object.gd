extends Node3D
class_name PickableObject

var is_picked: bool
var origin: Node3D
var _duplicated: PickableObject
var collision: StaticBody3D

var area_place: Area3D
var can_move: bool
var can_place: bool


func _ready() -> void:
	can_move = true
	can_place = true
	area_place = $AreaPlace
	area_place.area_entered.connect(_on_area_entered)
	area_place.area_exited.connect(_on_area_exited)
	print(self)
	if $Mesh:
		collision = $Mesh.get_child(1)
		print(collision.collision_layer)


func _process(delta: float) -> void:
	if is_picked:
		#if can_move:
		global_position = global_position.lerp(origin.global_position, .7)
		global_rotation.y = lerp_angle(global_rotation.y, origin.global_rotation.y, 0.5)
		print(area_place.get_overlapping_areas())


func _on_area_exited(area):
	if area_place.get_overlapping_areas():
		return
	can_place = true


func _on_area_entered(area):
	print(can_place)
	can_place = false


func pick(player_origin: Node3D):
	origin = player_origin
	if $Mesh:
		collision = $Mesh.get_child(1)
		collision.collision_layer = 0
		
	is_picked = true


func place() -> void:
	if $Mesh:
		collision = $Mesh.get_child(1)
		collision.collision_layer = 1
	is_picked = false

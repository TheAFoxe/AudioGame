class_name InteractionObject
extends Node3D

#signal send_chord_mask(chord_mask: Array[bool])

@export var interaction_menu_scene: PackedScene
var interaction_menu: Control

func _ready() -> void:
	interaction_menu = interaction_menu_scene.instantiate()
	add_child(interaction_menu)


func enter() -> void:
	interaction_menu.enter()


func leave() -> void:
	interaction_menu.leave()

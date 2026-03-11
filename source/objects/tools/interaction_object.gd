## On interaction opens UI for controlling.
class_name InteractionObject
extends Node3D

## Loads menu scene, that should be shown.
@export var interaction_menu_scene: PackedScene
## Instance of menu scene.
var interaction_menu: Control

func _ready() -> void:
	interaction_menu = interaction_menu_scene.instantiate()
	add_child(interaction_menu)

## Opens menu.
func enter() -> void:
	interaction_menu.enter()


## Close menu.
func leave() -> void:
	interaction_menu.leave()

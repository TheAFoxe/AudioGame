extends Node3D

var player: Player

@onready var audio := $AudioStreamPlayer3D

func _ready() -> void:
	player = get_player()
	print(player)


func _process(delta: float) -> void:
	#var distance = self.global_position.x - player.global_position.x - 2
	#audio.global_position.x =self.global_position.x - distance
	#audio.global_position.z = self.global_position.z + distance * tan(self.rotation.y)
	#audio.position.x = clampf(audio.position.x, -10, 0)
	pass


func get_player() -> Player:
	return _get_player_recursive(get_tree().get_root())

func _get_player_recursive(node: Node) -> Player:
	for child in node.get_children():
		if child is CharacterBody3D:
			return child
		var found = _get_player_recursive(child)
		if found:
			return found
	return null

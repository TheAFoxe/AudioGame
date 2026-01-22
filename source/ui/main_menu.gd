extends Control


signal level_pick(level)


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var level = load("res://source/levels/testing/level_testing.tscn")
	level_pick.emit(level)

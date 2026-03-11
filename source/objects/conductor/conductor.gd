## Managing playback of AudioPlayers in scene.
class_name Conductor
extends Timer


func _ready() -> void:
	GlobalSignals.conductor_loop_reset.emit()


func _on_timeout() -> void:
	GlobalSignals.conductor_loop_reset.emit()

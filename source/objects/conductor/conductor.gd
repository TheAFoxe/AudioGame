## Managing playback of AudioPlayers in scene.
class_name Conductor
extends Timer


func _on_timeout() -> void:
	GlobalSignals.conductor_loop_reset.emit()

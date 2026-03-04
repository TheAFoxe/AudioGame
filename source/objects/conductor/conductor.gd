class_name Conductor
extends Timer

signal _loop_reset

func _ready() -> void:
	ConductorLoopReset._loop_reset.emit()


func _on_timeout() -> void:
	ConductorLoopReset._loop_reset.emit()

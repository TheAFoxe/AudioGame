extends RayCast
class_name Speaker

@export var _chord_resource: Chord

func _ready() -> void:
	super()
	activate(_chord_resource)

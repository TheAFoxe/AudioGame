class_name TutorialLabel
extends Label3D

func _ready() -> void:
	#billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	visibility_range_begin_margin = 1.0
	visibility_range_end_margin = 2.0
	visibility_range_end = 3.0
	visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	modulate = Color("WHITE")
	outline_modulate = Color("BLACK")
	font_size = 64
	pixel_size = 0.0025
	#outline_size = 8

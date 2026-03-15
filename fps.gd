extends Label


func _process(delta: float) -> void:
	set_text("FPS %d | delta %.3f" % [Engine.get_frames_per_second(), delta])
	add_theme_color_override("font_color", Color.BLACK)

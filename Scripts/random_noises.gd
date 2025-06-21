extends AudioStreamPlayer2D



func _on_finished() -> void:
	self.pitch_scale = randf_range(0.90, 1.1)
	self.play()

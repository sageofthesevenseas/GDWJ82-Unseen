extends Node
# LZB NOTE 15-06-25 - This key gets attached to the main scene when you want to quickly have restart as a key
func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_QUOTELEFT):
		get_tree().reload_current_scene()

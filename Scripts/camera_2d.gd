extends Camera2D

@export var cameraZoomSpeed : Vector2 = Vector2(0.2, 0.2)
@export var cameraZoomDefault : Vector2 = Vector2(1.0, 1.0)
@export var zoomMin : Vector2 = Vector2(0.5, 0.5)
@export var zoomMax : Vector2 = Vector2(1.5, 1.5)
func _process(_delta) -> void:
	if Input.is_action_just_pressed("zoom_in") and GameController.instance.zoom_enable == true and $".".zoom <= zoomMax:
		set_zoom(get_zoom() * (cameraZoomDefault + cameraZoomSpeed))	
	elif Input.is_action_just_pressed("zoom_out") and GameController.instance.zoom_enable == true and $".".zoom >= zoomMin:
		set_zoom(get_zoom() / (cameraZoomDefault + cameraZoomSpeed))	

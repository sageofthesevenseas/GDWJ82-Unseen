extends Camera2D

@export var cameraZoomSpeed : Vector2 = Vector2(0.2, 0.2)
@export var cameraZoomDefault : Vector2 = Vector2(1.0, 1.0)
@export var zoomMin : Vector2 = Vector2(0.5, 0.5)
@export var zoomMax : Vector2 = Vector2(1.5, 1.5)

func _process(_delta) -> void:
	var zoom_allowed := true
	# allows us to use the camera if there is no GameController present (e.g. a test scene)
	if GameController.instance != null:
		zoom_allowed = GameController.instance.zoom_enable
	if zoom_allowed:
		if Input.is_action_just_pressed("zoom_in") and zoom <= zoomMax:
			set_zoom(get_zoom() * (cameraZoomDefault + cameraZoomSpeed))	
		elif Input.is_action_just_pressed("zoom_out") and zoom >= zoomMin:
			set_zoom(get_zoom() / (cameraZoomDefault + cameraZoomSpeed))	

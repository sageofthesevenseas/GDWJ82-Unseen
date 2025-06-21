extends Camera2D

@export var cameraZoomSpeed : Vector2 = Vector2(0.2, 0.2)
@export var cameraZoomDefault : Vector2 = Vector2(1.0, 1.0)
@export var zoomMin : Vector2 = Vector2(0.5, 0.5)
@export var zoomMax : Vector2 = Vector2(1.5, 1.5)


# Shaking intensity (from 0.0 to 1.0)
var trauma = 0.0
# Exponent for power of shaking strength
var trauma_power = 2
# Put the shaking strength trauma as a power exponent trauma_power
var amount = 0.0

# Shaking intensity that decays in 1 second
# Note that if it is less than 0.0, the shaking will last forever
var decay = 0.8
# Maximum shaking width
# Hold each value in x-axis direction and y-axis direction as one data in Vector2 type
var max_offset = Vector2(36, 64) # display ratio is 16 : 9
# Maximum angle of rotation (in radians)
var max_roll = 0.1

func _ready() -> void:
	randomize()
	add_to_group("camera")
	get_node("/root/GameController").connect("player_ui_ready", Callable(self, "_on_player_ui_ready"))	
	
func _process(delta) -> void:
	if trauma:
		trauma = max(trauma - decay * delta, 0)
	rough_shake()
		
	var zoom_allowed := true
	# allows us to use the camera if there is no GameController present (e.g. a test scene)
	if GameController.instance != null:
		zoom_allowed = GameController.instance.zoom_enable
	if zoom_allowed:
		if Input.is_action_just_pressed("zoom_in") and zoom <= zoomMax:
			set_zoom(get_zoom() * (cameraZoomDefault + cameraZoomSpeed))	
		elif Input.is_action_just_pressed("zoom_out") and zoom >= zoomMin:
			set_zoom(get_zoom() / (cameraZoomDefault + cameraZoomSpeed))	

func _on_player_ui_ready():
	get_tree().get_first_node_in_group("PlayerUI").connect("screenshake", Callable(self, "_on_screenshake_signal"))
func _on_screenshake_signal():
	set_shake()
	print("tried to shake")
	pass

func set_shake(add_trauma = 0.5):
	trauma = min(trauma + add_trauma, 1.0)

func rough_shake():
	print("trying rough shake")
	amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-0.3, 0.3)
	offset.x = max_offset.x * amount * randf_range(-0.3, 0.3)
	offset.y = max_offset.y * amount * randf_range(-0.3, 0.3)

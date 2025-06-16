class_name Character extends CharacterBody2D

@export var acceleration : float = 5000.0
@export var friction : float = 10.0
@export var max_speed : float = 1000.0

@export var diggable_range : float = 100.0

@onready var geolocation_area := $"GeolocationArea" as Area2D
@onready var chest_minigame_manager := $Chest_Minigame as ChestMinigameManager

enum GeolocationState { IDLE, IN_DIGGABLE_RANGE }
var current_geolocation_state := GeolocationState.IDLE
signal entered_diggable_range()
signal exited_diggable_range()

var can_move : bool = true

signal dug_anywhere()
signal dug_chest()

func _ready() -> void:
	$"Label".visible = current_geolocation_state == GeolocationState.IN_DIGGABLE_RANGE

func _physics_process(delta : float) -> void:
	if can_move:
		var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down").normalized()
		velocity += acceleration * input_dir * delta
	velocity -= velocity * friction * delta
	velocity = velocity.limit_length(max_speed)
	move_and_slide()

	var geolocatables : Array[HiddenChest] = []
	for area in geolocation_area.get_overlapping_areas():
		if (area is HiddenChest):
			geolocatables.append(area)
	geolocation_process(delta, geolocatables)

func geolocation_process(delta : float, geolocatables : Array[HiddenChest]) -> void:
	var previously_in_diggable_range : bool = current_geolocation_state == GeolocationState.IN_DIGGABLE_RANGE
	var in_diggable_range : bool = false
	if geolocatables.size():
		var closest_geolocatable : HiddenChest = geolocatables[0]
		var closest_dist := (closest_geolocatable.global_position - global_position).length()
		for i in geolocatables.size():
			var i_length := (geolocatables[i].global_position - global_position).length();
			if i_length < closest_dist:
				closest_geolocatable = geolocatables[i]
				closest_dist = i_length
		if closest_dist < diggable_range:
			in_diggable_range = true
			if Input.is_action_just_pressed(&"dig"):
				dig_chest(closest_geolocatable)
	else:
		in_diggable_range = false
		if Input.is_action_just_pressed(&"dig"):
			dig_anywhere()
	if not previously_in_diggable_range and in_diggable_range:
		current_geolocation_state = GeolocationState.IN_DIGGABLE_RANGE
		emit_signal(&"entered_diggable_range")
		($"Label" as Label).visible = true
	elif previously_in_diggable_range and not in_diggable_range:
		current_geolocation_state = GeolocationState.IDLE
		emit_signal(&"exited_diggable_range")
		($"Label" as Label).visible = false

func dig_anywhere() -> void:
	emit_signal(&"dug_anywhere")
	# player digged, but nothing was in diggable range! do something

func dig_chest(chest : HiddenChest) -> void:
	emit_signal(&"dug_chest")
	can_move = false
	chest_minigame_manager.start_minigame(chest)

# Need some kind of signal to return to here after closing a chest or something. Maybe ChestMinigameManager? Maybe Chest?
func on_chest_closed() -> void:
	can_move = true
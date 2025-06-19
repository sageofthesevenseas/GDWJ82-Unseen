class_name Character extends CharacterBody2D

@onready var animation_player: AnimationPlayer = get_node("PlayerVisuals/AnimationPlayer")

@export var max_health : float = 100.0
@export var health : float = 100.0
@export var acceleration : float = 5000.0
@export var friction : float = 10.0
@export var max_speed : float = 1000.0

@export var diggable_range : float = 100.0

@export var DEBUG_lightcheck_messages_on: bool = true

@onready var geolocation_area := $"GeolocationArea" as Area2D
@onready var dig_minigame_manager := $"DigMinigame" as DigMinigameManager
@onready var chest_minigame_manager := $"Chest_Minigame" as ChestMinigameManager

@onready var raycast_left := $RayCastLeft as RayCast2D
@onready var raycast_right := $RayCastRight as RayCast2D
@onready var raycasts : Array[RayCast2D] = [ raycast_left, raycast_right ]

enum GeolocationState { IDLE, IN_DIGGABLE_RANGE }
var current_geolocation_state := GeolocationState.IDLE
signal entered_diggable_range()
signal exited_diggable_range()

var controllable : bool = true

signal dug_anywhere()
signal dug_chest()

signal damage_taken()
signal health_depleted()

func _ready() -> void:
	$"Label".visible = current_geolocation_state == GeolocationState.IN_DIGGABLE_RANGE

func _physics_process(delta : float) -> void:
	if controllable:
		var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down").normalized()
		velocity += acceleration * input_dir * delta
	velocity -= velocity * friction * delta
	velocity = velocity.limit_length(max_speed)
	move_and_slide()

	# NOTE: when the player becomes not controllable whilst in an animation, we need to stop the animation or transition to another animation
	if not controllable:
		return

	#making player walk and flipping scale instead of flip_h because Node2D doesn't have flip_H
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		animation_player.speed_scale = 3.0
		animation_player.play("Player Walking")

	else:
		animation_player.stop()
	if Input.is_action_just_pressed("move_left") and $PlayerVisuals.scale.x > 0:
		$PlayerVisuals.scale.x *= -1
		print("Tried to flip")
	if Input.is_action_just_pressed("move_right") and $PlayerVisuals.scale.x < 0:
		$PlayerVisuals.scale.x *= -1
		print("Tried to flip")
	

	var geolocatables : Array[HiddenChest] = []
	for area in geolocation_area.get_overlapping_areas():
		if (area is HiddenChest):
			geolocatables.append(area)
	geolocation_process(delta, geolocatables)

	var in_light := false
	for light in get_tree().get_nodes_in_group(&"lights"):
		if not (light as Node2D).visible or not light.get_meta(&"use_for_darkness_damage", false):
			break
		in_light = not is_in_shadow(light.get_meta(&"light_range", 0.0), (light as Node2D).global_position)
		if in_light:
			break

	if not in_light:
		# Do something !
		if DEBUG_lightcheck_messages_on == true:
			print("Not in light")

func is_in_shadow(light_range : float, light_global_position : Vector2) -> bool:
	for raycast in raycasts:
		var rel_position := light_global_position - raycast.global_position
		raycast.target_position = rel_position.limit_length(light_range)
		raycast.force_raycast_update()
		if rel_position.length() < light_range and not raycast.is_colliding():
			return false
	return true

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

func dig_chest(hidden_chest : HiddenChest) -> void:
	emit_signal(&"dug_chest")
	controllable = false
	dig_minigame_manager.start_minigame(hidden_chest)

func on_chest_dug() -> void:
	controllable = true

# Need some kind of signal to return to here after closing a chest or something. Maybe ChestMinigameManager? Maybe Chest?
func on_chest_closed() -> void:
	controllable = true

func take_damage(amount : float) -> void:
	var prev_health := health
	health = maxf(health - amount, 0.0)
	if health <= 0.0 and health < prev_health:
		emit_signal(&"health_depleted")
	if amount > 0.0:
		emit_signal(&"damage_taken")

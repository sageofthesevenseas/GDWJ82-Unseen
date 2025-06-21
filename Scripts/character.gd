class_name Character extends CharacterBody2D

@onready var animation_player: AnimationPlayer = get_node("PlayerVisuals/AnimationPlayer")

@export var max_health : float = 100.0
@export var health : float = 100.0

@export var darkness_damage : float

@export var acceleration : float = 5000.0
@export var friction : float = 10.0
@export var max_speed : float = 1000.0

@export var diggable_range : float = 100.0

@export var DEBUG_lightcheck_messages_on: bool = true

@onready var geolocation_area := $"GeolocationArea" as Area2D
@onready var dig_minigame_manager := $"DigMinigame" as DigMinigameManager
@onready var chest_minigame_manager := $"Chest_Minigame" as ChestMinigameManager
@onready var throwing_system: Node2D = $ThrowingSystem
@onready var raycast_left := $RayCastLeft as RayCast2D
@onready var raycast_right := $RayCastRight as RayCast2D
@onready var raycasts : Array[RayCast2D] = [ raycast_left, raycast_right ]

enum GeolocationState { IDLE, IN_DIGGABLE_RANGE }
var current_geolocation_state := GeolocationState.IDLE
signal entered_diggable_range()
signal exited_diggable_range()

var closest_geolocatable_distance : float = 10000000.0
var closest_geolocatable: HiddenChest
var controllable : bool = true

var curframe_in_darkness : bool = false
var prvframe_in_darkness : bool = false

var curframe_can_dig_chest : bool = false
var curframe_can_open_chest : bool = false

signal dug_anywhere()
signal dug_chest()

signal damage_taken()
signal health_depleted()

signal entered_darkness()
signal exited_darkness()

func _ready() -> void:
	$"Label".visible = current_geolocation_state == GeolocationState.IN_DIGGABLE_RANGE
	if PlayerStats.instance != null:
		PlayerStats.instance.player_health = health
	else:
		push_warning("No PlayerStats instance available.")

func _physics_process(delta : float) -> void:
	curframe_can_open_chest = false
	curframe_can_dig_chest = false

	#region DARKNESS
	var in_light := false
	for light in get_tree().get_nodes_in_group(&"lights"):
		if not (light as Node2D).visible or not light.get_meta(&"use_for_darkness_damage", false):
			continue
		in_light = not is_in_shadow(light.get_meta(&"light_range", 0.0) * (light as Node2D).scale.x, (light as Node2D).global_position)
		if in_light:
			break

	curframe_in_darkness = not in_light
	if curframe_in_darkness:
		if not prvframe_in_darkness:
			emit_signal(&"entered_darkness")
		if DEBUG_lightcheck_messages_on == true:
			print("Not in light")
		take_damage(darkness_damage * delta)
	else:
		if prvframe_in_darkness:
			emit_signal(&"exited_darkness")
	#endregion

	#region MOVEMENT
	if controllable:
		var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down").normalized()
		velocity += acceleration * input_dir * delta
	velocity -= velocity * friction * delta
	velocity = velocity.limit_length(max_speed)
	move_and_slide()
	#endregion

	#region ANIMATION
	if controllable:
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
	else:
		pass
		# animation_player.stop()
	#endregion

	#region EXPOSEDCHEST
	if controllable:
		for body in $Exposed_Chest_Detector.get_overlapping_bodies():
			if body is ExposedChest and not body.chest_opened:
				curframe_can_open_chest = true
				break
	#endregion

	#region GEOLOCATION
	if controllable:
		var geolocatables : Array[HiddenChest] = []
		for area in geolocation_area.get_overlapping_areas():
			if (area is HiddenChest):
				geolocatables.append(area)
		geolocation_process(delta, geolocatables)
	#endregion

	#region DIG INPUT
	if controllable and Input.is_action_just_pressed(&"dig"):
		if curframe_can_open_chest:
			for body in $Exposed_Chest_Detector.get_overlapping_bodies():
				if body is ExposedChest and not body.chest_opened:
					open_chest(body)
		elif curframe_can_dig_chest:
			dig_chest(closest_geolocatable)
	#endregion

	$DebugHealth.text = "HP %.1f/%.1f" % [health, max_health]

	prvframe_in_darkness = curframe_in_darkness

func is_in_shadow(light_range : float, light_global_position : Vector2) -> bool:
	for raycast in raycasts:
		var rel_position := light_global_position - raycast.global_position
		raycast.target_position = rel_position.limit_length(light_range)
		raycast.force_raycast_update()
		if rel_position.length() < light_range and not raycast.is_colliding():
			return false
	return true

func geolocation_process(_delta : float, geolocatables : Array[HiddenChest]) -> void:
	var previously_in_diggable_range : bool = current_geolocation_state == GeolocationState.IN_DIGGABLE_RANGE
	var in_diggable_range : bool = false
	if geolocatables.size():
		closest_geolocatable = geolocatables[0]
		var closest_dist := (closest_geolocatable.global_position - global_position).length()
		for i in geolocatables.size():
			var i_length := (geolocatables[i].global_position - global_position).length();
			if i_length < closest_dist:
				closest_geolocatable = geolocatables[i]
				closest_dist = i_length
		if closest_dist < diggable_range:
			in_diggable_range = true
			curframe_can_dig_chest = true
		closest_geolocatable_distance = closest_dist
	else:
		in_diggable_range = false
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
	animation_player.speed_scale = 1.0
	animation_player.play(&"Player Dig")
	animation_player.queue(&"Player Dig Loop")

func on_chest_dug() -> void:
	controllable = true
	closest_geolocatable.spawn_real_chest()
	# LZB NOTE 21-06-25 - spawn the bloody chest here

func open_chest(chest : ExposedChest) -> void:
	controllable = false
	chest.start_minigame()

# Need some kind of signal to return to here after closing a chest or something. Maybe ChestMinigameManager? Maybe Chest?
func on_chest_closed() -> void:
	controllable = true

func on_minigame_cancelled() -> void:
	controllable = true

func take_damage(amount : float) -> void:
	var prev_health := health
	health = maxf(health - amount, 0.0)
	if health <= 0.0 and health < prev_health:
		die()
	if amount > 0.0:
		emit_signal(&"damage_taken")
	if PlayerStats.instance != null:
		PlayerStats.instance.player_health = health

func die():
	can_process()
	emit_signal(&"health_depleted")

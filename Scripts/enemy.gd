class_name Enemy extends CharacterBody2D

enum MovementState { GROUNDED, FLYING, PREPARE_SWOOP, SWOOP_IN }
var movement_state : MovementState = MovementState.FLYING

enum AttackState { NOT_READY, READY, ATTACKING }
var attack_state : AttackState = AttackState.NOT_READY

@export var max_health : float = 100.0
@export var health : float = 100.0
@export var max_time_in_darkness_before_despawn : float = 10.0

@export var memory_time : float = 7.0
@export var max_speed : float = 1500.0
@export var max_acceleration : float = 3000.0
@export var friction : float = 5.0

@export var preferred_max_target_distance : float = 1000.0
@export var preferred_min_target_distance : float = 300.0

@export var flight_max_turn_angle : float = 150.0 # terrible variable
@export var flaps_per_second : float = 2.0

@export var swoop_acceleration : float = 10000.0
@export var swoop_attack_max_range : float = 600.0
@export var swoop_attack_min_range : float = 400.0
@export var swoop_attack_cooldown : float = 6.0
@export var swoop_attack_damage : float = 5.0

@export var max_swoop_time : float = 1.2

@export var stuck_time_threshold : float = 1.0
@export var stuck_velocity_threshold : float = 20.0

@export_group("Debug Options")
@export var show_acceleration_line : bool = false
@export var show_move_goal : bool = false:
	set(b):
		if is_inside_tree():
			(get_node(^"MoveGoal") as Node2D).visible = b
		show_move_goal = b

var target : Node2D

var target_seen : bool
var time_since_target_seen : float = 0.0
var target_last_seen_position : Vector2

var time_since_attack : float = 0.0
var swooping_time : float = 0.0
var swoop_from : Vector2

var move_goal : Vector2

var time_since_not_moving : float = 0.0

var time_in_darkness : float = 0.0

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D

@onready var raycast_left := $RayCastLeft as RayCast2D
@onready var raycast_right := $RayCastRight as RayCast2D
@onready var raycast_top := $RayCastTop as RayCast2D
@onready var raycasts : Array[RayCast2D] = [ raycast_left, raycast_right, raycast_top ]

signal health_depleted()
signal damage_taken()

signal gained_sight_of_target()
signal lost_sight_of_target()

signal started_swoop_attack()
signal swoop_attack_successful()
signal swoop_attack_failed()

func _ready() -> void:
	$MoveGoal.visible = show_move_goal
	DebugMenuSingleton.enemy_nav_hints_toggled.connect(func (toggled_on : bool) -> void: show_acceleration_line = toggled_on; show_move_goal = toggled_on)

var prvframe_target_seen := false

var curframe_in_darkness : bool = false
var prvframe_in_darkness : bool = false

func _physics_process(delta : float) -> void:
	choose_target()

	#region (mostly) taken from Character
	var in_light := false
	for light in get_tree().get_nodes_in_group(&"lights"):
		if not (light as Node2D).visible or not light.get_meta(&"use_for_darkness_damage", false):
			continue
		in_light = not is_in_shadow(light.get_meta(&"light_range", 0.0) * (light as Node2D).scale.x, (light as Node2D).global_position)
		if in_light:
			break

	curframe_in_darkness = not in_light
	if curframe_in_darkness:
		time_in_darkness += delta
		if not prvframe_in_darkness:
			emit_signal(&"entered_darkness")
		if time_in_darkness > max_time_in_darkness_before_despawn:
			queue_free()
	else:
		time_in_darkness = 0.0
		if prvframe_in_darkness:
			emit_signal(&"exited_darkness")
	#endregion

	target_seen = can_see_target();
	if not target_seen:
		if prvframe_target_seen:
			emit_signal(&"lost_sight_of_target")
		time_since_target_seen += delta
	else:
		if not prvframe_target_seen:
			emit_signal(&"gained_sight_of_target")
		time_since_target_seen = 0.0
		target_last_seen_position = target.global_position

	if attack_state == AttackState.NOT_READY:
		time_since_attack += delta
		if time_since_attack > swoop_attack_cooldown:
			attack_state = AttackState.READY

	if attack_state == AttackState.READY:
		if target_seen and get_to_target_vec().length() < swoop_attack_max_range:
			$AttackScreech.pitch_scale = randf_range(0.95, 1.05)
			$AttackScreech.play()
			initiate_attack_target()

	if movement_state == MovementState.PREPARE_SWOOP:
		if attack_state == AttackState.ATTACKING:
			if get_to_target_vec().length() > swoop_attack_min_range:
				swoop_from = global_position
				var from_target_length := (swoop_from - target_last_seen_position).length()
				if from_target_length + 150.0 < swoop_attack_max_range:
					swoop_attack_min_range = from_target_length + 200.0
				movement_state = MovementState.SWOOP_IN
				swooping_time = 0.0

	if movement_state == MovementState.SWOOP_IN:
		swooping_time += delta
		var from_target_vec := global_position - target_last_seen_position
		var from_target_to_swoop_vec := swoop_from - target_last_seen_position
		if from_target_vec.normalized().dot(from_target_to_swoop_vec.normalized()) < 0.0:
			finish_attack_target()
		elif swooping_time > max_swoop_time:
			cancel_attack_target()

	if get_real_velocity().length() < stuck_velocity_threshold:
		time_since_not_moving += delta
	else:
		time_since_not_moving = 0.0

	update_move_goal(delta)
	velocity -= velocity * friction * delta
	move_to_goal(delta)
	move_and_slide()

	prvframe_target_seen = target_seen
	prvframe_in_darkness = curframe_in_darkness

# this is so stupid :(
func is_in_shadow(light_range : float, light_global_position : Vector2) -> bool:
	for raycast in raycasts:
		var rel_position := light_global_position - raycast.global_position
		raycast.target_position = rel_position.limit_length(light_range)
		raycast.force_raycast_update()
		if rel_position.length() < light_range and not raycast.is_colliding():
			return false
	return true

func choose_target() -> void:
	target = null
	var nodes : Array[Node]= get_tree().get_nodes_in_group(&"player")
	for node in nodes:
		if node is Character:
			target = node
			break

func can_see_target() -> bool:
	if target == null or target is not Character:
		assert(false)
		return false
	var character_target : Character = target
	var seen_by_raycasts := true
	for raycast in character_target.raycasts:
		var from_raycast_vec := global_position - raycast.global_position
		raycast.target_position = from_raycast_vec
		raycast.force_raycast_update()
		if raycast.is_colliding():
			seen_by_raycasts = false
			break
	return seen_by_raycasts

func can_remember_target() -> bool:
	return target_seen or time_since_target_seen < memory_time

func is_stuck() -> bool:
	return time_since_not_moving > stuck_time_threshold

func get_to_target_vec() -> Vector2:
	return target_last_seen_position - global_position

func get_to_move_goal_vec() -> Vector2:
	return move_goal - global_position

var _curframe_too_close_to_target : bool = false
var _prvframe_too_close_to_target : bool = false

var _move_away_goal : Vector2

func update_move_goal(delta : float) -> void:
	_curframe_too_close_to_target = false
	if target_seen:
		move_goal = target_last_seen_position
		var to_target_vec := get_to_target_vec()
		var to_target_len := to_target_vec.length()

		var current_preferred_max_distance := preferred_max_target_distance
		var current_preferred_min_distance := preferred_min_target_distance
		if movement_state == MovementState.PREPARE_SWOOP or attack_state == AttackState.READY:
			current_preferred_max_distance = swoop_attack_max_range
			current_preferred_min_distance = swoop_attack_min_range
		if (movement_state == MovementState.GROUNDED or movement_state == MovementState.FLYING or movement_state == MovementState.PREPARE_SWOOP):
			if to_target_len < current_preferred_min_distance:
				_curframe_too_close_to_target = true
				if not _prvframe_too_close_to_target or is_stuck() or (_move_away_goal - target_last_seen_position).length() < current_preferred_min_distance:
					var angle_of_approach := target_last_seen_position.angle_to_point(global_position)
					if is_stuck():
						angle_of_approach += PI / 2.0
					_move_away_goal = target_last_seen_position + Vector2.RIGHT.rotated(angle_of_approach) * current_preferred_min_distance
				move_goal = _move_away_goal
				# move_goal = target_last_seen_position + Vector2.RIGHT.rotated(_angle_of_approach) * current_preferred_min_distance
			elif to_target_len < current_preferred_max_distance:
				move_goal = global_position
	elif can_remember_target():
		move_goal = target_last_seen_position
		if get_to_target_vec().length() < 100.0:
			move_goal = global_position
	else:
		move_goal = global_position
	_prvframe_too_close_to_target = _curframe_too_close_to_target

	nav_agent.target_position = move_goal
	move_goal = nav_agent.get_next_path_position()
	$MoveGoal.global_position = move_goal
	$DebugHealthLabel.text = "HP %.1f/%.1f" % [ health, max_health ]

var this_frame_acceleration : Vector2

func move_to_goal(delta : float) -> void:
	var to_move_goal_vec := get_to_move_goal_vec()
	var to_move_goal_len := to_move_goal_vec.length()
	var move_direction := to_move_goal_vec.normalized()
	var thrust := 1.0
	if movement_state != MovementState.GROUNDED:
		var angle_to_goal := velocity.normalized().angle_to(move_direction)
		var turn_angle := clampf(angle_to_goal, -deg_to_rad(flight_max_turn_angle), deg_to_rad(flight_max_turn_angle)) / 2.0
		if movement_state != MovementState.SWOOP_IN:
			# periodic sway
			turn_angle += sin(Engine.get_physics_frames() * delta * 6.0) / 16.0
			thrust -= 1.0 - pow(1.0 + sin(Engine.get_physics_frames() * delta * PI * 2.0 * flaps_per_second) / 5.0, 3.0)
		move_direction = (velocity + move_direction * 100.0).normalized().rotated(turn_angle)
	var acceleration := thrust * move_direction * minf(to_move_goal_len / 20.0, 1.0) # minf for dampening
	for enemy in get_tree().get_nodes_in_group(&"enemy"):
		if not enemy == self:
			var from_enemy_vec :=  global_position - (enemy as Enemy).global_position
			acceleration += from_enemy_vec.normalized() / maxf(1.0, from_enemy_vec.length() / 50.0) * (0.4 + randfn(-0.1, 0.5))
	if to_move_goal_len < 20.0:
		acceleration.y += sin(Engine.get_physics_frames() * delta * PI * 2.0 * flaps_per_second) * 1.0
	this_frame_acceleration = acceleration / delta
	queue_redraw()
	match movement_state:
		MovementState.SWOOP_IN:
			acceleration *= swoop_acceleration
		_:
			acceleration *= max_acceleration

	velocity += acceleration * delta
	velocity = velocity.limit_length(max_speed)

func _draw() -> void:
	if show_acceleration_line:
		draw_line(Vector2(), this_frame_acceleration * 2.0, Color.LAWN_GREEN)

func initiate_attack_target() -> void:
	attack_state = AttackState.ATTACKING
	movement_state = MovementState.PREPARE_SWOOP
	emit_signal(&"started_swoop_attack")

func finish_attack_target() -> void:
	(target as Character).take_damage(swoop_attack_damage)
	attack_state = AttackState.NOT_READY
	movement_state = MovementState.FLYING
	time_since_attack = 0.0
	emit_signal(&"swoop_attack_successful")

func cancel_attack_target() -> void:
	attack_state = AttackState.NOT_READY
	movement_state = MovementState.FLYING
	time_since_attack = 0.0
	emit_signal(&"swoop_attack_failed")

func take_damage(amount : float) -> void:
	var prev_health := health
	health = maxf(health - amount, 0.0)
	if health <= 0.0 and health < prev_health:
		emit_signal(&"health_depleted")
		queue_free()
	if amount > 0.0:
		emit_signal(&"damage_taken")

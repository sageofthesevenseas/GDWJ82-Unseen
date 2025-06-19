extends CharacterBody2D

enum MovementState { GROUNDED, FLYING, PREPARE_SWOOP, SWOOP_IN }
var movement_state : MovementState = MovementState.FLYING

enum AttackState { NOT_READY, READY, ATTACKING }
var attack_state : AttackState = AttackState.NOT_READY

@export var memory_time : float = 5.0
@export var max_speed : float = 100.0
@export var max_acceleration : float = 100.0
@export var friction : float = 0.1

@export var preferred_target_distance : float = 750.0
@export var preferred_distance_wiggle_room : float = 20.0

@export var flight_max_turn_angle : float = 90.0 # terrible variable

@export var swoop_acceleration : float = 200.0
@export var swoop_attack_range : float = 800.0
@export var swoop_attack_cooldown : float = 5.0

@export var max_swoop_time : float = 1.5

var target : Node2D

var target_seen : bool
var time_since_target_seen : float = 0.0
var target_last_seen_position : Vector2

var time_since_attack : float = 0.0
var swooping_time : float = 0.0
var swoop_from : Vector2

var move_goal : Vector2

func _physics_process(delta : float) -> void:
	choose_target()

	target_seen = can_see_target();
	if not target_seen:
		time_since_target_seen += delta
	else:
		time_since_target_seen = 0.0
		target_last_seen_position = target.global_position

	if attack_state == AttackState.NOT_READY:
		time_since_attack += delta
		if time_since_attack > swoop_attack_cooldown:
			attack_state = AttackState.READY

	if attack_state == AttackState.READY:
		if target_seen and get_to_target_vec().length() < swoop_attack_range:
			initiate_attack_target()

	if movement_state == MovementState.PREPARE_SWOOP:
		if attack_state == AttackState.ATTACKING:
			if get_to_target_vec().length() > swoop_attack_range:
				swoop_from = global_position
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

	update_move_goal(delta)
	velocity -= velocity * friction * delta
	move_to_goal(delta)
	move_and_slide()

func choose_target() -> void:
	target = null
	var nodes : Array[Node]= get_tree().get_nodes_in_group(&"player")
	for node in nodes:
		if node is Character:
			target = node
			break

func can_see_target() -> bool:
	return target != null

func get_to_target_vec() -> Vector2:
	return target_last_seen_position - global_position

func get_to_move_goal_vec() -> Vector2:
	return move_goal - global_position

func update_move_goal(delta : float) -> void:
	if target_seen:
		move_goal = target_last_seen_position
		var to_target_vec := get_to_target_vec()
		var to_target_len := to_target_vec.length()

		var current_preferred_distance := preferred_target_distance
		if movement_state == MovementState.PREPARE_SWOOP:
			current_preferred_distance = swoop_attack_range
		if ((movement_state == MovementState.GROUNDED or movement_state == MovementState.FLYING or movement_state == MovementState.PREPARE_SWOOP)
			and to_target_len < current_preferred_distance + preferred_distance_wiggle_room
		):
			var from_target_vec := global_position - target_last_seen_position
			if movement_state == MovementState.FLYING:
				from_target_vec += velocity / 10.0 + Vector2(-5,0)
			move_goal = target_last_seen_position + from_target_vec.normalized() * (current_preferred_distance + preferred_distance_wiggle_room / 2.0)
	$MoveGoal.global_position = move_goal

var this_frame_acceleration : Vector2

func move_to_goal(delta : float) -> void:
	var to_move_goal_vec := get_to_move_goal_vec()
	var to_move_goal_len := to_move_goal_vec.length()
	var move_direction := to_move_goal_vec.normalized()
	if movement_state != MovementState.GROUNDED:
		var angle_to_goal := velocity.normalized().angle_to(move_direction)
		var turn_angle := clampf(angle_to_goal, -deg_to_rad(flight_max_turn_angle), deg_to_rad(flight_max_turn_angle)) / 4.0
		if movement_state == MovementState.SWOOP_IN:
			turn_angle *= 2.0 / clampf(velocity.length() * delta / 35.0 , 0.6, 1.5)
		else:
			# periodic sway
			turn_angle += sin(Engine.get_physics_frames() * delta * 6.0) / 6.0
		move_direction = (velocity + move_direction * 100.0).normalized().rotated(turn_angle)
	var acceleration := move_direction * minf(to_move_goal_len / 20.0, 1.0) # minf for dampening
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
	draw_line(Vector2(), this_frame_acceleration * 2.0, Color.LAWN_GREEN)

func initiate_attack_target() -> void:
	attack_state = AttackState.ATTACKING
	movement_state = MovementState.PREPARE_SWOOP

func finish_attack_target() -> void:
	attack_state = AttackState.NOT_READY
	movement_state = MovementState.FLYING
	time_since_attack = 0.0

func cancel_attack_target() -> void:
	attack_state = AttackState.NOT_READY
	movement_state = MovementState.FLYING
	time_since_attack = 0.0

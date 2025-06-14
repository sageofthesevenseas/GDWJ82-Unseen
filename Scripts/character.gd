class_name Character extends CharacterBody2D

@export var acceleration : float = 5000.0
@export var friction : float = 10.0
@export var max_speed : float = 1000.0

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down").normalized()
	velocity -= velocity * friction * delta
	velocity += acceleration * input_dir * delta
	velocity = velocity.limit_length(max_speed)
	move_and_slide()

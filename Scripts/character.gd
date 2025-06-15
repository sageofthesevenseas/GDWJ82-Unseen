class_name Character extends CharacterBody2D

@export var acceleration : float = 5000.0
@export var friction : float = 10.0
@export var max_speed : float = 1000.0

@onready var geolocation_area := $"GeolocationArea" as Area2D

func _physics_process(delta : float) -> void:
	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down").normalized()
	velocity -= velocity * friction * delta
	velocity += acceleration * input_dir * delta
	velocity = velocity.limit_length(max_speed)
	move_and_slide()

	var geolocatables : Array[HiddenChest] = []
	for area in geolocation_area.get_overlapping_areas():
		if (area is HiddenChest):
			geolocatables.append(area)
	geolocation_process(delta, geolocatables)

func geolocation_process(delta : float, geolocatables : Array[HiddenChest]) -> void:
	if geolocatables.size():
		var closest_geolocatable : Node2D = geolocatables[0]
		var closest_dist := (closest_geolocatable.global_position - global_position).length()
		for i in geolocatables.size():
			var i_length := (geolocatables[i].global_position - global_position).length();
			if i_length < closest_dist:
				closest_geolocatable = geolocatables[i]

		# do something

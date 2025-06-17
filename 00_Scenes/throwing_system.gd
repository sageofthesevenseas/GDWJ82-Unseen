extends Node2D
@onready var projectile_spawn: Marker2D = $ProjectileSpawn
@onready var trajectory_preview: Line2D = $TrajectoryPreview

var max_radius := 600.0

func _process(delta: float) -> void:
	
	var mouse_pos = get_local_mouse_position()
	var distance = mouse_pos.length()
	
	if distance > max_radius:
		projectile_spawn.position = mouse_pos.normalized() * max_radius
	else:
		projectile_spawn.position = mouse_pos

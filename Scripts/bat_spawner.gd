extends Node2D

@export var max_bats : int = 4
@export var max_tries : int
@export var spawn_max_range_of_player : float = 4000.0
@export var spawn_min_range_of_player : float = 2000.0

var bat_scene : PackedScene = load("res://00_Scenes/enemy.tscn")

func spawn_bat() -> void:
	if get_tree().get_node_count_in_group(&"enemy") >= max_bats:
		return
	var navregion_bounds := ($"../BatNavigationRegion" as NavigationRegion2D).get_bounds()
	var navregion_polygon := ($"../BatNavigationRegion" as NavigationRegion2D).navigation_polygon
	var player_position := (get_tree().get_first_node_in_group(&"player") as Character).global_position
	for i in max_tries:
		var spawn_position := Vector2(
			randf_range(maxf(navregion_bounds.position.x, player_position.x - spawn_max_range_of_player), minf(navregion_bounds.end.x, player_position.x + spawn_max_range_of_player)),
			randf_range(maxf(navregion_bounds.position.y, player_position.y - spawn_max_range_of_player), minf(navregion_bounds.end.y, player_position.y + spawn_max_range_of_player))
		)
		if (spawn_position - player_position).length() < spawn_min_range_of_player:
			continue
		if Geometry2D.is_point_in_polygon(spawn_position, navregion_polygon.get_vertices()):
			var bat : Enemy = bat_scene.instantiate()
			bat.global_position = spawn_position
			bat.target_last_seen_position = player_position
			bat.flaps_per_second += randf_range(-0.5, 0.5)
			bat.swoop_attack_cooldown += randf_range(-0.2, 0.2)
			add_child(bat)
			return

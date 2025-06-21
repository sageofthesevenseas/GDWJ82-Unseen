extends RigidBody2D
@onready var detectable_area: Area2D = $"Detectable area"

enum Categories {HEALTH, BOMB, FLARE, STORY, CHEESE}
@export var pickup_type: Categories = Categories.HEALTH
@export_range (1, 10) var selected_story: int

@export var attraction_strength: float = 2500.0
@export var player_center_offset= Vector2(0,100)

var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	for body in detectable_area.get_overlapping_bodies():
		if body.is_in_group("player") and body is CharacterBody2D:
			hurtle_towards(delta)

func hurtle_towards(delta):
	#determine direction
	var player_GP_offset = player.global_position - player_center_offset
	var direction = (player_GP_offset - global_position).normalized()
	var force = direction * attraction_strength
	apply_central_force(force)
	print(force)

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("give the pickup")
		pickup_assignment()
		queue_free()

func pickup_assignment():
	match  pickup_type:
		Categories.HEALTH:
			pass # LZB NOTE 21-06-25 - do somethinhg
		Categories.BOMB:
			pass
		Categories.FLARE:
			pass
		Categories.STORY:
			pass
		Categories.CHEESE:
			pass

extends RigidBody2D
@onready var detectable_area: Area2D = $"Detectable area"

enum Categories {BOMB, FLARE, STORY, CHEESE}
@export var pickup_type: Categories = Categories.CHEESE
@export_range(0, 9) var passed_in_story: int = 0

@export var attraction_strength: float = 2500.0
@export var player_center_offset= Vector2(0,100)
@export var item_value_int: int = 1
@export var health_value: float = 10.0

var player_throwing_system: ThrowingSystem
var player: CharacterBody2D

func _ready() -> void:
	player_throwing_system = get_tree().get_first_node_in_group("throwingsystem")
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

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("give the pickup")
		pickup_assignment()
		queue_free()

func pickup_assignment():
	match  pickup_type:
		Categories.BOMB:
			player_throwing_system.increase_bombs(item_value_int)
			player.pickup_sound()
		Categories.FLARE:
			player_throwing_system.increase_flares(item_value_int)
			player.pickup_sound()
		Categories.STORY:
			GameController.instance.add_lore(passed_in_story)
			player.pickup_sound()
		Categories.CHEESE:
			player.heal(health_value)
			player.pickup_sound()

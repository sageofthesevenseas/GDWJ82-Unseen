extends Node2D
@onready var projectile_spawn: Marker2D = $ProjectileSpawn
@onready var trajectory_preview: Line2D = $TrajectoryPreview
@onready var projectile_holdup: Sprite2D = $"Projectile Holdup"

@export var bomb_image: Texture2D
@export var flare_image: Texture2D
@export var bomb_prefab: PackedScene
@export var flare_prefab: PackedScene
const THROW_MARKER = preload("res://ItemTextures/Throw Marker.png")
var max_radius := 600.0

func _process(delta: float) -> void:
	
	var mouse_pos = get_local_mouse_position()
	var distance = mouse_pos.length()
	
	if distance > max_radius:
		projectile_spawn.position = mouse_pos.normalized() * max_radius
	else:
		projectile_spawn.position = mouse_pos
	if Input.is_action_pressed("throw"):
		print("winding up throw ")
		projectile_spawn.visible = true
		projectile_holdup.visible = true
		projectile_holdup.texture = bomb_image
		
	
	if Input.is_action_just_released("throw"):
		print("no longer winding up, throw!")
		projectile_spawn.visible = false
		projectile_holdup.visible = false
		

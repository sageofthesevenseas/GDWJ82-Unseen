extends Node2D
@onready var projectile_target: Sprite2D = $ProjectileTarget
@onready var projectile_holdup: Sprite2D = $ProjectileHoldup


@export var bomb_image: Texture2D
@export var flare_image: Texture2D
@export var bomb_prefab: PackedScene
@export var flare_prefab: PackedScene
var max_radius := 600.0

func _ready() -> void:
	pass # LZB NOTE 19-06-25 - will probably need stuff later 

func _process(delta: float) -> void:
	
	var mouse_pos = get_local_mouse_position()
	var distance = mouse_pos.length()
	
	if distance > max_radius:
		projectile_target.position = mouse_pos.normalized() * max_radius
	else:
		projectile_target.position = mouse_pos
	if Input.is_action_pressed("throw"):
		print("winding up throw ")
		projectile_target.visible = true
		projectile_holdup.visible = true
		projectile_holdup.texture = bomb_image
		
	
	if Input.is_action_just_released("throw"):
		print("no longer winding up, throw!")
		projectile_target.visible = false
		projectile_holdup.visible = false
		# LZB NOTE 19-06-25 - need to actually put throwing code in here lol

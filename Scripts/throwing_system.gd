extends Node2D

@onready var projectile_target: Sprite2D = $ProjectileTarget
@onready var projectile_holdup: Sprite2D = $ProjectileHoldup
@onready var debug_projectile_direction_sprite: Sprite2D = $DEBUG_ProjectileDirectionSprite

var weapon_counter: int = 1 #0 is bomb, 1 is flare
var chosen_weapon: PackedScene

@export var bomb_image: Texture2D
@export var flare_image: Texture2D
@export var bomb_prefab: PackedScene
@export var flare_prefab: PackedScene

@export var bomb_quantity: int = 5
@export var flare_quantity: int = 5
@export var bomb_explosion_timer: float = 3.0
@export var flare_timer: float = 30.0

@export var can_activate: bool = true
var mouse_pos
var distance
var max_mouse_radius := 800.0

@export var min_throw_force: float = 10.0
@export var max_throw_force: float = 10000.0
@onready var throw_origin: Marker2D = $ThrowOrigin
@onready var holdup_display_timer: Timer = $DisplayTimer

signal ammunition_changed()

func _ready() -> void:
	check_weapon_selected()
	toggle_images(false)

func _process(delta: float) -> void:
	mouse_pos = get_local_mouse_position()
	distance = mouse_pos.length()
	if distance > max_mouse_radius:
		projectile_target.position = mouse_pos.normalized() * max_mouse_radius
	else:
		projectile_target.position = mouse_pos
	
	if Input.is_action_just_pressed("change_weapon"):
		weapon_counter = (weapon_counter + 1) % 2
		print("current number for weapon counter is ", weapon_counter)
		check_weapon_selected()
		projectile_holdup.visible = true
		holdup_display_timer.start(1.5)

	if Input.is_action_pressed("throw"):
		print("winding up throw ")
		toggle_images(true)

	if Input.is_action_just_released("throw"):
		print("no longer winding up, throw!")
		toggle_images(false)
		throw_projectile()
		# LZB NOTE 19-06-25 - need to actually put throwing code in here lol

func throw_projectile():
	var throw_direction = mouse_pos.normalized()
	
	var normalized_distance = min(distance / max_mouse_radius, 1.0)
	print(normalized_distance, " is the lesser of dist/mmr vs 1.0")
	
	var throw_force = lerp(min_throw_force, max_throw_force,normalized_distance)
	print("The force of the throw should be ", throw_force)
	
	var new_projectile = chosen_weapon.instantiate()
	new_projectile.global_position = throw_origin.global_position
	get_tree().current_scene.add_child(new_projectile)
	debug_projectile_direction_sprite.position = throw_direction * max_mouse_radius
	#time to send that shit flying
	if new_projectile.has_method("start_countdown"):
		var pass_in_time: float
		if weapon_counter == 0:
			pass_in_time = bomb_explosion_timer
		if weapon_counter == 1:
			pass_in_time = flare_timer
		new_projectile.start_countdown(pass_in_time)
	
	if new_projectile is RigidBody2D:
		new_projectile.apply_impulse(throw_direction * throw_force, Vector2.ZERO)
		print(throw_direction * throw_force)
	else: 
		push_error("that's not a blardy RB2D!")

func check_weapon_selected():
	if  weapon_counter == 0:
		projectile_holdup.texture = bomb_image
		chosen_weapon = bomb_prefab
	if weapon_counter == 1:
		projectile_holdup.texture = flare_image
		chosen_weapon = flare_prefab

func toggle_images(bool_input: bool):
	projectile_target.visible = bool_input
	projectile_holdup.visible = bool_input

func reduce_ammunition():
	if  weapon_counter == 0:
		bomb_quantity = bomb_quantity - 1
	if weapon_counter == 1:
		flare_quantity = flare_quantity -1
	ammunition_changed.emit()

func increase_flares(amount: int):
	flare_quantity = flare_quantity + amount
	ammunition_changed.emit()

func increase_bombs(amount: int):
	bomb_quantity = bomb_quantity + amount
	ammunition_changed.emit()

func get_bomb_quantity():
	return bomb_quantity
func get_flare_quantity():
	return flare_quantity

func _on_display_timer_timeout() -> void:
	# LZB NOTE 20-06-25 - we want to turn the image off unless the player is holding left click
	if Input.is_action_pressed("throw"):
		return
	else:
		projectile_holdup.visible = false

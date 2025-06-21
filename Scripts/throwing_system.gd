extends Node2D

@onready var projectile_target: Sprite2D = $ProjectileTarget
@onready var projectile_holdup: Sprite2D = $ProjectileHoldup
@onready var debug_projectile_direction_sprite: Sprite2D = $DEBUG_ProjectileDirectionSprite
@onready var throw_origin: Marker2D = $ThrowOrigin
@onready var holdup_display_timer: Timer = $DisplayTimer
@onready var empty_sound: AudioStreamPlayer2D = $Empty_Sound
@onready var throw_sound: AudioStreamPlayer2D = $Throw_Sound
@onready var pickup_sound: AudioStreamPlayer2D = $Pickup_sound



@export var bomb_image: Texture2D
@export var flare_image: Texture2D
@export var bomb_prefab: PackedScene
@export var flare_prefab: PackedScene
@export var bomb_quantity: int = 5
@export var flare_quantity: int = 5
@export var bomb_explosion_timer: float = 3.0
@export var flare_timer: float = 30.0
@export var min_throw_force: float = 10.0
@export var max_throw_force: float = 10000.0
#@export var can_activate: bool = true

@export_group("Debug Settings")
@export var debug_infinite_ammo : bool = false

var mouse_pos
var distance
var max_mouse_radius := 800.0
var weapon_counter: int = 1 #0 is bomb, 1 is flare
var chosen_weapon: PackedScene


signal bombs_increased
signal flares_increased


func _ready() -> void:
	set_process(false)
	ammunition_changed() #doing this to set the singleton with the right ammo
	check_weapon_selected()
	projectile_target.visible = false
	projectile_holdup.visible = false
	await get_tree().create_timer(0.25).timeout
	set_process(true) # LZB NOTE 21-06-25 - just a short delay to stop a flare getting thrown by the player entering

func _process(_delta: float) -> void:
	
	mouse_pos = get_local_mouse_position()
	distance = mouse_pos.length()
	if distance > max_mouse_radius:
		projectile_target.position = mouse_pos.normalized() * max_mouse_radius
	else:
		projectile_target.position = mouse_pos
	
	if Input.is_action_just_pressed("select_bomb"):
		weapon_counter = 0
		check_weapon_selected()
		projectile_holdup.visible = true
		holdup_display_timer.start(1.5)
	
	if Input.is_action_just_pressed("select_flare"): #this will hard set to flare
		weapon_counter = 1
		check_weapon_selected()
		projectile_holdup.visible = true
		holdup_display_timer.start(1.5)
	
	if Input.is_action_just_pressed("change_weapon"):
		weapon_counter = (weapon_counter + 1) % 2
		print("current number for weapon counter is ", weapon_counter)
		check_weapon_selected()
		projectile_holdup.visible = true
		holdup_display_timer.start(1.5)
	
	if Input.is_action_pressed("throw"):
		projectile_target.visible = true
		projectile_holdup.visible = true
	
	if Input.is_action_just_released("throw"):
		projectile_target.visible = false
		projectile_holdup.visible = false
		if weapon_counter == 0:
			if bomb_quantity > 0 or debug_infinite_ammo:
				throw_projectile()
				bomb_quantity -= 1 
				ammunition_changed()
			else:
				print("player doesnt have enough bombs!")
				empty_sound.play()
		if weapon_counter == 1:
			if flare_quantity > 0 or debug_infinite_ammo:
				throw_projectile()
				flare_quantity -= 1
				ammunition_changed()
			else:
				print("player doesnt have enough flares!")
				empty_sound.play()

func throw_projectile():
	var throw_direction = mouse_pos.normalized()
	var normalized_distance = min(distance / max_mouse_radius, 1.0)
	print(normalized_distance, " is the lesser of dist/mmr vs 1.0")
	var throw_force = lerp(min_throw_force, max_throw_force,normalized_distance)
	print("The force of the throw should be ", throw_force)
	
	var new_projectile = chosen_weapon.instantiate()
	new_projectile.global_position = throw_origin.global_position
	get_tree().current_scene.add_child(new_projectile)
	#debug_projectile_direction_sprite.position = throw_direction * max_mouse_radius
	if new_projectile is RigidBody2D: 	#time to send that shit flying
		new_projectile.apply_impulse(throw_direction * throw_force, Vector2.ZERO)
		throw_sound.play()
		print(throw_direction * throw_force)
	else: 
		push_error("that's not a blardy RB2D!")
	
	var pass_in_time: float
	if weapon_counter == 0:
		pass_in_time = bomb_explosion_timer
	if weapon_counter == 1:
		pass_in_time = flare_timer
	new_projectile.start_countdown(pass_in_time)

func check_weapon_selected():
	if  weapon_counter == 0:
		projectile_holdup.texture = bomb_image
		chosen_weapon = bomb_prefab
	if weapon_counter == 1:
		projectile_holdup.texture = flare_image
		chosen_weapon = flare_prefab

func ammunition_changed():
	if PlayerStats.instance != null:
		PlayerStats.instance.player_bombs = bomb_quantity
		PlayerStats.instance.player_flares = flare_quantity
	else:
		push_warning("No PlayerStats instance available.")

func increase_flares(amount: int):
	flare_quantity += amount
	pickup_sound.play()
	ammunition_changed()
	flares_increased.emit()

func increase_bombs(amount: int):
	bomb_quantity += amount
	pickup_sound.play()
	ammunition_changed()
	bombs_increased.emit()


func _on_display_timer_timeout() -> void:
	# LZB NOTE 20-06-25 - we want to turn the image off unless the player is holding left click
	if Input.is_action_pressed("throw"):
		return
	else:
		projectile_holdup.visible = false

#func toggle_images(bool_input: bool):
	#projectile_target.visible = bool_input
	#projectile_holdup.visible = bool_input


#func get_bomb_quantity():
	#return bomb_quantity
#func get_flare_quantity():
	#return flare_quantity

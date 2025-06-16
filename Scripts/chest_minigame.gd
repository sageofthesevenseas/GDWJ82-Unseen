extends Node2D

@export var minigame_speed: float = 2.0

@onready var mini_game_path_3: Path2D = $"."
@onready var target_bar: PathFollow2D = $TargetBar
@onready var player_pin: PathFollow2D = $PlayerPin

enum MinigameState { STOPPED, SETUP,READY, RUNNING }
@export var game_state: MinigameState = MinigameState.STOPPED

@export var setup_rotation_speed: float = 0.5
var tbar_target_position: float
var target_range_min: float
var target_range_max: float
@export var target_range_offset: float = 0.04

var minigame_ready_triggered: bool = false
signal minigame_ready
signal minigame_completed

func change_state(statename: String):
	if MinigameState.has(statename):
		game_state = MinigameState[statename]
		print(self, " state is being changed to ", statename)
	else:
		push_error("invalid state name: " + statename)

func run():
	print("running minigame")
	change_state("RUNNING") #start the playerpin moving

func stop():
	change_state("STOPPED")
	

func prep():
	print("running setup of ", self)
	change_state("SETUP")
	var tbar_starting_position = randf_range(0,1) # start the bar somewhere random so it moves into the right spot from a different place every time
	target_bar.progress_ratio = tbar_starting_position
	tbar_target_position = randf_range(0.2,0.93) 	# pick position of the target. Can't be set to 0 as thats cruel
	print("target position of the target bar is ", tbar_target_position)
	target_range_min = tbar_target_position - target_range_offset
	target_range_max = tbar_target_position + target_range_offset #move the min and max ranges based on the tolerance we want to give
	player_pin.progress_ratio = 0.0 # reset the player position

func _process(delta: float) -> void:
	if game_state == MinigameState.STOPPED: return
	if game_state == MinigameState.READY: return
	
	if game_state == MinigameState.SETUP:
		target_bar.progress_ratio = move_toward(target_bar.progress_ratio, tbar_target_position, 0.005)
		if is_equal_approx(target_bar.progress_ratio, tbar_target_position):
			change_state("READY")
			emit_minigame_ready() #this will also stop emit from happening 10000 times
	
	if game_state == MinigameState.RUNNING:
		if Input.is_action_pressed("dig"): #player has to hold the key to progress
			#print("dig being held")
			player_pin.progress_ratio += minigame_speed * delta
		else:
			player_pin.progress_ratio -= minigame_speed * delta
		if Input.is_action_just_released("dig"):
			if player_pin.progress_ratio > target_range_min and player_pin.progress_ratio < target_range_max:
				print("congrats!")
				emit_minigame_completed()
				change_state("STOPPED")
			else:
				print("not quite")

func emit_minigame_completed():
	minigame_completed.emit()

func emit_minigame_ready():
	minigame_ready.emit()
	print(self," minigame is ready")

func flip_calc():
	var flip = randi_range(-1,1)
	print("flip value is, ", flip)

func _on_debug_timer_timeout() -> void:
# LZB NOTE 15-06-25 - remove when we have better methods of starting minigame
	prep()

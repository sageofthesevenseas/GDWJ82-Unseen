extends Node2D

@export var minigame_speed: float = 2.0

@onready var mini_game_path_3: Path2D = $"."
@onready var target_bar: PathFollow2D = $TargetBar
@onready var player_pin: PathFollow2D = $PlayerPin

@export var game_state: String = "stopped"
# LZB NOTE 15-06-25 - possibles are "stopped", "setup", and "running"

@export var setup_rotation_speed: float = 0.5
var tbar_target_position: float
var target_range_min: float
var target_range_max: float
@export var target_range_offset: float = 0.07

signal minigame_ready
signal minigame_completed

func _ready() -> void:
	prep_minigame()
func run_minigame():
	print("running minigame")
	# LZB NOTE 15-06-25 - start the playerpin moving
	game_state = "running"
func stop_minigame():
	game_state = "stopped"
func prep_minigame():
	print("running setup of minigame")
	game_state = "setup"
	var tbar_starting_position = randf_range(0,1)
	target_bar.progress_ratio = tbar_starting_position
	tbar_target_position = randf_range(0.2,0.93) 	# pick position of the target. Can't be set to 0 as thats cruel
	print("target position of the target bar is ", tbar_target_position)
	target_range_min = tbar_target_position - target_range_offset
	target_range_max = tbar_target_position + target_range_offset #move the min and max ranges based on the tolerance we want to give
	player_pin.progress_ratio = 0.0 # reset the player position

func _process(delta: float) -> void:
	if game_state == "stopped":
		return
	if game_state == "setup":
		target_bar.progress_ratio = move_toward(target_bar.progress_ratio, tbar_target_position, 0.005)
		if is_equal_approx(target_bar.progress_ratio, tbar_target_position):
			emit_minigame_ready()
			game_state = "ready"
	if game_state == "running":
		player_pin.progress_ratio += minigame_speed * delta


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
	prep_minigame()

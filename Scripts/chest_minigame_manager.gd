class_name ChestMinigameManager extends Node2D
@onready var mini_game_1: Path2D = $MiniGame1
@onready var mini_game_2: Path2D = $MiniGame2
@onready var mini_game_3: Path2D = $MiniGame3
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var open_sound: AudioStreamPlayer2D = $Open_sound
@onready var click_sound: AudioStreamPlayer2D = $Click_Sound

@export var DEBUG_run_mini_on_ready: bool = false
signal chest_game_beaten

func _ready() -> void:
	if DEBUG_run_mini_on_ready == true:
		start_minigame()

#func start_minigame(relevant_hidden_chest : HiddenChest) -> void:
func start_minigame() -> void:
	visible = true
	mini_game_1.visible = true
	mini_game_2.visible = true
	mini_game_3.visible = true
	animation_player.play("RESET")
	mini_game_1.prep()
	mini_game_2.prep()
	mini_game_3.prep()
	# LZB NOTE 16-06-25 - play starting noise

# LZB NOTE 16-06-25 - we only care when minigame 1 is ready, so we just get right to it
func _on_mini_game_1_minigame_ready() -> void:
	print("received ready call, telling minigame 1 to run")
	mini_game_1.run()

func _on_mini_game_1_minigame_completed() -> void:
	mini_game_2.run()
	click_sound.play()

func _on_mini_game_2_minigame_completed() -> void:
	mini_game_3.run()
	click_sound.play()

func _on_mini_game_3_minigame_completed() -> void:
	print("player has completed minigame!")
	mini_game_1.visible = false
	mini_game_2.visible = false
	mini_game_3.visible = false
	animation_player.play("Open")
	click_sound.play()
	open_sound.play()
	chest_game_beaten.emit()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		exit_minigame()

func exit_minigame():
	mini_game_1.stop()
	mini_game_2.stop()
	mini_game_3.stop()
	visible = false
	
	

extends StaticBody2D
class_name ExposedChest

@onready var sprites: Node2D = $Sprites
@onready var chest_top: Sprite2D = $"Sprites/Chest Top"

@export var chest_opened: bool = false
@export var max_items: int = 15

@export var cheese_reward: PackedScene
@export var bomb_reward: PackedScene
@export var flare_reward: PackedScene
@export var story_reward: PackedScene
var item_choice_array = [cheese_reward, bomb_reward, flare_reward]

@export_range(0, 9) var passed_in_story: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	appear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("dig"):
		#start_minigame()

func appear():
	sprites.visible = true

func start_minigame():
	var chest_minigame = get_tree().get_first_node_in_group("chestminigame")
	chest_minigame.start_minigame()
	chest_minigame.chest_game_beaten.connect(on_minigame_finished)

func on_minigame_finished():
	if chest_opened == true:
		return
	chest_opened = true
	chest_top.visible = false
	create_rewards()

func pass_in_story(storynum: int):
	passed_in_story = storynum

func create_rewards():
	var number_of_rewards = randi_range(5, max_items)
	for i in number_of_rewards:
		var selected_item: PackedScene
		var selection = randi_range(1,3)
		if selection == 1:
			selected_item = bomb_reward
		if selection == 2:
			selected_item = flare_reward
		if selection == 3:
			selected_item = cheese_reward
		if i == 1:
			selected_item = story_reward
		var new_item: Node2D = selected_item.instantiate()
		new_item.global_position = global_position
		new_item.passed_in_story = passed_in_story
		get_parent().add_child(new_item)
		# LZB NOTE 22-06-25 - now yeet that MF into orbit

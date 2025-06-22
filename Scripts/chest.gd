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
@export var shoot_force: float = 2500.0
@export_range(0, 9) var passed_in_story: int = 0
var story_options = [0,1,2,3,4,5,6,7,8,9]

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

func pass_in_story(_storynum: int): # LZB NOTE 22-06-25 - Deprecated! now uses pick a story instead!
	#passed_in_story = storynum
	pass

func pick_a_story():
	var lorefound = GameController.instance.lore_found
	for i in lorefound:
		if i == true:
			story_options.erase(i)
		print(story_options)
	passed_in_story = story_options.pick_random()

func create_rewards():
	var number_of_rewards = randi_range(10, max_items)
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
			pick_a_story()
		var new_item: RigidBody2D = selected_item.instantiate()
		new_item.global_position = global_position
		new_item.passed_in_story = passed_in_story
		get_parent().add_child(new_item)
		shoot_item(new_item)
		# LZB NOTE 22-06-25 - now yeet that MF into orbit

func shoot_item(fired_item: RigidBody2D):
	var pick_pos_x = randf_range(-1,1)
	var direction = Vector2(pick_pos_x, -1).normalized()
	var force = direction * shoot_force
	fired_item.apply_impulse(force)
	

extends StaticBody2D
class_name ExposedChest

@onready var sprites: Node2D = $Sprites
@onready var chest_top: Sprite2D = $"Sprites/Chest Top"

@export var chest_opened: bool = false

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
	chest_opened = true
	chest_top.visible = false

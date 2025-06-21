extends StaticBody2D

@onready var sprites: Node2D = $Sprites

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	appear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func appear():
	sprites.visible = true

extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $"Animated Sprite"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func appear():
	animated_sprite.visible == true

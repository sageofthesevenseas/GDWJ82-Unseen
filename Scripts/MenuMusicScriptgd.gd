extends FmodEventEmitter2D

func _ready() -> void:
	var MenuNode = get_node("../")
	MenuNode.connect("start_game", Callable(self, "_on_start_game"))
func _on_start_game ():
	self.set_parameter("GameStart", 1)

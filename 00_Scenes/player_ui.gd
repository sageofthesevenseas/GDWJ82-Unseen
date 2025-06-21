extends CanvasLayer



signal screenshake()
"entered_darkness"
func _ready():
	var player = get_tree().get_first_node_in_group("player")
	player.connect("entered_darkness", Callable(self, "_on_entering_darkness"))
	player.connect("exited_darkness", Callable(self, "_on_exiting_darkness"))
	player.connect("damage_taken", Callable(self, "_on_damage_taken"))

func _process(_delta: float) -> void:
	$BombValue.text = str(PlayerStats.instance.get_bombs())
	$TorchValue.text = str(PlayerStats.instance.get_flares())
func _on_entering_darkness():
	$LightIndicator.texture = load("res://UI_Textures/Moon.png")
func _on_exiting_darkness():
	$LightIndicator.texture = load("res://UI_Textures/Sun.png")
	
func _on_damage_taken():
	var health = PlayerStats.instance.get_health()
	$HeartOutside/HeartInside.scale = Vector2(health, health) / 100
	#emit_signal("screenshake")
	print(screenshake)
	

extends CanvasLayer

signal screenshake()

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	player.connect("entered_darkness", Callable(self, "_on_entering_darkness"))
	player.connect("exited_darkness", Callable(self, "_on_exiting_darkness"))
	player.connect("damage_taken", Callable(self, "_on_damage_taken"))
	
	get_tree().get_first_node_in_group("throwingsystem").connect("ui_bomb_active", Callable(self, "_on_ui_bomb_active"))
	get_tree().get_first_node_in_group("throwingsystem").connect("ui_torch_active", Callable(self, "_on_ui_torch_active"))
	
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
	emit_signal("screenshake")
	print(screenshake)


func show_lore(index : int) -> void:
	$Logs.visible = true
	$Logs.get_child(index).visible = true
	$"../SFX".process_mode = Node.PROCESS_MODE_ALWAYS
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameController.instance.zoom_enable = false
	get_tree().paused = true
	get_tree().get_first_node_in_group(&"throwingsystem").can_throw = false
	fx_handler.instance._on_play_sound("paper")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action(&"Escape") and event.is_pressed() and $Logs.visible:
		get_viewport().set_input_as_handled()
		close_lores()

func close_lores() -> void:
	for i in GameController.instance.lore_found.size():
		$Logs.get_child(i).visible = false
	$Logs.visible = false
	$"../SFX".process_mode = Node.PROCESS_MODE_INHERIT
	process_mode = Node.PROCESS_MODE_INHERIT
	GameController.instance.zoom_enable = true
	get_tree().paused = false
	get_tree().get_first_node_in_group(&"throwingsystem").enable_throw_after_delay()
	fx_handler.instance._on_play_sound("paper")

	
func _on_ui_bomb_active():
	$BombActiveIndicator.visible = true
	$TorchActiveIndicator.visible = false

func _on_ui_torch_active():
	$BombActiveIndicator.visible = false
	$TorchActiveIndicator.visible = true


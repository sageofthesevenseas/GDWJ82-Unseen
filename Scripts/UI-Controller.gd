extends Control


signal start_game
signal play_sound(sfx_name)
signal get_gameplay_nodes
var not_in_main_menu = false
var menu_open = false
var fmods

func _ready() -> void:
	set_parent_material_recurse(self)
	fmods = get_tree().get_nodes_in_group("fmod")

func set_parent_material_recurse(node : CanvasItem) -> void:
	for child in node.get_children():
		child.use_parent_material = true
		if child is CanvasItem: set_parent_material_recurse(child)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_game_start_pressed() -> void:
	emit_signal("play_sound", "accept")
	emit_signal("start_game")
	emit_signal("get_gameplay_nodes")
	print("Signals emmitted")
	not_in_main_menu = true

func _on_credits_pressed() -> void:
	emit_signal("play_sound", "accept")
	$Main.visible = false
	$Credits.visible = true
	GameController.instance.zoom_enable = true

func _on_settings_pressed() -> void:
	emit_signal("play_sound", "accept")
	$Main.visible = false
	$Settings.visible = true
	
func _on_return_pressed() -> void:
	emit_signal("play_sound", "accept")
	$Credits.visible = false
	$Journals.visible = false
	$Settings.visible = false
	$Main.visible = true
	GameController.instance.zoom_enable = false
	GameController.instance.zoom_reset()



func _on_journals_pressed() -> void:
	emit_signal("play_sound", "accept")
	$Main.visible = false
	$Journals.visible = true
	
func _on_fx_h_slider_drag_ended(value_changed : bool) -> void:
	if not value_changed:
		return
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"SFX Master"), $Settings/FX_HSlider.value)
	emit_signal("play_sound", "accept")

func _on_sfx_toggle_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(&"SFX Master"), not toggled_on)

func _on_mx_h_slider_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Music Master"), $Settings/MX_HSlider.value)
	
func _on_mx_toggle_toggled(toggled_on: bool) -> void:
	 #doesn't work because fmod isn't funnelled into the music master bus. # LZB NOTE 22-06-25 - have no fear my friend, I am here to help
	AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Music Master"), not toggled_on)
		#for i: FmodEventEmitter2D in fmods:
		#if toggled_on == true:
			#i.volume = $Settings/MX_HSlider.value
		#if toggled_on == false:
			#i.volume = 0.0
var camera_zoom_before_pausemenu : Vector2
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action(&"Escape") and event.is_pressed() and not_in_main_menu:
		if GameController.instance.in_game_over:
			return
		
		if not menu_open:
			open_menu()
		else:
			close_menu()
		get_viewport().set_input_as_handled()


func _on_button_1_pressed() -> void:
	GameController.instance.add_lore(0)

func _on_button_2_pressed() -> void:
	GameController.instance.add_lore(1)

func _on_button_3_pressed() -> void:
	GameController.instance.add_lore(2)

func _on_button_4_pressed() -> void:
	GameController.instance.add_lore(3)

func _on_button_5_pressed() -> void:
	GameController.instance.add_lore(4)

func _on_button_6_pressed() -> void:
	GameController.instance.add_lore(5)

func _on_button_7_button_up() -> void:
	GameController.instance.add_lore(6)

func _on_button_8_pressed() -> void:
	GameController.instance.add_lore(7)

func _on_button_9_pressed() -> void:
	GameController.instance.add_lore(8)

func _on_button_10_pressed() -> void:
	GameController.instance.add_lore(9)
	
func _on_continue_pressed():
	if get_tree().get_first_node_in_group(&"throwingsystem"):
		get_tree().get_first_node_in_group(&"throwingsystem").can_throw = false
		get_tree().get_first_node_in_group(&"throwingsystem").enable_throw_after_delay()
	emit_signal("play_sound", "accept")
	close_menu()

func open_menu() -> void:
	var camera = get_viewport().get_camera_2d()
	camera_zoom_before_pausemenu = camera.zoom
	camera.zoom = Vector2(1,1)
	camera.position_smoothing_enabled = false
	get_node("/root/GameController/GUI").position = camera.global_position
	self.visible = true
	$Main.visible = true
	$Main/GameStart.visible = false
	$Main/Continue.visible = true
	get_tree().get_first_node_in_group("PlayerUI").visible = false
	menu_open = true
	get_tree().paused = true
	print("menu opened")
	GameController.instance.zoom_enable = false


func close_menu() -> void:
	var camera = get_viewport().get_camera_2d()
	camera.zoom = camera_zoom_before_pausemenu
	camera.position_smoothing_enabled = true
	self.visible = false
	$Main.visible = false
	$Credits.visible = false
	$Journals.visible = false
	$Settings.visible = false
	$Main/GameStart.visible = true
	$Main/Continue.visible = false
	get_tree().get_first_node_in_group("PlayerUI").visible = true
	menu_open = false
	print("menu closed")
	get_tree().paused = false
	GameController.instance.zoom_enable = true

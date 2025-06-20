extends Control


signal start_game
signal play_sound(sfx_name)
var not_in_main_menu = false
var menu_open = false

func _on_ready():
	var not_in_main_menu = false
	var menu_open = false


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_game_start_pressed() -> void:
	emit_signal("play_sound", "accept")
	emit_signal("start_game")
	print("Signal emmitted")
	not_in_main_menu = true
	GameController.instance.add_lore(0)

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
	$Main.visible = true
	GameController.instance.zoom_enable = false
	GameController.instance.zoom_reset()



func _on_journals_pressed() -> void:
	emit_signal("play_sound", "accept")
	$Main.visible = false
	$Journals.visible = true
	
func _on_fx_h_slider_value_changed(value: float) -> void:
	emit_signal("play_sound", "accept")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		print("menu call recieved")
	if Input.is_action_just_pressed("Escape") and not_in_main_menu and menu_open == false:
		var player_position = get_node("root/GameController/World2D/CharacterBody2D")
		self.position = player_position.position
		self.visible = true
		$Main.visible = true
		$Main/GameStart.visible = false
		menu_open = true
		print("menu closed")
	elif Input.is_action_just_pressed("Escape") and not_in_main_menu and menu_open:
		self.visible = false
		$Main.visible = false
		$Main/GameStart.visible = true
		menu_open = false
		print("menu closed")
		
		
	

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

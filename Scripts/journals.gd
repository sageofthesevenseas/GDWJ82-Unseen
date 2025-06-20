extends Control

signal play_sound(sfx_name)

func _ready() -> void:
	pass
	
func spawn_unavailable_label():
	var unseen_message = preload("res://UI_Textures/label_unseen.tscn").instantiate()
	self.add_child(unseen_message)


func _on_button_log_1_pressed() -> void:
	if GameController.instance.lore_found[0] == true:
		emit_signal("play_sound", "paper")
		$Logs/LogBackground1.visible = true
		$JournalSelectors.visible = false
		$Close.visible = true
	else:
		spawn_unavailable_label()
		emit_signal("play_sound", "decline")

func _on_button_log_2_pressed() -> void:
	if GameController.instance.lore_found[1] == true:
		emit_signal("play_sound", "paper")
		$Logs/LogBackground2.visible = true
		$JournalSelectors.visible = false
		$Close.visible = true
	else:
		spawn_unavailable_label()
		emit_signal("play_sound", "decline")
		
func _on_button_log_3_pressed() -> void:
	if GameController.instance.lore_found[2] == true:
		emit_signal("play_sound", "paper")
		$JournalSelectors.visible = false
		$Logs/LogBackground3.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		emit_signal("play_sound", "decline")
		
func _on_button_log_4_pressed() -> void:
	if GameController.instance.lore_found[3] == true:
		emit_signal("play_sound", "paper")
		$JournalSelectors.visible = false
		$Logs/LogBackground4.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		emit_signal("play_sound", "decline")
		
func _on_button_log_5_pressed() -> void:
	if GameController.instance.lore_found[4] == true:
		emit_signal("play_sound", "paper")
		$JournalSelectors.visible = false
		$Logs/LogBackground5.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		emit_signal("play_sound", "decline")
		
func _on_button_log_6_pressed() -> void:
	if GameController.instance.lore_found[5] == true:
		emit_signal("play_sound", "paper")
		$JournalSelectors.visible = false
		$Logs/LogBackground6.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		emit_signal("play_sound", "decline")
		
func _on_button_log_7_pressed() -> void:
	if GameController.instance.lore_found[6] == true:
		emit_signal("play_sound", "paper")
		$JournalSelectors.visible = false
		$Logs/LogBackground7.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		emit_signal("play_sound", "decline")
		
func _on_button_log_8_pressed() -> void:
	if GameController.instance.lore_found[7] == true:
		emit_signal("play_sound", "paper")
		$JournalSelectors.visible = false
		$Logs/LogBackground8.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		emit_signal("play_sound", "decline")
		
func _on_button_log_9_pressed() -> void:
	if GameController.instance.lore_found[8] == true:
		emit_signal("play_sound", "paper")
		$JournalSelectors.visible = false
		$Logs/LogBackground9.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		emit_signal("play_sound", "decline")
		
func _on_button_log_10_pressed() -> void:
	if GameController.instance.lore_found[9] == true:
		emit_signal("play_sound", "paper")
		$JournalSelectors.visible = false
		$Logs/LogBackground10.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		emit_signal("play_sound", "decline")
		
func _on_close_pressed() -> void:
	emit_signal("play_sound", "paper")
	$Logs/LogBackground1.visible = false
	$Logs/LogBackground2.visible = false
	$Logs/LogBackground3.visible = false
	$Logs/LogBackground4.visible = false
	$Logs/LogBackground5.visible = false
	$Logs/LogBackground6.visible = false
	$Logs/LogBackground7.visible = false
	$Logs/LogBackground8.visible = false
	$Logs/LogBackground9.visible = false
	$Logs/LogBackground10.visible = false
	$JournalSelectors.visible = true
	$Close.visible = false

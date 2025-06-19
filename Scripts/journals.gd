extends Control

func _ready() -> void:
	pass
	
func spawn_unavailable_label():
	var unseen_message = preload("res://UI_Textures/label_unseen.tscn").instantiate()
	self.add_child(unseen_message)


func _on_button_log_1_pressed() -> void:
	if GameController.instance.lore_found[0] == true:
		$Logs/LogText1.visible = true
		$JournalSelectors.visible = false
		$Close.visible = true
	else:
		spawn_unavailable_label()

func _on_button_log_2_pressed() -> void:
	if GameController.instance.lore_found[1] == true:
		$Logs/LogText2.visible = true
		$JournalSelectors.visible = false
		$Close.visible = true
	else:
		spawn_unavailable_label()
		
func _on_button_log_3_pressed() -> void:
	if GameController.instance.lore_found[2] == true:
		$JournalSelectors.visible = false
		$Logs/LogText3.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		
func _on_button_log_4_pressed() -> void:
	if GameController.instance.lore_found[3] == true:
		$JournalSelectors.visible = false
		$Logs/LogText4.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		
func _on_button_log_5_pressed() -> void:
	if GameController.instance.lore_found[4] == true:
		$JournalSelectors.visible = false
		$Logs/LogText5.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		
func _on_button_log_6_pressed() -> void:
	if GameController.instance.lore_found[5] == true:
		$JournalSelectors.visible = false
		$Logs/LogText6.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		
func _on_button_log_7_pressed() -> void:
	if GameController.instance.lore_found[6] == true:
		$JournalSelectors.visible = false
		$Logs/LogText7.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		
func _on_button_log_8_pressed() -> void:
	if GameController.instance.lore_found[7] == true:
		$JournalSelectors.visible = false
		$Logs/LogText8.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		
func _on_button_log_9_pressed() -> void:
	if GameController.instance.lore_found[8] == true:
		$JournalSelectors.visible = false
		$Logs/LogText9.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		
func _on_button_log_10_pressed() -> void:
	if GameController.instance.lore_found[9] == true:
		$JournalSelectors.visible = false
		$Logs/LogText10.visible = true
		$Close.visible = true
	else:
		spawn_unavailable_label()
		
func _on_close_pressed() -> void:
	$Logs/LogText1.visible = false
	$Logs/LogText2.visible = false
	$Logs/LogText3.visible = false
	$Logs/LogText4.visible = false
	$Logs/LogText5.visible = false
	$Logs/LogText6.visible = false
	$Logs/LogText7.visible = false
	$Logs/LogText8.visible = false
	$Logs/LogText9.visible = false
	$Logs/LogText10.visible = false
	$JournalSelectors.visible = true
	$Close.visible = false
	
	
	
	
	
	

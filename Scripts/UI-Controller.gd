extends Control


signal start_game
	
	
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_game_start_pressed() -> void:
	emit_signal("start_game")
	print("Signal emmitted")
	pass # Replace with function body.

func _on_credits_pressed() -> void:
	$Main.visible = false
	$Credits.visible = true

func _on_return_pressed() -> void:
	$Credits.visible = false
	$Main.visible = true
	

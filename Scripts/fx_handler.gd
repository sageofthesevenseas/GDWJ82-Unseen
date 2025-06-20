extends Node




func _ready():
	await get_tree().process_frame
	var menu_signal_listen = get_node("/root/GameController/GUI/UI_Handler")
	menu_signal_listen.connect("play_sound", Callable(self, "_on_play_sound"))
	var journal_signal_listen = get_node("/root/GameController/GUI/UI_Handler/Journals")
	journal_signal_listen.connect("play_sound", Callable(self, "_on_play_sound"))
	
func _on_play_sound(sfx_name):
	print("Sound Queue recieved")
	get_node(sfx_name).play()

extends Node

class_name fx_handler
static var instance : fx_handler

func _ready():
	instance = self
	await get_tree().create_timer(1.0).timeout
	var menu_signal_listen = get_node("/root/GameController/GUI/UI_Handler")
	print(menu_signal_listen)
	menu_signal_listen.connect("play_sound", Callable(self, "_on_play_sound"))
	# menu_signal_listen.connect("get_gameplay_nodes", Callable(self, "on_get_gameplay_nodes"))
	var journal_signal_listen = get_tree().get_first_node_in_group("Journals")
	journal_signal_listen.connect("play_sound", Callable(self, "_on_play_sound"))


func _on_play_sound(sfx_name):
	print("Sound Queue recieved")
	get_node(sfx_name).play()

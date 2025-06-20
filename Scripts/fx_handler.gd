extends Node

class_name fx_handler
static var instance : fx_handler
@export var accept_default_volume : float = 15
@export var paper_default_volume : float = 20
@export var decline_default_volume : float = 10

var default_volume_dict = {
	"accept": accept_default_volume,
	"paper": paper_default_volume,
	"decline": decline_default_volume
}

func _ready():
	instance = self
	await get_tree().process_frame
	var menu_signal_listen = get_node("/root/GameController/GUI/UI_Handler")
	menu_signal_listen.connect("play_sound", Callable(self, "_on_play_sound"))
	var journal_signal_listen = get_node("/root/GameController/GUI/UI_Handler/Journals")
	journal_signal_listen.connect("play_sound", Callable(self, "_on_play_sound"))
	
func _on_play_sound(sfx_name):
	print("Sound Queue recieved")
	var sfx_volume = get_node("/root/GameController/GUI/UI_Handler/Settings/FX_HSlider").value
	get_node(sfx_name).set_volume_db(default_volume_dict[sfx_name] * sfx_volume)
	get_node(sfx_name).play()

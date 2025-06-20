extends Area2D
class_name HiddenChest

@export var real_chest: PackedScene

var item_passed # LZB NOTE 15-06-25 - no var for now, needs to be a packed scene I think

func spawn_real_chest():
	print("time to spawn a real chest G")
	var new_chest: Node2D = real_chest.instantiate()
	new_chest.global_position = global_position
	get_parent().add_child(new_chest)
	queue_free()

func pass_in_item (item):
	item_passed = item

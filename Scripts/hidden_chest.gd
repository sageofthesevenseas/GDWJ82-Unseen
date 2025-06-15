extends Area2D
class_name HiddenChest

var item_passed # LZB NOTE 15-06-25 - no var for now, needs to be a packed scene I think

func pass_in_item (item):
	item_passed = item

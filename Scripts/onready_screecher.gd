extends Node
# LZB NOTE 15-06-25 - this script is to be attached as a child to the node that you want to debug
func _ready() -> void:
	var parent = get_parent()
	print(parent, " is reaching ready")

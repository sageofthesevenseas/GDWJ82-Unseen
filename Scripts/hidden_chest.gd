extends Area2D
class_name HiddenChest

@export var real_chest: PackedScene
@export_range(0, 9)  var passed_in_story: int = 0

func spawn_real_chest():
	print("time to spawn a real chest G")
	var new_chest: Node2D = real_chest.instantiate()
	new_chest.global_position = global_position
	get_parent().add_child(new_chest)
	new_chest.pass_in_story(passed_in_story)
	queue_free()

func pass_in_story(storynum: int):
	passed_in_story = storynum

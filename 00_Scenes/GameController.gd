extends Node
class_name GameController
static var instance: GameController

@onready var camera: Node2D = $Camera


func _ready() -> void:
	instance = self
	var resolution : Vector2 = get_viewport().get_visible_rect().size
	var Main_Menu = preload("res://00_Scenes/UI.tscn").instantiate()
	var WorldNode = get_node("World2D")
	var GuiNode = get_node("GUI")	    
	Main_Menu.position -= Vector2(resolution.x/2, resolution.y/2)
	GuiNode.add_child(Main_Menu)
	var MenuNode = get_node("GUI/UI_Handler")
	MenuNode.connect("start_game", Callable(self, "_on_start_game"))
<<<<<<< Updated upstream
	
	# deeply evil code. just for debugging.
	DebugMenuSingleton.story_logs_toggled.connect(func (toggled_on : bool) -> void: for i in lore_found.size(): lore_found[i] = toggled_on)
=======
	var UI_Nodes = $GUI/UI_Handler.get_children()

	for nodes in UI_Nodes:
		nodes.use_parent_material = true
		var node_children = nodes.get_children()
		for node_grandchildren in node_children:
			node_grandchildren.use_parent_material = true
			var node_grandgrandchildren = node_grandchildren.get_children()
			for node_elderchildren in node_grandgrandchildren:
				node_elderchildren.use_parent_material = true
>>>>>>> Stashed changes

var lore_found : Array = [
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
]
var zoom_enable : bool = false


func zoom_reset():
	var cam = get_tree().get_first_node_in_group("camera")
	cam.zoom = Vector2(1.0, 1.0)




func add_lore(index : int) -> void:
	lore_found[index] = true
	print(lore_found)


func _on_start_game():
	var WorldNode = get_node("World2D")
	var GuiNode = get_node("GUI")
	var MenuNode = get_node("GUI/UI_Handler")
	var Level = preload("res://00_Scenes/TestScenery.tscn").instantiate()
	WorldNode.add_child(Level)
	spawn_player_and_switch_camera()
	MenuNode.visible = false
	
	$FmodEventEmitter2D_Menu.set_parameter("GameStart", 1)
	$Timer.start()

	
func _on_timer_timeout() -> void:
	$FmodEventEmitter2D_Cave.play()


func spawn_player_and_switch_camera():
	var WorldNode = get_node("World2D")
	var GuiNode = get_node("GUI")
	var MenuNode = get_node("GUI/UI_Handler")
	var Player = preload("res://00_Scenes/character.tscn").instantiate()
	var camera = get_tree().get_first_node_in_group("camera")
	camera.reparent(Player)
	WorldNode.add_child(Player)
	zoom_enable = true

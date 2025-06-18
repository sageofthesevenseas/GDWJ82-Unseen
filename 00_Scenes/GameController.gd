extends Node
@onready var camera: Node2D = $Camera

func _ready() -> void:
	var resolution : Vector2 = get_viewport().get_visible_rect().size
	var Main_Menu = preload("res://00_Scenes/UI.tscn").instantiate()
	var WorldNode = get_node("World2D")
	var GuiNode = get_node("GUI")
	
	
	Main_Menu.position -= Vector2(resolution.x/2, resolution.y/2)
	GuiNode.add_child(Main_Menu)
	var MenuNode = get_node("GUI/UI_Handler")
	MenuNode.connect("start_game", Callable(self, "_on_start_game"))
	pass

func _on_start_game():
	var WorldNode = get_node("World2D")
	var GuiNode = get_node("GUI")
	var MenuNode = get_node("GUI/UI_Handler")
	print("Loading Test Scenery")
	var Level = preload("res://00_Scenes/TestScenery.tscn").instantiate()
	WorldNode.add_child(Level)
	spawn_player_and_switch_camera()
	GuiNode.remove_child(MenuNode)

func spawn_player_and_switch_camera():
	var WorldNode = get_node("World2D")
	var GuiNode = get_node("GUI")
	var MenuNode = get_node("GUI/UI_Handler")
	var Player = preload("res://00_Scenes/character.tscn").instantiate()
	var camera = preload("res://00_Scenes/camera.tscn")
	var MenuCamera = get_node("Camera")
	WorldNode.add_child(Player)
	var camera_instance = camera.instantiate()
	Player.add_child(camera_instance)
	camera_instance.make_current()
	pass

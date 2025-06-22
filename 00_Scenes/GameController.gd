extends Node
class_name GameController
static var instance: GameController

@onready var camera: Node2D = $Camera

signal player_ui_ready()

# can't go to menu via escape while this is the case!!
var in_game_over : bool = false


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
	$FmodEventEmitter2D_Menu.play()
	
	# deeply evil code. just for debugging.
	DebugMenuSingleton.story_logs_toggled.connect(func (toggled_on : bool) -> void: for i in lore_found.size(): lore_found[i] = toggled_on)


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
	emit_signal("player_ui_ready")
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
	get_tree().get_first_node_in_group("player").connect("health_depleted", Callable(self, "_on_health_depleted"))
	zoom_enable = true

func _on_health_depleted():
	get_tree().get_first_node_in_group("camera").reparent(get_node("/root/GameController"))
	get_tree().get_first_node_in_group("camera").global_position = Vector2(0, 0)
	for child in $World2D.get_children():
		child.queue_free()
	get_tree().paused = true
	$GameOver.visible = true
	zoom_enable = false
	zoom_reset()
	in_game_over = true

func _on_return_pressed() -> void:
	$FmodEventEmitter2D_Cave.stop()
	$FmodEventEmitter2D_Menu.set_parameter("GameStart", 0)
	$FmodEventEmitter2D_Menu.play()
	$GameOver.visible = false
	get_tree().paused = false
	var MenuNode = get_node("GUI/UI_Handler")
	MenuNode.visible = true
	MenuNode.not_in_main_menu = false
	in_game_over = false

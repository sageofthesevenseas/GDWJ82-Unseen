extends Control

signal infinite_ammo_toggled(toggled_on : bool)
signal enemy_nav_hints_toggled(toggled_on : bool)
signal story_logs_toggled(toggled_on : bool)

var debug_menu_scene : PackedScene = load("res://00_Scenes/Debug Nodes/debug_menu.tscn")

func _ready() -> void:
	add_child(debug_menu_scene.instantiate())
	await get_tree().process_frame
	set_material_recursively(get_child(0), get_child(0).material)
	($DebugMenu/VBoxContainer/InfiniteAmmo/InfiniteAmmo as CheckButton).toggled.connect(on_infinite_ammo_toggled)
	($DebugMenu/VBoxContainer/ShowEnemyNavHints/ShowEnemyNavHints as CheckButton).toggled.connect(on_enemy_nav_hints_toggled)
	($DebugMenu/VBoxContainer/ToggleStoryLogs/ToggleStoryLogs as CheckButton).toggled.connect(on_story_logs_toggled)
	visible = false

func set_material_recursively(node : Control, the_material : Material) -> void:
	node.material = the_material
	for child in node.get_children():
		if child is Control:
			set_material_recursively(child, the_material)

func _input(event: InputEvent) -> void:
	if event.is_action(&"debug_menu_toggle") and event.is_pressed():
		visible = !visible

func _process(_delta: float) -> void:
	global_position = (-(get_canvas_transform() * Vector2(0,0))) / get_viewport().get_camera_2d().zoom
	scale = Vector2(1,1) / get_viewport().get_camera_2d().zoom

func on_infinite_ammo_toggled(toggled_on : bool) -> void:
	infinite_ammo_toggled.emit(toggled_on)

func on_enemy_nav_hints_toggled(toggled_on : bool) -> void:
	enemy_nav_hints_toggled.emit(toggled_on)

func on_story_logs_toggled(toggled_on : bool) -> void:
	story_logs_toggled.emit(toggled_on)

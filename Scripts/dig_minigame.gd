class_name DigMinigameManager extends Node2D

signal correct_key_pressed()
signal incorrect_key_pressed()

signal score_goal_reached()

@export var score_goal : int = 4
var score : int = 0
enum Keys { UP = 0, LEFT = 1, DOWN = 2, RIGHT = 3 }
# This could be anything else, but is just these characters for now.
var keys_string : Array = [ 
	preload("res://ItemTextures/arrow_up.png"),
	preload("res://ItemTextures/arrow_left.png"),
	preload("res://ItemTextures/arrow_down.png"),
	preload("res://ItemTextures/arrow_right.png")
	]
var keys_action : Array[StringName] = [ &"move_up", &"move_left", &"move_down", &"move_right" ]

var cur_key : Keys
var next_key : Keys

enum State { IDLE, PLAYING }
var state := State.IDLE

var cur_key_box_i : int = 0
var next_key_box_i : int = 1
@onready var key_boxes : Array[Control] = [ $Control/KeyBox0, $Control/KeyBox1 ]

func _ready() -> void:
	visible = false

var _relevant_hidden_chest : HiddenChest

func start_minigame(hidden_chest : HiddenChest) -> void:
	_relevant_hidden_chest = hidden_chest
	visible = true
	state = State.PLAYING
	cur_key = Keys.values().pick_random()
	next_key = Keys.values().pick_random()
	update_key_box_textures()
	move_key_boxes()

func quit_minigame() -> void:
	state = State.IDLE
	score = 0
	visible = false

func _physics_process(delta : float) -> void:
	if state == State.IDLE:
		return
	if Input.is_action_just_pressed(keys_action[cur_key]):
		on_correct_key_pressed()
	else:
		for key in Keys.values():
			if key != cur_key and Input.is_action_just_pressed(keys_action[key]):
				on_incorrect_key_pressed()
	# update_key_box_positions(delta)
	($PlaceholderScoreDisplay as Label).text = "score %d/%d" % [score, score_goal]

func swap_key_boxes() -> void:
	var temp_i := cur_key_box_i
	cur_key_box_i = next_key_box_i
	next_key_box_i = temp_i
	var temp_key := cur_key
	cur_key = next_key
	next_key = temp_key

func update_key_box_textures() -> void:
	(key_boxes[cur_key_box_i].get_child(1) as TextureRect).texture = keys_string[cur_key]
	(key_boxes[next_key_box_i].get_child(1) as TextureRect).texture = keys_string[next_key]

var tween : Tween
func move_key_boxes(move_left : bool = true) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	var middle_position : Vector2 = Vector2(0,0)
	var right_position : Vector2 = Vector2(128,0)
	var far_right_position : Vector2 = Vector2(160,0)

	var middle_scale : Vector2 = Vector2(1,1)
	var right_scale : Vector2 = Vector2(0.875,0.875)
	var far_right_scale : Vector2 = Vector2(0.875,0.875)
	var disappear_scale : Vector2 = Vector2(0.25,0.25)

	var middle_alpha : float = 1.0
	var right_alpha : float = 0.8
	var far_right_alpha : float = 0.5
	var disappear_alpha : float = 0.0
	if move_left:
		# middle box → disappear
		key_boxes[next_key_box_i].position = middle_position
		key_boxes[next_key_box_i].scale = middle_scale
		key_boxes[next_key_box_i].modulate.a = middle_alpha
		var mod := key_boxes[next_key_box_i].modulate
		mod.a = disappear_alpha
		key_boxes[next_key_box_i].visible = true
		tween.tween_property(key_boxes[next_key_box_i], ^"scale", disappear_scale, 0.1).set_trans(Tween.TransitionType.TRANS_LINEAR)
		tween.tween_property(key_boxes[next_key_box_i], ^"modulate", mod, 0.1).set_trans(Tween.TransitionType.TRANS_LINEAR)

		# right box → middle
		key_boxes[cur_key_box_i].position = right_position
		key_boxes[cur_key_box_i].scale = right_scale
		key_boxes[cur_key_box_i].modulate.a = right_alpha
		mod = key_boxes[cur_key_box_i].modulate
		mod.a = middle_alpha
		key_boxes[cur_key_box_i].visible = true
		tween.tween_property(key_boxes[cur_key_box_i], ^"position", middle_position, 0.16).set_trans(Tween.TransitionType.TRANS_CUBIC)
		tween.tween_property(key_boxes[cur_key_box_i], ^"scale", middle_scale, 0.16).set_trans(Tween.TransitionType.TRANS_SINE)
		tween.tween_property(key_boxes[cur_key_box_i], ^"modulate", mod, 0.16).set_trans(Tween.TransitionType.TRANS_CUBIC)

		# far right box → right
		mod = key_boxes[next_key_box_i].modulate
		mod.a = far_right_alpha
		tween.chain().tween_property(key_boxes[next_key_box_i], ^"position", far_right_position, 0.0).set_trans(Tween.TransitionType.TRANS_LINEAR)
		tween.tween_property(key_boxes[next_key_box_i], ^"scale", far_right_scale, 0.0).set_trans(Tween.TransitionType.TRANS_LINEAR)
		tween.tween_property(key_boxes[next_key_box_i], ^"modulate", mod, 0.0).set_trans(Tween.TransitionType.TRANS_LINEAR)
		if score + 2 >= score_goal:
			tween.tween_property(key_boxes[next_key_box_i], ^"visible", false, 0.0)
		mod.a = right_alpha
		tween.chain().tween_property(key_boxes[next_key_box_i], ^"position", right_position, 0.1).set_trans(Tween.TransitionType.TRANS_CIRC)
		tween.tween_property(key_boxes[next_key_box_i], ^"scale", right_scale, 0.1).set_trans(Tween.TransitionType.TRANS_LINEAR)
		tween.tween_property(key_boxes[next_key_box_i], ^"modulate", mod, 0.1).set_trans(Tween.TransitionType.TRANS_LINEAR)
	else:
		# right box → far right
		key_boxes[cur_key_box_i].position = right_position
		key_boxes[cur_key_box_i].scale = right_scale
		key_boxes[cur_key_box_i].modulate.a = far_right_alpha
		var mod := key_boxes[cur_key_box_i].modulate
		mod.a = disappear_alpha
		key_boxes[cur_key_box_i].visible = true
		if score + 1 >= score_goal:
			key_boxes[cur_key_box_i].visible = false
		tween.tween_property(key_boxes[cur_key_box_i], ^"position", far_right_position, 0.07).set_trans(Tween.TransitionType.TRANS_EXPO)
		tween.tween_property(key_boxes[cur_key_box_i], ^"modulate", mod, 0.07).set_trans(Tween.TransitionType.TRANS_LINEAR)

		# prepare box for middle appear
		mod = key_boxes[cur_key_box_i].modulate
		mod.a = far_right_alpha*0.2
		tween.chain().tween_property(key_boxes[cur_key_box_i], ^"position", middle_position, 0.0).set_trans(Tween.TransitionType.TRANS_LINEAR)
		tween.tween_property(key_boxes[cur_key_box_i], ^"scale", disappear_scale, 0.0).set_trans(Tween.TransitionType.TRANS_LINEAR)
		tween.tween_property(key_boxes[cur_key_box_i], ^"modulate", mod, 0.0).set_trans(Tween.TransitionType.TRANS_LINEAR)
		tween.tween_property(key_boxes[cur_key_box_i], ^"visible", true, 0.0)

		# middle appear box
		mod.a = middle_alpha
		tween.chain().tween_property(key_boxes[cur_key_box_i], ^"scale", middle_scale, 0.15).set_trans(Tween.TransitionType.TRANS_CIRC)
		tween.tween_property(key_boxes[cur_key_box_i], ^"modulate", mod, 0.2).set_trans(Tween.TransitionType.TRANS_CIRC)

		# middle box → right
		key_boxes[next_key_box_i].position = middle_position
		key_boxes[next_key_box_i].scale = middle_scale
		key_boxes[next_key_box_i].modulate.a = middle_alpha
		mod = key_boxes[next_key_box_i].modulate
		mod.a = right_alpha
		key_boxes[next_key_box_i].visible = true
		tween.tween_property(key_boxes[next_key_box_i], ^"position", right_position, 0.15).set_trans(Tween.TransitionType.TRANS_CUBIC)
		tween.tween_property(key_boxes[next_key_box_i], ^"scale", right_scale, 0.2).set_trans(Tween.TransitionType.TRANS_CIRC)
		tween.tween_property(key_boxes[next_key_box_i], ^"modulate", mod, 0.15).set_trans(Tween.TransitionType.TRANS_LINEAR)

func on_correct_key_pressed() -> void:
	swap_key_boxes()
	next_key = Keys.values().pick_random()
	update_key_box_textures()
	state = State.PLAYING
	move_key_boxes(true)
	score += 1
	emit_signal(&"correct_key_pressed")
	if score == score_goal:
		on_score_goal_reached()

func on_incorrect_key_pressed() -> void:
	swap_key_boxes()
	cur_key = Keys.values().pick_random()
	update_key_box_textures()
	state = State.PLAYING
	move_key_boxes(false)
	score = maxi(score - 1, 0)
	emit_signal(&"incorrect_key_pressed")

func on_score_goal_reached() -> void:
	quit_minigame()
	emit_signal(&"score_goal_reached")
	# TODO: Remove the hidden chest, spawn physical chest

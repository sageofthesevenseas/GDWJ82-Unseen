class_name DigMinigameManager extends Node2D

signal correct_key_pressed()
signal incorrect_key_pressed()

signal score_goal_reached()

@export var score_goal : int = 4
var score : int = 0
enum Keys { UP = 0, LEFT = 1, DOWN = 2, RIGHT = 3 }
# This could be anything else, but is just these characters for now.
var keys_string : Array[String] = [ "↑", "←", "↓", "→" ]
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

func _physics_process(delta: float) -> void:
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
	(key_boxes[cur_key_box_i].get_child(1) as Label).text = keys_string[cur_key]
	(key_boxes[next_key_box_i].get_child(1) as Label).text = keys_string[next_key]

var tween : Tween
func move_key_boxes() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	key_boxes[cur_key_box_i].position = Vector2(128,8)
	key_boxes[cur_key_box_i].scale = Vector2(0.875, 0.875)
	key_boxes[cur_key_box_i].modulate.a = 0.8
	var mod := key_boxes[cur_key_box_i].modulate
	mod.a = 1.0
	tween.set_parallel(true)
	tween.tween_property(key_boxes[cur_key_box_i], ^"position", Vector2(0,0), 0.1).set_trans(Tween.TransitionType.TRANS_EXPO)
	tween.tween_property(key_boxes[cur_key_box_i], ^"scale", Vector2(1.0,1.0), 0.1).set_trans(Tween.TransitionType.TRANS_SINE)
	tween.tween_property(key_boxes[cur_key_box_i], ^"modulate", mod, 0.1).set_trans(Tween.TransitionType.TRANS_CUBIC)

	key_boxes[next_key_box_i].position = Vector2(160,8)
	key_boxes[next_key_box_i].scale = Vector2(0.875, 0.875)
	key_boxes[next_key_box_i].modulate.a = 0.5
	mod = key_boxes[next_key_box_i].modulate
	mod.a = 0.8
	tween.tween_property(key_boxes[next_key_box_i], ^"position", Vector2(128,8), 0.2).set_trans(Tween.TransitionType.TRANS_CIRC)
	tween.tween_property(key_boxes[next_key_box_i], ^"modulate", mod, 0.2).set_trans(Tween.TransitionType.TRANS_LINEAR)

func on_key_pressed() -> void:
	swap_key_boxes()
	next_key = Keys.values().pick_random()
	update_key_box_textures()
	state = State.PLAYING
	move_key_boxes()

func on_correct_key_pressed() -> void:
	on_key_pressed()
	score += 1
	emit_signal(&"correct_key_pressed")
	if score == score_goal:
		on_score_goal_reached()

func on_incorrect_key_pressed() -> void:
	on_key_pressed()
	score = maxi(score - 1, 0)
	emit_signal(&"incorrect_key_pressed")

func on_score_goal_reached() -> void:
	state = State.IDLE
	score = 0
	visible = false
	emit_signal(&"score_goal_reached")
	# TODO: Remove the hidden chest, spawn physical chest

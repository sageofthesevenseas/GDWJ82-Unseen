extends Node
class_name PlayerStats
static var instance: PlayerStats
# LZB NOTE 21-06-25 - please note that these stats are only a COPY of what the player systems are holding
#changing these stats will NOT change the actual player stats
var player_health: float
var player_bombs: int
var player_flares: int

@onready var debug_stat_declare_timer: Timer = $Debug_Stat_declare_Timer

@export var DEBUG_timer_delay: float = 1.0
@export var DEBUG_declaring_stats_enabled: bool = false
@export var DEBUG_HEALTH_declare: bool = false
@export var DEBUG_BOMB_declare: bool = false
@export var DEBUG_FLARE_declare: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance =  self
	if DEBUG_declaring_stats_enabled == true:
		debug_stat_declare_timer.start(DEBUG_timer_delay)

func get_health():
	return player_health

func get_bombs():
	return player_bombs

func get_flares():
	return player_flares

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_debug_stat_declare_timer_timeout() -> void:
	if DEBUG_HEALTH_declare == true:
		print("players current health is ", player_health)
	if DEBUG_BOMB_declare == true:
		print("players bomb count is ", player_bombs)
	if DEBUG_FLARE_declare == true:
		print("players flare count is ", player_flares)

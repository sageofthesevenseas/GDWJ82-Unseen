extends RigidBody2D
@onready var fizzle_timer: Timer = $FizzleTimer
@onready var torch: Node2D = $Torch

var fizzle_delay: float = 30.0
var torch_spin_animator: AnimationPlayer
var max_speed: float = 1.0

func _ready() -> void:
	if torch.has_node('AnimationPlayer'):
		torch_spin_animator = torch.get_node('AnimationPlayer')


func start_countdown(timer_delay: float):
	print(self, " been told to start CD, ", timer_delay)
	fizzle_timer.start(timer_delay)

func _physics_process(_delta: float) -> void:
	var current_speed = linear_velocity.length()/200
	if current_speed > max_speed:
		max_speed = current_speed
	var spin_speed = (max_speed * current_speed) / 150 #should produce something between 1 and 0 lol
	torch_spin_animator.speed_scale = spin_speed
	#print("current_speed is ", current_speed, ", max_speed is ", max_speed)
	#print("spin speed is ", spin_speed)

func _on_fizzle_timer_timeout() -> void:
	queue_free()

extends RigidBody2D
@onready var explosion_countdown: Timer = $ExplosionCountdown
@onready var removeable_children: Node2D = $RemoveableChildren
@onready var fuse_sizzle: AudioStreamPlayer2D = $FuseSizzle
@onready var explosion_radius: ShapeCast2D = $ExplosionRadius
@onready var enemydetector: Area2D = $enemydetector

var fuse_timer: float = 3.0
@export var queue_free_delay: float = 1.5
@export var explode_on_contact_with_enemy: bool = true
@export var damage_amount: float
# Called when the node enters the scene tree for the first time.

func start_countdown(timer_delay: float):
	print(self, " been told to start CD, ", timer_delay)
	explosion_countdown.start(timer_delay)

func explode():
	explosion_radius.force_shapecast_update()
	var body_count = explosion_radius.get_collision_count()
	for detected_item in body_count:
		var body = explosion_radius.get_collider(detected_item)
		if body.is_in_group("enemy"):
			(body as Enemy).take_damage(damage_amount)
	removeable_children.top_level = true
	removeable_children.global_position = global_position
	removeable_children.reparent(get_tree().get_first_node_in_group("projectileparent"), true)
	removeable_children.start_the_show(queue_free_delay) # LZB NOTE 20-06-25 - we do all this so that the kids audio and SFX does not get cut off when the bomb blows up and queues free
	queue_free()

func _on_explosion_countdown_timeout() -> void:
	explode()

func _on_enemydetector_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if explode_on_contact_with_enemy == true:
			explode()

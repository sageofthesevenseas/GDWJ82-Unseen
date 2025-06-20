extends Node2D

@onready var explosion_vfx: CPUParticles2D = $ExplosionVFX
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound
@onready var queue_free_timer: Timer = $Queue_free_timer

func start_the_show(queue_free_delay: float):
	queue_free_timer.start(queue_free_delay)
	explosion_sound.play()
	explosion_vfx

func _on_queue_free_timer_timeout() -> void:
	queue_free()

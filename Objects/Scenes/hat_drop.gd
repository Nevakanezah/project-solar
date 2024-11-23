extends Node2D

@export var sprite_index: int = 1
@export var is_random := false

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_random:
		sprite_index = randi_range(1,3)
	$Sprite2D.frame = sprite_index

func _on_body_entered(body : CharacterBody2D):
	if body.has_method("on_hat_pickup"):
		body.on_hat_pickup(sprite_index)
		$Sprite2D.visible = false
		$passive_particles.emitting = false
		$pickup_particle.emitting = true
		GlobalSoundManager.play_hat_pickup()
		await get_tree().create_timer(1).timeout
		queue_free()

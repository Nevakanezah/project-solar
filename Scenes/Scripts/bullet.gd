class_name Bullet
extends CharacterBody2D

@export var hitbox : HitboxComponent

@export var speed := 1000.0
@export var damage := 1.0
@export var is_enemy := false
@export var max_pierce := 1
@export var lifespan := 10.0
@export var inaccuracy := 0.0

var current_pierce_count := 0
var ran_accuracy := 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if is_enemy:
		set_collision_mask_value(1, true)
		set_collision_mask_value(3, false)
		hitbox.set_collision_mask_value(1, true)
		hitbox.set_collision_mask_value(3, false)
		
	if hitbox:
		hitbox.hit_target.connect(_on_target_hit)
		
	ran_accuracy = randf_range(-inaccuracy, inaccuracy)

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation + deg_to_rad(ran_accuracy))
	velocity = direction * speed
	
	move_and_slide()
	
	if lifespan > 0.0:
		lifespan -= delta
	if lifespan <= 0.0:
		queue_free()

func _on_target_hit(victim : CollisionObject2D):
	current_pierce_count += 1
	var particle_colour : Color
	
	match victim.collision_layer:
		1: # Player
			particle_colour = Color(0.349, 0.196, 0.196)
		4:  # Enemy
			particle_colour = Color(0.459, 0.075, 0.086)
		8: # Obstacle
			particle_colour = Color(0.533, 0.267, 0.031)
		_: # Default
			particle_colour = Color(0, 0, 0, 0.004)
	#if victim.is_in_group("Player"):
		#particle_colour.hex(593232)
	#elif victim.is_in_group("Enemy"):
		#particle_colour.hex(751316)
	#elif victim.is_in_group("Obstacle"):
		#particle_colour.hex(884408)
	#else:
		#particle_colour.hex(00000001)

	$ImpactParticles.color = particle_colour
	$ImpactParticles.emitting = true
	$HitboxComponent.active = false
	$Sprite2D.visible = false
	
	if current_pierce_count >= max_pierce:
		await get_tree().create_timer(.3).timeout
		queue_free()

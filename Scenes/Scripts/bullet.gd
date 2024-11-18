class_name Bullet
extends CharacterBody2D

@export var hitbox : HitboxComponent

@export var speed := 1000.0
@export var damage := 1.0
#@export var is_enemy := false
@export var max_pierce := 1
@export var lifespan := 5.0
@export var inaccuracy := 0.0

var current_pierce_count := 0
var ran_accuracy := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var self_destruct_timer: Timer = $SelfDestructTimer

func _ready() -> void:
	if hitbox:
		hitbox.hit_target.connect(on_target_hit)
		
	ran_accuracy = randf_range(-inaccuracy, inaccuracy)
	self_destruct_timer.start(lifespan)
	
	## Pretty sure we inherit this from player now.
	#if is_enemy:
		#set_collision_mask_value(1, true)
		#set_collision_mask_value(3, false)

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation + deg_to_rad(ran_accuracy))
	
	velocity = direction * speed
	
	var collision := move_and_collide(velocity*delta)
	
	if collision:
		queue_free()

func _on_self_destruct_timer_timeout() -> void:
	queue_free()

func on_target_hit():
	current_pierce_count += 1
	
	if current_pierce_count >= max_pierce:
		queue_free()

class_name HealthComponent
extends Node

signal health_changed(health: float)

@export var hurtbox : HurtboxComponent
@export var animation_player : AnimationPlayer

@export var MAX_HEALTH := 10.0
@onready var health := MAX_HEALTH

@export var receives_grace_time := false
@export var MAX_GRACE_TIME := 0.5
@onready var grace_timer := 0.0

@onready var health_owner : CharacterBody2D = get_owner()

func _ready():
	if hurtbox:
		hurtbox.damaged.connect(on_damaged)

func _physics_process(delta):
	if receives_grace_time and grace_timer > 0.0:
		grace_timer -= delta
		
		if grace_timer <= 0.0:
			health_owner.invulnerable = false
			grace_timer = 0.0

func on_damaged(attack: Attack):
	if !health_owner.alive:
		return
	if health_owner.invulnerable:
		return
	
	health -= attack.damage
	health_changed.emit(health)
	
	if health <= 0:
		health = 0
		health_owner.alive = false
		if animation_player:
			animation_player.play("death")
		return
	
	if health_owner.receives_grace_time:
		grace_timer = MAX_GRACE_TIME
		health_owner.invulnerable = true

extends Node2D

signal player_weapon_fired()

@export var firing_position : Marker2D
@export var max_attack_cooldown := 0.6

@onready var player : Player = get_owner()
@onready var projectiles: Node = get_node("/root/Level/Projectiles")

var bullet_scene: PackedScene = preload("res://Objects/Scenes/bullet.tscn")

var attack_cooldown_remaining := 0.0
var attacking = true

func _physics_process(delta: float) -> void:
	
	if attack_cooldown_remaining > 0.0:
		attack_cooldown_remaining -= delta
		
		if attack_cooldown_remaining <= 0.0:
			attacking = true
			attack_cooldown_remaining = 0.0
	
	if Input.is_action_pressed("primary") and attacking:
		attacking = false
		attack_cooldown_remaining = max_attack_cooldown
		_handle_ranged_attack()

func _handle_ranged_attack() -> void:
	# REFERENCE CREDIT: https://github.com/Bitlytic/Strategy-GDScript/blob/master/Player/Scripts/player_weapon.gd
	# =============
		var player_direction = (get_global_mouse_position() - player.position).normalized()
		
		# If we're aiming at a different side, flip the firing position across the X axis
		if sign(player_direction.x) != sign(firing_position.position.x):
			firing_position.position.x *= -1
		
		var aim_direction = get_global_mouse_position() - firing_position.global_position
		
		# Spawn a bullet and give it a rotation based on the angle between the firing position and
		# the cursor's position.
		# The bullet will use this rotation to decide its direction.
		var spawned_bullet := bullet_scene.instantiate()
		
		spawned_bullet.is_enemy = false
		projectiles.add_child(spawned_bullet)
		spawned_bullet.global_position = firing_position.global_position
		spawned_bullet.rotation = aim_direction.angle()
	#=============
		player_weapon_fired.emit()

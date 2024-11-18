extends Node2D

@export var firing_position : Marker2D

@onready var player : Player = get_owner()
@onready var bullet_cooldown: Timer = $"../BulletCooldown"
@onready var projectiles: Node = get_node("/root/Level/Projectiles")

var bullet_scene: PackedScene = preload("res://Objects/Scenes/bullet.tscn")

var timer : Timer
var attack_time := 0.6
var attacking = false

func _physics_process(_delta: float) -> void:
	# CREDIT: https://github.com/Bitlytic/Strategy-GDScript/blob/master/Player/Scripts/player_weapon.gd
	# =============
	if Input.is_action_just_pressed("primary") and attacking:
		attacking = false
		bullet_cooldown.start()
		
		# If we're aiming at a different side, flip the firing position across the X axis
		if sign(player.aim_position.x) != sign(firing_position.position.x):
			firing_position.position.x *= -1
		
		# Spawn a bullet and give it a rotation based on the angle between the firing position and
		# the cursor's position.
		# The bullet will use this rotation to decide its direction.
		var spawned_bullet := bullet_scene.instantiate()
		var mouse_direction := get_global_mouse_position() - firing_position.global_position
		
		get_tree().root.add_child(spawned_bullet)
		projectiles.add_child(spawned_bullet)
		spawned_bullet.global_position = firing_position.global_position
		spawned_bullet.rotation = mouse_direction.angle()
	
	## Future expansion, maybe
	#for strategy in player.upgrades:
			#strategy.apply_upgrade(spawned_bullet)
	
	# ============

func _on_bullet_cooldown_timeout() -> void:
	attacking = true

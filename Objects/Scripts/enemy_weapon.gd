extends Node2D

signal enemy_shoot_event

@onready var weapon_owner : CharacterBody2D = get_owner()
@export var enabled := true
@export var firing_position : Marker2D

@export var max_attack_cooldown := 2.0
@export var rand_attack_delay := 1.0
@export var attack_damage := 10.0
@export var attack_range := 1000.0

@export var bullet_sprite: Texture2D
@export var bullet_speed := 500.0
@export var bullet_inaccuracy := 20.0

@onready var projectiles: Node = get_node("/root/Level/Projectiles")
@onready var player = get_node("/root/Level/Player")

var bullet_scene: PackedScene = preload("res://Objects/Scenes/bullet.tscn")

var attack_cooldown_remaining := 3.0
var attacking = false

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	if not player or not player.visible:
		return
	if attack_range > 0.0 and global_position.distance_to(player.global_position) > attack_range:
		return
	
	if attack_cooldown_remaining > 0.0:
		attack_cooldown_remaining -= delta
		
		if attack_cooldown_remaining <= 0.0:
			attacking = true
			attack_cooldown_remaining = 0.0
	
	if attacking:
		attacking = false
		attack_cooldown_remaining = max_attack_cooldown + randf_range(rand_attack_delay, -rand_attack_delay)
		if attack_range > 0.0:
			_handle_ranged_attack()
		else:
			_handle_melee_attack()


func _handle_ranged_attack() -> void:
	# REFERENCE CREDIT: https://github.com/Bitlytic/Strategy-GDScript/blob/master/Player/Scripts/player_weapon.gd
	# =============
	var player_direction = global_position.direction_to(player.global_position)
	
	# If we're aiming at a different side, flip the firing position across the X axis
	if sign(player_direction.x) != sign(firing_position.position.x):
		firing_position.position.x *= -1
	
	var bullet = bullet_scene.instantiate()
	bullet.is_enemy = true
	bullet.global_position = firing_position.global_position
	bullet.rotation = player_direction.angle()
	bullet.damage = attack_damage
	bullet.speed = bullet_speed
	bullet.inaccuracy = bullet_inaccuracy
	if bullet_sprite:
		bullet.bullet_image = bullet_sprite
		
	projectiles.add_child(bullet)
	# ============
	GlobalSoundManager.play_gunshot(4.0, 0.7, 1.3)
	enemy_shoot_event.emit()
	
func _handle_melee_attack():
	pass

extends CharacterBody2D

@export var difficulty_value: float = 1
@export var invincible_time: float = 0
@export var enemy_image: Texture2D
@export var enemy_size: float = 1
@export var speed: int = 200
@export var health: int = 2:
	set(value):
		health = value
		if health <= 0:
			queue_free()
@export var melee_damage: int = 1
@export var attack_speed: float = 0.2
@export var is_ranged: bool = true
@export var ideal_distance: int = 0
@export var ranged_damage: int = 1
@export var ranged_attack_speed: float = 1
@export var bullet_speed: int = 500
@export var bullet_image: Texture2D
@export var bullet_size: float = 1
@export var bullet_lifespan: float = 5
@export var bullet_inaccuracy: float = 20

var bullet_scene: PackedScene = preload("res://Scenes/bullet.tscn")
# "active" is just for whether the enemy is doing anything. Set it to false to create a "stun" effect.
var active: bool = false
var attack_targets: Array
var invincible: bool = false

@onready var time: float = randf_range(0, 100)
@onready var sprite: Sprite2D = $Sprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var attack_timer: Timer = $AttackTimer
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var ranged_attack_timer: Timer = $RangedAttackTimer
@onready var player = get_node("/root/Level/Player")
@onready var projectiles: Node = get_node("/root/Level/Projectiles")

func _ready() -> void:
	navigation_agent.target_position = player.global_position
	scale *= enemy_size
	
	if enemy_image:
		sprite.texture = enemy_image
	
	attack_timer.wait_time = attack_speed
	attack_timer.start()
	
	if is_ranged:
		ranged_attack_timer.wait_time = ranged_attack_speed
		ranged_attack_timer.start()
		
		ideal_distance = 300
	
	# active must start false and be set to true to avoid an annoying little inconsequential error
	# that happens whenever the enemy tries to get the next path position before the navigation 
	# agent can find a path.
	await get_tree().create_timer(0.05).timeout
	active = true

func _physics_process(delta):
	if active:
		time += delta
		var next_path_pos: Vector2 = navigation_agent.get_next_path_position()
		var direction: Vector2 = (next_path_pos - global_position).normalized()
		navigation_agent.set_velocity(direction * speed)
		
		var look_angle = direction.angle()
		rotation = look_angle + PI / 2

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

# "circle" makes the enemy (usually ranged enemies) rotate around the player at a certain distance.
func _on_navigation_timer_timeout() -> void:
	var angle = (.2) * time
	var circle = Vector2(cos(angle) * ideal_distance, sin(angle) * ideal_distance)
	navigation_agent.target_position = player.global_position + circle

func hit(damage):
	if !invincible:
		if invincible_time != 0:
			invincible = true
			invincible_timer.start(invincible_time)
		
		health -= damage

func _on_damage_area_body_entered(body: Node2D) -> void:
	if "hit" in body:
		attack_targets.append(body)
		
		# Hits the player as soon as they enter and then restarts the attack timer so that the
		# enemy doesn't do more damage than expected.
		body.hit(melee_damage)
		attack_timer.start(attack_speed)

func _on_damage_area_body_exited(body: Node2D) -> void:
	if body in attack_targets:
		attack_targets.erase(body)

func _on_attack_timer_timeout() -> void:
	for body in attack_targets:
		if "hit" in body:
			body.hit(melee_damage)

func _on_invincible_timer_timeout() -> void:
	invincible = false

func _on_ranged_attack_timer_timeout() -> void:
	if !is_ranged:
		return
	
	var player_direction = global_position.direction_to(player.global_position)
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = player_direction
	bullet.damage = ranged_damage
	bullet.is_enemy = true
	bullet.speed = bullet_speed
	bullet.bullet_size = bullet_size
	bullet.lifespan = bullet_lifespan
	bullet.inaccuracy = bullet_inaccuracy
	
	if bullet_image:
		bullet.bullet_image = bullet_image
	
	projectiles.add_child(bullet)

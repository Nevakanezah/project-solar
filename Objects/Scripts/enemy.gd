extends CharacterBody2D

@onready var sprite: Sprite2D = $EnemySprite
@export var difficulty_value: float = 1
@export var speed: int = 200

@export var melee_damage: int = 1
@export var attack_speed: float = 0.2
@onready var melee_attack_timer: Timer = $MeleeAttackTimer

@export var ideal_distance : int = 300
@onready var time: float = randf_range(0, 100)
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

@onready var player = get_node("/root/Level/Player")
@onready var health_component: HealthComponent = $HealthComponent

var invulnerable: bool = false
var alive: bool = true

# "active" is just for whether the enemy is doing anything. Set it to false to create a "stun" effect.
var active: bool = false
var attack_targets: Array

func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	
	navigation_agent.target_position = player.global_position
	
	melee_attack_timer.wait_time = attack_speed
	melee_attack_timer.start()
	
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

func _on_damage_area_body_entered(body: Node2D) -> void:
	if "hit" in body:
		attack_targets.append(body)
		
		# Hits the player as soon as they enter and then restarts the attack timer so that the
		# enemy doesn't do more damage than expected.
		body.hit(melee_damage)
		melee_attack_timer.start(attack_speed)

func _on_damage_area_body_exited(body: Node2D) -> void:
	if body in attack_targets:
		attack_targets.erase(body)

func _on_attack_timer_timeout() -> void:
	for body in attack_targets:
		if "hit" in body:
			body.hit(melee_damage)

func _on_health_changed(health : float):
	if health <= 0:
		queue_free()

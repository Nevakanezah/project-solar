extends CharacterBody2D

@export var invincible_time: float = 0.5
@export var player_image: Texture2D
@export var player_size: float = 1
@export var health: int = 300:
	set(value):
		health = value
		ui.health_label.text = "Health: " + str(health)
		if health <= 0:
			ui.restart_screen.visible = true
			dead = true
@export var speed: int = 250
@export var base_damage: float = 1
@export var damage_mult: float = 1
@export var bullet_speed: int = 1000

var primary_available: bool = true
var invincible: bool = false
var dead: bool = false
var bullet_scene: PackedScene = preload("res://Scenes/bullet.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var projectiles: Node = get_node("/root/Level/Projectiles")
@onready var ui: Node = get_node("/root/Level/UI")
@onready var bullet_cooldown: Timer = $BulletCooldown
@onready var invincible_timer: Timer = $InvincibleTimer

func _ready() -> void:
	scale *= player_size
	
	if player_image:
		sprite.texture = player_image
	
	# Must wait for UI to be instantiated.
	await get_tree().create_timer(.05).timeout
	ui.health_label.text = "Health: " + str(health)

func _process(_delta):
	if dead:
		return
	
	var direction = Input.get_vector("left","right","up","down")
	velocity = direction * speed
	move_and_slide()
	
	look_at(get_global_mouse_position())
	var player_direction = (get_global_mouse_position() - position).normalized()
	
	if Input.is_action_pressed("primary") and primary_available:
		primary_available = false
		bullet_cooldown.start()
		
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = player_direction
		bullet.damage = base_damage * damage_mult
		bullet.speed = bullet_speed
		projectiles.add_child(bullet)

func hit(damage):
	if !invincible and !dead:
		invincible = true
		health -= damage
		invincible_timer.start(invincible_time)

func _on_bullet_cooldown_timeout() -> void:
	primary_available = true

func _on_invincible_timer_timeout() -> void:
	invincible = false

class_name Player
extends CharacterBody2D

@export var speed: int = 250
@export var base_damage: float = 1
@export var damage_mult: float = 1
@export var bullet_speed: int = 1000

var invulnerable: bool = false
var alive: bool = true

@onready var sprite: Sprite2D = $PlayerSprite
@onready var ui: Node = get_node("/root/Level/UI")
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:	
	# Must wait for UI to be instantiated.
	await get_tree().create_timer(.05).timeout
	ui.health_label.text = "Health: " + str(health_component.health)

func _physics_process(_delta):
	if !alive:
		return
	
	var direction = Input.get_vector("left","right","up","down")
	velocity = direction * speed
	move_and_slide()
	
	look_at(get_global_mouse_position())

func _on_health_changed(health : float):
	if health <= 0:
		queue_free()

class_name Player
extends CharacterBody2D

@onready var playerwalkingaudiostream = $"SFX/AudioStreamPlayer_fs"
@onready var asp_player_hurt = $"SFX/AudioStreamPlayer_hurt"

@export var speed: int = 250

@export var base_damage: float = 1
@export var damage_mult: float = 1
@export var bullet_speed: int = 1000

@onready var sprite: Sprite2D = $PlayerSprite
@onready var ui: Node = get_node("/root/Level/UI")
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	# Must wait for UI to be instantiated.
	await get_tree().create_timer(.05).timeout
	ui.health_label.text = "Health: " + str(health_component.health)

func _physics_process(delta):
	if not health_component.alive:
		return
	
	var direction = Input.get_vector("left","right","up","down")
	
	if direction != Vector2.ZERO:
		#velocity = direction * speed
		velocity = velocity.move_toward(direction * speed, delta*speed*8)
		
		if not playerwalkingaudiostream.playing:
			playerwalkingaudiostream.pitch_scale = randf_range(0.9, 1.2)
			playerwalkingaudiostream.play() #start sound on movement
	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta*speed*3)
		playerwalkingaudiostream.stop() #stop sound when idle
  
	move_and_slide()
	look_at(get_global_mouse_position())

func _on_health_changed(health : float):
	ui.health_label.text = "Health: " + str(health_component.health)
	asp_player_hurt.play()
	if health <= 0:
		_on_player_killed_event()

func _on_player_killed_event():
	visible = false

class_name Player
extends CharacterBody2D

@export var speed: int = 250

@export var base_damage: float = 1
@export var damage_mult: float = 1
@export var bullet_speed: int = 1000

@onready var animation_player = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	$PlayerWeapon.player_weapon_fired.connect(_on_weapon_fired)
	# Must wait for UI to be instantiated.
	await get_tree().create_timer(.05).timeout
	GlobalUI.update_healthbar(100.0)
	GlobalUI.update_hatbar(50.0)
	animation_player.play("idle")

func _physics_process(delta):
	if not health_component.alive:
		_play_animation("die")
		return
	
	var direction = Input.get_vector("left","right","up","down")
	
	if direction != Vector2.ZERO:
		_play_animation("walk")
		velocity = velocity.move_toward(direction * speed, delta*speed*8)
		GlobalSoundManager.play_footsteps()
	else:
		_play_animation("idle")
		velocity = velocity.move_toward(Vector2.ZERO, delta*speed*3)
		GlobalSoundManager.stop_footsteps()
  
	move_and_slide()

func _on_health_changed(health : float):
	GlobalUI.update_hatbar(health)
	GlobalSoundManager.play_hurt()
	_play_animation("on_hit")
	if health <= 0:
		_on_player_killed_event()

func _on_player_killed_event():
	speed = 0
	_play_animation("die")
	$PlayerWeapon.enabled = false
	$PlayerHatSprite.visible = false
	get_tree().call_group("GlobalPlayerEvents", "global_player_died_event")
	
func _on_weapon_fired():
	_play_animation("shoot")
	
func _play_animation(anim : String):
	var mouse_direction = position.direction_to(get_global_mouse_position())
	$PlayerSprite.flip_h = sign(mouse_direction.x) < 0 # Flip sprite if mouse position is to the left of us.
	$PlayerHatSprite.flip_h = sign(mouse_direction.x) < 0 # Same for our hat.
	if anim in ["walk"]:
		await animation_player.animation_finished
	animation_player.play(anim)

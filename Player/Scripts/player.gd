class_name Player
extends CharacterBody2D

@export var speed: int = 250

@export var base_damage: float = 1
@export var damage_mult: float = 1
@export var bullet_speed: int = 1000

@onready var animation_player = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent

const MAX_PLAYER_HP := 100.0
var current_player_hp : float
var player_dead := false

const SUN_DAMAGE_RATE := 5.0
var is_in_sunlight := true
var current_sun_damage := 0.0
var sunlight_timer := 0.0

func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	$PlayerWeapon.player_weapon_fired.connect(_on_weapon_fired)
	$HatComponent.reset_hat()
	current_player_hp = MAX_PLAYER_HP
	_update_sunlight_damage()
	
	# Must wait for UI to be instantiated.
	await get_tree().create_timer(.05).timeout
	GlobalUI.update_healthbar(current_player_hp)
	animation_player.play("idle")

func _physics_process(delta):
	if player_dead:
		return
		
	var mouse_direction = position.direction_to(get_global_mouse_position())
	$PlayerSprite.flip_h = sign(mouse_direction.x) < 0 # Flip sprite if mouse position is to the left of us.
	$HatComponent.flip_h(sign(mouse_direction.x) < 0) # Same for our hat.
	
	var direction = Input.get_vector("left","right","up","down")
	
	if direction != Vector2.ZERO:
		_play_animation("walk")
		velocity = velocity.move_toward(direction * speed, delta*speed*8)
		GlobalSoundManager.play_footsteps()
	else:
		_play_animation("idle")
		velocity = velocity.move_toward(Vector2.ZERO, delta*speed*3)
		GlobalSoundManager.stop_footsteps()
	
	# Dawn and dusk provide safety
	sunlight_timer += delta
	
	if is_in_sunlight and sunlight_timer >= 3.0:
		$SmokeEmitter.emitting = true
		current_player_hp -= current_sun_damage * delta
		GlobalUI.update_healthbar(current_player_hp)
		GlobalSoundManager.play_sizzle()
		get_tree().call_group("GlobalPlayerEvents", "camera_start_sizzle", 15 * (1-(current_sun_damage / current_player_hp)))
	
	if not is_in_sunlight and not player_dead:
		$SmokeEmitter.emitting = false
		GlobalSoundManager.stop_sizzle()
		get_tree().call_group("GlobalPlayerEvents", "camera_end_sizzle")
	
	# I'm tired of this not working.
	if sunlight_timer >= 56.0:
		$SmokeEmitter.emitting = false
		GlobalSoundManager.stop_sizzle()
		get_tree().call_group("GlobalPlayerEvents", "camera_end_sizzle")
		
	if current_player_hp <= 0.0:
		player_dead = true
		_on_player_killed_event()
		
	move_and_slide()

func _on_health_changed(hat_health : float):
	_update_sunlight_damage()
	
	GlobalSoundManager.play_hurt()
	_play_animation("on_hit")
	
	get_tree().call_group("GlobalPlayerEvents", "camera_shake_onhit")

func _update_sunlight_damage():
	# Update sun damage whenever our hat value changes
	# Sun DPS is 5, multiplied by the % of empty hat bar we have.
	current_sun_damage = SUN_DAMAGE_RATE * (1.0 - (health_component.health / health_component.MAX_HEALTH))

func _on_player_killed_event():
	speed = 0
	_play_animation("die")
	$PlayerWeapon.enabled = false
	$HatComponent.visible = false
	get_tree().call_group("GlobalPlayerEvents", "camera_end_sizzle")
	get_tree().call_group("GlobalPlayerEvents", "global_player_died_event")
	
func _on_weapon_fired():
	_play_animation("shoot")

func on_level_transition():
	current_player_hp = MAX_PLAYER_HP
	GlobalUI.update_healthbar(current_player_hp)
	#$HatComponent.reset_hat(0) # To reset hat health between levels. Makes game easier.
	sunlight_timer = 0.0

func on_hat_pickup(sprite_index : int):
	$HatComponent.pickup_hat(sprite_index)
	_update_sunlight_damage()
	
func _play_animation(anim : String):
	# idle < walk < literally everything else.
	# Yes this should have been a statemachine, don't @ me
	if animation_player.current_animation != "walk" and anim == "idle":
		await animation_player.animation_finished
	if animation_player.current_animation != "idle" and anim == "walk":
		await animation_player.animation_finished
		
	if player_dead and anim not in ["die"]:
		return
	animation_player.play(anim)

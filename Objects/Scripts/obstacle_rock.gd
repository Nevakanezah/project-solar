extends StaticBody2D

# NOTE Obstacles can't damage while visibility is false. If we want this to be an option for any
# reason then ask MrCowdisease to find a solution, I'm just not considering it a priority right now.
@export var visibility: bool = true
@export var can_damage: bool = false
@export var invincible: bool = true
@export var health: int = 5:
	set(value):
		health = value
		if health <= 0:
			queue_free()
@export var damage_amount: float = 1
@export var attack_speed: float = 0.2

var attack_targets: Array

@onready var attack_timer: Timer = $AttackTimer

func _ready() -> void:
	visible = visibility
	attack_timer.wait_time = attack_speed
	attack_timer.start()
	$Sprite2D.frame = randi_range(0, 2)
	if $ShadowComponent:
		$ShadowComponent.set_sprite_details($Sprite2D.texture, $Sprite2D.hframes, $Sprite2D.vframes, $Sprite2D.frame)

func _on_damage_area_body_entered(body: Node2D) -> void:
	if "hit" in body and can_damage:
		attack_targets.append(body)
		
		# Hits the player as soon as they enter and then restarts the attack timer so that the
		# enemy doesn't do more damage than expected.
		body.hit(damage_amount)
		attack_timer.start(attack_speed)

func _on_damage_area_body_exited(body: Node2D) -> void:
	if body in attack_targets:
		attack_targets.erase(body)

func _on_attack_timer_timeout() -> void:
	for body in attack_targets:
		if "hit" in body:
			body.hit(damage_amount)

func hit(damage):
	if !invincible:
		health -= damage

func restart_shadows():
	$ShadowComponent.start_shadow()

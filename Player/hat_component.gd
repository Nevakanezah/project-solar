class_name HatComponent
extends Node2D

signal hat_destroyed

@onready var hat_owner : CollisionObject2D = get_owner()
@onready var health_component : HealthComponent = $"../HealthComponent"

const HAT_DICT = {
	0: 50.0, # Default
	1: 20.0, # Small
	2: 40.0, # Medium
	3: 75.0  # Large
}

# Called when the node enters the scene tree for the first time.
func _ready():
	health_component.health_changed.connect(_on_health_changed)

func _on_health_changed(hat_health : float):
	if hat_health <= 0.0:
		$PlayerHatSprite.visible = false
		hat_destroyed.emit()
	
	GlobalUI.update_hatbar(hat_health)

func flip_h(is_flipped : bool):
	$PlayerHatSprite.flip_h = is_flipped

func pickup_hat(hat_index : int):
	$PlayerHatSprite.visible = true
	
	if HAT_DICT[hat_index] > health_component.health:
		$PlayerHatSprite.frame = hat_index
	var new_health = min(health_component.health + HAT_DICT[hat_index], health_component.MAX_HEALTH)
	health_component.health = new_health
	GlobalUI.update_hatbar(health_component.health)
	
func reset_hat():
	$PlayerHatSprite.visible = true
	$PlayerHatSprite.frame = 0
		
	health_component.health = HAT_DICT[0]
	GlobalUI.update_hatbar(health_component.health)
	
func _on_hat_pickup(hat_index : int):
	pass

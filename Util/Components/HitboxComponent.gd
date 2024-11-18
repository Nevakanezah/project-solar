class_name HitboxComponent
extends Area2D

# Hitbox component for bullets. This hits a target's hurtbox on contact.

signal hit_target

@onready var bullet : Bullet = get_owner()

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D):
	if area is HurtboxComponent:
		var attack := Attack.new()
		attack.damage = bullet.damage
		area.damage(attack)
		
		hit_target.emit()

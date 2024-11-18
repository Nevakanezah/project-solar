class_name HurtboxComponent
extends Area2D

# Hurtbox component. This gets hit by an attack's hitbox.
# HealthComponents can reference this to receive damage.

signal damaged(attack: Attack)

func damage(attack: Attack):
	damaged.emit(attack)

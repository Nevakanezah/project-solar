extends Area2D

@export var speed: int = 1000
@export var damage: int = 1
@export var is_enemy: bool = false
@export var bullet_image: Texture2D
@export var bullet_size: float = 1
@export var lifespan: float = 5
@export var inaccuracy: float = 0

var direction: Vector2 = Vector2.UP

@onready var sprite: Sprite2D = $Sprite2D
@onready var self_destruct_timer: Timer = $SelfDestructTimer

func _ready() -> void:
	if is_enemy:
		set_collision_mask_value(1, true)
		set_collision_mask_value(3, false)
	
	var ran_accuracy: float = randf_range(-inaccuracy, inaccuracy)
	
	if bullet_image:
		sprite.texture = bullet_image
	
	scale *= bullet_size
	rotation_degrees = rad_to_deg(direction.angle()) + ran_accuracy
	
	self_destruct_timer.start(lifespan)

func _physics_process(delta: float) -> void:
	position += Vector2(1, 0).rotated(rotation) * delta * speed

func _on_self_destruct_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if "hit" in body:
		body.hit(damage)
	queue_free()

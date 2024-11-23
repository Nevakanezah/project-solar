extends Node2D

func _ready():
	start_shadow()

func set_sprite_details(tex : CompressedTexture2D, h_frame : int = 1, v_frame : int = 1, index :  int = 0):
	$Sprite2D.texture = tex
	$Sprite2D.hframes = h_frame
	$Sprite2D.vframes = v_frame
	$Sprite2D.frame = index

func start_shadow():
	$AnimationPlayer.play("move_shadow")

func _on_area_entered(area : Area2D):
	area.get_parent().is_in_sunlight = false

func _on_area_exited(area : Area2D):
	area.get_parent().is_in_sunlight = true

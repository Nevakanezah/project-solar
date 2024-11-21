extends Node
## Used for fade in/out effect on scene transitions
## @tutorial: https://www.gdquest.com/tutorial/godot/2d/scene-transition-rect/

signal music_transition

func transition_to(next_scene: PackedScene):
	# Plays the fade animation and wait until it finishes
	$AnimationPlayer.play("Fade")
	emit_signal("music_transition")
	await $AnimationPlayer.animation_finished
	# Change the scene
	get_tree().change_scene_to_packed(next_scene)
	# Play animation to fade in
	$AnimationPlayer.play_backwards("Fade")

func play_fade_out():
	$AnimationPlayer.play("Fade")

func play_fade_in():
	$AnimationPlayer.play_backwards("Fade")

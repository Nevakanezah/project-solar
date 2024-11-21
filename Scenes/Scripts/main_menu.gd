class_name MainMenu
extends Control


func _init():
	# Disable buttons until we're ready to use them
	for child in get_children():
		if is_instance_of(child, TextureButton):
			child.disabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
	# Enable buttons
	for child in get_children():
		if is_instance_of(child, TextureButton):
			child.disabled = false

func _on_start_button_pressed():
	var next_scene = load("res://Scenes/level.tscn")
	SceneTransition.transition_to(next_scene)
	GlobalSoundManager.play_hurt()


func _on_exit_button_pressed():
	get_tree().quit()


func _on_quit_button_pressed():
	pass # Replace with function body.

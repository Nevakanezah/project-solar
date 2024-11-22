class_name MainMenu
extends Control


func _init():
	# Disable buttons until we're ready to use them
	_disable_buttons()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Enable buttons
	_enable_buttons()

func _on_start_button_pressed():
	var next_scene = load("res://Scenes/level.tscn")
	SceneTransition.transition_to(next_scene)
	GlobalSoundManager.play_hurt()
	_disable_buttons()

func _on_quit_button_pressed():
	get_tree().quit()
	
func _disable_buttons() -> void:
	for child in get_children(true):
		if is_instance_of(child, TextureButton):
			child.disabled = true

func _enable_buttons() -> void:
	for child in get_children():
		if is_instance_of(child, TextureButton):
			child.disabled = false

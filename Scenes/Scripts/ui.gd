extends CanvasLayer

@onready var health_label: Label = $HealthLabel
@onready var restart_screen: Control = $RestartScreen

func _ready() -> void:
	restart_screen.visible = false

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

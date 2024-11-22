extends CanvasLayer

func _ready() -> void:
	$RestartScreen.visible = false
	$HealthbarContainer.visible = false
	$"HealthbarContainer/HealthProgressBar".value = 100

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

func update_healthbar(health : float) -> void:
	$"HealthbarContainer/HealthProgressBar".value = health

func update_hatbar(health : float) -> void:
	$"HealthbarContainer/HatProgressBar".value = health

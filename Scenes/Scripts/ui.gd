extends CanvasLayer

# level can't be assigned straight away because since the UI is a global variable it's ready from
# the main menu, while level doesn't exist until the play button is pressed.
var level
@onready var day_complete := $DayComplete
@onready var victory: Control = $Victory
@onready var day_label: Label = $DayLabel

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

func _on_next_day_button_pressed() -> void:
	day_complete.visible = false
	
	var next_level
	for child in level.levels.get_children():
		if child.day == level.current_level.day + 1:
			next_level = child
	
	level.current_level = next_level
	level.start_next_day()

func _on_victory_button_pressed() -> void:
	get_tree().reload_current_scene()
	victory.visible = false

func global_player_died_event():
	$RestartScreen.visible = true

extends Node


@export var fade_duration := 2.0
@export var original_volume_db := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
@onready var sfx_footstep = $sfx_footstep

# Called when the node enters the scene tree for the first time.
func _ready():
	SceneTransition.music_transition.connect(_on_music_transition)

func _on_music_transition():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	var music_bus_index = AudioServer.get_bus_index("Music")
	var current_volume_db = AudioServer.get_bus_volume_db(music_bus_index)
	
		# Fade out
	tween.tween_method(set_bus_volume, current_volume_db, -80.0, fade_duration / 2)
		
	# Fade back in
	tween.tween_method(set_bus_volume, -80.0, original_volume_db, 0.1)
	
func set_bus_volume(volume_db: float):
	var music_bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus_index, volume_db)
	
func play_gunshot(volume : float = 0.0, pitch_bottom : float = 1.0, pitch_top : float = 1.0):
	$sfx_shoot.volume_db = volume
	$sfx_shoot.pitch_scale = randf_range(pitch_bottom, pitch_top)
	$sfx_shoot.play()

func play_hurt():
	$sfx_hurt.play()

func play_footsteps():
	if not sfx_footstep.playing:
		sfx_footstep.pitch_scale = randf_range(0.9, 1.2)
		sfx_footstep.play()

func stop_footsteps():
	sfx_footstep.stop()

func global_player_died_event():
	$sfx_player_die.play()

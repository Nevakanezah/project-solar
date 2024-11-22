extends Node2D

@export var level_amount := 5

var level_spawner_scene := preload("res://Scenes/level_spawner.tscn")
var backgroundmusicOn = true
var current_level

@onready var musicaudiostreamBG: AudioStreamPlayer2D = $Player/AudioStreamPlayerBGmusic
@onready var levels := $Levels
@onready var camera := $Camera2D
@onready var player: Player = $Player
@onready var enemies: Node = $Enemies

func _ready():
	GlobalUI.find_child("HealthbarContainer").visible = true
	GlobalUI.find_child("DayLabel").visible = true
	GlobalUI.level = get_tree().root.get_node("Level")
	
	for level in level_amount:
		level += 1
		var new_level = level_spawner_scene.instantiate()
		new_level.global_position.x = 2000 * level
		new_level.day = level
		levels.add_child(new_level)
		
		if new_level.day == 1:
			current_level = new_level
	
	camera.global_position = current_level.level_center.global_position
	player.global_position = camera.global_position
	start_next_day()

func _process(_delta):
	update_music_stats()
	
	camera.global_position = lerp(camera.global_position, current_level.level_center.global_position, 0.05)

func update_music_stats():
	if backgroundmusicOn:
		if !musicaudiostreamBG.playing:
				musicaudiostreamBG.play()
	else:
		musicaudiostreamBG.stop()

func start_next_day():
	# FIXME This code could potentially trigger before the camera reaches the next level's position.
	await get_tree().create_timer(0.5).timeout
	player.global_position = camera.global_position
	
	current_level.spawn_enemies = true
	current_level.length_timer.start()
	current_level.generate_enemies()
	
	GlobalUI.day_label.text = "Day: " + str(current_level.day)

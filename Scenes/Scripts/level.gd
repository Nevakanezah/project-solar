extends Node2D

@onready var musicaudiostreamBG = $AudioStreamPlayerBGmusic
var backgroundmusicOn = true

func _ready():
	GlobalUI.find_child("HealthbarContainer").visible = true

func _process(_delta):
	update_music_stats()
	
func update_music_stats():
	if backgroundmusicOn:
		if !musicaudiostreamBG.playing:
				musicaudiostreamBG.play()
	else:
		musicaudiostreamBG.stop()

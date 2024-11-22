extends Node2D

@export var level_length := 10
@export var day := 1
@export var min_obstacles := 2
@export var max_obstacles := 5

var spawn_enemies := false
var enemy_scene := preload("res://Objects/Scenes/enemy.tscn")
var obstacle_scene := preload("res://Objects/Scenes/obstacle_rock.tscn")

@onready var level = get_node("/root/Level")
@onready var length_timer: Timer = $LengthTimer
@onready var level_center: Marker2D = $LevelCenter
@onready var enemy_spawns: Node2D = $EnemySpawns
@onready var obstacles: Node2D = $Obstacles

@onready var invis_1: StaticBody2D = $Obstacles/InvisibleBorders/InvisibleBorder
@onready var invis_2: StaticBody2D = $Obstacles/InvisibleBorders/InvisibleBorder2
@onready var invis_3: StaticBody2D = $Obstacles/InvisibleBorders/InvisibleBorder3
@onready var invis_4: StaticBody2D = $Obstacles/InvisibleBorders/InvisibleBorder4

func _ready() -> void:
	length_timer.wait_time = level_length
	
	var obstacle_amount = randi_range(min_obstacles, max_obstacles)
	
	# FIXME This is where obstacles are randomly spawned in. This code doesn't prevent obstacles
	# from spawning on top of each other, but it at least stops it from spawning on the player.
	for obstacle in obstacle_amount:
		var new_obstacle = obstacle_scene.instantiate()
		obstacles.add_child(new_obstacle)
		
		var valid_position = false
		while !valid_position:
			@warning_ignore("narrowing_conversion")
			new_obstacle.global_position = Vector2(randi_range(invis_1.global_position.x + 100, invis_2.global_position.x - 100), randi_range(invis_3.global_position.y + 100, invis_4.global_position.y - 100))
			if new_obstacle.global_position.distance_to(level_center.global_position) >= 100:
				valid_position = true

func _on_length_timer_timeout() -> void:
	spawn_enemies = false
	
	if get_tree().get_nodes_in_group("Enemy").size() == 0:
		GlobalUI.day_complete.visible = true

func _on_enemy_timer_timeout() -> void:
	if spawn_enemies:
		generate_enemies()

# Spawns between 1 and the day number of enemies, could be easily adjusted to spawn the enemies
# based off of the pre-defined difficulty value for all of the custom enemies.
func generate_enemies():
	var spawn_difficulty = randi_range(1, day)
	for enemy in spawn_difficulty:
		var ran_spawn = enemy_spawns.get_children().pick_random()
		
		var new_enemy = enemy_scene.instantiate()
		new_enemy.global_position = ran_spawn.global_position + Vector2(randi_range(-100, 100), randi_range(-100, 100))
		level.enemies.add_child(new_enemy)

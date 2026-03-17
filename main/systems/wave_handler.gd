extends Node

@export var enemy_scene: PackedScene

@onready var spawn_timer: Timer = $SpawnTimer
@onready var enemy_spawner := $EnemySpawner

var player: Node2D

var base_wait_time: float = 2.0
var min_wait_time: float = 0.2   
var time_passed: float = 0.0     

func set_player(p: Node2D) -> void:
	player = p

func _ready() -> void:
	spawn_timer.wait_time = base_wait_time
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _process(delta: float) -> void:
	time_passed += delta

func _on_spawn_timer_timeout():
	if not player: return
	var enemies_to_spawn = 1 + int(time_passed / 30.0) 
	for i in range(enemies_to_spawn):
		enemy_spawner.spawn_enemy_around_player(player, enemy_scene, 300, 500)
	var new_time = spawn_timer.wait_time * 0.98
	spawn_timer.wait_time = max(min_wait_time, new_time)
	spawn_timer.start()

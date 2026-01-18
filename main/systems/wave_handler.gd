extends Node

@export var enemy_scene: PackedScene

@onready var spawn_timer: Timer = $SpawnTimer
@onready var enemy_spawner := $EnemySpawner

var player: Node2D

func set_player(p: Node2D) -> void:
	player = p

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	enemy_spawner.spawn_enemy_around_player(player, enemy_scene, 100, 400)

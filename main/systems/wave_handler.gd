extends Node

@export var enemy_scene: PackedScene
@export var max_enemies: int = 100

@onready var spawn_timer: Timer = $SpawnTimer
@onready var enemy_spawner := $EnemySpawner2

var player: Node2D

# --- BALANCING ---
var base_wait_time: float = 1.0   
var min_wait_time: float = 0.3  
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
	
	var current_enemy_count = get_tree().get_nodes_in_group("Enemygroup").size()
	
	if current_enemy_count >= max_enemies:
		return
		
	var enemies_to_spawn = 2 + int(time_passed / 20.0) 
	var space_left = max_enemies - current_enemy_count
	enemies_to_spawn = min(enemies_to_spawn, space_left)

	for i in range(enemies_to_spawn):
		enemy_spawner.spawn_enemy_around_player(player, enemy_scene, 300, 500)
		
	var new_time = spawn_timer.wait_time * 0.99
	spawn_timer.wait_time = max(min_wait_time, new_time)
	spawn_timer.start()

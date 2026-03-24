extends Node

@export var enemy_scenes: Array[PackedScene] 
@export var enemy_weights: Array[float]
@export var max_enemies: int = 200
@export var wheel_index: int = 2
@export var max_wheels: int = 2

@onready var spawn_timer: Timer = $SpawnTimer
@onready var enemy_spawner := $EnemySpawner2

var player: Node2D

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
	if enemy_scenes.is_empty(): return
	
	var current_enemy_count = get_tree().get_nodes_in_group("Enemygroup").size()
	if current_enemy_count >= max_enemies:
		return
		
	var enemies_to_spawn = 2 + int(time_passed / 20.0) 
	var space_left = max_enemies - current_enemy_count
	enemies_to_spawn = min(enemies_to_spawn, space_left)
	var is_swarm = randf() < 0.15 
	
	if is_swarm and enemies_to_spawn >= 3:
		var chosen_enemy = get_enemy_for_current_wave()
		chosen_enemy = apply_wheel_limit(chosen_enemy)
		enemy_spawner.spawn_enemy_group(player, chosen_enemy, 300, 500, enemies_to_spawn)
	else:
		for i in range(enemies_to_spawn):
			var chosen_enemy = get_enemy_for_current_wave()
			chosen_enemy = apply_wheel_limit(chosen_enemy)
			enemy_spawner.spawn_enemy_around_player(player, chosen_enemy, 300, 500)
	
	var new_time = spawn_timer.wait_time * 0.99
	spawn_timer.wait_time = max(min_wait_time, new_time)
	spawn_timer.start()

func get_enemy_for_current_wave() -> PackedScene:
	var current_minute = int(time_passed / 10.0)
	var max_allowed_index = min(current_minute, enemy_scenes.size() - 1)
	
	var total_weight: float = 0.0
	for i in range(max_allowed_index + 1):
		if i < enemy_weights.size():
			total_weight += enemy_weights[i]
		else:
			total_weight += 10.0
			
	var random_roll = randf_range(0.0, total_weight)
	var current_weight: float = 0.0
	
	for i in range(max_allowed_index + 1):
		var weight = enemy_weights[i] if i < enemy_weights.size() else 10.0
		current_weight += weight
		if random_roll <= current_weight:
			return enemy_scenes[i]
			
	return enemy_scenes[0]

func apply_wheel_limit(chosen_scene: PackedScene) -> PackedScene:
	if enemy_scenes.size() > wheel_index and chosen_scene == enemy_scenes[wheel_index]:
		var wheel_count = get_tree().get_nodes_in_group("EliteWheels").size()
		if wheel_count >= max_wheels:
			return enemy_scenes[0]
	return chosen_scene

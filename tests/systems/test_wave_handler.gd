extends GdUnitTestSuite

const SCENE_PATH = "res://main/systems/wave_handler.tscn"


# Wird vor JEDEM Test aufgerufen, um eine saubere Umgebung zu schaffen
func before_test() -> void:
	# Alle alten Gegner löschen, damit Gruppen-Größen wieder bei 0 starten
	for enemy in get_tree().get_nodes_in_group("Enemygroup"):
		enemy.free()


func test_max_enemies_limit():
	var runner = scene_runner(SCENE_PATH)
	await runner.simulate_frames(1)  # Warten auf @onready

	var manager = runner.scene()
	manager.max_enemies = 5

	var player = auto_free(Node2D.new())
	manager.set_player(player)

	# 5 Gegner spawnen
	for i in range(5):
		var enemy = Node2D.new()
		enemy.add_to_group("Enemygroup")
		manager.add_child(enemy)

	runner.invoke("_on_spawn_timer_timeout")

	var enemy_count = get_tree().get_nodes_in_group("Enemygroup").size()
	assert_int(enemy_count).is_equal(5)


func test_scaling_over_time():
	var runner = scene_runner(SCENE_PATH)
	await runner.simulate_frames(1)

	var manager = runner.scene()
	manager.set_player(auto_free(Node2D.new()))

	# Fall A: 0s -> 2 Gegner erwartet
	manager.time_passed = 0.0
	runner.invoke("_on_spawn_timer_timeout")
	assert_int(get_tree().get_nodes_in_group("Enemygroup").size()).is_equal(2)

	# Fall B: 40s -> +4 Gegner (insgesamt 6)
	manager.time_passed = 40.0
	runner.invoke("_on_spawn_timer_timeout")
	assert_int(get_tree().get_nodes_in_group("Enemygroup").size()).is_equal(6)


func test_timer_acceleration():
	var runner = scene_runner(SCENE_PATH)
	await runner.simulate_frames(1)

	var manager = runner.scene()
	var timer = manager.find_child("SpawnTimer", true, false) as Timer

	# Korrektur für Zeile 64: override_failure_message nutzen
	assert_object(timer).override_failure_message("SpawnTimer nicht gefunden!").is_not_null()

	var initial_wait = manager.base_wait_time
	manager.set_player(auto_free(Node2D.new()))

	runner.invoke("_on_spawn_timer_timeout")

	# Float-Vergleiche sind bei Zeitwerten oft präziser mit assert_float
	assert_float(timer.wait_time).is_equal(initial_wait * 0.99)

	# Minimum-Limit
	timer.wait_time = 0.31
	runner.invoke("_on_spawn_timer_timeout")
	assert_float(timer.wait_time).is_equal(0.3)


func test_no_player_no_spawn():
	var runner = scene_runner(SCENE_PATH)
	await runner.simulate_frames(1)

	var manager = runner.scene()
	manager.set_player(null)

	runner.invoke("_on_spawn_timer_timeout")

	# Dank before_test() ist die Gruppe hier garantiert leer
	assert_int(get_tree().get_nodes_in_group("Enemygroup").size()).is_equal(0)

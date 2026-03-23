extends GdUnitTestSuite

const SCENE_PATH = "res://main/systems/wave_handler.tscn"

func test_max_enemies_limit():
	var runner = scene_runner(SCENE_PATH)
	var manager = runner.working_node()
	
	# Setup: Wir setzen das Limit künstlich niedrig für den Test
	manager.max_enemies = 5
	
	# Wir erstellen einen Mock-Player
	var player = auto_free(Node2D.new())
	manager.set_player(player)
	
	# Wir simulieren, dass bereits 5 Gegner im Spiel sind
	for i in range(5):
		var enemy = Node2D.new()
		enemy.add_to_group("Enemygroup")
		runner.get_tree().root.add_child(enemy)
	
	# Den Timeout manuell triggern
	runner.invoke("_on_spawn_timer_timeout")
	
	# Es dürfen immer noch nur 5 Gegner in der Gruppe sein
	var enemy_count = runner.get_tree().get_nodes_in_group("Enemygroup").size()
	assert_that(enemy_count).is_equal(5)

func test_scaling_over_time():
	var runner = scene_runner(SCENE_PATH)
	var manager = runner.working_node()
	var player = auto_free(Node2D.new())
	manager.set_player(player)
	
	# Fall A: Ganz am Anfang (time_passed = 0)
	# Formel: 2 + int(0 / 20) = 2 Gegner
	manager.time_passed = 0.0
	runner.invoke("_on_spawn_timer_timeout")
	
	var count_start = runner.get_tree().get_nodes_in_group("Enemygroup").size()
	assert_that(count_start).is_equal(2)
	
	# Fall B: Nach 40 Sekunden
	# Formel: 2 + int(40 / 20) = 4 Gegner
	manager.time_passed = 40.0
	runner.invoke("_on_spawn_timer_timeout")
	
	# 2 (von vorher) + 4 (neue) = 6
	var count_after = runner.get_tree().get_nodes_in_group("Enemygroup").size()
	assert_that(count_after).is_equal(6)

func test_timer_acceleration():
	var runner = scene_runner(SCENE_PATH)
	var manager = runner.working_node()
	var timer = manager.get_node("SpawnTimer") as Timer
	
	var initial_wait = manager.base_wait_time
	manager.set_player(auto_free(Node2D.new()))
	
	# Erster Timeout
	runner.invoke("_on_spawn_timer_timeout")
	
	# Der neue wait_time sollte 99% vom alten sein
	assert_that(timer.wait_time).is_equal(initial_wait * 0.99)
	
	# Teste das Minimum-Limit
	timer.wait_time = 0.31
	runner.invoke("_on_spawn_timer_timeout")
	assert_that(timer.wait_time).is_equal(0.3) # Darf nicht unter min_wait_time fallen

func test_no_player_no_spawn():
	var runner = scene_runner(SCENE_PATH)
	var manager = runner.working_node()
	
	manager.set_player(null) # Keinen Spieler setzen
	runner.invoke("_on_spawn_timer_timeout")
	
	var enemy_count = runner.get_tree().get_nodes_in_group("Enemygroup").size()
	assert_that(enemy_count).is_equal(0)

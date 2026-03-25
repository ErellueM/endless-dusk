# Pfad zu deinem Spawner-Skript
extends GdUnitTestSuite

const SPAWNER_SCRIPT = preload("res://main/systems/enemy_spawner.gd")

func test_spawn_enemy_within_distance_range():
	# Wir erstellen einen Runner für eine leere Szene
	var runner = scene_runner(Node2D.new())
	
	# Spawner-Node erstellen und Skript zuweisen
	var spawner = auto_free(Node.new())
	spawner.set_script(SPAWNER_SCRIPT)
	runner.scene().get_tree().root.add_child(spawner)
	
	# 1. Setup: Spieler-Position festlegen
	var player = auto_free(Node2D.new())
	player.global_position = Vector2(100, 100)
	runner.scene().get_tree().root.add_child(player)
	
	var min_dist = 50.0
	var max_dist = 100.0
	
	# 2. Eine echte PackedScene simulieren
	# Wir erstellen ein Node2D, packen es in eine PackedScene
	var enemy_inner_node = Node2D.new()
	var enemy_scene = PackedScene.new()
	enemy_scene.pack(enemy_inner_node)
	
	# 3. Wir spawnen 20 Gegner, um den Zufallsbereich zu prüfen
	for i in range(20):
		spawner.spawn_enemy_around_player(player, enemy_scene, min_dist, max_dist)
		
		# Den zuletzt gespawnten Gegner im Tree finden
		# (Da dein Skript 'add_child' auf die current_scene macht)
		var scene_root = runner.scene().get_tree().current_scene
		var enemy = scene_root.get_child(scene_root.get_child_count() - 1) as Node2D
		
		# 4. Distanz berechnen
		var actual_dist = player.global_position.distance_to(enemy.global_position)
		
		# Prüfen mit assert_that()
		assert_that(actual_dist).is_between(min_dist, max_dist)
		
		# Cleanup für den nächsten Loop-Durchgang
		enemy.queue_free()

func test_spawn_direction_is_random():
	var runner = scene_runner(Node2D.new())
	var spawner = auto_free(Node.new())
	spawner.set_script(SPAWNER_SCRIPT)
	runner.scene().get_tree().root.add_child(spawner)
	
	var player = auto_free(Node2D.new())
	player.global_position = Vector2.ZERO
	runner.scene().get_tree().root.add_child(player)
	
	var enemy_inner = Node2D.new()
	var enemy_scene = PackedScene.new()
	enemy_scene.pack(enemy_inner)
	
	var positions = []
	for i in range(2):
		spawner.spawn_enemy_around_player(player, enemy_scene, 10, 20)
		var scene_root = runner.scene().get_tree().current_scene
		var enemy = scene_root.get_child(scene_root.get_child_count() - 1)
		positions.append(enemy.global_position)
		enemy.queue_free()
	
	# Prüfen, dass nicht beide an der exakt gleichen Stelle sind
	assert_that(positions[0]).is_not_equal(positions[1])

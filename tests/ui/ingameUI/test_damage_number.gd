extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/ingameUI/damage_number.tscn"

func test_setup_and_initial_display():
	# 1. Wir erstellen die Instanz manuell, um 'setup' VOR '_ready' zu rufen
	var scene = load(SCENE_PATH)
	var dmg_node = scene.instantiate()
	
	# Werte setzen
	dmg_node.setup(42.7, false, false) # Schaden: 42.7
	
	# In den SceneTree bringen (triggert _ready)
	var runner = scene_runner(dmg_node)
	await runner.simulate_frames(1)
	
	# Label prüfen (int(42.7) sollte "42" sein)
	var label = dmg_node.get_node("Label") as Label
	assert_that(label.text).is_equal("42")
	# Standardfarbe (weder Player noch Poison) -> Gelb
	assert_that(label.modulate).is_equal(Color(1.0, 1.0, 0))

func test_color_for_player_damage():
	var scene = load(SCENE_PATH)
	var dmg_node = scene.instantiate()
	
	dmg_node.setup(10.0, true, false) # is_player = true
	
	var runner = scene_runner(dmg_node)
	await runner.simulate_frames(1)
	
	var label = dmg_node.get_node("Label")
	assert_that(label.modulate).is_equal(Color(1.0, 0.2, 0.2)) # Rot-Ton

func test_color_and_travel_for_poison():
	var scene = load(SCENE_PATH)
	var dmg_node = scene.instantiate()
	
	var start_pos = Vector2(100, 100)
	dmg_node.position = start_pos
	dmg_node.setup(5.0, false, true) # is_poison = true
	
	var runner = scene_runner(dmg_node)
	await runner.simulate_frames(1)
	
	var label = dmg_node.get_node("Label")
	assert_that(label.modulate).is_equal(Color(0.3, 1.0, 0.3)) # Gift-Grün
	
	# Wir warten, bis der Tween ein Stück gelaufen ist
	await runner.simulate_frames(30)
	
	# Da Poison -30 travelt, sollte die Y-Position kleiner (höher) als bei normalem Schaden sein
	assert_that(dmg_node.position.y).is_less(start_pos.y)

func test_self_destruction_after_animation():
	var runner = scene_runner(SCENE_PATH)
	var dmg_node = runner.scene()
	
	# Die Animation dauert 1.2 Sekunden. 
	# Wir simulieren etwas mehr Zeit (z.B. 1.5s), um sicher zu sein.
	await runner.simulate_frames(90, 20) # ca. 1.5 Sekunden bei 60 FPS
	
	# Prüfen, ob der Node aus dem Tree entfernt wurde (queue_free)
	assert_that(is_instance_valid(dmg_node)).is_false()

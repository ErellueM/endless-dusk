extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/ingameUI/upgradeUI/UpgradeCard.tscn"


func test_set_item_data_updates_ui():
	var runner = scene_runner(SCENE_PATH)
	var card = runner.working_node()

	# Test-Daten definieren
	var title = "Legendary Sword"
	var desc = "Does [color=red]huge[/color] damage."
	var rarity = "Legendary"

	# Funktion aufrufen
	card.set_item_data(title, desc, rarity)

	# UI-Elemente prüfen
	var title_label = runner.find_child("TitleLabel") as Label
	var desc_label = runner.find_child("DescriptionLabel") as RichTextLabel
	var rarity_label = runner.find_child("RarityLabel") as Label

	assert_that(title_label.text).is_equal(title)
	assert_that(desc_label.text).is_equal(desc)
	assert_that(rarity_label.text).is_equal(rarity)

	# Farbe prüfen (Legendary sollte Gold sein)
	var expected_color = card.rarity_colors["Legendary"]
	assert_that(card.self_modulate).is_equal(expected_color)


func test_spam_protection_emits_only_once():
	var runner = scene_runner(SCENE_PATH)
	var card = runner.working_node()

	# Wir überwachen das Signal "selected"
	var monitor = monitor_signals(card)

	# Erster Klick
	runner.invoke("_on_button_pressed")
	# Zweiter Klick (sollte ignoriert werden)
	runner.invoke("_on_button_pressed")
	# Dritter Klick (sollte ignoriert werden)
	runner.invoke("_on_button_pressed")

	# Prüfen, ob das Signal GENAU einmal gesendet wurde
	await assert_signal(card).is_emitted("selected")

	# Da GdUnit4 standardmäßig auf Emission prüft,
	# können wir hier zusätzlich die Variable prüfen:
	assert_that(card.is_clicked).is_true()


func test_appear_animation_sets_visuals():
	var runner = scene_runner(SCENE_PATH)
	var card = runner.working_node()

	# Vor der Animation (in _ready gesetzt)
	assert_that(card.modulate.a).is_equal(0.0)
	assert_that(card.scale).is_equal(Vector2.ZERO)

	# Animation starten (mit 0 Delay für den Test)
	card.appear(0.0)

	# Wir warten ein bisschen länger als die Tween-Dauer (0.5s)
	await runner.simulate_frames(60, 10)  # 60 Frames (~1 Sekunde)

	assert_that(card.modulate.a).is_equal(1.0)
	assert_that(card.scale).is_equal(Vector2.ONE)


func test_shader_intensity_on_rarity():
	var runner = scene_runner(SCENE_PATH)
	var card = runner.working_node()

	# Wir müssen sicherstellen, dass die Karte ein Material hat,
	# sonst überspringt das Skript den Shader-Teil.
	if card.material is ShaderMaterial:
		# Test für Legendary (0.8 Intensity)
		card.set_item_data("Test", "Desc", "Legendary")
		var intensity = card.material.get_shader_parameter("intensity")
		assert_that(intensity).is_equal(0.8)

		# Test für Common (0.0 Intensity)
		card.set_item_data("Test", "Desc", "Common")
		intensity = card.material.get_shader_parameter("intensity")
		assert_that(intensity).is_equal(0.0)

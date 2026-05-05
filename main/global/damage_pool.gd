extends Node

var pool: Array[Node2D] = []
var max_pool_size: int = 100
var damage_scene: PackedScene = preload("res://main/ui/ingameUI/damage_number.tscn")


func _ready():
	for i in range(max_pool_size):
		var dmg_node = damage_scene.instantiate()
		add_child(dmg_node)
		dmg_node.global_position = Vector2(-99999, -99999)  # Auf den Friedhof!
		pool.append(dmg_node)


func spawn_number(pos: Vector2, amount: float, is_dot: bool, color: Color):
	if pool.is_empty():
		return

	var dmg_node = pool.pop_back()
	dmg_node.global_position = pos  # Zum Gegner teleportieren
	dmg_node.setup_and_play(amount, is_dot, color)


func return_to_pool(dmg_node: Node2D):
	# ZURÜCK AUF DEN FRIEDHOF
	dmg_node.global_position = Vector2(-99999, -99999)
	pool.append(dmg_node)


# --- NEU: WIRD VON DER HOLY BOMB AUFGERUFEN ---
func wipe_enemies(damage_amount: float, enemies_per_frame: int = 20):
	var enemies = get_tree().get_nodes_in_group("Enemygroup")
	var player = get_tree().get_first_node_in_group("player")

	if player:
		# Sortieren nach Distanz zum Spieler (Druckwellen-Effekt)
		enemies.sort_custom(
			func(a, b):
				return (
					a.global_position.distance_squared_to(player.global_position)
					< b.global_position.distance_squared_to(player.global_position)
				)
		)

	var count = 0
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_dead and enemy.has_method("take_damage"):
			# Fügt Schaden zu und sagt: show_number = false!
			if enemy.get("is_miniboss") == true or enemy.is_in_group("boss") or enemy.is_in_group("miniboss"):
				continue
			
			enemy.take_damage(damage_amount, false)
			count += 1

			# Kurze Pause für die Engine
			if count >= enemies_per_frame:
				count = 0
				await get_tree().process_frame

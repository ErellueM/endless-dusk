extends Node

var pools: Dictionary = {}

func clear_pools():
	for path in pools:
		for enemy in pools[path]:
			if is_instance_valid(enemy):
				enemy.queue_free()
	pools.clear()
	
func get_enemy(scene: PackedScene) -> Node2D:
	var path = scene.resource_path

	if not pools.has(path):
		pools[path] = []

	var enemy: Node2D

	if pools[path].size() > 0:
		enemy = pools[path].pop_back()
	else:
		enemy = scene.instantiate()
		enemy.set_meta("scene_path", path) 
		get_tree().current_scene.add_child(enemy)

	return enemy


func return_enemy(enemy: Node2D):
	if not is_instance_valid(enemy): return
	
	if not enemy.has_meta("scene_path"):
		enemy.queue_free()
		return
		
	# 1. Sofort die Hitbox abschalten, damit der Spieler nicht in den unsichtbaren Gegner rennt!
	var coll = enemy.get_node_or_null("CollisionShape2D")
	if coll:
		coll.set_deferred("disabled", true)
	
	# 2. Den "Void"-Verschlingungs-Effekt abspielen (Shrink auf 0)
	var tween = enemy.create_tween().set_parallel(true)
	tween.tween_property(enemy, "scale", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(enemy, "modulate:a", 0.0, 0.4)
	
	# 3. WARTEN, bis die Animation fertig ist!
	await tween.finished
	
	# Sicherheitscheck, falls das Spiel in den 0.4 Sekunden beendet wurde
	if not is_instance_valid(enemy): return
		
	# 4. Jetzt erst in den Pool zurücklegen und Physik ausschalten
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.visible = false
	enemy.global_position = Vector2(-9999, -9999)
	
	var path = enemy.get_meta("scene_path")
	
	if not pools.has(path):
		pools[path] = []
		
	pools[path].append(enemy)

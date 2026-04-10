extends Node

# Ein Dictionary, das für JEDE Gegner-Art eine eigene Liste führt!
# z.B.: { "res://.../green_slime.tscn": [slime1, slime2], "res://.../blue_slime.tscn": [slime3] }
var pools: Dictionary = {}

func get_enemy(scene: PackedScene) -> Node2D:
	var path = scene.resource_path
	
	# Gibt es für diese Art von Gegner noch gar keine Liste? Dann leg eine an!
	if not pools.has(path):
		pools[path] = []
		
	var enemy: Node2D
	
	# Haben wir einen schlafenden Gegner dieser Art auf Lager?
	if pools[path].size() > 0:
		enemy = pools[path].pop_back()
	else:
		# Nein? Dann müssen wir einmalig einen neuen bauen!
		enemy = scene.instantiate()
		enemy.set_meta("scene_path", path) # Wir kleben ihm ein Namensschild auf, damit er weiß, wo er hingehört!
		get_tree().current_scene.add_child(enemy)
		
	return enemy

func return_enemy(enemy: Node2D):
	# Sicherheits-Check: Hat er ein Namensschild?
	if not enemy.has_meta("scene_path"):
		enemy.queue_free() # Wenn nicht, einfach normal löschen!
		return
		
	# Ab in den Tiefschlaf!
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.visible = false
	enemy.global_position = Vector2(-9999, -9999)
	
	# Lies das Namensschild und leg ihn in die richtige Kiste zurück
	var path = enemy.get_meta("scene_path")
	pools[path].append(enemy)

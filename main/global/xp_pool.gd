extends Node

var pool: Array[Area2D] = []
var active_gems: Array[Area2D] = []
var max_active_gems: int = 300
var xp_scene: PackedScene = preload("res://main/entities/xp/xp.tscn")

func _ready():
	for i in range(max_active_gems):
		var gem = xp_scene.instantiate()
		add_child(gem)
		gem.global_position = Vector2(-99999, -99999)
		pool.append(gem)

func spawn_gem(pos: Vector2, amount: float):
	# FIX 1: Richtige Mathematik für 40 Pixel Radius (40 * 40 = 1600)
	var merge_radius_sq = 500.0 
	
	for gem in active_gems:
		if gem.is_flying: continue
		
		var dist_sq = gem.global_position.distance_squared_to(pos)
		
		if dist_sq < merge_radius_sq:
			gem.add_xp_silently(amount)
			# Wenn wir gemerged haben, können wir die Animation des XP-Gems 
			# vielleicht leicht aufblinken lassen oder ihn größer skalieren!
			return

	if pool.size() > 0:
		var gem = pool.pop_back()
		gem.global_position = pos
		if gem.has_method("reset_physics_interpolation"):
			gem.reset_physics_interpolation()
		gem.setup(amount)
		active_gems.append(gem)
	else:
		# FIX 2: RECYCLING! 
		# Wenn der Pool leer ist, klauen wir den am weitesten entfernten Gem!
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var furthest_gem: Area2D = null
			var max_dist = 0.0
			
			for gem in active_gems:
				if gem.is_flying: continue
				
				var dist = gem.global_position.distance_squared_to(player.global_position)
				if dist > max_dist:
					max_dist = dist
					furthest_gem = gem
					
			if furthest_gem:
				# Wir schieben ihn zum toten Gegner und pumpen die neuen XP rein
				furthest_gem.global_position = pos
				furthest_gem.add_xp_silently(amount)
				if furthest_gem.has_method("reset_physics_interpolation"):
					furthest_gem.reset_physics_interpolation()

func return_to_pool(gem: Area2D):
	gem.global_position = Vector2(-99999, -99999)
	gem.is_flying = false
	active_gems.erase(gem)
	pool.append(gem)

func reset_pool():
	for gem in active_gems:
		gem.global_position = Vector2(-99999, -99999)
		gem.is_flying = false
		pool.append(gem)
	active_gems.clear()

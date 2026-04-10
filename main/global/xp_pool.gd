extends Node

var pool: Array[Area2D] = []
var active_gems: Array[Area2D] = []
var max_active_gems: int = 700
var xp_scene: PackedScene = preload("res://main/entities/xp/xp.tscn")


func _ready():
	for i in range(max_active_gems):
		var gem = xp_scene.instantiate()
		add_child(gem)
		gem.global_position = Vector2(-99999, -99999)
		pool.append(gem)


func spawn_gem(pos: Vector2, amount: float):
	if pool.size() > 0:
		var gem = pool.pop_back()
		gem.global_position = pos

		if gem.has_method("reset_physics_interpolation"):
			gem.reset_physics_interpolation()

		gem.setup(amount)
		active_gems.append(gem)
	else:
		# --- DEIN GENIALER RECYCLING TRICK ---
		# Das Limit ist voll! Wir suchen den ÄLTESTEN Stein, der NICHT gerade zum Spieler fliegt.
		var recycled_gem: Area2D = null

		for i in range(active_gems.size()):
			if not active_gems[i].is_flying:
				# pop_at(i) nimmt ihn aus der Liste heraus
				recycled_gem = active_gems.pop_at(i)
				break

		if recycled_gem:
			# Wir teleportieren den alten Stein zur Leiche des neuen Gegners!
			recycled_gem.global_position = pos
			if recycled_gem.has_method("reset_physics_interpolation"):
				recycled_gem.reset_physics_interpolation()

			# Wir behalten seine alten XP und addieren die neuen dazu (mit kleinem Plopp-Effekt)
			recycled_gem.add_xp_silently(amount)

			# Wir hängen ihn ganz hinten an die Liste (er ist jetzt der "neueste" Stein)
			active_gems.append(recycled_gem)
		# -------------------------------------


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

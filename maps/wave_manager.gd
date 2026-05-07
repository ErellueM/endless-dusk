extends Node

enum State { NORMAL, PRE_BOSS, BOSS }
var current_state: State = State.NORMAL

@export_group("Enemy Databases")
@export var elite_database: Array[SpawnData]
@export var swarm_database: Array[SpawnData]
@export var miniboss_database: Array[SpawnData]

@export_group("Spawning Limits")
@export var max_swarm_enemies: int = 1000  # Das absolute Late-Game Fleischwolf-Limit
@export var max_elite_enemies: int = 50  # Das absolute Taktik-Limit
@export var base_spawn_interval: float = 0.5

@export_group("Scaling Factors")
@export var swarm_scaling_factor: float = 1.05 # Normale Gegner wachsen stetig
@export var boss_scaling_factor: float = 1.25 # Bosse wachsen extrem aggressiv
@export var boss_damage_scaling_factor: float = 1.02

@export_group("Bosses")
@export var boss_scenes: Array[PackedScene]
@export var boss_interval_minutes: float = 10.0
@export var miniboss_interval_minutes: float = 2.5

@export_group("Props (Fässer)")
@export var prop_scene: PackedScene
@export var prop_spawn_interval: float = 8.0
@export var max_props: int = 10

var map_bounds: Rect2 = Rect2(-181, -111, 1536, 916)

var time_elapsed: float = 0.0
var spawn_timer: float = 0.0
var prop_timer: float = 0.0

var bosses_spawned: int = 0
var minibosses_spawned: int = 0

var player: Node2D
var dark_arena: Node2D

# --- DER SPAWN-PUFFER ---
var pending_enemy_spawns: Array = []

func set_player(p: Node2D) -> void:
	player = p

func get_active_enemy_count(group_name: String) -> int:
	var count = 0
	for e in get_tree().get_nodes_in_group(group_name):
		if e.visible and not e.get("is_dead"):
			count += 1
	return count


func _process(delta: float):
	if not player:
		return

	if int(time_elapsed) % 1 == 0 and not Engine.get_frames_drawn() % 60:
		print(
			"Swarm: ",
			get_active_enemy_count("SwarmEnemies"),
			" | Elite: ",
			get_active_enemy_count("EliteEnemies")
		)

	time_elapsed += delta
	var current_minute = time_elapsed / 60.0

	check_for_miniboss(current_minute)
	check_for_boss(current_minute)

	if current_state == State.PRE_BOSS:
		return

	if current_state == State.BOSS:
		return

	prop_timer += delta
	if prop_timer >= prop_spawn_interval and prop_scene:
		prop_timer = 0.0
		try_spawn_prop()

	if pending_enemy_spawns.size() > 0:
		var spawn_info = pending_enemy_spawns.pop_front()
		spawn_single_enemy(
			spawn_info.data, spawn_info.minute, spawn_info.angle, spawn_info.is_swarm
		)
		return

	spawn_timer += delta
	if spawn_timer >= get_current_spawn_rate():
		spawn_timer = 0.0
		recycle_distant_enemies()

		# --- DYNAMISCHE LIMITS BERECHNEN ---
		# Swarm: Startet bei 30, erreicht max_swarm_enemies nach ca. 15 Minuten (65 * 15 = 975)
		var current_swarm_cap = min(max_swarm_enemies, 5 + int(current_minute * 40.0))
		# Elite: Startet bei 2, erreicht max_elite_enemies nach ca. 15 Minuten
		var current_elite_cap = min(max_elite_enemies, 2 + int(current_minute * 3.0))

		# --- ELITE GEGNER PRÜFEN ---
		var current_elites = get_active_enemy_count("EliteEnemies")
		if current_elites < current_elite_cap and elite_database.size() > 0:
			var elite_deficit = current_elite_cap - current_elites
			var batch = min(1 + int(current_minute / 2.0), elite_deficit)
			queue_spawn_from_array(elite_database, batch, false)

		# --- SCHWARM GEGNER PRÜFEN ---
		var current_swarms = get_active_enemy_count("SwarmEnemies")
		if current_swarms < current_swarm_cap and swarm_database.size() > 0:
			var swarm_deficit = current_swarm_cap - current_swarms
			
			# Sanftes Ansteigen der Spawn-Menge pro Tick
			var batch = 2 + int(current_minute * 1.5)

			# Wenn mehr als 50% zum aktuellen (!) Cap fehlen, leicht beschleunigen
			if swarm_deficit > current_swarm_cap * 0.5 and current_minute > 1.0:
				batch *= 2

			batch = min(batch, swarm_deficit)
			queue_spawn_from_array(swarm_database, batch, true)


func queue_spawn_from_array(database: Array, amount: int, is_swarm: bool):
	var current_minute = time_elapsed / 60.0

	for i in range(amount):
		var valid_enemies = []
		var total_weight = 0.0

		for data in database:
			if (
				current_minute >= data.spawn_start_minute
				and current_minute <= data.spawn_end_minute
			):
				if not is_swarm and data.max_active_count > 0:
					if get_active_enemy_count(data.enemy_id) >= data.max_active_count:
						continue

				valid_enemies.append(data)
				total_weight += data.weight

		if valid_enemies.size() == 0:
			return

		var roll = randf_range(0.0, total_weight)
		var chosen_data: SpawnData = null

		for data in valid_enemies:
			roll -= data.weight
			if roll <= 0:
				chosen_data = data
				break

		if chosen_data:
			var random_angle = randf() * TAU
			pending_enemy_spawns.append(
				{
					"data": chosen_data,
					"minute": current_minute,
					"angle": random_angle,
					"is_swarm": is_swarm
				}
			)


func spawn_single_enemy(data: SpawnData, current_minute: float, angle: float, is_swarm: bool):
	var enemy = EnemyPool.get_enemy(data.enemy_scene)

	enemy.add_to_group("Enemygroup")
	enemy.add_to_group(data.enemy_id)

	if is_swarm:
		enemy.add_to_group("SwarmEnemies")
	else:
		enemy.add_to_group("EliteEnemies")

	# HIER DAS SCALING FÜR NORMALE GEGNER
	var current_multiplier = 1.0
	if current_minute >= 1.0:
		current_multiplier = pow(swarm_scaling_factor, current_minute)

	var spawn_pos = get_offscreen_position(angle)

	if enemy.has_method("revive"):
		enemy.revive(spawn_pos, current_multiplier)
	else:
		enemy.global_position = spawn_pos
		enemy.visible = true
		enemy.set_process(true)
		enemy.set_physics_process(true)

	var target_scale = enemy.scale
	
	enemy.scale = Vector2.ZERO
	enemy.modulate.a = 0.0

	if not enemy.is_inside_tree():
		get_tree().current_scene.add_child(enemy)

	var spawn_tween = enemy.create_tween().set_parallel(true)
	spawn_tween.tween_property(enemy, "scale", target_scale, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	spawn_tween.tween_property(enemy, "modulate:a", 1.0, 0.5)


func recycle_distant_enemies():
	var center_pos = player.global_position
	var cam = get_tree().get_first_node_in_group("camera")
	if cam:
		center_pos = cam.get_screen_center_position()

	var max_dist_squared = 550000.0
	var all_enemies = get_tree().get_nodes_in_group("Enemygroup")
	var despawned = 0

	for e in all_enemies:
		if not e.visible or e.get("is_dead"):
			continue

		if e.is_in_group("boss") or e.is_in_group("miniboss"):
			continue

		if e.global_position.distance_squared_to(center_pos) > max_dist_squared:
			if EnemyPool.has_method("return_enemy"):
				EnemyPool.return_enemy(e)
			else:
				e.queue_free()

			despawned += 1
			if despawned >= 5:
				break


func get_current_spawn_rate() -> float:
	var current_minute = time_elapsed / 60.0
	var speed_up = clamp(current_minute * 0.03, 0.0, 0.5)
	return base_spawn_interval * (1.0 - speed_up)


func try_spawn_prop():
	var current_props = get_tree().get_nodes_in_group("Props").size()
	if current_props >= max_props:
		return

	var random_angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(random_angle), sin(random_angle)) * 400.0

	if map_bounds.has_point(spawn_pos):
		var prop = prop_scene.instantiate()
		prop.global_position = spawn_pos
		get_tree().current_scene.add_child(prop)


func get_offscreen_position(base_angle: float) -> Vector2:
	if not player:
		return Vector2.ZERO

	if current_state == State.BOSS and dark_arena:
		for i in range(10):
			var random_angle = randf() * TAU
			var test_pos = (
				dark_arena.global_position + Vector2(cos(random_angle), sin(random_angle)) * 240.0
			)
			if test_pos.distance_to(player.global_position) > 100.0:
				return test_pos
		var opposite_angle = (player.global_position - dark_arena.global_position).angle() + PI
		return (
			dark_arena.global_position + Vector2(cos(opposite_angle), sin(opposite_angle)) * 240.0
		)

	var cam = get_tree().get_first_node_in_group("camera")
	var center_pos = player.global_position
	if cam:
		center_pos = cam.get_screen_center_position()

	var current_angle = base_angle + randf_range(-0.15, 0.15)
	var distance = 350.0

	var safe_bounds = map_bounds.grow(-20.0)
	for i in range(12):
		var offset = Vector2(cos(current_angle), sin(current_angle)) * distance
		var test_pos = center_pos + offset
		if safe_bounds.has_point(test_pos):
			return test_pos
		current_angle += (PI / 6.0)

	var fallback_offset = Vector2(cos(base_angle), sin(base_angle)) * distance
	var raw_pos = center_pos + fallback_offset
	raw_pos.x = clamp(raw_pos.x, safe_bounds.position.x, safe_bounds.end.x)
	raw_pos.y = clamp(raw_pos.y, safe_bounds.position.y, safe_bounds.end.y)
	return raw_pos


func check_for_miniboss(current_minute: float):
	if current_state != State.NORMAL:
		return
	var expected_minibosses = int(current_minute / miniboss_interval_minutes)

	if expected_minibosses > minibosses_spawned:
		spawn_random_miniboss(current_minute)


func spawn_random_miniboss(current_minute: float):
	if miniboss_database.size() == 0:
		return
	minibosses_spawned += 1
	queue_spawn_from_array(miniboss_database, 1, false)


func check_for_boss(current_minute: float):
	var expected_boss_count = int(current_minute / boss_interval_minutes)

	if expected_boss_count > bosses_spawned and current_state == State.NORMAL:
		start_pre_boss_warning()


func start_pre_boss_warning():
	current_state = State.PRE_BOSS
	bosses_spawned += 1

	var all_enemies = get_tree().get_nodes_in_group("Enemygroup")
	for e in all_enemies:
		if not e.visible:
			continue
		var tween = create_tween()
		tween.tween_property(e, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(
			Tween.EASE_IN
		)
		if EnemyPool.has_method("return_enemy"):
			tween.tween_callback(func(): EnemyPool.return_enemy(e))
		else:
			tween.tween_callback(e.queue_free)

	var arena_center = player.global_position
	var cam = get_tree().get_first_node_in_group("camera")
	if cam:
		arena_center = cam.get_screen_center_position()

	var arena_safe_bounds = map_bounds.grow(-250.0)
	arena_center.x = clamp(arena_center.x, arena_safe_bounds.position.x, arena_safe_bounds.end.x)
	arena_center.y = clamp(arena_center.y, arena_safe_bounds.position.y, arena_safe_bounds.end.y)

	create_dark_arena(arena_center)

	if player.global_position.distance_to(arena_center) > 160.0:
		var pull_tween = player.create_tween()
		(
			pull_tween
			. tween_property(player, "global_position", arena_center, 2.0)
			. set_trans(Tween.TRANS_SINE)
			. set_ease(Tween.EASE_IN_OUT)
		)

		for i in range(15):
			var streak = ColorRect.new()
			streak.color = Color(0.02, 0.0, 0.05, 0.8)
			streak.size = Vector2(randf_range(40, 120), randf_range(3, 8))

			var random_offset = Vector2(randf_range(-200, 200), randf_range(-200, 200))
			streak.global_position = player.global_position + random_offset

			streak.rotation = (arena_center - streak.global_position).angle()
			streak.z_index = 60
			get_tree().current_scene.add_child(streak)

			var s_tween = streak.create_tween()
			var delay = randf_range(0.0, 1.5)
			s_tween.tween_interval(delay)
			(
				s_tween
				. tween_property(streak, "global_position", arena_center, 0.3)
				. set_trans(Tween.TRANS_EXPO)
				. set_ease(Tween.EASE_IN)
			)
			s_tween.tween_callback(streak.queue_free)

	var boss_spawn_pos = arena_center + Vector2(0, -80)

	var marker = Node2D.new()
	marker.name = "BossMarker"
	marker.global_position = boss_spawn_pos
	marker.z_index = 10

	var circle_visual = Line2D.new()
	circle_visual.default_color = Color(1.0, 0.0, 0.0, 0.9)
	circle_visual.width = 4.0
	var points = PackedVector2Array()
	for i in range(33):
		var angle = i * TAU / 32.0
		points.append(Vector2(cos(angle), sin(angle)) * 25.0)
	circle_visual.points = points
	circle_visual.closed = true
	marker.add_child(circle_visual)

	var circle_glow = Line2D.new()
	circle_glow.default_color = Color(1.0, 0.0, 0.0, 0.3)
	circle_glow.width = 12.0
	circle_glow.points = points
	circle_glow.closed = true
	marker.add_child(circle_glow)

	get_tree().current_scene.add_child(marker)

	var m_tween = marker.create_tween().set_loops()
	m_tween.tween_property(marker, "scale", Vector2(1.3, 1.3), 0.3)
	m_tween.tween_property(marker, "scale", Vector2(1.0, 1.0), 0.3)

	await get_tree().create_timer(2.5).timeout

	if marker:
		marker.queue_free()

	spawn_actual_boss(arena_center, boss_spawn_pos)


func create_dark_arena(center_pos: Vector2):
	dark_arena = Node2D.new()
	dark_arena.global_position = center_pos
	dark_arena.z_index = 50
	get_tree().current_scene.add_child(dark_arena)

	var static_body = StaticBody2D.new()
	static_body.collision_layer = 0
	static_body.set_collision_layer_value(3, true)
	var radius = 250.0
	var segments = 32

	for i in range(segments):
		var angle = i * TAU / float(segments)
		var coll = CollisionShape2D.new()
		var shape = RectangleShape2D.new()

		shape.size = Vector2(500, 60)
		coll.shape = shape

		coll.position = Vector2(cos(angle), sin(angle)) * (radius + 250.0)
		coll.rotation = angle
		static_body.add_child(coll)

	dark_arena.add_child(static_body)

	var void_visual = ColorRect.new()
	void_visual.z_index = 0

	void_visual.size = Vector2(3000, 3000)
	void_visual.position = Vector2(-1500, -1500)
	void_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader_code = """
		shader_type canvas_item;

		uniform float radius : hint_range(0.0, 1.0) = 0.0833; 
		uniform float wave_intensity : hint_range(0.0, 0.5) = 0.005;
		uniform float wave_speed : hint_range(0.0, 10.0) = 4.0;

		float hash(vec2 p) {
			return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
		}

		void fragment() {
			vec2 centered_uv = UV - vec2(0.5);
			float dist = length(centered_uv);
			float angle = atan(centered_uv.y, centered_uv.x);
			
			float waves = sin(angle * 8.0 + TIME * wave_speed) * sin(angle * 4.0 - TIME * 0.5 * wave_speed) * 0.5 + 0.5;
			waves += hash(vec2(angle * 5.0, TIME)) * 0.1;
			
			float wave_r = radius + (waves * wave_intensity) - (wave_intensity * 0.5);
			
			float alpha = smoothstep(wave_r - 0.005, wave_r + 0.005, dist);
			
			COLOR = vec4(0.02, 0.0, 0.05, alpha); 
		}
	"""

	var shader = Shader.new()
	shader.code = shader_code
	var mat = ShaderMaterial.new()
	mat.shader = shader
	void_visual.material = mat

	dark_arena.add_child(void_visual)

	void_visual.modulate.a = 0.0
	var tween = create_tween().set_parallel(true)

	tween.tween_property(void_visual, "modulate:a", 1.0, 1.5)

	(
		tween
		. tween_method(
			func(r):
				if void_visual and void_visual.material:
					void_visual.material.set_shader_parameter("radius", r),
			1.0,
			0.0833,
			1.5
		)
		. set_trans(Tween.TRANS_QUART)
		. set_ease(Tween.EASE_OUT)
	)


func spawn_actual_boss(arena_center: Vector2, spawn_pos: Vector2):
	current_state = State.BOSS

	if boss_scenes.size() == 0:
		_on_boss_defeated()
		return

	var random_boss_scene = boss_scenes.pick_random()
	var boss = random_boss_scene.instantiate()

	# HIER DAS NEUE SCALING FÜR BOSSE (Nutzt boss_scaling_factor!)
	var current_minute = time_elapsed / 60.0
	var boss_mult = pow(boss_scaling_factor, current_minute)
	var boss_dmg_mult = pow(boss_damage_scaling_factor, current_minute)
	
	if "max_health" in boss:
		boss.max_health *= boss_mult
	if "damage" in boss:
		boss.damage *= boss_dmg_mult

	boss.global_position = spawn_pos

	var boss_health = boss.get_node_or_null("Health")
	if boss_health:
		boss_health.died.connect(_on_boss_defeated)

	boss.scale = Vector2.ZERO
	boss.modulate.a = 0.0

	var boss_tween = create_tween().set_parallel(true)
	(
		boss_tween
		. tween_property(boss, "scale", Vector2.ONE, 1.5)
		. set_trans(Tween.TRANS_ELASTIC)
		. set_ease(Tween.EASE_OUT)
	)
	boss_tween.tween_property(boss, "modulate:a", 1.0, 1.0)

	var cam = get_tree().get_first_node_in_group("camera")
	if cam and cam.has_method("shake"):
		cam.shake(1.0, 10.0)

	get_tree().current_scene.add_child(boss)


func _on_boss_defeated():
	if dark_arena:
		var static_body = dark_arena.get_child(0)
		static_body.queue_free()

		var void_visual = dark_arena.get_child(1)
		var tween = create_tween().set_parallel(true)

		(
			tween
			. tween_method(
				func(r):
					if void_visual and void_visual.material:
						void_visual.material.set_shader_parameter("radius", r),
				0.0833,
				1.0,
				2.0
			)
			. set_trans(Tween.TRANS_CUBIC)
			. set_ease(Tween.EASE_IN)
		)

		tween.tween_property(void_visual, "modulate:a", 0.0, 2.0)

		tween.chain().tween_callback(dark_arena.queue_free)
		dark_arena = null

	current_state = State.NORMAL

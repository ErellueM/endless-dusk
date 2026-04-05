extends Node

enum State { NORMAL, PRE_BOSS, BOSS }
var current_state: State = State.NORMAL

@export var enemy_database: Array[SpawnData] 
@export var boss_scenes: Array[PackedScene] 
@export var boss_interval_minutes: float = 10.0 

@export var max_enemies_on_screen: int = 300 # 300 ist ein super Wert für Godot!
@export var base_spawn_interval: float = 0.5 
@export var miniboss_interval_minutes: float = 1.0

var minibosses_spawned: int = 0 

var map_bounds: Rect2 = Rect2(-181, -171, 1536, 976)

var time_elapsed: float = 0.0
var spawn_timer: float = 0.0
var bosses_spawned: int = 0
var scaling_factor: float = 1.05 
var last_spawn_angle: float = 0.0 

var player: Node2D

func set_player(p: Node2D) -> void:
	player = p

func _process(delta: float):
	time_elapsed += delta
	spawn_timer += delta
	
	check_for_miniboss()
	check_for_boss()
	
	if current_state == State.PRE_BOSS:
		return 
		
	if current_state == State.BOSS:
		var time_since_boss_spawn = time_elapsed - (bosses_spawned * boss_interval_minutes * 60.0)
		if time_since_boss_spawn < 60.0:
			return 
	
	if spawn_timer >= get_current_spawn_rate():
		spawn_timer = 0.0
		# --- NEU: BATCH SPAWNING (Masse statt Klasse) ---
		# Je später im Spiel, desto mehr Gegner spawnen GLEICHZEITIG pro Tick!
		var batch_size = 1 + int(time_elapsed / 30.0) # Jede halbe Minute +1 Gegner pro Welle
		if current_state == State.BOSS:
			batch_size += 5 # Im Bosskampf kommen nochmal 5 extra pro Welle dazu!
			
		for i in range(batch_size):
			try_spawn_enemy()

func get_current_spawn_rate() -> float:
	# Die Rate geht nicht mehr ins unendliche (0.01), sondern stoppt sanft,
	# da wir ja jetzt durch die "batch_size" die Masse regulieren!
	var current_minute = time_elapsed / 60.0
	var speed_up = clamp(current_minute * 0.03, 0.0, 0.5) 
	return base_spawn_interval * (1.0 - speed_up)

func try_spawn_enemy():
	var current_enemies = get_tree().get_nodes_in_group("Enemygroup")
	
	# --- VS LAUFBAND-RECYCLING ---
	if current_enemies.size() >= max_enemies_on_screen:
		if current_state == State.BOSS and player:
			var furthest_enemy = null
			var max_dist = 0.0
			
			for e in current_enemies:
				if e.is_in_group("boss") or e.is_in_group("miniboss"):
					continue
					
				var d = e.global_position.distance_to(player.global_position)
				if d > max_dist:
					max_dist = d
					furthest_enemy = e
			
			# Gnadenloses Löschen der Nachzügler, um Platz für die Frontlinie zu machen
			if furthest_enemy and max_dist > 140.0:
				furthest_enemy.queue_free()
			else:
				return 
		else:
			return 
		
	var current_minute = time_elapsed / 60.0
	var valid_enemies = []
	var total_weight = 0.0
	
	for data in enemy_database:
		if data.spawn_type == SpawnData.SpawnType.MINIBOSS:
			continue
			
		if current_minute >= data.spawn_start_minute and current_minute <= data.spawn_end_minute:
			if data.max_active_count > 0:
				var current_count = get_tree().get_nodes_in_group(data.enemy_id).size()
				if current_count >= data.max_active_count:
					continue 
			
			valid_enemies.append(data)
			total_weight += data.weight
			
	if valid_enemies.size() == 0: return
	
	var roll = randf_range(0.0, total_weight)
	var chosen_data: SpawnData = null
	
	for data in valid_enemies:
		roll -= data.weight
		if roll <= 0:
			chosen_data = data
			break
			
	if not chosen_data: return
	
	var new_angle = last_spawn_angle + randf_range(PI / 2.0, PI * 1.5)
	last_spawn_angle = new_angle 
	
	if chosen_data.spawn_type == SpawnData.SpawnType.SWARM:
		var amount = randi_range(chosen_data.swarm_min_count, chosen_data.swarm_max_count)
		for i in amount:
			spawn_single_enemy(chosen_data, current_minute, new_angle)
	else:
		spawn_single_enemy(chosen_data, current_minute, new_angle)

func spawn_single_enemy(data: SpawnData, current_minute: float, base_angle: float):
	var enemy = data.enemy_scene.instantiate()
	enemy.add_to_group(data.enemy_id)
	enemy.add_to_group("Enemygroup")
	
	var current_multiplier = pow(scaling_factor, current_minute)
	if "max_health" in enemy: enemy.max_health *= current_multiplier
	if "damage" in enemy: enemy.damage *= current_multiplier
	if "xp_reward" in enemy: enemy.xp_reward *= (current_multiplier * 0.5) 
	
	enemy.global_position = get_offscreen_position(base_angle)
	
	enemy.scale = Vector2.ZERO
	enemy.modulate = Color(0.0, 0.0, 0.0, 0.0) 
	get_tree().current_scene.add_child(enemy)
	
	var spawn_tween = enemy.create_tween().set_parallel(true)
	spawn_tween.tween_property(enemy, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	spawn_tween.tween_property(enemy, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)

func get_offscreen_position(base_angle: float) -> Vector2:
	if not player: return Vector2.ZERO

	if current_state == State.BOSS and dark_arena:
		for i in range(10):
			var random_angle = randf() * TAU
			var test_pos = dark_arena.global_position + Vector2(cos(random_angle), sin(random_angle)) * 240.0
			
			if test_pos.distance_to(player.global_position) > 100.0:
				return test_pos
				
		var opposite_angle = (player.global_position - dark_arena.global_position).angle() + PI
		return dark_arena.global_position + Vector2(cos(opposite_angle), sin(opposite_angle)) * 240.0

	var cam = get_tree().get_first_node_in_group("camera")
	var center_pos = player.global_position
	if cam:
		center_pos = cam.get_screen_center_position()
		
	var current_angle = base_angle + randf_range(-0.35, 0.35) 
	var distance = 300.0 
	
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


# --- MINIBOSS LOGIK ---
func check_for_miniboss():
	if current_state != State.NORMAL: 
		return
		
	var current_minute = time_elapsed / 60.0
	var expected_minibosses = int(current_minute / miniboss_interval_minutes)
	
	if expected_minibosses > minibosses_spawned:
		spawn_random_miniboss(current_minute)

func spawn_random_miniboss(current_minute: float):
	var miniboss_pool: Array[SpawnData] = []
	var total_weight = 0.0
	
	for data in enemy_database:
		if data.spawn_type == SpawnData.SpawnType.MINIBOSS:
			if data.max_active_count > 0:
				var current_count = get_tree().get_nodes_in_group(data.enemy_id).size()
				if current_count >= data.max_active_count:
					continue 
					
			miniboss_pool.append(data)
			total_weight += data.weight
			
	if miniboss_pool.size() == 0:
		return
		
	minibosses_spawned += 1 
		
	var roll = randf_range(0.0, total_weight)
	var chosen_miniboss: SpawnData = null
	
	for data in miniboss_pool:
		roll -= data.weight
		if roll <= 0:
			chosen_miniboss = data
			break
			
	if not chosen_miniboss: return
	
	var random_angle = randf() * TAU
	spawn_single_enemy(chosen_miniboss, current_minute, random_angle)

# --- BOSS LOGIK & DUNKLE DIMENSION ---
var dark_arena: Node2D 

func check_for_boss():
	var current_minute = time_elapsed / 60.0
	var expected_boss_count = int(current_minute / boss_interval_minutes)
	
	if expected_boss_count > bosses_spawned and current_state == State.NORMAL:
		start_pre_boss_warning()

func start_pre_boss_warning():
	current_state = State.PRE_BOSS
	bosses_spawned += 1
	
	var all_enemies = get_tree().get_nodes_in_group("Enemygroup")
	for e in all_enemies:
		var tween = create_tween()
		tween.tween_property(e, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_callback(e.queue_free)
		
	var arena_center = player.global_position
	var cam = get_tree().get_first_node_in_group("camera")
	if cam:
		arena_center = cam.get_screen_center_position()
		
	var arena_safe_bounds = map_bounds.grow(-250.0)
	arena_center.x = clamp(arena_center.x, arena_safe_bounds.position.x, arena_safe_bounds.end.x)
	arena_center.y = clamp(arena_center.y, arena_safe_bounds.position.y, arena_safe_bounds.end.y)
	
	# --- FIX: ARENA WIRD SOFORT ERSTELLT ---
	# Der Spieler kann jetzt während der 2.5 Sekunden Warnung nicht mehr fliehen!
	create_dark_arena(arena_center)
	
	# --- FIX 1: SANFTER SOG & PARTIKEL EFFEKT ---
	if player.global_position.distance_to(arena_center) > 160.0:
		var pull_tween = player.create_tween()
		pull_tween.tween_property(player, "global_position", arena_center, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		# Erschafft 15 "Void-Schlieren" (Schwarze Striche), die den Spieler in die Mitte saugen
		for i in range(15):
			var streak = ColorRect.new()
			streak.color = Color(0.02, 0.0, 0.05, 0.8) # Void-Farbe
			streak.size = Vector2(randf_range(40, 120), randf_range(3, 8)) # Unterschiedliche Länge/Dicke
			
			# Spawnen wild verteilt um den Spieler herum
			var random_offset = Vector2(randf_range(-200, 200), randf_range(-200, 200))
			streak.global_position = player.global_position + random_offset
			
			# Sie rotieren automatisch so, dass sie exakt in die Mitte zeigen
			streak.rotation = (arena_center - streak.global_position).angle()
			streak.z_index = 60 # Über dem Spieler
			get_tree().current_scene.add_child(streak)
			
			# Sie fliegen blitzschnell und nacheinander in das Zentrum
			var s_tween = streak.create_tween()
			var delay = randf_range(0.0, 1.5) # Wann der Strich losfliegt
			s_tween.tween_interval(delay)
			s_tween.tween_property(streak, "global_position", arena_center, 0.3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
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
	static_body.collision_layer = 1
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
	
	tween.tween_method(func(r): 
		if void_visual and void_visual.material:
			void_visual.material.set_shader_parameter("radius", r), 
		1.0, 0.0833, 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)


func spawn_actual_boss(arena_center: Vector2, spawn_pos: Vector2):
	current_state = State.BOSS
		
	if boss_scenes.size() == 0:
		_on_boss_defeated() 
		return
		
	var boss_idx = min(bosses_spawned - 1, boss_scenes.size() - 1)
	var boss = boss_scenes[boss_idx].instantiate()
	
	var current_minute = time_elapsed / 60.0
	var boss_mult = pow(scaling_factor, current_minute)
	if "max_health" in boss: boss.max_health *= boss_mult
	if "damage" in boss: boss.damage *= boss_mult
	
	boss.global_position = spawn_pos
	
	var boss_health = boss.get_node_or_null("Health")
	if boss_health:
		boss_health.died.connect(_on_boss_defeated)
	
	boss.scale = Vector2.ZERO
	boss.modulate.a = 0.0
	
	var boss_tween = create_tween().set_parallel(true)
	boss_tween.tween_property(boss, "scale", Vector2.ONE, 1.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
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
		
		tween.tween_method(func(r): 
			if void_visual and void_visual.material:
				void_visual.material.set_shader_parameter("radius", r), 
			0.0833, 1.0, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			
		tween.tween_property(void_visual, "modulate:a", 0.0, 2.0)
		
		tween.chain().tween_callback(dark_arena.queue_free)
		dark_arena = null
	
	current_state = State.NORMAL

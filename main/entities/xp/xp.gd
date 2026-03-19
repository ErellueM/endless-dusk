extends Area2D

@export var xp_value: float = 1.0
@export var base_scale: Vector2 = Vector2(1, 1)
@export var base_transparency: float = 0.5
@export var pulsing_duration: float = 1.0
@export var fly_speed: float = 1.0

# --- MERGING EINSTELLUNGEN ---
@export var max_gems_on_screen: int = 150 
@export var merge_radius: float = 100.0   
@export var merge_threshold_percent: float = 0.6 

@onready var sprite = $Sprite2D

var target_player: Node2D = null
var is_flying: bool = false
var is_merging: bool = false
var pulse_tween: Tween 

func _ready():
	add_to_group("XPGem")
	
	scale = base_scale
	modulate.a = base_transparency
	
	_update_visuals()
	get_tree().create_timer(randf_range(0.5, 2.0)).timeout.connect(_on_optimization_tick)

func _process(delta):
	if is_flying and target_player:
		var direction = (target_player.global_position - global_position).normalized()
		global_position += direction * fly_speed * delta

func fly_to_player(player_node: Node2D):
	target_player = player_node
	is_flying = true

	var tween = create_tween()
	tween.tween_property(self, "fly_speed", 1200.0, 0.5)

func animate_pulsing():
	if pulse_tween:
		pulse_tween.kill()
		
	pulse_tween = create_tween()
	pulse_tween.set_parallel(true)
	
	pulse_tween.tween_property(self, "scale", base_scale * 0.7, pulsing_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.chain().tween_property(self, "scale", base_scale, pulsing_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	pulse_tween.tween_property(self, "modulate:a", base_transparency * 0.7, pulsing_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.chain().tween_property(self, "modulate:a", base_transparency, pulsing_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	pulse_tween.set_loops()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("gain_xp"):
			body.gain_xp(xp_value)
			queue_free()

# ==========================================
# --- DAS NEUE, SIMPLIFIZIERTE SYSTEM ---
# ==========================================

func _on_optimization_tick():
	if is_flying or is_merging or not is_inside_tree(): return
	
	var all_gems = get_tree().get_nodes_in_group("XPGem")
	
	# 1. GRENZWERT-PRÜFUNG (Erst ab 60% Auslastung mergen)
	var start_merging_limit = max_gems_on_screen * merge_threshold_percent
	if all_gems.size() < start_merging_limit:
		get_tree().create_timer(randf_range(1.5, 2.5)).timeout.connect(_on_optimization_tick)
		return
	
	# 2. NOTFALL-LIMIT (Zu viele auf dem Schirm)
	if all_gems.size() > max_gems_on_screen:
		var closest = _get_closest_gem(all_gems)
		if closest and not closest.is_merging:
			closest.absorb_gem(self) 
			return 
			
	# 3. LOKALES MERGING (Fliegt zu >=)
	var best_target: Area2D = null
	for other in all_gems:
		if other == self or other.is_flying or other.is_merging or not other.is_inside_tree():
			continue
		
		if global_position.distance_to(other.global_position) < merge_radius:
			# Die einzige Regel, die wir jetzt brauchen:
			# Fliege zum anderen Stein, wenn er GRÖSSER ist.
			# Wenn er EXAKT GLEICH GROSS ist, entscheidet die Godot-ID, wer zu wem fliegt (verhindert Crash!)
			if other.xp_value > self.xp_value or (other.xp_value == self.xp_value and other.get_instance_id() > self.get_instance_id()):
				best_target = other
				break 
	
	if best_target:
		best_target.absorb_gem(self)
		return 
	
	get_tree().create_timer(randf_range(1.5, 2.5)).timeout.connect(_on_optimization_tick)

func absorb_gem(other_gem: Area2D):
	if self.is_merging or other_gem.is_merging: return 
	other_gem.is_merging = true
	self.xp_value += other_gem.xp_value 
	
	var pull_tween = create_tween()
	pull_tween.tween_property(other_gem, "global_position", global_position, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	pull_tween.tween_callback(func():
		if is_instance_valid(self):
			self._update_visuals()
			self._play_pop_animation()
		if is_instance_valid(other_gem):
			other_gem.queue_free()
	)

func _update_visuals():
	var target_color = Color(1, 1, 1) 
	var target_scale_mult = 1.0 
	
	if xp_value >= 100: 
		target_color = Color(0.8, 0.2, 1.0) 
		target_scale_mult = 2.0
	elif xp_value >= 50: 
		target_color = Color(1.0, 0.2, 0.2) 
		target_scale_mult = 1.75
	elif xp_value >= 25: 
		target_color = Color(1.0, 0.8, 0.1) 
		target_scale_mult = 1.5
	elif xp_value >= 10: 
		target_color = Color(0.2, 1.0, 0.2) 
		target_scale_mult = 1.25
	elif xp_value >= 5: 
		target_color = Color(0.2, 0.6, 1.0) 
		target_scale_mult = 1.1

	modulate = Color(target_color.r, target_color.g, target_color.b, modulate.a)
	base_scale = Vector2(1, 1) * target_scale_mult
	animate_pulsing()

func _play_pop_animation():
	var pop = create_tween()
	pop.tween_property(self, "scale", base_scale * 1.1, 0.05).set_trans(Tween.TRANS_SINE)
	pop.tween_property(self, "scale", base_scale, 0.1).set_trans(Tween.TRANS_SINE)

func _get_closest_gem(gems: Array) -> Area2D:
	var closest: Area2D = null
	var min_dist = INF
	for g in gems:
		if g == self or g.is_flying or g.is_merging or not g.is_inside_tree(): continue
		var d = global_position.distance_to(g.global_position)
		if d < min_dist:
			min_dist = d
			closest = g
	return closest

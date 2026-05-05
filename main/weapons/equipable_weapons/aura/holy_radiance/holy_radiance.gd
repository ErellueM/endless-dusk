extends Weapon
class_name HolyRadiance

@export var base_pulse_radius: float = 60.0
@export var knockback_force: float = 15.0

var aura_area: Area2D
var collision_shape: CollisionShape2D
var visual_node: Node2D
var outer_glow: Line2D
var inner_core: Line2D
var pulse_timer: Timer

func _ready():
	# 1. Die physische Hitbox (Area2D) aufbauen
	aura_area = Area2D.new()
	aura_area.collision_layer = 0
	aura_area.collision_mask = 10 # Gegner & Props
	add_child(aura_area)
	
	collision_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = base_pulse_radius
	collision_shape.shape = circle
	aura_area.add_child(collision_shape)
	
	# 2. Visuelle Effekte vorbereiten
	_create_holy_visuals()
	
	# 3. Der Timer, der die Waffe steuert
	pulse_timer = Timer.new()
	pulse_timer.wait_time = base_fire_rate
	pulse_timer.autostart = true
	pulse_timer.timeout.connect(_on_pulse)
	add_child(pulse_timer)
	
	_on_pulse()

func attack() -> bool:
	return true

# --- DIE VISUELLE GENERIERUNG ---
func _create_holy_visuals():
	visual_node = Node2D.new()
	visual_node.modulate.a = 0.0 # Startet unsichtbar
	add_child(visual_node)
	
	var glow_mat = CanvasItemMaterial.new()
	glow_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	visual_node.material = glow_mat
	
	# Wir erstellen nur die leeren Linien, die Punkte füllen wir beim Pulsieren!
	outer_glow = Line2D.new()
	outer_glow.width = 6.0 # Schön dünn
	outer_glow.default_color = Color(1.0, 0.9, 0.3, 0.4) 
	outer_glow.closed = true
	outer_glow.use_parent_material = true
	visual_node.add_child(outer_glow)
	
	inner_core = Line2D.new()
	inner_core.width = 2.0 # Sehr feiner Kern
	inner_core.default_color = Color(1.0, 1.0, 0.8, 0.8) 
	inner_core.closed = true
	inner_core.use_parent_material = true
	visual_node.add_child(inner_core)

# Diese Funktion wird vom Tween jeden Frame aufgerufen, um den Kreis zu malen
func _draw_ring_at_radius(r: float):
	var pts = PackedVector2Array()
	var segments = 32
	for i in range(segments + 1):
		var angle = (i / float(segments)) * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * r)
	
	outer_glow.points = pts
	inner_core.points = pts

# --- DER PULS (ANIMATION & SCHADEN) ---
func _on_pulse():
	var current_radius = base_pulse_radius * get_actual_area()
	collision_shape.shape.radius = current_radius
	
	# 1. VISUELLE ANIMATION (Subtile Welle)
	visual_node.modulate.a = 1.0
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Tween animiert den Radius von 10% auf 110% der Zielgröße
	tween.tween_method(_draw_ring_at_radius, current_radius * 0.1, current_radius * 1.1, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Gleichzeitig verblasst die Welle nach außen hin
	tween.tween_property(visual_node, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	
	if level >= 3:
		var cam = get_tree().get_first_node_in_group("camera")
		if cam and cam.has_method("shake"):
			cam.shake(0.1, 2.0) # Sehr leichtes Wackeln
	
	# 2. SCHADEN & KNOCKBACK
	var targets = aura_area.get_overlapping_bodies() + aura_area.get_overlapping_areas()
	var dmg = get_actual_damage()
	
	for target in targets:
		if is_instance_valid(target) and not target.get("is_dead"):
			
			if target.has_method("take_damage"):
				var actual_dmg = target.take_damage(dmg)
				add_damage_stat(actual_dmg)
				
			if player_ref:
				var push_dir = player_ref.global_position.direction_to(target.global_position)
				
				if target.has_method("apply_knockback"):
					target.apply_knockback(push_dir, knockback_force)
				else:
					var kb_tween = create_tween()
					var target_pos = target.global_position + (push_dir * knockback_force)
					kb_tween.tween_property(target, "global_position", target_pos, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# --- UPGRADES ---
func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+20% Area[/color]\nA wider safe zone.", "rarity": "Common"}
		3: return {"desc": "[color=green]+3 Base Damage[/color]\n[color=green]Stronger Knockback[/color]", "rarity": "Uncommon"}
		4: return {"desc": "[color=green]-0.3s Cooldown[/color]\nPulses much faster.", "rarity": "Rare"}
		5: return {"desc": "[color=orange]Divine Wave[/color]\n[color=green]Massive Knockback & Damage![/color]", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		1:
			base_damage = 3.0
			base_fire_rate = 1.5
		2:
			base_area += 0.20
		3:
			base_damage += 3.0
			knockback_force += 10.0 # Von 12 auf 20
		4:
			base_fire_rate -= 0.3
			pulse_timer.wait_time = get_actual_fire_rate() 
		5:
			base_damage += 6.0
			knockback_force += 15.0 # Von 20 auf 35
			base_area += 0.25

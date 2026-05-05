extends Weapon

@export_group("Orb Settings")
@export var orbit_speed: float = 3.0
@export var orbit_radius: float = 60.0

var orb_count: int = 1
var orb_container: Node2D
var orbs: Array = []

func _ready():
	orb_container = Node2D.new()
	add_child(orb_container)
	_rebuild_orbs()

func _physics_process(delta: float) -> void:
	if not orb_container:
		return

	orb_container.rotation += orbit_speed * delta

	var current_radius = orbit_radius * get_actual_area()
	var step = TAU / orb_count

	for i in range(orbs.size()):
		var angle = i * step
		orbs[i].position = Vector2(cos(angle), sin(angle)) * current_radius

func _rebuild_orbs():
	for child in orb_container.get_children():
		child.queue_free()
	orbs.clear()

	for i in range(orb_count):
		var orb = Area2D.new()
		# Layer 0, aber wir scannen nach Layer 2 (Gegner)
		orb.collision_layer = 0
		orb.collision_mask = 10 # Nur Gegner scannen (Layer 2)

		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 15.0
		shape.shape = circle
		orb.add_child(shape)

		# Visuals
		var glow = Polygon2D.new()
		glow.color = Color(0.6, 0.1, 0.9, 0.3)
		glow.polygon = _create_circle_points(8.0)
		orb.add_child(glow)

		var core = Polygon2D.new()
		core.color = Color(0.8, 0.3, 1.0, 1.0)
		core.polygon = _create_circle_points(2.5)
		orb.add_child(core)

		# --- NEU: SIGNALE FÜR SOFORT-SCHADEN ---
		orb.body_entered.connect(_on_target_entered)
		orb.area_entered.connect(_on_target_entered)

		orb_container.add_child(orb)
		orbs.append(orb)

func _on_target_entered(target: Node2D):
	# Wird sofort aufgerufen, wenn die Orb einen Gegner berührt
	_apply_orb_damage(target)

func _apply_orb_damage(target: Node2D):
	if (target.is_in_group("Enemygroup") or target.is_in_group("Props")) and target.has_method("take_damage"):
		var dmg = get_actual_damage()
		var actual_dmg = target.take_damage(dmg, true)
		add_damage_stat(actual_dmg)

func attack() -> bool:
	# Dieser Teil läuft über den Waffen-Timer (für Gegner, die in der Orb stehen bleiben)
	var hit_someone = false
	for orb in orbs:
		var targets = orb.get_overlapping_bodies() + orb.get_overlapping_areas()
		for target in targets:
			_apply_orb_damage(target)
			hit_someone = true
	return hit_someone

func _create_circle_points(radius: float) -> PackedVector2Array:
	var pts = PackedVector2Array()
	for j in range(12):
		var a = (j / 12.0) * TAU
		pts.append(Vector2(cos(a), sin(a)) * radius)
	return pts

# Ersetze die Upgrades in void_orbs.gd hiermit:
func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+1 Orb[/color]", "rarity": "Common"}
		3: return {"desc": "[color=green]+15% Orbit Speed[/color]\n[color=green]+2 Base Damage[/color]", "rarity": "Uncommon"}
		4: return {"desc": "[color=green]+1 Orb[/color]", "rarity": "Common"}
		5: return {"desc": "[color=green]+20% Area[/color]\nOrbs fly further out.", "rarity": "Rare"}
		6: return {"desc": "[color=green]+2 Orbs[/color]\nA proper swarm.", "rarity": "Epic"}
		7: return {"desc": "[color=green]-0.2s Hit Cooldown[/color]\nZaps enemies much faster.", "rarity": "Rare"}
		8: return {"desc": "[color=purple]Void Mastery[/color]\n[color=green]+2 Orbs & +10 Base Damage![/color]", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: orb_count += 1
		3: 
			orbit_speed *= 1.15
			base_damage += 2.0
		4: orb_count += 1
		5: base_area += 0.20
		6: orb_count += 2
		7: base_fire_rate -= 0.2
		8: 
			orb_count += 2
			base_damage += 10.0
	_rebuild_orbs()

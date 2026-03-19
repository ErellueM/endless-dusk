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
	if not orb_container: return
	
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
		orb.collision_layer = 0
		orb.collision_mask = 4294967295 
		
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 15.0 
		shape.shape = circle
		orb.add_child(shape)
		
		var glow = Polygon2D.new()
		glow.color = Color(0.6, 0.1, 0.9, 0.3)
		glow.polygon = _create_circle_points(8.0)
		orb.add_child(glow)
		
		var core = Polygon2D.new()
		core.color = Color(0.8, 0.3, 1.0, 1.0)
		core.polygon = _create_circle_points(2.5) 
		orb.add_child(core)
		
		orb_container.add_child(orb)
		orbs.append(orb)

func _create_circle_points(radius: float) -> PackedVector2Array:
	var pts = PackedVector2Array()
	for j in range(12):
		var a = (j / 12.0) * TAU
		pts.append(Vector2(cos(a), sin(a)) * radius)
	return pts

func attack() -> bool:
	var hit_someone = false
	var dmg = get_actual_damage()
	
	for orb in orbs:
		var bodies = orb.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("Enemygroup") and body.has_method("take_damage"):
				body.take_damage(dmg)
				add_damage_stat(dmg)
				hit_someone = true
				
	return hit_someone

func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+1 Orb[/color]\nDouble the trouble.", "rarity": "Common"}
		3: return {"desc": "[color=green]-0.2s Hit Cooldown[/color]\nZaps faster.", "rarity": "Rare"}
		4: return {"desc": "[color=green]+2 Orbs[/color]\nA proper swarm.", "rarity": "Legendary"}
		5: return {"desc": "[color=green]+15 Base Damage, +1 Orb[/color]\nVoid mastery.", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: orb_count += 1
		3: base_fire_rate -= 0.2
		4: orb_count += 2
		5: 
			base_damage += 15.0
			orb_count += 1
			
	_rebuild_orbs()

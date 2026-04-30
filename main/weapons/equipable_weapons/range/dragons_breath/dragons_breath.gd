extends Weapon
class_name DragonsBreath

@export var projectile_scene: PackedScene
@export var pellet_count: int = 5 
@export var spread_angle_degrees: float = 45.0 
@export var projectile_speed: float = 600.0

var last_facing_direction: Vector2 = Vector2.RIGHT 

func _physics_process(delta):
	# Wir prüfen die velocity über die player_ref
	if player_ref and "velocity" in player_ref and player_ref.velocity != Vector2.ZERO:
		last_facing_direction = player_ref.velocity.normalized()

func attack() -> bool:
	if not projectile_scene or not player_ref:
		return false
		
	var base_angle = last_facing_direction.angle()
	var half_spread = deg_to_rad(spread_angle_degrees) / 2.0
	var start_angle = base_angle - half_spread
	var angle_step = deg_to_rad(spread_angle_degrees) / float(max(1, pellet_count - 1))
	
	for i in range(pellet_count):
		var proj = projectile_scene.instantiate()
		get_tree().current_scene.add_child(proj)
		
		proj.global_position = player_ref.global_position
		
		# Winkel mit ein bisschen Zufall (Shotgun-Effekt)
		var current_angle = start_angle + (i * angle_step)
		current_angle += randf_range(-0.15, 0.15) 
		
		var shoot_dir = Vector2(cos(current_angle), sin(current_angle))
		
		# Geschwindigkeit leicht variieren, damit sie nicht wie eine perfekte Wand fliegen
		var speed_variance = projectile_speed * randf_range(0.85, 1.15)
		
		proj.velocity = shoot_dir * speed_variance
		proj.damage = get_actual_damage()
		proj.weapon_ref = self
		
	# Kamera wackeln lassen für ordentlich "Wumms"
	var cam = get_tree().get_first_node_in_group("camera")
	if cam and cam.has_method("shake"):
		cam.shake(0.2, 5.0)

	return true

# -- UPGRADE LOGIK --
func _apply_stats_for_current_level():
	match level:
		1:
			pellet_count = 5
			base_damage = 8.0
			base_fire_rate = 1.2
		2:
			pellet_count = 7
			base_damage = 10.0
		3:
			spread_angle_degrees = 60.0
			pellet_count = 9
		4:
			base_fire_rate = 0.9
			base_damage = 14.0
		5:
			pellet_count = 12
			spread_angle_degrees = 80.0
			base_damage = 18.0

func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2:
			return {
				"desc": "[color=green]+2 Flames[/color]\n[color=green]+2 Base Damage[/color]\nFires a denser spread.",
				"rarity": "Common"
			}
		3:
			return {
				"desc": "[color=green]+2 Flames[/color]\n[color=green]Wider Spread[/color]\nCovers a larger area.",
				"rarity": "Uncommon"
			}
		4:
			return {
				"desc": "[color=green]-0.3s Cooldown[/color]\n[color=green]+4 Base Damage[/color]\nFaster and deadlier.",
				"rarity": "Rare"
			}
		5:
			return {
				"desc": "[color=green]+3 Flames[/color]\n[color=red]Massive fiery blast![/color]",
				"rarity": "Epic"
			}
	return {"desc": "MAX", "rarity": "Common"}

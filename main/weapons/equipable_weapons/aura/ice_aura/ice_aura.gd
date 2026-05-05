extends AuraWeapon

@export var slowness_factor: float = 0.65 # Startet etwas schwächer (Gegner behalten 65% Speed)
var ice_color = Color(0.5, 0.5, 1.0)
var base_radius: float = 50.0
var applies_frostbite: bool = false # Neue Lvl 5 Mechanik!

@onready var particles = $GPUParticles2D

func _ready():
	super()
	_apply_particle_setting(SettingsManager.reduce_particles)
	SettingsManager.particles_setting_changed.connect(_apply_particle_setting)

func _apply_particle_setting(is_reduced: bool):
	if is_instance_valid(particles):
		particles.emitting = not is_reduced

# --- LEVEL 5 UPDATE ---
func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2:
			return {
				"desc": "[color=green]+20% Area[/color]\nLarger freezing zone.", "rarity": "Common"
			}
		3:
			return {
				"desc": "[color=green]+15% Slow Power[/color]\nEnemies move much slower.", "rarity": "Rare"
			}
		4:
			return {
				"desc": "[color=green]+30% Area[/color]\nMassive freezing zone.", "rarity": "Uncommon"
			}
		5:
			return {
				"desc": "[color=cyan]Frostbite[/color]\n[color=green]Enemies inside the aura now take damage over time.[/color]", 
				"rarity": "Epic"
			}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2:
			base_area += 0.20
		3:
			slowness_factor -= 0.15 # Wird von 0.65 auf 0.50 reduziert
		4:
			base_area += 0.30
		5:
			applies_frostbite = true
			base_damage = 5.0 # Tick-Schaden aktivieren!

func apply_enter_effect(target: Node2D):
	if target.has_method("add_status_effect"):
		target.add_status_effect(SlowEffect.new(999.0, slowness_factor, ice_color))

func apply_tick_effect(target: Node2D):
	# Neue Funktion, die das Frostbite auf Level 5 handhabt!
	if applies_frostbite and target.has_method("take_damage"):
		# Macht 5 Schaden pro Tick (tötet rote Slimes sofort, Standard-Slimes nach 3 Ticks)
		var actual_dmg = target.take_damage(get_actual_damage(), false) 
		add_damage_stat(actual_dmg)

func apply_exit_effect(target: Node2D):
	var status_manager = target.get_node_or_null("StatusManager")

	if status_manager and status_manager.has_method("remove_effect_by_id"):
		status_manager.remove_effect_by_id("ice_slow")
	elif "is_iced" in target:
		target.is_iced = false
		target.speed_modifier /= slowness_factor
		target._update_visual_state()


func _draw():
	var inner_color = Color(0.2, 0.5, 1.0, 0.1)
	draw_circle(Vector2.ZERO, base_radius, inner_color)
	var outline_color = Color(0.1, 0.4, 1.0, 0.1)
	draw_arc(Vector2.ZERO, base_radius, 0, TAU, 64, outline_color, 1.0, true)

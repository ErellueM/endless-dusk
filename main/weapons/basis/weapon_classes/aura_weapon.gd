extends Weapon
class_name AuraWeapon

@onready var aura_area = $AuraArea

func _ready():
	# 1. Reagiert auf dicke Gegner (CharacterBody2D)
	aura_area.body_entered.connect(_on_target_entered)
	aura_area.body_exited.connect(_on_target_exited)
	
	# 2. Reagiert auf unsere neuen Schwarm-Slimes (Area2D)
	aura_area.area_entered.connect(_on_target_entered)
	aura_area.area_exited.connect(_on_target_exited)

func _process(delta: float):
	super._process(delta)
	var current_scale = get_actual_area()
	scale = Vector2(current_scale, current_scale)

func attack() -> bool:
	var hit_someone = false
	var dmg = get_actual_damage()

	# Wir werfen Bodies und Areas in EINE gemeinsame Liste zusammen!
	var all_targets = aura_area.get_overlapping_bodies() + aura_area.get_overlapping_areas()

	for target in all_targets:
		if target.is_in_group("Enemygroup"):
			
			# Schaden austeilen
			if dmg > 0 and target.has_method("take_damage"):
				# Bei Auren empfiehlt es sich oft, die Schadenszahlen auszumachen (false),
				# da bei 400 Slimes sonst 400 Zahlen pro Tick aufploppen!
				target.take_damage(dmg, false) 
				add_damage_stat(dmg)
				hit_someone = true
			
			# Buffs/Debuffs (Tick) anwenden
			apply_tick_effect(target) 
			
	return hit_someone

# --- BASIS-FUNKTIONEN (Werden von Eis/Feuer überschrieben) ---
func apply_enter_effect(target: Node2D):
	pass

func apply_exit_effect(target: Node2D):
	pass

func apply_tick_effect(target: Node2D):
	pass

# --- SIGNAL-EMPFÄNGER ---
func _on_target_entered(target: Node2D):
	if target.is_in_group("Enemygroup"):
		apply_enter_effect(target)

func _on_target_exited(target: Node2D):
	if target.is_in_group("Enemygroup"):
		apply_exit_effect(target)

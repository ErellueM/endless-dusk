class_name BloodlustEffect extends StatusEffect

var damage_multiplier: float
var aura_instance: Node2D

const AURA_SCENE = preload("res://main/entities/status_effects/appliable_status_effects/bloodlust_effect/bloodlust_aura.tscn")

func _init(_duration: float, _damage_multiplier: float):
	super._init("bloodlust", _duration)
	damage_multiplier = _damage_multiplier

func get_dmg_dealt_mult() -> float:
	return damage_multiplier
	
func get_color() -> Color:
	return Color(2.5, 1.5, 1.5) 

func apply(_target: Node2D):
	super.apply(_target)
	if not _target.is_in_group("SwarmEnemies"):
		if AURA_SCENE:
			aura_instance = AURA_SCENE.instantiate()
			_target.add_child(aura_instance)

func remove():
	if is_instance_valid(aura_instance) and aura_instance.has_method("shrink_and_free"):
		aura_instance.shrink_and_free()

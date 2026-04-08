extends Effect
class_name InstantDamage

func apply_to(target, stats):
	if target.health:
		target.health.take_damage(stats.damage)

extends BaseEnemy
class_name BaseBoss

func _ready():
	super._ready() # Ruft die HP/Speed-Sachen von BaseEnemy auf
	
	is_miniboss = true # Wichtig für deinen vorhandenen Code
	
	# Hier triggerst du später das UI und die Arena:
	# Global.show_boss_healthbar(enemy_name, max_health)
	# _spawn_arena_walls()

func _on_death():
	super._on_death()
	# Global.hide_boss_healthbar()
	# _remove_arena_walls()

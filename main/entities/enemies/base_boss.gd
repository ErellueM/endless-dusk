extends BaseEnemy
class_name BaseBoss

var boss_ui: BossUI

func _ready():
	is_miniboss = true 
	super._ready() 
	boss_ui = get_tree().get_first_node_in_group("BossUI")
	
	if boss_ui:
		boss_ui.show_boss(enemy_name, max_health)
	
	if health:
		health.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health: float, _max_health: float):
	if boss_ui:
		boss_ui.update_health(new_health)

func _on_death():
	super._on_death()
	Global.process_boss_kill()
	if boss_ui:
		boss_ui.hide_boss()

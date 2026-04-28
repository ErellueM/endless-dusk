extends CanvasLayer
class_name BossUI

@onready var health_bar = $Container/HealthBar
@onready var name_label = $Container/HealthBar/BossName

func _ready():
	add_to_group("BossUI")
	hide() # Die Leiste ist am Anfang unsichtbar

func show_boss(boss_name: String, max_hp: float):
	name_label.text = boss_name
	health_bar.max_value = max_hp
	health_bar.value = max_hp
	show()

func update_health(current_hp: float):
	# Optional: Hier könntest du einen Tween einbauen für weiches Abziehen!
	health_bar.value = current_hp

func hide_boss():
	hide()

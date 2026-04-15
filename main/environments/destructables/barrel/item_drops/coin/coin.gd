extends BasePickup

@export var gold_amount: int = 1

# Wir überschreiben die leere Funktion aus dem Base-Skript
func _apply_effect(_player: Node2D):
	# 1. Gold zum globalen Speicher hinzufügen
	Global.gold += gold_amount
	
	# 2. (Optional) Einen Sound abspielen
	# AudioManager.play_sound("coin_pickup")
	
	# 3. (Optional) Einen kleinen goldenen Text aufploppen lassen
	# DamagePool.spawn_number(global_position, gold_amount, false, Color("#fceda6"))

class_name AoEDelivery
extends Delivery

func deliver(stats, effects):
	apply_aoe(stats, effects)

	while true:
		await get_tree().create_timer(stats.tick_rate).timeout
		apply_aoe(stats, effects)

func apply_aoe(stats, effects):
	print("AOE tick:", stats.damage)

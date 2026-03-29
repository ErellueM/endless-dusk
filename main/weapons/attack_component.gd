class_name AttackComponent
extends Node

var can_attack := true

func execute(stats, delivery, effects):
	if not can_attack:
		return

	perform_attack(stats, delivery, effects)
	start_cooldown(stats.attack_speed)

func perform_attack(stats, delivery, effects):
	delivery.deliver(stats, effects)

func start_cooldown(speed):
	can_attack = false
	await get_tree().create_timer(1.0 / speed).timeout
	can_attack = true

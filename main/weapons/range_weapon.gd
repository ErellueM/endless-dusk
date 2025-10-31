extends Weapon
class_name RangeWeapon
@export var knockback: int
var ProjectileScene = preload("res://main/environments/Weapons/projectile.tscn")
var time_since_last_shot = 0.0

func get_nearest_enemy() -> Node2D:
	var nearest_enemy = null
	var shortest_distance := INF
	for enemy in get_tree().get_nodes_in_group("Enemygroup"):
		if not enemy or not enemy.is_inside_tree():
			continue
		var distance = global_position.distance_to(enemy.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_enemy = enemy
	
	return nearest_enemy
	
func fire_weapon():
	var target = get_nearest_enemy()
	if not target:
		return
	
	var spawn = get_node("../../projectile_spawn")
	var projectile = ProjectileScene.instantiate()
	projectile.global_position = spawn.global_position
	projectile.z_index = 2

	var direction = (target.global_position - global_position).normalized()
	projectile.velocity = direction * projectile.speed

	get_tree().current_scene.add_child(projectile)
	
func _process(delta: float) -> void:
	time_since_last_shot += delta
	var target = get_nearest_enemy()
	if target:
		look_at(target.global_position)
		if time_since_last_shot > fire_rate:
			fire_weapon()
			time_since_last_shot = 0.0

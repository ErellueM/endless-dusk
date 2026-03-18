extends Weapon
class_name RangeWeapon

@export_group("Range Specifics")
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 400.0
@export var spawn_offset: float = 0 #25

func attack() -> bool:
	var target = get_nearest_enemy()
	if not target:
		return false
		
	shoot_at(target)
	return true

func shoot_at(target: Node2D):
	if not projectile_scene: return
	
	var projectile = projectile_scene.instantiate()
	
	var direction = (target.global_position - self.global_position).normalized()

	var total_offset = direction * spawn_offset 
	projectile.global_position = self.global_position + total_offset
	
	projectile.z_index = 2
	
	if "damage" in projectile:
		projectile.damage = get_actual_damage()
		
	if "weapon_ref" in projectile:
		projectile.weapon_ref = self 
		
	var actual_area = get_actual_area()
	projectile.scale = Vector2(actual_area, actual_area)
	
	if "velocity" in projectile:
		projectile.velocity = direction * projectile_speed

	add_child(projectile)
	

func get_nearest_enemy() -> Node2D:
	var nearest = null
	var shortest_dist = get_actual_range()
	
	for enemy in get_tree().get_nodes_in_group("Enemygroup"):
		if not enemy or not enemy.is_inside_tree() or enemy.get("is_dead"): 
			continue
			
		var dist = global_position.distance_to(enemy.global_position)
		if dist < shortest_dist:
			shortest_dist = dist
			nearest = enemy
			
	return nearest

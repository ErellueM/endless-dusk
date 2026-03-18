extends Node2D
class_name Weapon

@export_group("Base Weapon Stats")
@export var weapon_id: String = "unknown"
@export var max_level: int = 5
@export var base_damage: float = 10.0
@export var base_fire_rate: float = 1.0 
@export var base_range: float = 200.0
@export var base_area: float = 1.0

var level: int = 1
var cooldown_timer: float = 0.0
var player_ref: Node2D = null
var total_damage_dealt: float = 0.0

func _process(delta: float) -> void:
	cooldown_timer += delta
	var current_fire_rate = get_actual_fire_rate()
	
	if cooldown_timer >= current_fire_rate:
		if await attack(): 
			cooldown_timer = 0.0

func get_actual_damage() -> float:
	if player_ref and "might" in player_ref:
		return base_damage * player_ref.might
	return base_damage

func get_actual_fire_rate() -> float:
	if player_ref and "cooldown_mult" in player_ref:
		return base_fire_rate * player_ref.cooldown_mult
	return base_fire_rate

func get_actual_area() -> float:
	if player_ref and "area" in player_ref:
		return base_area * player_ref.area
	return base_area

func get_actual_range() -> float:
	if player_ref and "area" in player_ref:
		return base_range * player_ref.area 
	return base_range

func add_damage_stat(amount: float):
	total_damage_dealt += amount

func attack() -> bool:
	return false
	
# Called by UI when player selects an upgrade card
func apply_level_upgrade(new_level: int):
	level = new_level
	_apply_stats_for_current_level()

# Virtual method: Override this in your specific weapons
func _apply_stats_for_current_level():
	pass

# Virtual method: UI calls this to get the text for the upgrade card
func get_upgrade_info(next_level: int) -> Dictionary:
	return {"desc": "Missing description", "rarity": "Common"}

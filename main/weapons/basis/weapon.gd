extends Node2D
class_name Weapon

@export_group("Base Weapon Stats")
@export var base_damage: float = 10.0
@export var base_fire_rate: float = 1.0 
@export var base_range: float = 200.0
@export var base_area: float = 1.0

var cooldown_timer: float = 0.0
var player_ref: Node2D = null
var total_damage_dealt: float = 0.0

func _ready():
	pass

func _process(delta: float) -> void:
	cooldown_timer += delta
	var current_fire_rate = get_actual_fire_rate()
	
	if cooldown_timer >= current_fire_rate:
		if attack(): 
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

extends Weapon
class_name AuraWeapon

@export var slowness_factor: float = 0.5

@onready var aura_area = $AuraArea

func _ready():
	super._ready()
	aura_area.body_entered.connect(_on_body_entered)
	aura_area.body_exited.connect(_on_body_exited)

func _process(delta: float):
	super._process(delta)
	
	var current_scale = get_actual_area()
	scale = Vector2(current_scale, current_scale)

func attack() -> bool:
	var hit_someone = false
	var dmg = get_actual_damage()

	for body in aura_area.get_overlapping_bodies():
		if body.is_in_group("Enemygroup") and body.has_method("take_damage"):
			body.take_damage(dmg)
			add_damage_stat(dmg)
			hit_someone = true
			
	return hit_someone


func _on_body_entered(body: Node2D):
	if body.is_in_group("Enemygroup") and "speed" in body:
		body.speed *= slowness_factor 

func _on_body_exited(body: Node2D):
	if body.is_in_group("Enemygroup") and "speed" in body:
		body.speed /= slowness_factor

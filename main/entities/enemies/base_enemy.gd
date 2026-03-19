extends CharacterBody2D
class_name BaseEnemy 

@export var enemy_name: String = "Monster"
@export var speed: float = 100.0
@export var damage: float = 10.0
@export var xp_gem_scene: PackedScene 
@export var damage_number_scene: PackedScene

var base_speed: float
var current_speed: float
var base_color: Color = Color(1, 1, 1)

var active_effects: Dictionary = {}

var player: Node2D
var is_dead: bool = false       
var can_attack: bool = true     

@onready var health = $Health
@onready var anim = $AnimatedSprite2D
@onready var attack_area = $AttackArea

func _ready():
	add_to_group("Enemygroup")
	player = get_tree().get_first_node_in_group("player")
	base_speed = speed * randf_range(0.8, 1.2)
	current_speed = base_speed
	if health:
		health.died.connect(_on_death)

func _physics_process(delta):
	if is_dead: return 
	
	var effects_to_remove = []
	for effect_name in active_effects:
		var effect = active_effects[effect_name]
		
		if effect.has("duration"):
			effect["duration"] -= delta
			if effect["duration"] <= 0:
				effects_to_remove.append(effect_name)
				continue 
				
		if effect.has("tick_damage") and effect.has("tick_rate"):
			if not effect.has("current_tick"):
				effect["current_tick"] = effect["tick_rate"]
				
			effect["current_tick"] -= delta
			if effect["current_tick"] <= 0:
				take_damage(effect["tick_damage"], true) 
				if effect.has("source") and is_instance_valid(effect["source"]) and effect["source"].has_method("add_damage_stat"):
					effect["source"].add_damage_stat(effect["tick_damage"])
					
				effect["current_tick"] = effect["tick_rate"]
				
	for eff in effects_to_remove:
		remove_status_effect(eff)
	
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * current_speed
		move_and_slide()
		if velocity.x != 0:
			anim.flip_h = velocity.x < 0
			anim.play("default")
	
	if can_attack:
		var overlapping_bodies = attack_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player") and body.has_method("take_damage"):
				body.take_damage(damage)
				start_attack_cooldown()
				break

func start_attack_cooldown():
	can_attack = false
	await get_tree().create_timer(1.0).timeout 
	can_attack = true

# --- DAS SMARTE UPGRADE ---
func add_status_effect(effect_name: String, data: Dictionary):
	if active_effects.has(effect_name):
		# Wenn der Effekt schon da ist, NUR die Zeit erneuern!
		# So bleibt 'current_tick' erhalten und wird nicht resettet.
		if data.has("duration"):
			active_effects[effect_name]["duration"] = data["duration"]
	else:
		# Neuer Effekt? Dann komplett rein damit.
		active_effects[effect_name] = data
		
	recalculate_status()

func remove_status_effect(effect_name: String):
	if active_effects.has(effect_name):
		active_effects.erase(effect_name)
	recalculate_status()

func recalculate_status():
	current_speed = base_speed
	var final_color = Color(1, 1, 1) 
	for effect_name in active_effects:
		var data = active_effects[effect_name]
		if data.has("slow_factor"):
			current_speed *= data["slow_factor"]
		if data.has("color"):
			final_color *= data["color"] 
	base_color = final_color
	if is_instance_valid(anim) and anim.modulate != Color(1, 0, 0):
		anim.modulate = base_color

func take_damage(amount: float, is_poison: bool = false):
	if is_dead: return
	
	if damage_number_scene and amount > 0:
		var dmg_num = damage_number_scene.instantiate()
		var offset = Vector2(+38, -20)
		var random_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		dmg_num.global_position = global_position + random_offset + offset
		get_tree().current_scene.call_deferred("add_child", dmg_num)
		dmg_num.setup(amount, false, is_poison)
	
	if health and amount > 0:
		health.take_damage(amount)
	
	if not is_poison:
		anim.modulate = Color(1, 0.1, 0.1)
		await get_tree().create_timer(0.2).timeout
		if is_instance_valid(anim):
			anim.modulate = base_color

func _on_death():
	is_dead = true
	$CollisionShape2D.set_deferred("disabled", true) 
	Global.register_kill(enemy_name)
	drop_soul()
	queue_free()

func drop_soul():
	if xp_gem_scene != null:
		var gem = xp_gem_scene.instantiate()
		var offset = Vector2(+38,0)
		gem.set_deferred("global_position", global_position + offset)
		get_tree().current_scene.call_deferred("add_child", gem)

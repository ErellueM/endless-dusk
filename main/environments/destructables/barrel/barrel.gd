extends StaticBody2D

@export var heal_scene: PackedScene
@export var magnet_scene: PackedScene
@export var bomb_scene: PackedScene
@export var coin_scene: PackedScene

# --- BESSERES LOOT SYSTEM (Weighted Drops) ---
# Hier kannst du die Werte im Editor jederzeit super einfach anpassen!
@export var drop_weights = {
	"coin": 40.0,
	"heal": 15.0,
	"bomb": 5.0,
	"magnet": 5.0,
	"nothing": 35.0  # Wichtig: Chance, dass das Fass leer ist
}

var is_destroyed: bool = false 

func _ready():
	add_to_group("Props")

func take_damage(amount: float, is_dot: bool = false, dmg_color: Color = Color.WHITE) -> float:
	if is_destroyed:
		return 0.0

	is_destroyed = true
	destroy()
	return 0.0

func destroy():
	spawn_loot()

	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false
	if has_node("Shadow"):
		$Shadow.visible = false

	if has_node("WoodSplinters"):
		$WoodSplinters.emitting = true

	await get_tree().create_timer(1.0).timeout
	queue_free()

func spawn_loot():
	# 1. Zuerst alle Gewichte zusammenrechnen
	var total_weight = 0.0
	for weight in drop_weights.values():
		total_weight += weight
		
	# 2. Eine zufällige Zahl zwischen 0 und dem Gesamtgewicht ziehen
	var roll = randf_range(0.0, total_weight)
	
	# 3. Herausfinden, was gedroppt ist
	var current_weight = 0.0
	var chosen_drop = "nothing"
	
	for drop_key in drop_weights.keys():
		current_weight += drop_weights[drop_key]
		if roll <= current_weight:
			chosen_drop = drop_key
			break
			
	# 4. Das entsprechende Item spawnen
	var drop_instance = null
	
	match chosen_drop:
		"coin":
			if coin_scene: drop_instance = coin_scene.instantiate()
		"heal":
			if heal_scene: drop_instance = heal_scene.instantiate()
		"bomb":
			if bomb_scene: drop_instance = bomb_scene.instantiate()
		"magnet":
			if magnet_scene: drop_instance = magnet_scene.instantiate()
			
	if drop_instance:
		get_tree().current_scene.call_deferred("add_child", drop_instance)
		drop_instance.set_deferred("global_position", global_position)

extends StaticBody2D

@export var heal_scene: PackedScene
@export var magnet_scene: PackedScene
@export var bomb_scene: PackedScene

func _ready():
	add_to_group("Props")

var is_destroyed: bool = false # <--- NEU

func take_damage(amount: float, is_dot: bool = false, dmg_color: Color = Color.WHITE) -> float:
	if is_destroyed: 
		return 0.0 
		
	is_destroyed = true 
	destroy()
	return amount

func destroy():
	spawn_loot()
	
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false
	$Shadow.visible = false
	
	if has_node("WoodSplinters"):
		$WoodSplinters.emitting = true
		
	await get_tree().create_timer(1.0).timeout
	queue_free()

func spawn_loot():
	var roll = randf()
	var drop_instance = null
	
	if roll <= 0.25 and bomb_scene:
		drop_instance = bomb_scene.instantiate()
	elif roll <= 0.50 and magnet_scene:
		drop_instance = magnet_scene.instantiate()
	elif heal_scene:
		drop_instance = heal_scene.instantiate()
		
	if drop_instance:
		get_tree().current_scene.call_deferred("add_child", drop_instance)
		drop_instance.set_deferred("global_position", global_position)

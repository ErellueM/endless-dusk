extends BaseEnemy
class_name MitosisBoss

@export_group("Mitosis Settings")
@export var splits_into: int = 3
@export var small_enemy_scene: PackedScene

var is_stomping: bool = false
var stomp_timer: float = 0.5

func _ready():
	is_miniboss = true
	super._ready()

func process_movement(delta: float):
	if is_stomping:
		move_and_slide()
		return

	stomp_timer -= delta
	if stomp_timer <= 0:
		_perform_heavy_stomp()

func _perform_heavy_stomp():
	is_stomping = true
	
	var dir = global_position.direction_to(player.global_position)
	var s_mult = status_manager.speed_mult if status_manager else 1.0
	velocity = dir * (speed * 3.5 * s_mult)
	
	#if velocity.x != 0:
	#	anim.flip_h = velocity.x < 0
		
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(anim, "position:y", -20.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(anim, "scale", Vector2(0.8, 1.2), 0.15)
	
	tween.set_parallel(false)
	tween.tween_interval(0.15)
	
	tween.set_parallel(true)
	tween.tween_property(anim, "position:y", 0.0, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(anim, "scale", Vector2(1.3, 0.7), 0.1)
	
	tween.set_parallel(false)
	tween.tween_callback(_on_stomp_landed)

func _on_stomp_landed():
	velocity = Vector2.ZERO
	is_stomping = false
	stomp_timer = 0.7
	
	var cam = get_tree().get_first_node_in_group("camera")
	if cam and cam.has_method("shake"):
		cam.shake(0.15, 5.0)
		
	var reset_tween = create_tween()
	reset_tween.tween_property(anim, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_death():
	if small_enemy_scene:
		for i in range(splits_into):
			var small_enemy = small_enemy_scene.instantiate()
			var angle = (TAU / splits_into) * i
			var spawn_offset = Vector2(cos(angle), sin(angle)) * 30.0
			
			small_enemy.global_position = global_position + spawn_offset
			small_enemy.is_miniboss = false
			
			get_tree().current_scene.call_deferred("add_child", small_enemy)
			
			var tween = small_enemy.create_tween()
			small_enemy.scale = Vector2.ZERO
			tween.tween_property(small_enemy, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	super._on_death()

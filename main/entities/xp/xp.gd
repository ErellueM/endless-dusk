extends Area2D

@export var xp_value: float = 1.0
@export var base_scale: Vector2 = Vector2(1, 1)
@export var base_transparency: float = 0.5
@export var pulsing_duration: float = 1.0
@export var fly_speed: float = 1.0

@onready var sprite = $Sprite2D

var target_player: Node2D = null
var is_flying: bool = false

func _ready():
	add_to_group("XPGem")
	body_entered.connect(_on_body_entered)
	
	scale = base_scale
	modulate.a = base_transparency
	animate_pulsing()

func _process(delta):
	if is_flying and target_player:
		var direction = (target_player.global_position - global_position).normalized()
		global_position += direction * fly_speed * delta

func fly_to_player(player_node: Node2D):
	target_player = player_node
	is_flying = true

	var tween = create_tween()
	tween.tween_property(self, "fly_speed", 1200.0, 0.5)

func animate_pulsing():
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "scale", base_scale * 0.7, pulsing_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(self, "scale", base_scale, pulsing_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "modulate:a", base_transparency * 0.7, pulsing_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(self, "modulate:a", base_transparency, pulsing_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.set_loops()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("gain_xp"):
			body.gain_xp(xp_value)
			queue_free()

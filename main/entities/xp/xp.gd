extends Area2D

@export var xp_value: float = 1.0
@export var base_scale: Vector2 = Vector2(1, 1)
@export var base_transparency: float = 0.5
@export var pulsing_duration: float = 1.0

@onready var sprite = $Sprite2D

func _ready():
	#body_entered.connect(_on_body_entered)
	scale = base_scale
	modulate.a = base_transparency
	animate_pulsing()

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

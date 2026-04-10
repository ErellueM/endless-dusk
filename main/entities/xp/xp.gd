extends Area2D

@export var fly_speed: float = 1.0
@onready var sprite = $Sprite2D

var xp_value: float = 1.0
var target_player: Node2D = null
var is_flying: bool = false
var base_scale: Vector2 = Vector2.ONE

func _ready():
	# Standardmäßig auf Schlafmodus setzen
	set_process(false)

func setup(amount: float):
	xp_value = amount
	fly_speed = 1.0
	is_flying = false
	target_player = null
	_update_visuals()
	
	# WICHTIG: Der Stein liegt auf dem Boden -> Tiefschlaf!
	# Die Engine berechnet diesen Stein jetzt überhaupt nicht mehr.
	set_process(false) 

func add_xp_silently(extra_amount: float):
	xp_value += extra_amount
	_update_visuals()
	
	# Tween für das Ploppen ist völlig in Ordnung (Tweens sind sehr effizient)
	var pop = create_tween()
	pop.tween_property(self, "scale", base_scale * 1.3, 0.05).set_trans(Tween.TRANS_SINE)
	pop.tween_property(self, "scale", base_scale, 0.1).set_trans(Tween.TRANS_SINE)

func _process(delta):
	# Diese Funktion läuft JETZT NUR NOCH, wenn der Stein fliegt!
	if is_flying and target_player:
		fly_speed += 2500.0 * delta 
		var move_amount = fly_speed * delta
		var dist = global_position.distance_to(target_player.global_position)
		
		if dist <= move_amount or dist < 10.0:
			if target_player.has_method("gain_xp"):
				target_player.gain_xp(xp_value)
				XpPool.return_to_pool(self)
			return 

		global_position = global_position.move_toward(target_player.global_position, move_amount)

func fly_to_player(player_node: Node2D):
	target_player = player_node
	is_flying = true
	# WICHTIG: Der Magnet hat den Stein erfasst -> Aufwachen!
	set_process(true) 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("gain_xp"):
			body.gain_xp(xp_value)
			XpPool.return_to_pool(self)

func _update_visuals():
	var target_color = Color(1, 1, 1) 
	var target_scale_mult = 1.0 
	
	if xp_value >= 100: 
		target_color = Color(0.8, 0.2, 1.0) 
		target_scale_mult = 1.8
	elif xp_value >= 50: 
		target_color = Color(1.0, 0.2, 0.2) 
		target_scale_mult = 1.6
	elif xp_value >= 25: 
		target_color = Color(1.0, 0.8, 0.1) 
		target_scale_mult = 1.4
	elif xp_value >= 10: 
		target_color = Color(0.2, 1.0, 0.2) 
		target_scale_mult = 1.2
	elif xp_value >= 5: 
		target_color = Color(0.2, 0.6, 1.0) 
		target_scale_mult = 1.1

	modulate = target_color
	base_scale = Vector2(1, 1) * target_scale_mult
	scale = base_scale # Setze die Skalierung sofort

extends Weapon
class_name MeleeWeapon

@onready var hitbox = $HitboxArea
@onready var anim_player = $AnimationPlayer

func _ready():
	super._ready()
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func attack() -> bool:
	if anim_player.has_animation("swing"):
		anim_player.play("swing")
		return true
	return false

func _on_hitbox_body_entered(body: Node2D):
	if body.is_in_group("Enemygroup") and body.has_method("take_damage"):
		var dmg = get_actual_damage()
		body.take_damage(dmg)
		add_damage_stat(dmg)

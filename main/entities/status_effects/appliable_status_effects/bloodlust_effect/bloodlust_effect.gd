class_name BloodlustEffect extends StatusEffect

var damage_multiplier: float
var aura_instance: Node2D

# HIER DEN PFAD ZU DEINER NEUEN SZENE EINTRAGEN!
const AURA_SCENE = preload(
	"res://main/entities/status_effects/appliable_status_effects/bloodlust_effect/bloodlust_aura.tscn"
)


func _init(_duration: float, _damage_multiplier: float):
	super._init("bloodlust", _duration)
	damage_multiplier = _damage_multiplier


func get_dmg_dealt_mult() -> float:
	return damage_multiplier


func apply(_target: Node2D):
	super.apply(_target)

	# Szene instanziieren und als Kind an den Gegner heften
	if AURA_SCENE and _target:
		aura_instance = AURA_SCENE.instantiate()

		# (Optional) Wenn die Aura weiter unten am Boden spawnen soll:
		# aura_instance.position = Vector2(0, 10)

		_target.add_child(aura_instance)


func remove():
	# Wenn der Buff abläuft, lassen wir den Teufelskreis schrumpfen!
	if is_instance_valid(aura_instance) and aura_instance.has_method("shrink_and_free"):
		aura_instance.shrink_and_free()

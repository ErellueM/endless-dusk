class_name StatusEffect extends RefCounted

# =========================================================================================
# 📖 STATUS EFFEKT CHEAT SHEET (Kopieren & Einfügen in deine Waffen)
# =========================================================================================
# WIE MAN EINEN EFFEKT ANWENDET:
# 1. Prüfe, ob der Gegner den Manager hat:
#    var manager = enemy.get_node_or_null("StatusManager")
# 2. Füge den Effekt hinzu:
#    if manager: manager.add_effect( ... )
#
# --- 🔴 BURN (FEUER) ---
# Macht sehr schnellen Schaden über Zeit und färbt den Gegner Orange. Stackt pro Waffe!
# Parameter: (Dauer, Schaden_pro_Tick, Tick_Geschwindigkeit, Waffe_als_Source)
# COPY: status_manager.add_effect(BurnEffect.new(3.0, 1.0, 0.2, self))
#
# --- 🟢 POISON (GIFT) ---
# Macht langsamen, aber stetigen Schaden. Färbt den Gegner Grün. Stackt pro Waffe!
# Parameter: (Dauer, Schaden_pro_Tick, Tick_Geschwindigkeit, Waffe_als_Source)
# COPY: status_manager.add_effect(PoisonEffect.new(5.0, 5.0, 1.0, self))
#
# --- 🔵 SLOW (EIS / VERLANGSAMUNG) ---
# Verlangsamt den Gegner. 0.5 = Halbes Tempo. Färbt den Gegner Eisblau. Stackt NICHT!
# Parameter: (Dauer, Speed_Multiplikator, Farbe)
# COPY: status_manager.add_effect(SlowEffect.new(4.0, 0.5, Color(0.5, 0.5, 1.0)))
#
# --- ⚪ STUN (BETÄUBUNG) ---
# Friert den Gegner komplett ein (Speed = 0.0). Färbt ihn Grau. Stackt NICHT!
# Parameter: (Dauer)
# COPY: status_manager.add_effect(StunEffect.new(1.5))
#
# --- 🟣 VULNERABLE (RÜSTUNGSBRUCH / SCHWÄCHE) ---
# Gegner nimmt mehr Schaden aus ALLEN Quellen (1.5 = 50% mehr). Färbt Lila. Stackt NICHT!
# Parameter: (Dauer, Schadens_Multiplikator)
# COPY: status_manager.add_effect(VulnerableEffect.new(5.0, 1.5))
# =========================================================================================

var id: String = "base"
var duration: float = 0.0
var target: Node2D = null
var source: Node2D = null


func _init(
	_base_id: String, _duration: float, _source: Node2D = null, _stack_per_source: bool = false
):
	duration = _duration
	source = _source

	if _stack_per_source and _source != null:
		id = _base_id + "_" + str(_source.get_instance_id())
	else:
		id = _base_id


func apply(_target: Node2D):
	target = _target


func tick(delta: float):
	duration -= delta


func remove():
	pass


func get_speed_mult() -> float:
	return 1.0


func get_dmg_taken_mult() -> float:
	return 1.0


func get_color() -> Color:
	return Color(1, 1, 1)


func get_power() -> float:
	return 0.0


func get_dmg_dealt_mult() -> float:
	return 1.0

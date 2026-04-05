extends Resource
class_name SpawnData

enum SpawnType { NORMAL, SWARM, MINIBOSS }

@export var enemy_scene: PackedScene
@export var spawn_type: SpawnType = SpawnType.NORMAL
@export var weight: float = 10.0 # Wie oft er gespawnt wird (höher = öfter)

@export_group("Limits & Groups")
@export var enemy_id: String = "basic_enemy" # Eindeutiger Name (z.B. "buffer", "zombie")
@export var max_active_count: int = 0 # 0 = unendlich. 3 = Maximal 3 gleichzeitig auf der Map.

@export_group("Time Limits (in Minutes)")
@export var spawn_start_minute: float = 0.0 # Ab Minute X
@export var spawn_end_minute: float = 999.0 # Bis Minute Y

@export_group("Swarm Settings")
@export var swarm_min_count: int = 3
@export var swarm_max_count: int = 7

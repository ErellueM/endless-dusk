extends Resource
class_name SpawnData

enum SpawnType { NORMAL, MINIBOSS }

@export var enemy_scene: PackedScene
@export var spawn_type: SpawnType = SpawnType.NORMAL

@export var weight: float = 10.0

@export_group("Limits & Groups")
@export var enemy_id: StringName = "basic_enemy"
@export var max_active_count: int = 0

@export_group("Time Limits (in Minutes)")
@export var spawn_start_minute: float = 0.0
@export var spawn_end_minute: float = 999.0

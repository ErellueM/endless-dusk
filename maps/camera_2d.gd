extends Camera2D

@export var target_path: NodePath  # Player_01 im Inspector auswählen
var target_node: Node2D

func _ready():
	if target_path:
		target_node = get_node(target_path)

func _process(_delta):
	if target_node:
		global_position = target_node.global_position

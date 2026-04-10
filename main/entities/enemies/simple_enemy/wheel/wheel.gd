extends BaseEnemy

@export var chase_time: float = 3.0
@export var rush_speed_multiplier: float = 4.0
@export var aim_time: float = 1.0
@export var charge_time: float = 0.5
@export var rush_time: float = 1.0
@export var cooldown_time: float = 0.5

@onready var aim_line: Line2D = $AimLine2D

enum States { CHASE, AIM, CHARGE, RUSH, COOLDOWN }
var current_state = States.CHASE

var state_timer: float = 0.0
var rush_direction: Vector2 = Vector2.ZERO


func _ready():
	super._ready()
	add_to_group("EliteWheels")

	if aim_line:
		aim_line.visible = false


func process_movement(delta: float):
	var s_mult = status_manager.speed_mult if status_manager else 1.0
	state_timer += delta

	match current_state:
		States.CHASE:
			var distance_to_player = global_position.distance_to(player.global_position)
			var dir_to_player = (player.global_position - global_position).normalized()
			var stop_distance = 150.0

			if distance_to_player > stop_distance + 15.0:
				velocity = dir_to_player * (speed * s_mult)
				if not anim.is_playing():
					anim.play("default")
				anim.speed_scale = 1.0
			elif distance_to_player < stop_distance - 15.0:
				velocity = -dir_to_player * (speed * 0.5 * s_mult)
				if not anim.is_playing():
					anim.play("default")
				anim.speed_scale = -0.5
			else:
				velocity = velocity.lerp(Vector2.ZERO, 10 * delta)
				anim.pause()

			move_and_slide()

			if dir_to_player.x != 0:
				anim.flip_h = dir_to_player.x < 0

			if state_timer >= chase_time:
				current_state = States.AIM
				state_timer = 0.0
				anim.pause()

		States.AIM:
			velocity = Vector2.ZERO
			var dir_to_player = (player.global_position - global_position).normalized()
			rush_direction = dir_to_player

			if dir_to_player.x != 0:
				anim.flip_h = dir_to_player.x < 0

			if aim_line:
				aim_line.visible = true
				aim_line.clear_points()
				aim_line.add_point(Vector2.ZERO)

				var rush_distance = (speed * rush_speed_multiplier) * rush_time
				var target_local_pos = to_local(global_position + (rush_direction * rush_distance))
				aim_line.add_point(target_local_pos)
				aim_line.default_color = Color(1.0, 0.0, 0.0, 0.15)

			if state_timer >= aim_time:
				current_state = States.CHARGE
				state_timer = 0.0
				anim.play("default")

				if aim_line:
					aim_line.default_color = Color(1.0, 0.0, 0.0, 0.3)

		States.CHARGE:
			velocity = Vector2.ZERO
			anim.speed_scale = 4.0

			if state_timer >= charge_time:
				current_state = States.RUSH
				state_timer = 0.0

				if aim_line:
					aim_line.visible = false

		States.RUSH:
			velocity = rush_direction * (speed * rush_speed_multiplier * s_mult)
			move_and_slide()
			anim.speed_scale = 4.0

			if state_timer >= rush_time:
				current_state = States.COOLDOWN
				state_timer = 0.0

		States.COOLDOWN:
			velocity = velocity.lerp(Vector2.ZERO, 10 * delta)
			move_and_slide()
			anim.speed_scale = clamp(velocity.length() / speed, 0.0, 1.0)

			if state_timer >= cooldown_time:
				current_state = States.CHASE
				state_timer = 0.0

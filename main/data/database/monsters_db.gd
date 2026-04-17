class_name MonstersDatabase
extends Node

static var monsters =  {
	"Green Slime": {
		"scene": preload("res://main/entities/enemies/dump_swarm_enemy/swarm_enemies/green_slime.tscn"),
		"category": "Swarm"
	},
	"Red Slime": {
		"scene": preload("res://main/entities/enemies/dump_swarm_enemy/swarm_enemies/red_slime.tscn"),
		"category": "Swarm"
	},
	"Tank Slime": {
		"scene": preload("res://main/entities/enemies/dump_swarm_enemy/swarm_enemies/tank_slime.tscn"),
		"category": "Swarm"
	},
	"Mushroom Brute": {
		"scene": preload("res://main/entities/enemies/simple_enemy/mushroom_brute/mushroom_brute.tscn"),
		"category": "Normal"
	},
	"Wheel": {
		"scene": preload("res://main/entities/enemies/simple_enemy/wheel/wheel.tscn"),
		"category": "Normal"
	},
	"Tollkeeper": {
		"scene": preload("res://main/entities/enemies/simple_enemy/tollkeeper/tollkeeper.tscn"),
		"category": "Normal"
	},
	"Plague Doctor": {
		"scene": preload("res://main/entities/enemies/simple_ranged_enemy/plagueDoctor/plague_doctor.tscn"),
		"category": "Normal"
	},
	"Slime King": {
		"scene": preload("res://main/entities/enemies/miniboss/slime_king/slime_king.tscn"),
		"category": "Miniboss"
	}
}

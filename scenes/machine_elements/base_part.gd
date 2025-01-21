class_name MachinePart
extends Area2D

signal died(tile_pos: Vector2i, prioritize_friend: bool)

var team = Globals.Team.Neutral:
	set(value):
		team = value
		call_deferred("_update_collision_layer")
var type = Globals.MachineType.Part
@export var default_health: int = -1
@export var default_armor: int = -1

var tile_pos: Vector2i = Vector2i.ZERO
var has_died: bool = false
var health: int
var armor: int

func _ready():
	health = default_health
	armor = default_armor

func init_module(pos: Vector2i) -> void:
	tile_pos = pos

func hurt(amount: int):
	if armor > 0:
		armor -= amount
	else:
		health -= amount
	if health <= 0 and not has_died:
		die()

func die():
	has_died = true
	# 如果是敌方, 则定然是被友方打死的, 因此优先连友方
	var prioritize_friend: bool = true if team == Globals.Team.Enemy else false
	died.emit(tile_pos, prioritize_friend)

func _update_collision_layer() -> void:
	# 首先清除所有相关层
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, false)
	
	# 根据队伍设置对应层
	match team:
		Globals.Team.Friend:
			set_collision_layer_value(1, true)
		Globals.Team.Enemy:
			set_collision_layer_value(2, true)
		Globals.Team.Neutral:
			set_collision_layer_value(3, true)

func activate(energy: int, energy_dir: int):
	return

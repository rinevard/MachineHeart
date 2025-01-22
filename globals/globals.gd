extends Node

var is_picking: bool = false # 该变量表示玩家是否抓着什么东西, 如果抓着就不能买东西了

var map_size_x: int = 40
var map_size_y: int = 30
var money: int = 20
var camera_x_min = 0
var camera_x_max = 40 * 64
var camera_y_min = 0
var camera_y_max = 30 * 64

# 多写几遍重复内容就能实现 "加权" 了
var all_possible_shop_item_paths: Array[PackedScene] = [
preload("res://scenes/machine_elements/blue_core.tscn"),
preload("res://scenes/machine_elements/gun_part.tscn"),
preload("res://scenes/machine_elements/money_part.tscn"), 
preload("res://scenes/machine_elements/sword_part.tscn"), 
preload("res://scenes/machine_elements/shield_part.tscn")
]
var all_possible_enemy_part_paths: Array[PackedScene] = [
preload("res://scenes/machine_elements/gun_part.tscn"),
preload("res://scenes/machine_elements/sword_part.tscn"), 
preload("res://scenes/machine_elements/shield_part.tscn")
]
var enemy_core_path: PackedScene = preload("res://scenes/machine_elements/black_core.tscn")

enum Team {Friend, Enemy, Neutral}
enum MachineType {Core, Part, Undefined}
enum HexDirection {
	UP_RIGHT = 0,      # 向右上射击
	RIGHT = 1,    # 向右射击
	DOWN_RIGHT = 2,    # 向右下射击
	DOWN_LEFT = 3,     # 向左下射击
	LEFT = 4,     # 向左射击
	UP_LEFT = 5,       # 向左上射击
}

func direcToVec(dir: int) -> Vector2:
	match dir:
		HexDirection.RIGHT:
			return Vector2(1, 0)
		HexDirection.LEFT:
			return Vector2(-1, 0)
		HexDirection.DOWN_RIGHT:
			return Vector2(0.5, 0.866).normalized()  # sqrt(3)/2 ≈ 0.866
		HexDirection.DOWN_LEFT:
			return Vector2(-0.5, 0.866).normalized()
		HexDirection.UP_RIGHT:
			return Vector2(0.5, -0.866).normalized()
		HexDirection.UP_LEFT:
			return Vector2(-0.5, -0.866).normalized()
		_:
			push_error("direcToVec 接收到的 dir 为", dir, ", 它不在 HexDirection 中")
			return Vector2(1, 0)

# 将方向枚举转换为可读字符串
func direction_to_string(direction: int) -> String:
	match direction:
		Globals.HexDirection.RIGHT:
			return "RIGHT"
		Globals.HexDirection.LEFT:
			return "LEFT"
		Globals.HexDirection.DOWN_RIGHT:
			return "DOWN_RIGHT"
		Globals.HexDirection.DOWN_LEFT:
			return "DOWN_LEFT"
		Globals.HexDirection.UP_RIGHT:
			return "UP_RIGHT"
		Globals.HexDirection.UP_LEFT:
			return "UP_LEFT"
		_:
			return "UNKNOWN"

# pos -> scene
var pos_to_module: Dictionary = {}

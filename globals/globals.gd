extends Node

enum Team {Friend, Enemy, Neutral}
enum MachineType {Core, Part, Undefined}
enum HexDirection {
	RIGHT = 0,    # 向右射击
	LEFT = 1,     # 向左射击
	DOWN_RIGHT = 2,    # 向右下射击
	DOWN_LEFT = 3,     # 向左下射击
	UP_RIGHT = 4,      # 向右上射击
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

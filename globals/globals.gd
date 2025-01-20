extends Node

enum Team {Friend, Enemy, Neutral}
enum MachineType {Core, Part, Undefined}
enum HexDirection {
	RIGHT = 0,    # 向右射击（从左边来）
	LEFT = 1,     # 向左射击（从右边来）
	DOWN_RIGHT = 2,    # 向右下射击（从左上来）
	DOWN_LEFT = 3,     # 向左下射击（从右上来）
	UP_RIGHT = 4,      # 向右上射击（从左下来）
	UP_LEFT = 5,       # 向左上射击（从右下来）
}

# pos -> scene
var pos_to_module: Dictionary = {}

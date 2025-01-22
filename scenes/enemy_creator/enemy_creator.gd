class_name EnemyCreator
extends Node2D

# 在地图上放置一个新的节点（core或part）
# Parameters:
#   scene_path: PackedScene - 要实例化的场景
#   pos: Vector2i - 放置的网格坐标
#   core_team: Team - 如果放置的是core，指定其阵营（Friend或Enemy）
#   prioritize_friend: bool - 当放置part同时与友方和敌方阵营分量相邻时，是否优先加入友方分量（默认true）
signal successfully_put(scene_path: PackedScene, pos: Vector2i, core_team, prioritize_friend: bool)

## 生成一个合适的敌人来占满 positions 
func create_enemy(positions: Array[Vector2i]):
	if positions.is_empty() or Globals.all_possible_part_paths.is_empty():
		return
		
	# 计算所有位置的中点
	var sum_x = 0
	var sum_y = 0
	for pos in positions:
		sum_x += pos.x
		sum_y += pos.y
	
	var mid_pos = Vector2i(
		round(float(sum_x) / positions.size()),
		round(float(sum_y) / positions.size())
	)
	
	# 在中点位置放置core
	successfully_put.emit(Globals.enemy_core_path, mid_pos, Globals.Team.Enemy, false)
	
	# 在其他位置随机放置部件
	for pos in positions:
		if pos == mid_pos:
			continue
		var random_scene_path = Globals.all_possible_part_paths.pick_random()
		successfully_put.emit(random_scene_path, pos, Globals.Team.Enemy, false)

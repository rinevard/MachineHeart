extends Node2D
@onready var background_tile_map_layer: TileMapLayer = $BackgroundTileMapLayer
@onready var team_tile_map_layer = $TeamTileMapLayer
@onready var turn_handler = $ShopCanvasLayer/TurnHandler
@onready var shop: Shop = $ShopCanvasLayer/Shop
@onready var moving_camera: MovingCamera = $MovingCamera
@onready var chess_place_audio_stream_player: AudioStreamPlayer = $ChessPlaceAudioStreamPlayer
@onready var mouse_handler: MouseHandler = $MouseHandler
@onready var enemy_creator: EnemyCreator = $EnemyCreator

const BLUE_CORE: PackedScene = preload("res://scenes/machine_elements/blue_core.tscn")
const GUN_PART: PackedScene = preload("res://scenes/machine_elements/gun_part.tscn")

# 以下皆为 tile_pos
# 连通分量列表，每个元素是[core/null, part1, part2, ...]
var components: Array = []
# 位置到分量索引的映射
var pos_to_component_idx: Dictionary = {}
# Globals.pos_to_module
var cur_turn: int = 0
var cur_activating_cnt: int = 0 # 对当前正在被激活的机械进行计数. 我们希望所有机械都被激活后才可以进入下一回合, 即该值为 0 时允许进入下一回合
var turn_able_to_end: bool = true

func _ready():
	turn_handler.turn_ended.connect(_on_turn_ended)
	mouse_handler.successfully_put.connect(_on_successfully_put)
	enemy_creator.successfully_put.connect(_on_successfully_put)
	mouse_handler.successfully_delete.connect(_on_successfully_delete)
	#------------test---------------
	_create_enemy(5)
	#------------test---------------
	# 初始化摄像头位置
	moving_camera.position = Vector2(2560, 1600)
	await get_tree().create_timer(0.4).timeout
	moving_camera.target_zoom = Vector2.ONE * moving_camera.min_zoom
	
	# 游戏开始时在中间放核心和枪给玩家
	_on_successfully_put(BLUE_CORE, Vector2i(20, 15), Globals.Team.Friend, true)
	await get_tree().create_timer(0.4).timeout
	_on_successfully_put(GUN_PART, Vector2i(21, 15), Globals.Team.Friend, true)

func _process(delta):
	if cur_activating_cnt == 0:
		turn_able_to_end = true
		turn_handler.show()
	else:
		turn_able_to_end = false
		turn_handler.hide()

func _on_turn_ended():
	if not turn_able_to_end:
		return
	#------------test---------------
	cur_turn += 1
	if (cur_turn > 2):
		_create_enemy(randi_range(4, 10))
		cur_turn = 0
	#------------test---------------
	shop.refresh()
	for component in components:
		activate_nodes(component)

# 根据两个位置的相对关系确定方向
# 返回 Globals.HexDirection 中的一个值
func _get_direction(from_pos: Vector2i, to_pos: Vector2i) -> int:
	var diff = to_pos - from_pos
	
	if diff == Vector2i(1, 0):
		return Globals.HexDirection.RIGHT
	elif diff == Vector2i(-1, 0):
		return Globals.HexDirection.LEFT
		
	if from_pos.y % 2 == 0:  # 起点y为偶数
		match diff:
			Vector2i(0, -1):
				return Globals.HexDirection.UP_RIGHT
			Vector2i(-1, -1):
				return Globals.HexDirection.UP_LEFT
			Vector2i(0, 1):
				return Globals.HexDirection.DOWN_RIGHT
			Vector2i(-1, 1):
				return Globals.HexDirection.DOWN_LEFT
	else:  # 起点y为奇数
		match diff:
			Vector2i(1, -1):
				return Globals.HexDirection.UP_RIGHT
			Vector2i(0, -1):
				return Globals.HexDirection.UP_LEFT
			Vector2i(1, 1):
				return Globals.HexDirection.DOWN_RIGHT
			Vector2i(0, 1):
				return Globals.HexDirection.DOWN_LEFT
				
	push_error("无效的方向！")
	return -1

# 计算组件中各个部分的激活顺序和能量传递
func activate_nodes(component: Array) -> void:
	if component.is_empty() or component[0] == null:
		return
	
	cur_activating_cnt += 1
	var core_pos = component[0]
	# activate_parts_in_layer_order 里分为由核心到外边的若干个layer
	# 每个layer是一个列表, 
	# layer 里每个元素形如 {pos: [scene, [[energy1, dir1], [energy2, dir2], ...]}
	var activate_parts_in_layer_order = []
	var visited = {core_pos: true}
	var cur_layer = {core_pos: [[1.0, -1]]}  # core的方向标记为-1
	
	while not cur_layer.is_empty():
		var activate_parts = []
		var next_layer = {}
		var current_layer_info = {}
		
		for pos in component:
			if pos == null or pos == core_pos:
				continue
				
			var energies_with_directions = []
			for cur_pos in cur_layer:
				if is_adjacent(pos, cur_pos):
					var direction = _get_direction(cur_pos, pos)
					for energy_info in cur_layer[cur_pos]:
						energies_with_directions.append([energy_info[0], direction])
			
			if not energies_with_directions.is_empty():
				if pos in next_layer:
					next_layer[pos].append_array(energies_with_directions)
				elif not pos in visited:
					next_layer[pos] = energies_with_directions
					visited[pos] = true
		
		if not next_layer.is_empty():
			var layer_info = {}
			for pos in next_layer:
				if pos != core_pos:
					layer_info[pos] = [
						Globals.pos_to_module[pos],
						next_layer[pos]
					]
			if not layer_info.is_empty():
				activate_parts.append(layer_info)

		# 在更新cur_layer之前合并每个位置的能量
		var merged_next_layer = {}
		for pos in next_layer:
			var total_energy = 0.0
			for energy_info in next_layer[pos]:
				total_energy += energy_info[0]
			# 只保留一个合并后的能量值，方向使用第一个能量的方向
			merged_next_layer[pos] = [[total_energy, next_layer[pos][0][1]]]
		cur_layer = merged_next_layer
		activate_parts_in_layer_order.append(activate_parts)

	# 按顺序激活零件
	for activate_parts in activate_parts_in_layer_order:
		for i in range(activate_parts.size()):
			for pos in activate_parts[i]:
				var scene = activate_parts[i][pos][0]
				var energies_dirs = activate_parts[i][pos][1]
				activate_helper(scene, energies_dirs)
		await get_tree().create_timer(0.5).timeout
	cur_activating_cnt -= 1

# 实现同一位置多次激活时多次激活的中间间隔
func activate_helper(scene, energies_dirs):
	for energy_dir in energies_dirs:
		if scene != null and is_instance_valid(scene) and \
			scene.has_method("activate"):
			scene.activate(energy_dir[0], energy_dir[1])
			await get_tree().create_timer(0.1).timeout

# 判断pos处是否有module且是core
func _is_core(pos: Vector2i) -> bool:
	return Globals.pos_to_module.has(pos) and Globals.pos_to_module[pos].type == Globals.MachineType.Core

# 找出一个component中的所有连通块，返回形如[core/null, pos1, pos2...]的数组列表
# 对于有core的连通块，确保core位置在首位；对于无core的连通块，首位为null
func _find_connected_components_after_removal(component: Array, removed_pos: Vector2i) -> Array:
	var visited = {}
	var result = []
	var core_idx = -1  # 记录带core的连通块的索引
	
	# 对component中每个位置，如果未访问过就开始BFS
	for pos in component:
		if pos == removed_pos or visited.has(pos) or pos == null:
			continue
		
		var current_block = []
		var queue = [pos]
		var core_pos = null
		
		while not queue.is_empty():
			var current = queue.pop_front()
			if visited.has(current):
				continue
			
			visited[current] = true
			if _is_core(current):
				core_pos = current
			else:
				current_block.append(current)
			
			# 检查相邻位置
			for neighbor in get_neighbors(current):
				if neighbor == removed_pos:
					continue
				if component.has(neighbor) and not visited.has(neighbor):
					queue.append(neighbor)
		
		# 根据是否有core构造结果
		if core_pos != null:
			core_idx = result.size()
			result.append([core_pos] + current_block)
		else:
			result.append([null] + current_block)
	
	# 如果有带core的连通块，把它移到第一位
	if core_idx > 0:
		var temp = result[0]
		result[0] = result[core_idx]
		result[core_idx] = temp
	
	return result

# 获取与给定component相邻的所有component的索引
func _get_adjacent_component_indices(component: Array) -> Array:
	var adjacent_indices = {}
	
	for pos in component:
		if pos == null:
			continue
		for neighbor in get_neighbors(pos):
			if pos_to_component_idx.has(neighbor):
				var idx = pos_to_component_idx[neighbor]
				if not components[idx].is_empty() and idx != components.find(component):
					adjacent_indices[idx] = true
	
	return adjacent_indices.keys()

# 获取一个component的team，如果有core返回core的team，否则返回Neutral
func _get_component_team(component: Array) -> int:
	if component.is_empty() or component[0] == null:
		return Globals.Team.Neutral
	return Globals.pos_to_module[component[0]].team

# 将src_component合并到dst_component中，并更新所有相关信息
func _merge_components(dst_idx: int, src_idx: int) -> void:
	var dst_component = components[dst_idx]
	var src_component = components[src_idx]
	
	if src_component.is_empty():
		return
		
	# 更新team
	var team = _get_component_team(dst_component)
	for pos in src_component:
		if pos != null:  # 跳过可能的null（表示无core的标记）
			dst_component.append(pos)
			pos_to_component_idx[pos] = dst_idx
			if Globals.pos_to_module.has(pos):
				Globals.pos_to_module[pos].team = team
	
	components[src_idx] = []

# 放置新的节点（core或part）到指定位置
# params: scene_path - 要实例化的场景
#         pos - 放置位置
#         core_team - 如果是core，指定其队伍
#         prioritize_friend - 合并时是否优先合并到友方
func _on_successfully_put(scene_path: PackedScene, pos: Vector2i, core_team, prioritize_friend: bool) -> void:
	# 实例化并放置
	var rel_pos = background_tile_map_layer.map_to_local(pos)
	var something: Node2D = scene_path.instantiate()
	add_child(something)
		
	if something.get("type") == null or something.get("team") == null:
		push_error("放置了一个没有type或team属性的东西")
		return
	assert(something.has_method("init_module"), "放置了一个没有 init_module 的东西: " + something.name)
	assert(something.has_signal("died"), "放置了一个没有 died 信号的东西: " + something.name)
	Globals.pos_to_module[pos] = something
	something.init_module(pos)
	something.died.connect(_on_successfully_delete)
	chess_place_audio_stream_player.play()
	
	# 从天上落下的棋子
	var origin_layer = something.collision_layer
	var origin_mask = something.collision_mask
	something.set_collision_layer_value(1, false)
	something.set_collision_layer_value(2, false)
	something.set_collision_layer_value(3, false)
	something.set_collision_layer_value(4, true)
	something.set_collision_mask_value(1, false)
	something.set_collision_mask_value(2, false)
	something.set_collision_mask_value(3, false)
	var tween = create_tween()
	var target_global_pos = background_tile_map_layer.to_global(rel_pos)
	something.global_position = target_global_pos + Vector2(0, -4096)
	tween.tween_property(something, "global_position", target_global_pos, 0.44).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	await tween.finished
	if something != null and is_instance_valid(something):
		something.set("team", something.team)

	match something.type:
		Globals.MachineType.Core:
			something.team = core_team
			components.append([pos])
			pos_to_component_idx[pos] = components.size() - 1
			_merge_component(components.size() - 1, prioritize_friend)

		Globals.MachineType.Part:
			components.append([null, pos])
			pos_to_component_idx[pos] = components.size() - 1
			_merge_component(components.size() - 1, prioritize_friend)
	_update_info_after_components_changed()

# 删除指定位置的节点
func _on_successfully_delete(pos: Vector2i, prioritize_friend: bool) -> void:
	if not Globals.pos_to_module.has(pos):
		push_error("successfully delete信号发出, 但", pos, "处没有物件！")
	var original_idx = pos_to_component_idx[pos]
	var original_component = components[original_idx]
	var was_core = _is_core(pos)
	var removed_scene: Node2D = Globals.pos_to_module[pos]
	removed_scene.visible = false
	removed_scene.call_deferred("queue_free")
	
	# 从映射中移除
	pos_to_component_idx.erase(pos)
	Globals.pos_to_module.erase(pos)
	
	# 找出删除后的连通块
	var new_components = _find_connected_components_after_removal(original_component, pos)
	
	# 如果只有一个连通块且不是core被删除，直接用这个连通块替换原来的
	if new_components.size() <= 1 and not was_core:
		if new_components.is_empty():
			components[original_idx] = []
		else:
			components[original_idx] = new_components[0]
		_update_info_after_components_changed()
		return
	
	# 将原分量标记为空
	components[original_idx] = []
	
	# 添加新的连通块并尝试合并
	for component in new_components:
		components.append(component)
		var rep_pos = component[1] if component[0] == null else component[0]  # 用第一个非null位置作为代表
		pos_to_component_idx[rep_pos] = components.size() - 1
		_merge_component(components.size() - 1, prioritize_friend)
	_update_info_after_components_changed()

# 尝试将指定索引的分量与其他分量合并
# params: component_idx - 要合并的分量索引
#         prioritize_friend - 是否优先合并到友方
func _merge_component(component_idx: int, prioritize_friend: bool) -> void:
	if components[component_idx].is_empty():
		return
		
	var current_component = components[component_idx]
	var adjacent_indices = _get_adjacent_component_indices(current_component)
	
	if current_component[0] != null:  # 有core的分量
		# 只合并相邻的中立分量
		for adj_idx in adjacent_indices:
			var adj_component = components[adj_idx]
			if adj_component[0] == null:  # 中立分量
				_merge_components(component_idx, adj_idx)
	else:  # 无core的分量
		# 先合并所有相邻的中立分量
		for adj_idx in adjacent_indices.duplicate():  # duplicate避免在迭代时修改数组
			var adj_component = components[adj_idx]
			if adj_component[0] == null:
				_merge_components(component_idx, adj_idx)
				adjacent_indices = _get_adjacent_component_indices(components[component_idx])
		
		# 然后尝试合并到非中立分量
		var friend_idx = -1
		var enemy_idx = -1
		
		for adj_idx in adjacent_indices:
			var adj_component = components[adj_idx]
			if adj_component[0] != null:  # 非中立分量
				var team = _get_component_team(adj_component)
				if team == Globals.Team.Friend:
					friend_idx = adj_idx
				else:
					enemy_idx = adj_idx
		
		# 根据优先级决定合并顺序
		var primary_idx = friend_idx if prioritize_friend else enemy_idx
		var secondary_idx = enemy_idx if prioritize_friend else friend_idx
		
		if primary_idx != -1:
			_merge_components(primary_idx, component_idx)
		elif secondary_idx != -1:
			_merge_components(secondary_idx, component_idx)
	
	_update_info_after_components_changed()

# 清理空分量并更新位置到分量的映射
func _update_info_after_components_changed() -> void:
	# 清理空分量
	var i = 0
	while i < components.size():
		if components[i].is_empty():
			components.remove_at(i)
		else:
			i += 1
	
	# 更新映射
	pos_to_component_idx.clear()
	for j in components.size():
		for pos in components[j]:
			if pos != null:  # 跳过可能的null（表示无core的标记）
				pos_to_component_idx[pos] = j
	
	# 更新零件阵营
	for component in components:
		var core_team = Globals.Team.Neutral if component[0] == null else Globals.pos_to_module[component[0]].team
		for j in range(1, component.size()):
			Globals.pos_to_module[component[j]].team = core_team
	_update_team_tilemap()

## 根据阵营更新 tilemap 的背景显示
func _update_team_tilemap():
	team_tile_map_layer.clear()
	for component in components:
		if component[0] == null:
			for i in range(1, component.size()):
				var pos = component[i]
				team_tile_map_layer.set_cell(pos, 1, Vector2i(3, 9)) # 中立
		else:
			assert(Globals.pos_to_module.has(component[0]), str(component[0]) + "不在globals的记录里")
			match Globals.pos_to_module[component[0]].team:
				Globals.Team.Friend:
					for pos in component:
						team_tile_map_layer.set_cell(pos, 1, Vector2i(4, 2)) # 友方
				Globals.Team.Enemy:
					for pos in component:
						team_tile_map_layer.set_cell(pos, 1, Vector2i(4, 0)) # 敌方
				_:
					push_error(Globals.pos_to_module[component[0]], "的 team 不在 globals 里")	

func _create_enemy(enemy_size: int) -> void:
	# 初始化所有可能的位置
	var all_possible_positions: Array[Vector2i] = []
	for x in range(Globals.map_size_x):
		for y in range(Globals.map_size_y):
			var pos = Vector2i(x, y)
			if not Globals.pos_to_module.has(pos):
				all_possible_positions.append(pos)
	
	# 如果没有可用位置，直接返回
	if all_possible_positions.is_empty():
		return
	
	# 选择起始点
	var start_pos: Vector2i = all_possible_positions.pick_random()
	
	# BFS探测可用空间
	var available_count: int = 0
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [start_pos]
	visited[start_pos] = true
	
	while queue.size() > 0:
		var current: Vector2i = queue.pop_front()
		available_count += 1
		
		for next_pos in get_neighbors(current):
			if (next_pos.x >= 0 and next_pos.x < Globals.map_size_x and 
				next_pos.y >= 0 and next_pos.y < Globals.map_size_y and 
				not Globals.pos_to_module.has(next_pos) and
				not visited.has(next_pos)):
					queue.push_back(next_pos)
					visited[next_pos] = true
	
	# 取可用空间和目标数量的较小值
	var target_size: int = mini(enemy_size, available_count)
	
	# 开始生成实际位置
	var positions: Array[Vector2i] = [start_pos]
	var current_pos: Vector2i = start_pos
	
	while positions.size() < target_size:
		var neighbors: Array = get_neighbors(current_pos)
		var valid_neighbors: Array[Vector2i] = []
		
		for n in neighbors:
			if (n.x >= 0 and n.x < Globals.map_size_x and 
				n.y >= 0 and n.y < Globals.map_size_y and 
				not Globals.pos_to_module.has(n) and
				not positions.has(n)):
					valid_neighbors.append(n)
		
		if valid_neighbors.size() > 0:
			var weighted_neighbors: Array = []
			for n in valid_neighbors:
				var neighbor_count: int = 0
				for nn in get_neighbors(n):
					if positions.has(nn):
						neighbor_count += 1
				weighted_neighbors.append({
					"pos": n,
					"weight": 1 + neighbor_count * 2
				})
			
			var total_weight: int = 0
			for n in weighted_neighbors:
				total_weight += n.weight
			
			var random_weight: int = randi() % total_weight
			var chosen_pos: Vector2i
			
			for n in weighted_neighbors:
				random_weight -= n.weight
				if random_weight < 0:
					chosen_pos = n.pos
					break
			
			if not chosen_pos:
				chosen_pos = weighted_neighbors[-1].pos
			
			positions.append(chosen_pos)
			current_pos = chosen_pos
		else:
			current_pos = positions[randi() % positions.size()]
	
	enemy_creator.create_enemy(positions)

func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var x: int = pos.x
	var y: int = pos.y
	
	if y % 2 == 0:  # y为偶数
		return [
			Vector2i(x-1, y-1),
			Vector2i(x, y-1),
			Vector2i(x-1, y),
			Vector2i(x+1, y),
			Vector2i(x-1, y+1),
			Vector2i(x, y+1)
		]
	else:  # y为奇数
		return [
			Vector2i(x, y-1),
			Vector2i(x+1, y-1),
			Vector2i(x-1, y),
			Vector2i(x+1, y), 
			Vector2i(x, y+1),
			Vector2i(x+1, y+1)
		]

func is_adjacent(pos1: Vector2i, pos2: Vector2i) -> bool:
	var neighbors = get_neighbors(pos1)
	
	for neighbor in neighbors:
		if neighbor == pos2:
			return true
	
	return false

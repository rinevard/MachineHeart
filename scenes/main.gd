extends Node2D
@onready var background_tile_map_layer: TileMapLayer = $BackgroundTileMapLayer
@onready var turn_handler: TurnHandler = $TurnHandler
@onready var mouse_put_handler: MousePutHandler = $MousePutHandler
# 以下皆为 tile_pos
# 连通分量列表，每个元素是[core/null, part1, part2, ...]
var components: Array = []
# 位置到分量索引的映射
var pos_to_component_idx: Dictionary = {}
# Globals.pos_to_module
# core_pos -> [module_pos_1, module_pos_2, ...]
var core_to_machines: Dictionary = {}

func _ready():
	turn_handler.turn_ended.connect(_on_turn_ended)
	mouse_put_handler.successfully_put.connect(_on_successfully_put)

func _on_turn_ended():
	activate_nodes()

func activate_nodes():
	return
	# 应当包含若干个列表, 
	# activate_parts[k] 表示第 k + 1 轮被同时激活的节点
	var activate_parts: Array = []
	
	# 用 BFS 更新 activate_parts
	for core_pos in core_to_machines:
		var machine: Array = core_to_machines[core_pos]
		
		var visited: Dictionary = {}
		var cur_layer: Dictionary = {core_pos: [1]} # 初始能量为1
		visited[core_pos] = true
		
		while not cur_layer.is_empty():
			var next_layer: Dictionary = {}
			
			# 遍历当前层的所有节点
			for pos in cur_layer:
				var energies: Array = cur_layer[pos]
				var energy_sum: int = 0
				for e in energies:
					energy_sum += e
					
				# 遍历machine中的所有部件，寻找相邻节点
				for module_pos in machine:
					if is_adjacent(pos, module_pos):
						if module_pos in next_layer:
							next_layer[module_pos].append(energy_sum)
						elif module_pos in visited:
							continue
						else:
							next_layer[module_pos] = [energy_sum]
							visited[module_pos] = true
			
			# 更新activate_parts
			if not cur_layer.is_empty():
				var layer_dict: Dictionary = {}
				for pos in cur_layer:
					if pos in Globals.pos_to_module:
						layer_dict[pos] = [Globals.pos_to_module[pos], cur_layer[pos]]
				if not layer_dict.is_empty():
					activate_parts.append(layer_dict)
			
			cur_layer = next_layer
		
		print(activate_parts)



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
func _on_successfully_put(scene_path: PackedScene, pos: Vector2i, core_team, prioritize_friend: bool = true) -> void:
	# 实例化并放置
	var rel_pos = background_tile_map_layer.map_to_local(pos)
	var something: Node2D = scene_path.instantiate()
	add_child(something)
	something.global_position = background_tile_map_layer.to_global(rel_pos)
	
	if something.get("type") == null or something.get("team") == null:
		push_error("放置了一个没有type或team属性的东西")
		return
	
	Globals.pos_to_module[pos] = something
	
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

# 删除指定位置的节点
func _on_successfully_delete(pos: Vector2i, prioritize_friend: bool = true) -> void:
	var original_idx = pos_to_component_idx[pos]
	var original_component = components[original_idx]
	var was_core = _is_core(pos)
	
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
	print("components: \n", components, "\n")



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

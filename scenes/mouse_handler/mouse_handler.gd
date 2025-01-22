class_name MouseHandler
extends Node2D

# 在地图上放置一个新的节点（core或part）
# Parameters:
#   scene_path: PackedScene - 要实例化的场景
#   pos: Vector2i - 放置的网格坐标
#   core_team: Team - 如果放置的是core，指定其阵营（Friend或Enemy）
#   prioritize_friend: bool - 当放置part同时与友方和敌方阵营分量相邻时，是否优先加入友方分量（默认true）
signal successfully_put(scene_path: PackedScene, pos: Vector2i, core_team, prioritize_friend: bool)
signal successfully_delete(pos: Vector2i, prioritize_friend: bool)

@onready var highlight_tile_map_layer: TileMapLayer = $HighlightTileMapLayer
var cursor_tile: Vector2i = Vector2i(-99, -99)
var selected_item: PackedScene = null

func _process(_delta):
	# 悬停高亮
	cursor_tile = get_mouse_tilepos()
	if selected_item != null:
		update_highlight_tile()

func _unhandled_input(event):
	# 左键放置物品
	if Globals.is_picking and ((selected_item != null) and event.is_action_pressed("left_click")) and \
	not Globals.pos_to_module.has(cursor_tile):
		place_obj_mousepos(selected_item)
		selected_item = null
		update_highlight_tile()
		Globals.is_picking = false
	# 右键卖出
	if event.is_action_pressed("right_click") and \
	Globals.pos_to_module.has(cursor_tile):
		sell_obj_mousepos()

func update_highlight_tile() -> void:
	highlight_tile_map_layer.clear()
	# 如果有选中的物件才悬停高亮, 否则无高亮
	if selected_item != null and not Globals.pos_to_module.has(cursor_tile):
		highlight_tile_map_layer.set_cell(cursor_tile, 1, Vector2i(1, 1))
	return

func place_obj_mousepos(scene_path: PackedScene):
	var mouse_tile_pos: Vector2i = get_mouse_tilepos()
	# 手动放置的队伍为友方
	successfully_put.emit(scene_path, mouse_tile_pos, Globals.Team.Friend, true)

func sell_obj_mousepos():
	var mouse_tile_pos: Vector2i = get_mouse_tilepos()
	if not Globals.pos_to_module.has(mouse_tile_pos):
		return
	var module: Node2D = Globals.pos_to_module[mouse_tile_pos]
	assert(module.get("team") != null, "module 没有阵营!")
	assert(module.get("type") != null, "module 没有 machine_type!")
	assert(module.get("sold") != null, "module 没有 卖出价格!")
	# 只能删除友方零件, 不能删除核心或是别的阵营的东西
	if module.team != Globals.Team.Friend or module.type == Globals.MachineType.Core:
		return
	# 删除以后优先和友方合并
	Globals.money += module.sold
	successfully_delete.emit(mouse_tile_pos, true)

func get_mouse_tilepos() -> Vector2i:
	var mouse_global_pos = get_global_mouse_position()
	var mouse_local_pos_for_tilemap = highlight_tile_map_layer.to_local(mouse_global_pos)
	return highlight_tile_map_layer.local_to_map(mouse_local_pos_for_tilemap)


func _on_shop_item_bought(item: PackedScene):
	Globals.is_picking = true
	selected_item = item

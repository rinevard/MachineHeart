extends Node2D

signal board_updated()
@onready var highlight_tile_map_layer: TileMapLayer = $HighlightTileMapLayer
var cursor_tile: Vector2i = Vector2i(-99, -99)
var selected_item: PackedScene = null
var item_on_board: Dictionary = {} # 用 dict 模拟集合, 设置所有 value 为 true

const BLUE_GODOT: PackedScene = preload("res://scenes/tmp/blue_godot.tscn")
const PURPLE_GODOT: PackedScene = preload("res://scenes/tmp/purple_godot.tscn")

func _process(_delta):
	# 悬停高亮
	if selected_item:
		cursor_tile = get_mouse_tilepos()
		update_highlight_tile()

func _unhandled_input(event):	
	# 按键选择放置的物品
	# 暂时以 q 为紫色, w 为蓝色
	if event.is_action_pressed("q"):
		selected_item = PURPLE_GODOT
	elif event.is_action_pressed("w"):
		selected_item = BLUE_GODOT

	# 左键放置物品
	if ((selected_item!= null) and event.is_action_pressed("left_click")) and \
	not item_on_board.has(cursor_tile):
		place_obj_mousepos(selected_item)
		selected_item = null
		update_highlight_tile()
		board_updated.emit()

func update_highlight_tile() -> void:
	highlight_tile_map_layer.clear()
	# 如果有选中的物件才悬停高亮, 否则无高亮
	if selected_item:
		highlight_tile_map_layer.set_cell(cursor_tile, 1, Vector2i(1, 1))
	return

func place_obj_mousepos(scene_path: PackedScene):
	var something: Node2D = scene_path.instantiate()
	add_child(something)
	var mouse_tile_pos: Vector2i = get_mouse_tilepos()
	# tile_local_pos 是对应的 tile 的中心位置, 所以要放置的东西最好要在原场景里 centered
	var tile_local_pos: Vector2 = highlight_tile_map_layer.map_to_local(mouse_tile_pos)
	something.global_position = highlight_tile_map_layer.to_global(tile_local_pos)
	item_on_board[cursor_tile] = true

func get_mouse_tilepos() -> Vector2i:
	var mouse_global_pos = get_global_mouse_position()
	var mouse_local_pos_for_tilemap = highlight_tile_map_layer.to_local(mouse_global_pos)
	return highlight_tile_map_layer.local_to_map(mouse_local_pos_for_tilemap)

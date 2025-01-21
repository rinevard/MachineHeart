class_name ShopItemButton
extends Button

var cur_packed_item: PackedScene
@onready var area_2d_wrapper: Control = $CenterContainer/Area2DWrapper

signal item_bought(item: String)

func _ready():
	pressed.connect(buy)
	refresh()

## 在 globals 的 item 列表里随机选一个作为新 cur_item
func refresh():
	# TODO
	# 随机选一个的代码逻辑
	var random_item = Globals.all_possible_item_paths.pick_random()
	cur_packed_item = random_item
	_update_display()

func buy():
	# 如果栏为空或者已经抓着东西，不能买
	if cur_packed_item == null or Globals.is_picking:
		return
	item_bought.emit(cur_packed_item)
	cur_packed_item = null
	_update_display()

func _update_display():
	# 移除原本的显示
	var children = area_2d_wrapper.get_children()
	for child in children:
		child.call_deferred("queue_free")
	
	if cur_packed_item == null:
		return
	# 更新显示
	var new_item = cur_packed_item.instantiate()
	area_2d_wrapper.add_child(new_item)

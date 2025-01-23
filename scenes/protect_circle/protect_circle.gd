class_name ProtectCircle
extends Area2D

var modules_in_shield = [] # 记录在防护罩范围内的所有节点
var team = Globals.Team.Neutral
var shield_count: int = 0

func _ready():
	init_protect_circle(team)

func init_protect_circle(new_team):
	update_team(new_team)

func update_team(new_team):
	team = new_team
	remove_protection()
	if shield_count > 0:
		protect_team_in_shield()
	else:
		disable_shield_and_clear_protection()

# 当防护罩被攻击时
func hurt(amount: int):
	shield_count -= 1
	# 盾碎时
	if shield_count <= 0:
		break_shield()

func activate_shield():
	shield_count += 1
	if shield_count == 1: # 从无盾到有盾的转换
		enable_shield_and_protect_team()

func break_shield():
	shield_count = 0
	disable_shield_and_clear_protection()

func remove_protection():
	_remove_invalid_module()
	for module in modules_in_shield:
		if is_instance_valid(module):
			module.remove_protection(self)

func protect_team_in_shield():
	_remove_invalid_module()
	for module in modules_in_shield:
		if is_instance_valid(module) and module.team == team:
			module.add_protection(self)

func disable_shield_and_clear_protection():
	hide()
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, false)
	remove_protection()

func enable_shield_and_protect_team():
	show()
	_update_collision_layer()
	protect_team_in_shield()

func _update_collision_layer() -> void:
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, false)
	match team:
		Globals.Team.Friend:
			set_collision_layer_value(1, true)
		Globals.Team.Enemy:
			set_collision_layer_value(2, true)
		Globals.Team.Neutral:
			set_collision_layer_value(3, true)
		_:
			push_error("无效的队伍类型")

# 当模块进入保护范围
func _on_detect_area_area_entered(area: Area2D):
	print("area entered shield!")

	if not area.has_method("init_module"):
		return
	_remove_invalid_module()
	modules_in_shield.append(area)
	if is_instance_valid(area) and area.team == team:
		area.add_protection(self)
	print(modules_in_shield)

# 当模块离开保护范围
func _on_detect_area_area_exited(area: Area2D):
	if not area.has_method("init_module"):
		return
	_remove_invalid_module()
	modules_in_shield.erase(area)
	area.remove_protection(self)
	print("area exit shield!")
	print(modules_in_shield)

# 当防护罩被移除时（比如被售出）
func _exit_tree():
	disable_shield_and_clear_protection()

func _remove_invalid_module():
	var idxs_need_remove = []
	for i in range(modules_in_shield.size()):
		var module = modules_in_shield[i]
		if module == null or not is_instance_valid(module):
			idxs_need_remove.append(i)
	idxs_need_remove.reverse()
	for idx in idxs_need_remove:
		modules_in_shield.pop_at(idx)

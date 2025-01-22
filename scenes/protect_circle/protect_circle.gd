class_name ProtectCircle
extends Area2D

## 保护伞的剩余防护次数
var protect_count: int = 1:
	set(value):
		protect_count = value
		if protect_count > 3:
			protect_count = 3
		if protect_count < 0:
			protect_count = -1
			_disable_protection()
		else:
			_enable_protection()

## 当前在保护圈内的友方模块
var protected_modules: Dictionary = {}

var team = Globals.Team.Neutral

func init_protect_circle(new_team):
	update_team(new_team)
	
func update_team(new_team):
	team = new_team
	# 更新碰撞层
	_update_collision_layer()
	# 重新检查所有被保护的模块
	_update_protected_status()

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

# 当防护罩被攻击时
func hurt(amount: int):
	protect_count -= 1

# 启用保护
func _enable_protection():
	show()
	_update_collision_layer()
	_update_protected_status()

# 禁用保护
func _disable_protection():
	hide()
	# 清除所有碰撞层
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, false)
	# 移除所有保护
	for module in protected_modules.values():
		if is_instance_valid(module):
			module.remove_protection(self)

# 当模块进入保护范围
func _on_detect_area_area_entered(area: Area2D):
	if not area.has_method("init_module"):
		return
		
	var module_id = area.get_instance_id()
	protected_modules[module_id] = area
	_update_module_protection(area)

# 当模块离开保护范围
func _on_detect_area_area_exited(area: Area2D):
	if not area.has_method("init_module"):
		return
		
	var module_id = area.get_instance_id()
	if protected_modules.has(module_id):
		protected_modules.erase(module_id)
		# 移除保护效果
		area.remove_protection(self)

# 更新所有被保护模块的状态
func _update_protected_status():
	var modules_to_remove = []
	
	for module_id in protected_modules:
		var module = protected_modules[module_id]
		if is_instance_valid(module):
			_update_module_protection(module)
		else:
			modules_to_remove.append(module_id)
	
	# 清理无效的模块引用
	for module_id in modules_to_remove:
		protected_modules.erase(module_id)

# 更新单个模块的保护状态
func _update_module_protection(module):
	if protect_count <= 0:
		module.remove_protection(self)
	elif module.team == team:
		module.add_protection(self)
	else:
		module.remove_protection(self)

# 当防护罩被移除时（比如被售出）
func _exit_tree():
	# 移除所有模块的保护效果
	for module in protected_modules.values():
		if is_instance_valid(module):
			module.remove_protection(self)

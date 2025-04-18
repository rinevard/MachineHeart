extends MachinePart

@onready var protect_circle: ProtectCircle = $ProtectCircle

func init_module(pos: Vector2i) -> void:
	tile_pos = pos
	protect_circle.init_protect_circle(team)

func activate(energy: int, energy_dir: int):
	super.activate(energy, energy_dir)
	for i in range(energy):
		protect_circle.activate_shield()

func _update_collision_layer() -> void:
	# 首先清除所有相关层
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, false)
	
	# 根据队伍设置对应层
	match team:
		Globals.Team.Friend:
			set_collision_layer_value(1, true)
		Globals.Team.Enemy:
			set_collision_layer_value(2, true)
		Globals.Team.Neutral:
			set_collision_layer_value(3, true)
	protect_circle.update_team(team)

func set_module_label():
	effec = "接收到能量时，生成能抵抗一次伤害的防护罩保护相邻零件，生成x次。防护罩最多叠加3个。当前有" + str(protect_circle.shield_count) + "个"
	module_label.set_module_label(cost, sold, health, effec)

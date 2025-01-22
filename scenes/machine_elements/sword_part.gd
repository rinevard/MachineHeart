extends MachinePart

const SWORD_ARC = preload("res://scenes/sword_arc/sword_arc.tscn")

func activate(energy: int, energy_dir: int):
	super.activate(energy, energy_dir)
	# 测试用的子弹射击
	var sword_arc: SwordArc = SWORD_ARC.instantiate()
	sword_arc.init_sword_arc(energy, Globals.direcToVec(energy_dir), team)
	add_child(sword_arc)

extends MachinePart

const BULLET = preload("res://scenes/bullet/bullet.tscn")

func activate(energy: int, energy_dir: int):
	super.activate(energy, energy_dir)
	# 测试用的子弹射击
	var new_bullet: Bullet = BULLET.instantiate()
	new_bullet.init_bullet(energy, Globals.direcToVec(energy_dir), team)
	add_child(new_bullet)

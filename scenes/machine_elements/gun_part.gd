extends MachinePart

var dir: Vector2 = Vector2(1, 0)
const BULLET = preload("res://scenes/bullet/bullet.tscn")

func activate():
	super.activate()
	# 测试用的子弹射击
	var new_bullet: Bullet = BULLET.instantiate()
	new_bullet.init_bullet(dir, team)
	add_child(new_bullet)

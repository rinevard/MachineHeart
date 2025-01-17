class_name Bullet
extends Area2D

var speed = 300
var direction = Vector2(1, 0)
var team = Globals.Team.Neutral

func _physics_process(delta):
	position += delta * speed * direction.normalized()

func init_bullet(dir: Vector2, new_team):
	direction = dir.normalized()
	rotation = dir.angle()
	update_team(new_team)

func update_team(new_team):
	team = new_team
	match team:
		Globals.Team.Friend:
			set_collision_mask_value(1, false)
			set_collision_mask_value(2, true)
			set_collision_mask_value(3, true)
		Globals.Team.Enemy:
			set_collision_mask_value(1, true)
			set_collision_mask_value(2, false)
			set_collision_mask_value(3, true)
		Globals.Team.Neutral:
			set_collision_mask_value(1, false)
			set_collision_mask_value(2, false)
			set_collision_mask_value(3, false)
		_:
			push_error("调用 init_bullet 时, team 不是任何 globals 里预定义的任何一类")	
	return

func _on_area_entered(area: Area2D):
	print("bullet hit ", area.name)
	queue_free()

class_name Bullet
extends Area2D

var energy: int = 1
var speed = 4400
var direction = Vector2(1, 0)
var team = Globals.Team.Neutral

func _physics_process(delta):
	position += delta * speed * direction.normalized()
	if global_position.x > 6000 or global_position.x < -1000 or global_position.y > 6000 or global_position.y < -1000:
		call_deferred("queue_free")

func init_bullet(new_energy: int, dir: Vector2, new_team):
	energy = new_energy
	direction = dir.normalized()
	rotation = dir.angle()
	update_team(new_team)

func update_team(new_team):
	team = new_team
	call_deferred("_update_collision_mask")
	return

func _update_collision_mask() -> void:
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

func _on_area_entered(area: Area2D):
	if area.has_method("hurt"):
		area.hurt(energy)
		call_deferred("queue_free")

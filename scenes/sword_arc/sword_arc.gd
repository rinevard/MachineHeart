class_name SwordArc
extends Area2D

var energy: int = 1
var direction = Vector2(1, 0)
var team = Globals.Team.Neutral

var rest_live_time: float = 0.2

func _process(delta):
	rest_live_time -= delta
	if rest_live_time <= 0:
		call_deferred("queue_free")

func init_sword_arc(new_energy: int, dir: Vector2, new_team):
	energy = new_energy
	direction = dir.normalized()
	rotation = dir.angle()
	update_team(new_team)

func update_team(new_team):
	team = new_team
	call_deferred("_update_collision_mask")
	if team == Globals.Team.Friend:
		modulate = Color.SKY_BLUE
		modulate.a = 0.7
	elif team == Globals.Team.Enemy:
		modulate = Color.FIREBRICK
		modulate.a = 0.7
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
		area.hurt(2 * energy)
	if area.has_method("hit_shake") and area.has_method("is_protected"):
		if not area.is_protected():
			area.hit_shake(direction)

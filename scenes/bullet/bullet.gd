class_name Bullet
extends Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var energy: int = 1
var speed = 4400
var direction = Vector2(1, 0)
var team = Globals.Team.Neutral

const BULLET_HURT_PARTICLE: PackedScene = preload("res://scenes/particles/bullet_hurt_particle.tscn")

func _physics_process(delta):
	position += delta * speed * direction.normalized()
	if global_position.x > 6000 or global_position.x < -1000 or global_position.y > 6000 or global_position.y < -1000:
		call_deferred("queue_free")

func init_bullet(new_energy: int, dir: Vector2, new_team):
	energy = new_energy
	direction = dir.normalized()
	rotation = dir.angle()
	call_deferred("update_team", new_team)

func update_team(new_team):
	team = new_team
	call_deferred("_update_collision_mask")
	if team == Globals.Team.Friend:
		modulate = Color.BLUE
	elif team == Globals.Team.Enemy:
		modulate = Color.DARK_RED
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
		
		# 创建打中时的粒子
		var bullet_particle: GPUParticles2D = BULLET_HURT_PARTICLE.instantiate()
		get_tree().root.add_child(bullet_particle)
		bullet_particle.global_position = global_position + direction * 60
		bullet_particle.rotation_degrees = rotation_degrees + 180
		bullet_particle.one_shot = true
		bullet_particle.emitting = true
		if area.has_method("init_module"):
			bullet_particle.process_material.color = Color.ORANGE
		else:
			bullet_particle.process_material.color = Color.SKY_BLUE
		if area.has_method("hit_shake") and area.has_method("is_protected"):
			if not area.is_protected():
				area.hit_shake(direction)

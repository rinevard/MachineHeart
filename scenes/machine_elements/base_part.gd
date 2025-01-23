class_name MachinePart
extends Area2D

const EXPLODE_PARTICLE = preload("res://scenes/particles/explode_particle.tscn")

signal died(tile_pos: Vector2i, prioritize_friend: bool)

var team = Globals.Team.Neutral:
	set(value):
		team = value
		call_deferred("_update_collision_layer")
var type = Globals.MachineType.Part
@export var cost: int = -1
@export var sold: int = -1
@export var default_health: int = -1
@export var default_armor: int = -1

var tile_pos: Vector2i = Vector2i.ZERO
var has_died: bool = false
var health: int
var armor: int
var active_protections: Array[ProtectCircle] = []

func _ready():
	health = default_health
	armor = default_armor

func init_module(pos: Vector2i) -> void:
	tile_pos = pos

func add_protection(protector: ProtectCircle):
	if not active_protections.has(protector):
		active_protections.append(protector)

func remove_protection(protector: ProtectCircle):
	active_protections.erase(protector)

# 判断是否处于保护状态
func is_protected() -> bool:
	# 清理已失效的保护者
	active_protections = active_protections.filter(func(p): return is_instance_valid(p))
	return active_protections.size() > 0

func hurt(amount: int):
	# 如果 protector 非空, 说明正在被保护, 不受伤害
	if is_protected():
		return
	if armor > 0:
		armor -= amount
	else:
		health -= amount
		
	# 添加摇晃效果
	var sprite = $Sprite2D
	var tween = create_tween()
	# 连续执行2次小幅度的来回摇晃
	for i in range(2):
		# 向左旋转
		tween.tween_property(sprite, "rotation_degrees", -5.0, 0.05)
		# 向右旋转
		tween.tween_property(sprite, "rotation_degrees", 5.0, 0.05)
	# 最后回到原始位置
	tween.tween_property(sprite, "rotation_degrees", 0.0, 0.05)
	await tween.finished
	if health <= 0 and not has_died:
		die()

func die():
	has_died = true
	# 如果是敌方, 则定然是被友方打死的, 因此优先连友方
	var prioritize_friend: bool = true if team == Globals.Team.Enemy else false
	died.emit(tile_pos, prioritize_friend)

	# 在原位置播放爆炸动画
	var explode_particle: GPUParticles2D = EXPLODE_PARTICLE.instantiate()
	get_tree().root.add_child(explode_particle)
	explode_particle.one_shot = true
	explode_particle.emitting = true
	explode_particle.global_position = global_position

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

func activate(energy: int, energy_dir: int):
	return

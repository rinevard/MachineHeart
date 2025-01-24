class_name MachinePart
extends Area2D

const EXPLODE_PARTICLE = preload("res://scenes/particles/explode_particle.tscn")

@onready var module_label: ModuleLabel = $ModuleLabel
signal died(tile_pos: Vector2i, prioritize_friend: bool)

var team = Globals.Team.Neutral:
	set(value):
		team = value
		call_deferred("_update_collision_layer")
var type = Globals.MachineType.Part
@export var cost: int = -1
@export var sold: int = -1
@export var default_health: int = -1
@export var effec: String = "这里是 part 的默认文字"

var tile_pos: Vector2i = Vector2i.ZERO
var has_died: bool = false
var health: int
var active_protections: Array[ProtectCircle] = []
var is_shaking: bool = false

func _ready():
	health = default_health
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	module_label.hide()

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

func hit_shake(direction: Vector2, shake_dis: float=20.0):
	if is_shaking:
		return
	is_shaking = true
	# 标准化方向向量
	var normalized_dir = direction.normalized()
	# 获取原始位置
	var original_position = position
	# 设置震动距离
	var shake_distance = shake_dis  # 可以调整这个值来改变震动距离
	
	# 创建 tween
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	
	# 设置震动动画
	# 首先快速向后移动
	tween.tween_property(self, "position", 
		original_position + normalized_dir * shake_distance, 
		0.1)
	# 然后弹回原位置
	tween.tween_property(self, "position", 
		original_position, 
		0.3)
	
	await tween.finished
	is_shaking = false

func set_module_label():
	module_label.set_module_label(cost, sold, health, effec)

func _on_mouse_entered():
	set_module_label()
	module_label.show()

func _on_mouse_exited():
	module_label.hide()

class_name FloatingNumber
extends Node2D

@onready var rich_text_label: RichTextLabel = $FloatingNumber/RichTextLabel

# 动画参数
const START_SCALE: float = 0.1       # 初始缩放
const MAX_SCALE: float = 1.0         # 最大缩放
const END_SCALE: float = 1.0         # 结束缩放
const FLOAT_DISTANCE1: float = 40.0  # 第一段上升距离
const FLOAT_DISTANCE2: float = 50.0  # 第二段上升距离
const GROW_DURATION: float = 0.2     # 放大动画时间
const PAUSE_DURATION: float = 0.05    # 停顿时间
const SHRINK_DURATION: float = 0.1   # 缩小动画时间

func _ready():
	# 设置初始缩放
	scale = Vector2.ONE * START_SCALE
	floating_and_scaling()

func floating_and_scaling():
	# 第一阶段：上升并放大
	var tween1 = create_tween()
	tween1.set_parallel(true)
	tween1.tween_property(
		self,
		"position:y",
		position.y - FLOAT_DISTANCE1,
		GROW_DURATION
	)
	tween1.tween_property(
		self,
		"scale",
		Vector2.ONE * MAX_SCALE,
		GROW_DURATION
	)
	
	# 等待第一阶段完成
	await tween1.finished
	
	# 停顿
	await get_tree().create_timer(PAUSE_DURATION).timeout
	
	# 第二阶段：继续上升并缩小至消失
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.tween_property(
		self,
		"position:y",
		position.y - FLOAT_DISTANCE1 - FLOAT_DISTANCE2,
		SHRINK_DURATION
	)
	tween2.tween_property(
		self,
		"scale",
		Vector2.ONE * END_SCALE,
		SHRINK_DURATION
	)
	tween2.tween_property(
		self,
		"modulate:a",
		0.0,
		SHRINK_DURATION
	)
	
	# 等待第二阶段完成后删除自身
	await tween2.finished
	queue_free()

func set_num(num: int, color: String):
	rich_text_label.text = """
[center]
[font_size=64]
[outline_size=2][outline_color=#000000][color=""" + color + """]""" + str(num) + \
"""
[/color][/outline_color][/outline_size]
[/font_size]
[/center]
	"""

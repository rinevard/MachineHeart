extends Camera2D

@export var move_speed: float = 3000.0  # 移动速度
@export var smoothness: float = 20.0    # 平滑程度，值越大移动越平滑
@export var min_zoom: float = 0.5       # 最小缩放值
@export var max_zoom: float = 1.2       # 最大缩放值
@export var zoom_speed: float = 0.05     # 缩放速度

var target_position: Vector2 = Vector2.ZERO  # 目标位置
var target_zoom: Vector2 = Vector2.ONE      # 目标缩放值

func _ready() -> void:
	target_position = position
	target_zoom = zoom

func _process(delta: float) -> void:
	var movement = Vector2.ZERO
	
	# 检测输入
	if Input.is_action_pressed("right"):
		movement.x += 1
	if Input.is_action_pressed("left"):
		movement.x -= 1
	if Input.is_action_pressed("up"):
		movement.y -= 1
	if Input.is_action_pressed("down"):
		movement.y += 1
		
	# 标准化向量
	if movement.length() > 0:
		movement = movement.normalized()
	
	# 更新目标位置
	target_position += movement * move_speed * delta
	
	# 限制移动范围
	target_position.x = clamp(target_position.x, Globals.camera_x_min, Globals.camera_x_max)
	target_position.y = clamp(target_position.y, Globals.camera_y_min, Globals.camera_y_max)
	
	# 平滑移动和缩放
	position = position.lerp(target_position, delta * smoothness)
	zoom = zoom.lerp(target_zoom, delta * smoothness)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# 放大
			target_zoom = (target_zoom + Vector2.ONE * zoom_speed).clamp(Vector2.ONE * min_zoom, Vector2.ONE * max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# 缩小
			target_zoom = (target_zoom - Vector2.ONE * zoom_speed).clamp(Vector2.ONE * min_zoom, Vector2.ONE * max_zoom)

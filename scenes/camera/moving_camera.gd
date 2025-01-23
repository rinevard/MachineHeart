class_name MovingCamera
extends Camera2D

@export var move_speed: float = 3000.0  # 移动速度
@export var smoothness: float = 10.0    # 平滑程度，值越大移动越平滑
@export var min_zoom: float = 0.5       # 最小缩放值
@export var max_zoom: float = 0.9       # 最大缩放值
@export var zoom_speed: float = 0.05     # 缩放速度

var target_zoom: Vector2 = Vector2.ONE      # 目标缩放值

func _ready() -> void:
	limit_left = Globals.camera_x_min
	limit_top = Globals.camera_y_min
	limit_right = Globals.camera_x_max
	limit_bottom = Globals.camera_y_max
	target_zoom = zoom

func _process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	# 更新目标位置
	position = position + direction * move_speed * delta
	position.x = clamp(position.x, limit_left + 1024, limit_right - 1024)
	position.y = clamp(position.y, limit_top + 1024, limit_bottom - 1024)

	zoom = zoom.lerp(target_zoom, delta * smoothness)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# 放大
			target_zoom = (target_zoom + Vector2.ONE * zoom_speed).clamp(Vector2.ONE * min_zoom, Vector2.ONE * max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# 缩小
			target_zoom = (target_zoom - Vector2.ONE * zoom_speed).clamp(Vector2.ONE * min_zoom, Vector2.ONE * max_zoom)

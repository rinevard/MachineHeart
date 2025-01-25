extends Control

@onready var continue_button = $CenterContainer/HBoxContainer/VBoxContainer/ContinueButton
@onready var back_to_start = $CenterContainer/HBoxContainer/VBoxContainer/BackToStart
@onready var black_mask: ColorRect = $BlackMask
var is_paused: bool = false
var is_exiting: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	continue_button.pressed.connect(_on_continue_pressed)
	back_to_start.pressed.connect(_on_back_to_start_pressed)
	black_mask.color = Color(0, 0, 0, 0)
	black_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()

func _unhandled_input(event):
	if event.is_action_pressed("pause") and not is_exiting:
		_change_pause_state()

func _change_pause_state():
	if is_paused: # 说明正在暂停
		hide()
		Engine.time_scale = 1
		is_paused = false
	else:
		show()
		Engine.time_scale = 0.05
		is_paused = true

func _on_continue_pressed():
	if is_paused: # 仅在暂停的时候 "继续" 有效
		_change_pause_state()

func _on_back_to_start_pressed():
	# 用黑幕把菜单遮起来然后转移场景
	is_exiting = true
	Engine.time_scale = 1
	var wait_time: float = 0.8
	black_mask.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(black_mask, "color:a", 1.0, wait_time)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/menus/start_menu.tscn")

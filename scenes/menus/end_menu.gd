class_name EndMenu
extends Control
signal exit_to_main_menu

@onready var black_mask: ColorRect = $BlackMask
@onready var exit_button: Button = $CenterContainer/VBoxContainer/ExitButton
@onready var congrat_label = $CenterContainer/VBoxContainer/CongratLabel
@onready var label_2 = $CenterContainer/VBoxContainer/Label2

func _ready():
	exit_button.pressed.connect(_on_back_to_start_pressed)
	black_mask.color = Color(0, 0, 0, 0)
	black_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()

func init_and_show_end_menu(is_win: bool): # 调用该函数来显示胜利或者失败
	# "你消灭了所有的敌方核心, 胜利！"
	# "你的所有核心被消灭了, 失败！"
	if is_win:
		congrat_label.text = "你赢了！"
		label_2.text = "你消灭了所有的敌方核心"
	else:
		congrat_label.text = "失败"
		label_2.text = "你的所有核心被消灭了"
	show()
	pass

func _on_back_to_start_pressed():
	var wait_time: float = 0.8
	black_mask.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(black_mask, "color:a", 1.0, wait_time)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/menus/start_menu.tscn")

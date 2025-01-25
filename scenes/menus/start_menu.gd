extends Control

@onready var black_mask: ColorRect = $BlackMask
@onready var start_button = $VBoxContainer/CenterContainer/HBoxContainer/VBoxContainer/StartButton
@onready var instruction_button = $VBoxContainer/CenterContainer/HBoxContainer/VBoxContainer/InstructionButton
@onready var exit_button = $VBoxContainer/CenterContainer/HBoxContainer/VBoxContainer/ExitButton

@onready var up_place_holder: Control = $VBoxContainer/UpPlaceHolder
@onready var up_place_holder_2: Control = $VBoxContainer/UpPlaceHolder2
@onready var left_place_holder: Control = $VBoxContainer/CenterContainer/HBoxContainer/LeftPlaceHolder
@onready var right_place_holder: Control = $VBoxContainer/CenterContainer/HBoxContainer/RightPlaceHolder
@onready var instruction : Control = $Instruction

# Called when the node enters the scene tree for the first time.
func _ready():
	instruction.hide()
	var screen_size = DisplayServer.window_get_size()
	var width = screen_size.x
	var height = screen_size.y
	up_place_holder.custom_minimum_size = up_place_holder.custom_minimum_size * width / 2880
	up_place_holder_2.custom_minimum_size = up_place_holder_2.custom_minimum_size * width / 2880
	left_place_holder.custom_minimum_size = left_place_holder.custom_minimum_size * width / 2880
	right_place_holder.custom_minimum_size = right_place_holder.custom_minimum_size * width / 2880
		
	start_button.pressed.connect(_on_start_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	instruction_button.pressed.connect(_on_instruction_pressed)
	black_mask.color = Color(0, 0, 0, 0)
	black_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_start_pressed():
	var wait_time: float = 0.8
	black_mask.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(black_mask, "color:a", 1.0, wait_time)
	await tween.finished
	init_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func init_game():
	Globals.money = 20
	Globals.pos_to_module = {}
	Globals.is_picking = false

func _on_exit_pressed():
	var wait_time: float = 0.8
	black_mask.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(black_mask, "color:a", 1.0, wait_time)
	await tween.finished
	get_tree().quit()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		instruction.hide()
		# 关闭说明书

func _on_instruction_pressed():
	instruction.show()
	# 打开说明书

extends Control

@onready var black_mask: ColorRect = $BlackMask
@onready var start_button = $VBoxContainer/CenterContainer/HBoxContainer/VBoxContainer/StartButton
@onready var instruction_button = $VBoxContainer/CenterContainer/HBoxContainer/VBoxContainer/InstructionButton
@onready var exit_button = $VBoxContainer/CenterContainer/HBoxContainer/VBoxContainer/ExitButton

# Called when the node enters the scene tree for the first time.
func _ready():
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
	Globals.pos_to_module = {}
	Globals.is_picking = false

func _on_exit_pressed():
	var wait_time: float = 0.8
	black_mask.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(black_mask, "color:a", 1.0, wait_time)
	await tween.finished
	get_tree().quit()

func _on_instruction_pressed():
	pass

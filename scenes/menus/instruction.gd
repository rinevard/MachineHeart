extends Control

const PAGE_1 = preload("res://assets/instruction/page1.png")
const PAGE_2 = preload("res://assets/instruction/page2.jpg")
const PAGE_3 = preload("res://assets/instruction/page3.jpg")
var pages = [null, PAGE_1, PAGE_2, PAGE_3]
var cur_page: int = 1
@onready var instruction_texture: TextureRect = $InstructionTexture

func _ready():
	instruction_texture.mouse_filter = Control.MOUSE_FILTER_STOP
	instruction_texture.gui_input.connect(_gui_input)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		flip_page()

func flip_page():
	cur_page += 1
	if cur_page > 3:
		hide()
		cur_page = 1
	instruction_texture.texture  =pages[cur_page]	

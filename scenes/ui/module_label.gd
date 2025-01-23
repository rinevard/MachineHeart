class_name ModuleLabel
extends Control

@onready var price_and_sold_label: Label = $VBoxContainer/PriceAndSold
@onready var health_label: Label  = $VBoxContainer/Health
@onready var effec_label: Label  = $VBoxContainer/Effec

func _ready():
	set_module_label(10, 3, 5, "超级猫咪")

func set_module_label(price: int, sold: int, health: int, effec: String):
	price_and_sold_label.text = "买入: " + str(price) + ", 卖出: " + str(sold)
	health_label.text = "当前生命值: " + str(health)
	effec_label.text = effec

class_name ModuleLabel
extends Control

@onready var price_and_sold_label = $CenterContainer/VBoxContainer/PriceAndSoldLabel
@onready var health_label = $CenterContainer/VBoxContainer/HealthLabel
@onready var effec_label = $CenterContainer/VBoxContainer/EffecLabel

func _ready():
	set_module_label(10, 3, 5, "超级猫咪")

func set_module_label(price: int, sold: int, health: int, effec: String):
	price_and_sold_label.text = "买入: " + str(price) + ", 卖出: " + str(sold)
	health_label.text = "当前生命值: " + str(health)
	effec_label.text = effec

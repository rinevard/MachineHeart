extends Control

signal item_bought(item: PackedScene)

@onready var refresh_button: Button = $CenterContainer/HBoxContainer/RefreshButton

@onready var shop_item_1: ShopItemButton = $CenterContainer/HBoxContainer/ShopItem1
@onready var shop_item_2: ShopItemButton = $CenterContainer/HBoxContainer/ShopItem2
@onready var shop_item_3: ShopItemButton = $CenterContainer/HBoxContainer/ShopItem3
@onready var shop_item_4: ShopItemButton = $CenterContainer/HBoxContainer/ShopItem4

var shop_items: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	refresh_button.pressed.connect(_on_refresh_button_pressed)
	shop_items = [shop_item_1, shop_item_2, shop_item_3, shop_item_4]
	for shop_item: ShopItemButton in shop_items:
		shop_item.item_bought.connect(_on_item_bought)

func _on_refresh_button_pressed():
	for shop_item: ShopItemButton in shop_items:
		shop_item.refresh()

func _on_item_bought(item: PackedScene):
	item_bought.emit(item)

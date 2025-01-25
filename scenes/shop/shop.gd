class_name Shop
extends Control

signal item_bought(item: PackedScene)

@onready var money_label = $CenterContainer/HBoxContainer/VBoxContainer/ColorRect/MoneyLabel
@onready var refresh_button = $CenterContainer/HBoxContainer/VBoxContainer/RefreshButton
@onready var buy_audio_stream_player: AudioStreamPlayer = $BuyAudioStreamPlayer
@onready var refresh_audio_stream_player: AudioStreamPlayer = $RefreshAudioStreamPlayer

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

func _process(delta):
	money_label.text = str(Globals.money)

func _on_refresh_button_pressed():
	if Globals.money <= 0:
		return
	Globals.money -= 1
	refresh()
	refresh_audio_stream_player.play()

func refresh():
	for shop_item: ShopItemButton in shop_items:
		shop_item.refresh()

func _on_item_bought(item: PackedScene):
	item_bought.emit(item)
	buy_audio_stream_player.play()

class_name AcitvateNumberShower
extends Node2D

const FLOATING_NUMBER: PackedScene = preload("res://scenes/ui/floating_number.tscn")
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

func _ready():
	pass

func show_num(num: int, tile_pos: Vector2i, color: String):
	var floating_number: FloatingNumber = FLOATING_NUMBER.instantiate()
	floating_number.global_position = tile_pos_to_global_pos(tile_pos)
	add_child(floating_number)
	floating_number.set_num(num, color)

func tile_pos_to_global_pos(tile_pos: Vector2i) -> Vector2:
	var local_pos: Vector2 = tile_map_layer.map_to_local(tile_pos)
	return tile_map_layer.to_global(local_pos)

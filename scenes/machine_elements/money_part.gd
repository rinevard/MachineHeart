extends MachinePart

const MONEY_PICKED: PackedScene = preload("res://scenes/money_picked/money_picked.tscn")

# 一种改法是增加自己售价?
func activate(energy: int, energy_dir: int):
	sold += 1
	if sold > 8:
		sold = 8
	var money_picked = MONEY_PICKED.instantiate()
	add_child(money_picked)
	money_picked.global_position = global_position

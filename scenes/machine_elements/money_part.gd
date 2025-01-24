extends MachinePart

const MONEY_PICKED: PackedScene = preload("res://scenes/money_picked/money_picked.tscn")

# 一种改法是增加自己售价?
func activate(energy: int, energy_dir: int):
	var origin_sold = sold
	sold += 2
	if sold > 8:
		sold = 8
	for i in range(sold - origin_sold):
		var money_picked = MONEY_PICKED.instantiate()
		add_child(money_picked)
		money_picked.global_position = global_position
		await get_tree().create_timer(0.04).timeout

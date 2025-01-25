extends MachinePart

const MONEY_PICKED: PackedScene = preload("res://scenes/money_picked/money_picked.tscn")
const FEW_MONEY = preload("res://assets/art/machine/few_money.png")
const LOTS_MONEY = preload("res://assets/art/machine/lots_money.png")

# 一种改法是增加自己售价?
func activate(energy: int, energy_dir: int):
	var origin_sold = sold
	sold += 2
	if sold > 8:
		sold = 8
		sprite_2d.texture = LOTS_MONEY
		
	for i in range(sold - origin_sold):
		var money_picked = MONEY_PICKED.instantiate()
		add_child(money_picked)
		money_picked.global_position = global_position
		await get_tree().create_timer(0.04).timeout

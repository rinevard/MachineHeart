extends MachinePart


func activate(energy: int, energy_dir: int):
	if team == Globals.Team.Friend:
		Globals.money += 1

extends MachinePart

const BULLET = preload("res://scenes/bullet/bullet.tscn")
@onready var shot_audio_stream_player: AudioStreamPlayer = $ShotAudioStreamPlayer

func activate(energy: int, energy_dir: int):
	super.activate(energy, energy_dir)
	# 计算三个方向
	var directions = [
		energy_dir,
		(energy_dir - 1 + 6) % 6,  # 确保结果在0-5之间
		(energy_dir + 1) % 6
	]
	
	# 向三个方向发射子弹
	for dir in directions:
		var new_bullet: Bullet = BULLET.instantiate()
		new_bullet.init_bullet(energy, Globals.direcToVec(dir), team)
		add_child(new_bullet)
	shot_audio_stream_player.play()
	hit_shake(Globals.direcToVec((energy_dir + 3) % 6), 10.0)

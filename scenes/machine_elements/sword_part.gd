extends MachinePart

const SWORD_ARC = preload("res://scenes/sword_arc/sword_arc.tscn")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func activate(energy: int, energy_dir: int):
	super.activate(energy, energy_dir)
	# 测试用的子弹射击
	var sword_arc: SwordArc = SWORD_ARC.instantiate()
	var tween = create_tween()
	tween.tween_property(sprite_2d, "rotation", 5.759 + Globals.direcToVec(energy_dir).angle(), 0.2)
	sword_arc.init_sword_arc(energy, Globals.direcToVec(energy_dir), team)
	add_child(sword_arc)
	audio_stream_player.play()

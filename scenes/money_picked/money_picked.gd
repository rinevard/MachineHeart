extends Node2D

# 节点引用
@onready var coin_sprite_2d: Sprite2D = $CoinSprite2D
@onready var get_money_audio_stream_player: AudioStreamPlayer = $GetMoneyAudioStreamPlayer

# 动画参数
const INITIAL_SCALE := 0.05
const FINAL_SCALE := 0.2
const MOVE_DISTANCE := -200.0
const SCALE_DURATION := 0.1
const MOVE_DURATION := 0.5
const FADE_DELAY := 0.4
const FADE_DURATION := 0.1

func _ready():
	# 初始化
	coin_sprite_2d.scale = Vector2(INITIAL_SCALE, INITIAL_SCALE)
	coin_sprite_2d.modulate.a = 1.0
	
	# 创建tween动画
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 缩放动画
	tween.tween_property(
		coin_sprite_2d,
		"scale",
		Vector2(FINAL_SCALE, FINAL_SCALE),
		SCALE_DURATION
	).set_ease(Tween.EASE_OUT)
	
	# 向上移动
	tween.tween_property(
		coin_sprite_2d,
		"position",
		coin_sprite_2d.position + Vector2(0, MOVE_DISTANCE),
		MOVE_DURATION
	).set_ease(Tween.EASE_OUT)
	
	# 透明度渐变动画
	tween.tween_property(
		coin_sprite_2d,
		"modulate:a",
		0.0,
		FADE_DURATION
	).set_delay(FADE_DELAY)
	
	# 播放音效
	get_money_audio_stream_player.play()
	
	# 等待动画和音效都完成
	await tween.finished
	await get_money_audio_stream_player.finished
	
	# 删除节点
	call_deferred("queue_free")

class_name TurnHandler
extends Node2D
signal turn_ended

func _on_button_pressed():
	turn_ended.emit()

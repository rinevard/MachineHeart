class_name TurnHandler
extends Control
signal turn_ended

func _on_button_pressed():
	turn_ended.emit()

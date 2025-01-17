class_name MachinePart
extends Area2D

var team = Globals.Team.Neutral
var type = Globals.MachineType.Part
@export var default_health: int = -1
@export var default_armor: int = -1

var health: int
var armor: int

func _ready():
	health = default_health
	armor = default_armor

func activate():
	print(name, " is activated!")

extends Node

export(NodePath) var weapon_path

export(int) var min_damage = 1
export(int) var max_damage = 6

export(int) var accuracy = 0

export(int) var armor_class = 0

func roll_damage():
	return round( rand_range( self.min_damage, self.max_damage ) )

func _ready():
	if "Gear" in get_parent():
		get_parent().Gear = self
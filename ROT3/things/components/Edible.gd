extends Node


export(int) var hunger_filled = 1

func _ready():
	if Owner: # Subscribe to parent as Item component
		Owner.components["edible"] = self

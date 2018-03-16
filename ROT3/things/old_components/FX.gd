extends Node

onready var Owner = get_parent()

export(int) var duration = 1

onready var life = self.duration setget _set_life

func _ready():
	if Owner:
		Owner.components["FX"] = self
		Owner.add_to_group("FX")

func _enter_tree():
	if Owner:
		Owner.z_index = RPG.THING_LAYER_FX

func _set_life( what ):
	life = what
	if life < 0:
		if Owner:	Owner.queue_free()
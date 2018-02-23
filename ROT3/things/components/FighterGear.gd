extends Node

"""
FIGHTERGEAR SUB-COMPONENT (Make the child of a Fighter component)
Makes a fighter capable of equiping various Equipment-type Things.
"""

var slots = {
	"weapon":	null,
	"shield":	null,
	"helm":		null,
	"body":		null,
	"legs":		null,
	"boots":	null,
	"cloak":	null,
	"gloves":	null,
	"amulet":	null,
	"ring":		null,
	}

func update_paperdoll():
	if "paperdoll" in get_parent().Owner.components:
		var doll = get_parent().Owner.components.paperdoll
		for slot in slots:
			if slots[slot] != null:
				var sprite = slots[slot].components.equipment.paperdoll_sprite
				doll.set_doll_sprite( slot, sprite )
			else:
				doll.set_doll_sprite( slot, null )

func _ready():
	# Subscribe as a subcomponent of Fighter
	if "Gear" in get_parent():
		get_parent().Gear = self
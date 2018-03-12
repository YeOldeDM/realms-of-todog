extends Node

export(String) var paperdoll_slot = ""
export(Texture) var paperdoll_sprite = null

func _ready():
	if owner:
		if 'paperdoll_slots' in owner:
			owner.paperdoll_slots.append( self )

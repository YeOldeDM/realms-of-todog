extends Node2D


"""
PAPERDOLL COMPONENT
Allows a thing's Sprite to be augmented
with additional sprites
(use on Heroes and Monsters who can equip weapons)
"""


onready var Owner = get_parent()

func set_doll_sprite( slot, texture ):
	if has_node( slot ):
		get_node( slot ).texture = texture

func _ready():
	if Owner:
		Owner.components['paperdoll'] = self



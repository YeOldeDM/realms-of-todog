extends Node2D

"""
EQUIPMENT COMPONENT (Requires an Item component in the same Thing)
Equipment can:
	be equipped/removed
	add to damage or defense abilities when equipped
	be cursed: Cursed equipment cannot be removed until the curse is broken

"""


signal request_equip( what )
signal request_dequip( what )


onready var Owner = get_parent()

export(String) var equip_slot = ""

export(Texture) var paperdoll_sprite = null

export(bool) var cursed = false

export(int) var min_damage = 0
export(int) var max_damage = 0
export(int) var accuracy = 0

export(int) var armor_class = 0

var equipped = false setget _set_equipped


func equip():
	emit_signal("request_equip", Owner)
#func equip(to):
#	var did_equip = to.components.fighter.equip_item( Owner )
#	if did_equip == "OK":
#		self.equipped = true
#		RPG.messageboard.message( "%s equipped the %s" % [ to.get_message_name(), Owner.get_message_name() ] )
#		to.emit_signal("acted")
#	else:
#		RPG.messageboard.message( "%s must remove the %s before you can equip the %s" % [to.get_message_name(), did_equip, Owner.get_message_name()] )

func dequip():
	emit_signal("request_dequip", Owner)
#func dequip(from):
#	var did_remove = from.components.fighter.dequip_item( Owner )
#	if did_remove == OK:
#		self.equipped = false
#		RPG.messageboard.message( "%s removes the %s" % [from.get_message_name(), Owner.get_message_name() ] )
#		from.emit_signal("acted")




func roll_damage():
	var dmin = clamp( self.min_damage, 0, self.max_damage )
	var dmax = self.max_damage
	return round(rand_range( dmin, dmax ) )

func _ready():
	if Owner:
		Owner.components["equipment"] = self
		Owner.add_to_group("equipment")
		
		if RPG.game:
			connect("request_equip", RPG.game, "_on_thing_request_equip")
			connect("request_dequip", RPG.game, "_on_thing_request_dequip")
	# Bootstrap Equip sprite
	self.equipped = self.equipped


func _set_equipped( what ):
	equipped = what
	var n = int(equipped) + ( int(cursed)*2 )
	$Equipped.frame = n





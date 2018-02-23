extends Control




onready var message_board = $Frame/View/GUI/Messageboard

onready var world_map = $Frame/View/Port/Viewport/World.map
onready var inventory_map = $Frame/Char/Inventory/InventoryMap






func _ready():
	RPG.game = self




func _on_thing_request_pickup( thing ):
	thing = world_map.remove_thing( thing )
	inventory_map.add_to_inventory( thing )
	# Return an error state?




func _on_thing_request_drop( thing ):
	inventory_map.remove_from_inventory(thing)
	thing = world_map.add_thing( thing, RPG.player.cell )
	RPG.player.emit_signal("acted")
	# Return an error state?



func _on_thing_request_equip( thing ):
	var did_equip = RPG.player.components.fighter.equip_item( thing )
	if thing.is_equipped_by_player():
		RPG.message.message( "That is already equipped!" )
	elif did_equip == "OK":	#SPOOPY!
		RPG.messageboard.message( "You equipped the %s" % thing.get_message_name() )
		RPG.player.emit_signal("acted")
	else:
		RPG.messageboard.message( "You must remove the %s before you can equip the %s" 
									% [ did_equip, thing.get_message_name()] )
	# Return an error state?


func _on_thing_request_dequip( thing ):
	var did_dequip = RPG.player.components.fighter.dequip_item( thing )
	if did_dequip == OK:
		RPG.messageboard.message( "You remove the %s" % thing.get_message_name() )
		RPG.player.emit_signal("acted")
	else:
		RPG.messageboard.message_cantdo()
	# Return an error state?




func _on_GodModeSwitch_toggled( button_pressed ):
	if RPG.player:
		RPG.player.components.fighter.invincible = button_pressed
		RPG.messageboard.message( "GOD MODE %s" % ["OFF","ON"][int(button_pressed)], RPG.messageboard.COLOR_SYSTEM )










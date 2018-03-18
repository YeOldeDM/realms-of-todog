extends Control




onready var message_board = $Frame/View/GUI/Messageboard

onready var world_map = $Frame/View/Port/Viewport/World.map
onready var inventory_map = $Frame/Char/Inventory/InventoryMap



func get_game_dict():
	# Build Data
	var data = {}
	# Get Version Data
	data.version = {
		"MAJOR": DATA.VERSION.MAJOR,
		"MINOR": DATA.VERSION.MINOR,
		"BABY": DATA.VERSION.BABY,
		}
	# Get Map Data
	data.map = world_map.data
	# Get Rooms Data
	var room_dicts = []
	for room in data.map.rooms:
		room_dicts.append( room.get_save_dict() )
	data.map.rooms = room_dicts
	# Get Map Things Data
	data.map_things = []
	for thing in world_map.get_things():
		data.map_things.append( thing.get_save_dict() )
	# Get Inventory Things Data
	# Get global Player Data
	data.player_data = RPG.player_data
	return data

func _ready():
	RPG.game = self




func _on_thing_request_pickup( thing ):
	thing = world_map.remove_thing( thing )
	inventory_map.add_to_inventory( thing )
	# Return an error state?




func _on_thing_request_drop( thing ):
	inventory_map.remove_from_inventory(thing)
	thing = world_map.add_thing( thing, RPG.player.cell )
	RPG.player.emit_signal("acted", DATA.DEFAULT_ACTION_TIME)
	# Return an error state?



func _on_thing_request_equip( thing ):
	var did_equip = RPG.player.components.fighter.equip_item( thing )
	if thing.is_equipped_by_player():
		RPG.message.message( "That is already equipped!" )
	elif did_equip == "OK":	#SPOOPY!
		RPG.messageboard.message( "You equipped the %s" % thing.get_message_name() )
		RPG.player.emit_signal("acted", DATA.DEFAULT_ACTION_TIME) 
	else:
		RPG.messageboard.message( "You must remove the %s before you can equip the %s" 
									% [ did_equip, thing.get_message_name()] )
	# Return an error state?


func _on_thing_request_dequip( thing ):
	var did_dequip = RPG.player.components.fighter.dequip_item( thing )
	if did_dequip == OK:
		RPG.messageboard.message( "You remove the %s" % thing.get_message_name() )
		RPG.player.emit_signal("acted", DATA.DEFAULT_ACTION_TIME) 
	else:
		RPG.messageboard.message_cantdo()
	# Return an error state?




func _on_GodModeSwitch_toggled( button_pressed ):
	if RPG.player:
		RPG.player.fighter.invincible = button_pressed
		RPG.messageboard.message( "GOD MODE %s" % ["OFF","ON"][int(button_pressed)], RPG.messageboard.COLOR_SYSTEM )
	
#	RPG.save_game()










func _on_SummonerSwitch_toggled( button_pressed ):
	$Summoner.visible = button_pressed


func _input(ev):
	if ev is InputEventKey:
		if ev.pressed and !ev.is_echo():
			match ev.scancode:
				KEY_F1:
					$HelpPanel.popup_centered()
				KEY_ESCAPE:
					print("POOP")
#			if ev.scancode == KEY_F1:
#				$HelpPanel.popup()
#			elif ev.scancode == 
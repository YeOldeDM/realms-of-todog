extends Node


# Spell Effect Methods:
#	These should return true/false
#	Return false if the spell effect is invalidated
#	invalid effects do not count as actions

onready var world = $"../../"

#func get_cell_select_action():
#	return yield( world, "cell_selected" )


func LightHealSelf():
	var target = RPG.player
	if target:
		if target.components.fighter.is_HP_full():
			RPG.messageboard.message( "You're already uninjured." )
			return false
		var amt = 8 + RPG.roll(2,8)
		target.components.fighter.heal_damage(amt)
		
		return true
	return false


func ConfuseTarget():
	RPG.messageboard.message("Choose a target..")
	var action = yield( world, "cell_selected" )
	if action == null:
		RPG.messageboard.message_cancel()
		return false
	else:
		prints("ASDFASDFACTION",action)
		var targets = get_parent().get_things_in_cells( [action] )
		if !targets.empty():
			for thing in targets:
				if "AI" in thing.components:
					RPG.messageboard.message( "%s has become confused!" % thing.get_message_name() )
					thing.components.AI.confuse()
					return true
	return false

func get_fireball_damage():
	return RPG.roll(5,20)


func Fireball():
	var action = yield( world, "cell_selected" )
	if action == null:	#Action cancelled
		RPG.messageboard.message_cancel()
		return false
	else:	#Action Success!
		assert typeof(action) == TYPE_VECTOR2
		var cells = world.map.get_floor_cells_in_radius( action )
		var targets = world.map.get_things_in_cells(cells)
		for cell in cells:
			# Spawn fireball FX
			var fx = RPG.spawn("FX/Fireball")
			world.map.add_thing( fx, cell )
			# Deal damage to targets
			for thing in targets:
				if thing.cell == cell:
					thing.hurt( get_fireball_damage(), fx )
		return true
	# Just in case??
	return false






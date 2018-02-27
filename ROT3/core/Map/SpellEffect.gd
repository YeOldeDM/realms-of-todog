extends Node


# Spell Effect Methods:
#	These should return true/false
#	Return false if the spell effect is invalidated
#	invalid effects do not count as actions

signal executed( success )	# Emitted after a SpellEffect is processed. Passes whether or not the effect is considered successful. 
# Unsuccessful execution doesn't count as an action, don't burn charges/items/MP

onready var world = $"../../"




func LightHealSelf():
	var target = RPG.player
	if target:
		if target.components.fighter.is_HP_full():
			RPG.messageboard.message( "You're already uninjured." )
			return false
		var amt = 8 + RPG.roll(2,8)
		target.components.fighter.heal_damage(amt)
		
		emit_signal("executed", true)
		return true
	emit_signal("executed", false)
	return false


func ConfuseTarget():
	RPG.messageboard.message("Choose a target..")
	var action = yield( world, "cell_selected" )
	if action == null:
		RPG.messageboard.message_cancel()
		emit_signal("executed", false)
		return false
	else:
		var targets = get_parent().get_things_in_cells( [action] )
		if !targets.empty():
			for thing in targets:
				if "AI" in thing.components:
					RPG.messageboard.message( "%s has become confused!" % thing.get_message_name() )
					thing.components.AI.confuse()
					emit_signal("executed", true)
					return true
	emit_signal("executed", false)
	return false

# Baloney numbers
func get_fireball_damage():
	return RPG.roll(5,20)


func Fireball():
	RPG.messageboard.message("Choose a target..")
	var action = yield( world, "cell_selected" )
	if action == null:	#Action cancelled
		RPG.messageboard.message_cancel()
		emit_signal("executed", false)
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
		emit_signal("executed", true)
		return true
	# Just in case??
	emit_signal("executed", false)
	return false


func SummonSwine():
	var cell = RPG.player.cell
	var cells = world.map.get_floor_cells_in_radius( cell, 4 )
	for cell in cells:
		if world.map.get_things_in_cells([cell]).empty():
			world.map.add_thing( RPG.spawn( "Monster/Hog" ), cell )
	return true


func RandomUselessness():
	RPG.messageboard.random_message()
	emit_signal("executed", true)
	return true
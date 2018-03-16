extends Node

signal hp_changed( to )
signal current_hp_changed( to )

signal died( from )

# These are overridden for RPG.player!
export(float) var move_speed = 1.0	
export(int) var hp = 10 setget _set_hp


var current_hp = -1 setget _set_current_hp

func step_or_attack( direction ):
	assert direction in RPG.DIRECTIONS.values()
	
	var acted = true
	
	var new_cell = get_parent().cell + direction
	
	# Check for colliders at new cell
	var collider = RPG.map.get_collider( new_cell )
	if collider == RPG.map: # if the collider is a wall..
#		print( "%s hits the wall with a thud!" % get_parent().Name )
		acted = false # dont count this as an action
	elif collider != null and collider != self: # if collider can be attacked..
#		print( "%s punches the %s in the face!" % [get_parent().Name, collider.Name] )
		attack( collider )

	else: # the cell is empty, so step there
		get_parent().cell = new_cell
	# Emit the acted signal, or not..
	if acted:
		get_parent().emit_signal("acted",DATA.DEFAULT_ACTION_TIME)
	

func attack( who ):
	pass

func heal_damage( amt, from=null ):
	pass

func take_damage( amt, from=null ):
	pass


func setup():
	get_parent().fighter = self
	self.current_hp = self.hp

func _set_hp( what ):
	hp = what
	emit_signal( "hp_changed", hp )

func _set_current_hp( what ):
	current_hp = what
	emit_signal( "current_hp_changed", current_hp )
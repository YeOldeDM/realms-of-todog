extends Node

signal hp_changed( to )
signal current_hp_changed( to )



signal died()

# These are overridden for RPG.player!
export(float) var move_speed = 1.0	
export(int) var hp = 10 setget _set_hp


var current_hp = -1 setget _set_current_hp

export(bool) var invincible = false

func get_weapon_damage():
	return 3

func get_attack_bonus():
	return 0


func get_armor_class():
	return 10



func die(from_string):
	
	if get_parent().ai:
		get_parent().ai.alive = false
	
	if get_parent().pawn:
		get_parent().pawn.queue_free()
	RPG.messageboard.message( "%s was killed by %s" % [get_parent().get_message_name(), from_string] )
	emit_signal("died")

	
func step_or_attack( direction ):
	assert direction in RPG.DIRECTIONS.values()
	
	var acted = true
	
	var new_cell = get_parent().cell + direction
	
	# Check for colliders at new cell
	var collider = RPG.map.get_collider( new_cell )
	if collider == RPG.map: # if the collider is a wall..
		acted = false # dont count this as an action
	elif collider != null and collider != self: # if collider can be attacked..
		attack( collider )

	else: # the cell is empty, so step there
		get_parent().cell = new_cell
	# Emit the acted signal, or not..
	if acted:
		get_parent().emit_signal("acted",DATA.DEFAULT_ACTION_TIME)
	

func attack( who ):
	var result = RPG.process_attack( get_parent(), who )
	if result.hits:
		if who.fighter:
			who.fighter.take_damage( result.damage, get_parent().get_message_name() )


func heal_damage( amt, from_string="A mysterious force" ):
	pass

func take_damage( amt, from_string="A mysterious force" ):
	if invincible:
		RPG.messageboard.message( "%s cannot be harmed" % get_parent().get_message_name() )
		return
	# Clamp incoming damage. N less than zero, no more than our current HP
	amt = clamp( amt, 0, self.current_hp )
	# Adjust HP property
	self.current_hp -= amt
	# Print an attack message
	RPG.messageboard.message_attack( from_string, get_parent().get_message_name(), amt )
	# Check for death
	if self.current_hp <= 0:
		die( from_string )


func setup():
	connect( "died", get_parent(), "_on_fighter_died" )
	get_parent().fighter = self
	self.current_hp = self.hp

func _set_hp( what ):
	hp = what
	emit_signal( "hp_changed", hp )

func _set_current_hp( what ):
	current_hp = what
	emit_signal( "current_hp_changed", current_hp )
extends Node

signal cell_changed( from, to )

signal about_to_act( delta )
signal acted( action )

signal kill(me)

export(String) var thing_name = "Thing"

# The text that's shown when you Examine this thing
export(String) var description = "It's a thing."

# The default texture to use for this Thing's pawn
export(Texture) var default_pawn_texture = preload( "res://graphics/misc/todo.png" )

export(bool) var blocks_movement = false setget _set_blocks_movement	# Other things can't enter our cell
export(bool) var blocks_sight = false setget _set_blocks_sight	# our cell blocks line of sight
export(bool) var stay_visible = false	# we stay visible to the player after being found

var found = false	# Have we been seen by the player yet

var cell = Vector2() setget _set_cell	# This Thing's cell position on the Map

var SID = -1	# Unique SpawnID for each Thing in the game
var database_path	# Reference to its original in DATABASE


var pawn = null	# Map Pawn representing this Thing

var in_inventory = false


# Component refs
var fighter
var item
var equipment
var ai

func setup():
	connect( "about_to_act", self, "_rpg_process" )
	add_to_group( "things" )
	if blocks_movement:
		add_to_group("blockers")
	if blocks_sight:
		add_to_group("sightblockers")

	for node in get_children():
		if node.has_method("setup"):
			node.setup()

func get_message_name( the=false ):
	var n = self.thing_name
	if self == RPG.player:
		n = "you"
	else:
		if the:
			n = "the "+n
		elif n[0] in ["a","e","i","o","u"]:
			n = "an "+n
		else:
			n = "a "+n
	return n

func _rpg_process( delta ):
	if ai:
		ai.act(delta)


func _set_blocks_movement( what ):
	blocks_movement = what
	if blocks_movement:
		if !is_in_group("blockers"):
			add_to_group("blockers")
	else:
		if is_in_group("blockers"):
			remove_from_gruop("blockers")
	
func _set_blocks_sight( what ):
	blocks_sight = what
	if blocks_sight:
		if !is_in_group("sightblockers"):
			add_to_group("sightblockers")
	else:
		if is_in_group("sightblockers"):
			remove_from_gruop("sightblockers")


func _set_cell( what ):
	cell = what
	emit_signal( "cell_changed", cell, what )
		

func _on_fighter_died():
	emit_signal("kill", self)


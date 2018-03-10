extends Node

"""
PLAYER COMPONENT (requires a Fighter component on the same Thing)
Gets player input and controls the player's Hero.

"""


onready var Owner = get_parent()

var is_dead = false

func pickup_items_in_cell( cell=Owner.cell ):
	var things = Owner.map.get_things_in_cells([Owner.cell])
	if not things.empty():
		for thing in things:
			if "item" in thing.components:
				thing.components.item.pickup()
				RPG.messageboard.message("You pick up the %s" % thing.get_message_name())
				Owner.emit_signal("acted", DATA.DEFAULT_ACTION_TIME)
				break

func kill( from ):
	is_dead = true
	RPG.messageboard.message_playerdeath()

func enter_map( map ):
	Owner.connect( "map_cell_changed", map, "_on_player_map_cell_changed" )
	Owner.connect( "acted", map, "_on_player_acted" )


func _ready():
	if Owner:
		Owner.components["player"] = self
		Owner.get_node("Camera").make_current()
		# The player finds themselves!
		Owner.found = true
		
		RPG.player = Owner
#		get_node("/root/Game").player = Owner	# phase me out!




var key_pressed = false
# Turn Input into player action
func _input( event ):
	if "pressed" in event and !is_dead:
		if !key_pressed and event.pressed:
			if event.is_action( "action_pickup" ):
				pickup_items_in_cell()
			
			elif event.is_action( "action_wait" ):
				Owner.components.fighter.idle()
			
			elif event.is_action( "step_N" ):
				Owner.components.fighter.step_or_attack( RPG.DIRECTIONS.N )
			elif event.is_action( "step_NE" ):
				Owner.components.fighter.step_or_attack( RPG.DIRECTIONS.NE )
			elif event.is_action( "step_E" ):
				Owner.components.fighter.step_or_attack( RPG.DIRECTIONS.E )
			elif event.is_action( "step_SE" ):
				Owner.components.fighter.step_or_attack( RPG.DIRECTIONS.SE )
			elif event.is_action( "step_S" ):
				Owner.components.fighter.step_or_attack( RPG.DIRECTIONS.S )
			elif event.is_action( "step_SW" ):
				Owner.components.fighter.step_or_attack( RPG.DIRECTIONS.SW )
			elif event.is_action( "step_W" ):
				Owner.components.fighter.step_or_attack( RPG.DIRECTIONS.W )
			elif event.is_action( "step_NW" ):
				Owner.components.fighter.step_or_attack( RPG.DIRECTIONS.NW )
		key_pressed = event.pressed

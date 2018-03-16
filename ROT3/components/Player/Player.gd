extends Node


var active = false	# if false, don't process input

func setup():
	active = true

func _ready():
	RPG.player = get_parent()
#	get_parent().add_to_group("player")



var P = false
func _input( event ):
	if active and 'pressed' in event:
		if event.pressed and !P:
			if event.is_action( "action_pickup" ):
				pass
			
			elif event.is_action( "action_wait" ):
				pass
			
			elif event.is_action( "step_N" ):
				get_parent().fighter.step_or_attack( RPG.DIRECTIONS.N )
			elif event.is_action( "step_NE" ):
				get_parent().fighter.step_or_attack( RPG.DIRECTIONS.NE )
			elif event.is_action( "step_E" ):
				get_parent().fighter.step_or_attack( RPG.DIRECTIONS.E )
			elif event.is_action( "step_SE" ):
				get_parent().fighter.step_or_attack( RPG.DIRECTIONS.SE )
			elif event.is_action( "step_S" ):
				get_parent().fighter.step_or_attack( RPG.DIRECTIONS.S )
			elif event.is_action( "step_SW" ):
				get_parent().fighter.step_or_attack( RPG.DIRECTIONS.SW )
			elif event.is_action( "step_W" ):
				get_parent().fighter.step_or_attack( RPG.DIRECTIONS.W )
			elif event.is_action( "step_NW" ):
				get_parent().fighter.step_or_attack( RPG.DIRECTIONS.NW )
		P = event.pressed
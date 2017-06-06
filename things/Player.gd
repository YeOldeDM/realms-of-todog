extends "res://things/Thing.gd"



# Init
func _ready():
	set_process_input( true )

# Input
func _input( event ):
	
	if Input.is_action_pressed( "step_n" ):
		step( DIRECTIONS.N )
	if Input.is_action_pressed( "step_ne" ):
		step( DIRECTIONS.NE )
	if Input.is_action_pressed( "step_e" ):
		step( DIRECTIONS.E )
	if Input.is_action_pressed( "step_se" ):
		step( DIRECTIONS.SE )
	if Input.is_action_pressed( "step_s" ):
		step( DIRECTIONS.S )
	if Input.is_action_pressed( "step_sw" ):
		step( DIRECTIONS.SW )
	if Input.is_action_pressed( "step_w" ):
		step( DIRECTIONS.W )
	if Input.is_action_pressed( "step_nw" ):
		step( DIRECTIONS.NW )
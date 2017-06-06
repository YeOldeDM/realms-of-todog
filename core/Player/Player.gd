extends "res://things/Thing.gd"

#const DIRECTIONS = {
#	"N":	Vector2(0,-1),
#	"NE":	Vector2(1,-1),
#	"E":	Vector2(1,0),
#	"SE":	Vector2(1,1),
#	"S":	Vector2(0,1),
#	"SW":	Vector2(-1,1),
#	"W":	Vector2(-1,0),
#	"NW":	Vector2(-1,-1),
#	}


# Map node
#onready var map = get_parent()




# Step one cell in a direction
#func step( dir ):
#	# Clamp vector to 1 cell in any direction
#	dir.x = clamp( dir.x, -1, 1 )
#	dir.y = clamp( dir.y, -1, 1 )
#	
#	# Calculate new cell
#	var new_cell = get_map_pos() + dir
#	
#	# Check for valid cell to step to
#	if map.is_floor( new_cell ):
#		set_map_pos( new_cell )
#	else:
#		print( "Ow! You hit a wall!" )


# Get our position in Map Coordinates
#func get_map_pos():
#	return map.world_to_map( get_pos() )


# Set our position to Map Coordinates
#func set_map_pos( cell ):
#	set_pos( map.map_to_world( cell ) )


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
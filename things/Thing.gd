extends Node2D

const DIRECTIONS = {
	"N":	Vector2(0,-1),
	"NE":	Vector2(1,-1),
	"E":	Vector2(1,0),
	"SE":	Vector2(1,1),
	"S":	Vector2(0,1),
	"SW":	Vector2(-1,1),
	"W":	Vector2(-1,0),
	"NW":	Vector2(-1,-1),
	}


# Map node
onready var map = get_parent()



# Step one cell in a direction
func step( dir ):
	# Clamp vector to 1 cell in any direction
	dir.x = clamp( dir.x, -1, 1 )
	dir.y = clamp( dir.y, -1, 1 )
	
	# Calculate new cell
	var new_cell = get_map_pos() + dir
	
	# Check for valid cell to step to
	if map.is_floor( new_cell ):
		set_map_pos( new_cell )
	else:
		print( "Ow! You hit a wall!" )


# Get our position in Map Coordinates
func get_map_pos():
	return map.world_to_map( get_pos() )


# Set our position to Map Coordinates
func set_map_pos( cell ):
	set_pos( map.map_to_world( cell ) )



func _ready():
	pass

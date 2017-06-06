extends Node

# Return an instance of a node in that database at 'path'
func spawn( path ):
	# Find our Thing before we try returning anything
	var thing = find_node( path )
	if thing:	return thing.duplicate(true)
	# Print an error message if thing doesn't drop out
	print( "Cannot find a Thing at: " + path )

func _ready():
	pass

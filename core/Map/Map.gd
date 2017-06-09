extends TileMap

# Player Start Position
const START_POS = Vector2(10,10)

# Return Array of all Things
func get_things():
	return get_tree().get_nodes_in_group("things")

# Return Array of all Movement-Blocking Things
func get_blockers():
	return get_tree().get_nodes_in_group("blockers")


# Spawn what path from Database, set position to where
func spawn( what, where ):
	# Add the Thing to the scene and set its pos
	add_child( what )
	what.set_map_pos( where )
	# All things go to things group
	what.add_to_group("things")
	# Add blocking things to a blockers group
	if what.blocks_movement:
		what.add_to_group("blockers")

# Return a blocking Thing, this Map, or null at cell
func get_collider( cell ):
	for thing in get_blockers():
		if thing.get_map_pos() == cell:
			# Return the blocking Thing at this map pos
			return thing
	# Else return me if hitting a wall, or null if hitting air
	return self if not is_floor( cell ) else null


# Return TRUE if cell is blocked by anything
func is_cell_blocked( cell ):
	for thing in get_blockers():
		if thing.get_map_pos() == cell:
			return true
	# if no blockers here, check for walls
	return !is_floor( cell )

# Return TRUE if cell is a floor on the map
func is_floor( cell ):
	return get_cellv( cell ) == 1


# Init
func _ready():
	# Test objects
	var player = RPG.make_thing( "player/player" )
	var alter1 = RPG.make_thing( "props/altar" )
	var alter2 = RPG.make_thing( "props/altar" )
	var potion = RPG.make_thing( "items/potion" )
	
	spawn( alter1, Vector2(8,7) )
	spawn( alter2, Vector2(14,7) )
	spawn( potion, Vector2(12,10) )
	spawn( player, START_POS )

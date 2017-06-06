extends TileMap

const START_POS = Vector2(10,10)

func get_things():
	return get_tree().get_nodes_in_group("things")

func spawn( what, where ):
	add_child( what )
	what.set_map_pos( where )
	what.add_to_group("things")

func is_cell_blocked( cell ):
	for thing in get_things():
		if thing.get_map_pos() == cell:
			return thing.blocks_movement
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

extends TileMap

const START_POS = Vector2(10,10)

func spawn( what, where ):
	add_child( what )
	what.set_map_pos( where )

# Return TRUE if cell is a floor on the map
func is_floor( cell ):
	return get_cellv( cell ) == 1

func _ready():
	var player = RPG.make_thing( "player/player" )
	var alter1 = RPG.make_thing( "props/altar" )
	var alter2 = RPG.make_thing( "props/altar" )
	var potion = RPG.make_thing( "items/potion" )
	
	spawn( alter1, Vector2(8,7) )
	spawn( alter2, Vector2(14,7) )
	spawn( potion, Vector2(12,10) )
	spawn( player, START_POS )

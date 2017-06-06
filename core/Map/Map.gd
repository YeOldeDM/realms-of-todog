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
	spawn( player, START_POS )

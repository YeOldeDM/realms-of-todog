extends TileMap



# Return TRUE if cell is a floor on the map
func is_floor( cell ):
	return get_cellv( cell ) == 1

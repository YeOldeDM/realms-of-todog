extends TileMap

func is_floor( cell ):
	return get_cellv( cell ) == 1

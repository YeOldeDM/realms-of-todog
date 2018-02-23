extends TileMap

func fill_rect( rect ):
	for x in range( rect.size.x ):
		for y in range( rect.size.y ):
			set_cell( x + rect.position.x, y + rect.position.y, 0 )

func reveal_cells( cells=[Vector2(-1, -1)] ):
	for cell in cells:
		set_cellv( cell, -1 )

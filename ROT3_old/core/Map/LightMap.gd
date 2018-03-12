extends TileMap

onready var map = get_parent()

func light_cells( cells ):
	clear()
	for cell in cells:
		if map.is_cell_floor( cell ):
			set_cellv( cell, 0 )

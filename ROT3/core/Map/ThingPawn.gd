extends Node2D

var map

func init( from ):
	$Doll/body.texture = from.default_pawn_texture
	position = map.map_to_world( from.cell )

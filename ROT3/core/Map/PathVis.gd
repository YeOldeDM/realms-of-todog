extends Node2D

var path_points = []
func _draw():
	for point in path_points:
		var pos = get_node("../Pathfinder").map.get_point_position(point)
		pos = Vector2(pos.x,pos.y) * 32
		if get_node("../Pathfinder").map.get_point_connections(point).size() > 0:
			draw_circle( pos+Vector2(16,16), 4, Color(1,1,1) )
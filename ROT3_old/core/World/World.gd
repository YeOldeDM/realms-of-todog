extends Node2D

signal game_time_changed( to )

signal cell_selected( cell )

var map_hovered = false setget _set_map_hovered
var cell_hovered = null setget _set_cell_hovered

var map


var game_time = 0 setget _set_game_time

func _on_Port_gui_input( ev ):
	# Place the Map Cursor
	if ev is InputEventMouseMotion:
		if !self.map_hovered:
			self.map_hovered = true
		var mcell = map.world_to_map( get_global_mouse_position() )
		if mcell != self.cell_hovered:
			self.cell_hovered = mcell
	# Select a cell that's clicked
	if ev is InputEventMouseButton and map_hovered:
		if ev.pressed and ev.button_index == BUTTON_LEFT:
			print("click!",self.cell_hovered)
			emit_signal( "cell_selected", self.cell_hovered )
		elif ev.pressed and ev.button_index == BUTTON_RIGHT:
			print("cancelled")
			emit_signal( "cell_selected", null )

func _on_Port_mouse_exited():
	self.map_hovered = false
	self.cell_hovered = null


func _set_cell_hovered( what ):
	cell_hovered = what
	if cell_hovered:
		$Cursor.position = map.map_to_world( cell_hovered )


func _set_map_hovered( what ):
	map_hovered = what
	$Cursor.visible = map_hovered



func _set_game_time( what ):
	game_time = what
	emit_signal("game_time_changed", game_time)
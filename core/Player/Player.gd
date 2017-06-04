extends Node2D

# Map node
onready var map = get_parent()

# Get our position in Map Coordinates
func get_map_pos():
	return map.world_to_map( get_pos() )

# Set our position to Map Coordinates
func set_map_pos( cell ):
	set_pos( map.map_to_world( cell ) )


# Init
func _ready():
	set_process_input( true )

# Input
func _input( event ):
	
	# Action flags
	var UP = event.is_action_pressed("ui_up")
	var DOWN = event.is_action_pressed("ui_down")
	var LEFT = event.is_action_pressed("ui_left")
	var RIGHT = event.is_action_pressed("ui_right")
	
	# get our map position to modify
	var new_cell = get_map_pos()
	
	# Modify new_cell based on actions
	if UP:
		new_cell.y -= 1
	if DOWN:
		new_cell.y += 1
	if LEFT:
		new_cell.x -= 1
	if RIGHT:
		new_cell.x += 1
	
	# If new_cell was modified, set our position
	if new_cell != get_map_pos():
		set_map_pos( new_cell )




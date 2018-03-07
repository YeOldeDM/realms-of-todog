extends TileMap


const FLOOR = 0
const WALL = 1

var torch_radius = 6

var data = [[]]





class Room:
	# A Dungeon Room
	var rect
	var floor_tile_family
	var wall_tile_family
	
	func _init( rect, floor_tile=null, wall_tile=null ):
		self.rect = rect
		self.floor_tile_family = floor_tile
		self.wall_tile_family = wall_tile
	
	func get_floor_rect():
		return Rect2( self.rect.position + Vector2(1,1), self.rect.size - Vector2(2,2) )

	func occupies_cell( cell ):
		return self.rect.intersects( cell )












# Draw the map and fill it with Fog of War
func draw_map( data ):
	clear()
	for x in range( data.map.size() ):
		for y in range( data.map[x].size() ):
			var type = data.map[x][y]
			var i = -1
			if type == FLOOR:
				i = RPG.get_random_tile_index_by_family( "floors", "pebble_brown" )
			elif type == WALL:
				i = RPG.get_random_tile_index_by_family( "walls", "brick_brown" )
			set_cell( x, y, i )
			
	for room in data.rooms:
		for x in range( room.rect.position.x, room.rect.end.x ):
			for y in range( room.rect.position.y, room.rect.end.y ):
				var i = -1
				var type = data.map[x][y]
				if type == FLOOR:
					i = RPG.get_random_tile_index_by_family( "floors", room.floor_tile_family )
				elif type == WALL:
					i = RPG.get_random_tile_index_by_family( "walls", room.wall_tile_family )
				if i >= 0:
					set_cell( x, y, i )

	var fog_rect = Rect2( 0, 0, data.map.size(), data.map[0].size() )
	$FogMap.fill_rect( fog_rect )

func make_paths( map ):
	var cells = []
	var bounds = Vector2( map.size(), map[0].size() )
	for x in bounds.x:
		for y in bounds.y:
			if map[x][y] == FLOOR:
				cells.append(Vector2(x,y))
	$Pathfinder.build_map( bounds, cells )





# Add an instanced Thing to the map at a cell position
# Return OK if all is well, or return ERROR
func add_thing( thing, where, start_found=false ):
	
	if start_found:
		thing.found = true

	add_child( thing )

	thing.cell = where
	if thing.blocks_movement:
		# Block this cell for pathfinding
		$Pathfinder.dirty_cells[where]=false
		thing.connect("map_cell_changed", self, "_on_blocker_map_cell_changed")
	return thing

func remove_thing( thing ):
	if thing.blocks_movement:
		$Pathfinder.dirty_cells[thing.cell]=true
		thing.disconnect("map_cell_changed", self, "_on_blocker_map_cell_changed")
	remove_child( thing )
	return thing




# Return any colliding object in this cell
func get_collider( cell ):
	for thing in get_blockers():
		if thing.cell == cell:
			return thing
	return self if not is_cell_floor( cell ) else null

func is_cell_in_fov( cell ):
	return cell in fov_cells


# Return true if this cell blocks movement
# (by walls or otherwise)
func is_cell_blocked( cell ):
	for thing in get_blockers():
		if thing.cell == cell:
			return true
	return !is_floor( cell )



# Return true if this cell is a floor
func is_cell_floor( cell ):
	return data.map[cell.x][cell.y] == FLOOR




# Get all the Things
func get_things():
	return get_tree().get_nodes_in_group( "things" )

# Get all Movement-Blocking things
func get_blockers():
	return get_tree().get_nodes_in_group( "blockers" )

# Get all Sight-Blocking things
func get_sightblockers():
	return get_tree().get_nodes_in_group( "sightblockers" )

func get_actors():
	return get_tree().get_nodes_in_group( "actors" )

func get_items():
	return get_tree().get_nodes_in_group( "items" )

func get_fx():
	return get_tree().get_nodes_in_group( "FX" )


# Return all open cells within a square radius of a cell
# for AOE effects with a "blast radius"
func get_floor_cells_in_radius( cell, radius=1 ):
	var cells = PoolVector2Array()
	if is_cell_floor( cell ):
		cells.append( cell )
	for x in range( cell.x -radius, cell.x + radius + 1 ):
		for y in range( cell.y - radius, cell.y + radius + 1 ):
			var c = Vector2(x,y)
			if is_cell_floor( c ):
				cells.append( c )
	return cells



# Get all Things within a list of cells
func get_things_in_cells( cells ):
	var list = []
	for thing in get_things():
		if thing in get_children() and thing.cell in cells:
			list.append(thing)
	return list


func find_empty_cells_at( where ):
	var cells = RPG.DIRECTIONS
	var choices = []
	for cell in cells: 
		if not get_collider( cell + where ):
			choices.append(cell)
	return choices


func spawn_player( where ):
	# Spawn Player
	var obj = add_thing( RPG.spawn("Hero/Godot"), where )
	if typeof( obj ) == TYPE_INT:
		OS.alert("Failed to load the HERO THING. This is really bad!!")
		return

	# obj component init
	obj.components.player.enter_map( self )
	
	#connect player to HUD
	var hud = $"/root/Game/Frame/Char"
	obj.components.fighter.connect( "HP_changed", hud, "_on_HP_changed" )
	obj.components.fighter.connect( "maxHP_changed", hud, "_on_maxHP_changed" )
	#Kickstart HUD
	obj.components.fighter.emit_signal("maxHP_changed", obj.components.fighter.HP)
	obj.components.fighter.emit_signal("HP_changed", obj.components.fighter.HP)
	
	# Kickstart FOV
	_on_player_map_cell_changed( where, where )




func generate_map():
	# Generate & Draw the Map
	data = DunGen.Generate()
	# Convert DunGen room rect array to Room classes
	var rooms = []
	for room in data.rooms:
		var room_family = RPG.get_random_tile_family_pair()
		rooms.append( Room.new( room, room_family[0], room_family[1] ) )
	data.rooms = rooms
	
	draw_map( data )
	# Build A* paths
	make_paths( data.map )
	




func get_random_room_cell( room ):
	var rect = room.get_floor_rect()
	return Vector2( 
		RPG.roll( rect.position.x, rect.end.x-1 ), 
		RPG.roll( rect.position.y, rect.end.y-1 ) 
		)



func fill_room( room, what ):
	var rect = room.get_floor_rect()
	for x in range( rect.size.x ):
		for y in range( rect.size.y ):
			prints(x,y)
			add_thing( RPG.spawn(what), Vector2(rect.position.x+x,rect.position.y+y) )

func populate_room( room ):
	var occupied = []
	var n = RPG.roll( 1,4 )
	for i in range( n ):
		var pos = get_random_room_cell(room)
		var tries = 0
		var passed = !pos in occupied
		for i in range(5):
			if !passed:
				pos = get_random_room_cell(room)
				passed = !pos in occupied

		if passed:
			occupied.append( pos )
			
			var choices = [
				"Monster/GiantRat",
				"Monster/GiantBat",
				"Monster/Goblin",
				"Monster/GreenSnake",
				"Equipment/Weapon/Dagger",
				"Equipment/Weapon/Club",
				"Equipment/Weapon/Shortsword",
				"Equipment/Body/Robes",
				"Equipment/Body/LeatherJerkin",
				"Equipment/Body/LeatherArmor",
				"Equipment/Shield/RoundShield",
				"Item/Potion/HealingPotion",
				"Item/Wand/ConfusionWand",
				"Item/Scroll/FireballScroll",
				]
			
			var choice = choices[randi() % choices.size()]
			
			add_thing( RPG.spawn( choice ), pos )






func populate_rooms( rooms ):
	for room in rooms:
		populate_room( room )


func _ready():
	get_parent().map = self
	# Don't initiate the map until everyone is ready!
	call_deferred("go")





# Map init
func go():
#	# Generate & Draw Map
	generate_map()
	# Fill the map with Stuff
	populate_rooms( data.rooms )
	# Always spawn the player last!
	spawn_player( data.start_pos )









# Callback to Notify Pathfinder node when blocking Things change cells
func _on_blocker_map_cell_changed( from, to ):
	#Unblock previous cell
	if typeof(from) == TYPE_VECTOR2:
		$Pathfinder.dirty_cells[from]=true
	# Block new cell
	if typeof(to) == TYPE_VECTOR2:
		$Pathfinder.dirty_cells[to]=false


var fov_cells = PoolVector2Array()
# Special callback when Player Thing changes cells
# Updates Fog and vision, finds unfound Things, and wakes sleeping AIs
func _on_player_map_cell_changed( from, to ):
	var blocks = []
	for thing in get_sightblockers():
		blocks.append( thing.cell )
	fov_cells = FOV.calculate_fov( data.map, WALL, to, self.torch_radius, blocks )
	$FogMap.reveal_cells( fov_cells )
	$LightMap.light_cells( fov_cells )
	
	for thing in get_things():
		if thing.cell in fov_cells:
			if !thing.found:
				thing.found = true
			if "AI" in thing.components:
				if !thing.components.AI.awake:
					thing.components.AI.wake_up( RPG.player )
		thing.visible = thing.cell in fov_cells or (thing.found and thing.stay_visible)


# Main gameplay loop!
# Called after Player performs an action
# All other actors act in turn before Player can act again
func _on_player_acted():
	for actor in get_actors():
		if "AI" in actor.components and actor != RPG.player:
			actor.components.AI.act()
	for thing in get_fx():
		thing.components.FX.life -= 1
	# Add 5 sec to game time
	get_parent().game_time += 5






var map_hovered = false setget _set_map_hovered
var cell_hovered = null setget _set_cell_hovered

func _on_Port_gui_input( ev ):
	if ev is InputEventMouseMotion:
		if !self.map_hovered:
			self.map_hovered = true
		var mcell = world_to_map( get_global_mouse_position() )
		if mcell != self.cell_hovered:
			self.cell_hovered = mcell


func _on_Port_mouse_exited():
	self.map_hovered = false
	self.cell_hovered = null


func _set_cell_hovered( what ):
	cell_hovered = what


func _set_map_hovered( what ):
	map_hovered = what
	



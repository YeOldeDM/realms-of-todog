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

	func get_save_dict():
		return {
			"rect":[
				self.rect.position.x,
				self.rect.position.y,
				self.rect.size.x,
				self.rect.size.y
				],
			"floor_tile_family": self.floor_tile_family,
			"wall_tile_family": self.wall_tile_family,
		}



func can_see_thing( thing ):
	return thing.cell in fov_cells or (thing.found and thing.stay_visible)








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

func find_path( from, to ):
	return $Pathfinder.find_path( from, to )


func make_paths( map ):
	var cells = []
	var bounds = Vector2( map.size(), map[0].size() )
	for x in bounds.x:
		for y in bounds.y:
			if map[x][y] == FLOOR:
				cells.append(Vector2(x,y))
	$Pathfinder.build_map( bounds, cells )



func draw_pawns():
	get_tree().call_group("pawns", "queue_free")
	
	for thing in $Things.get_children():
		if can_see_thing( thing ):
			var pawn = preload("res://core/Map/ThingPawn.tscn").instance()
			$Pawns.add_child(pawn)
			pawn.map = self
			pawn.init(thing)


# Add a new Thing to the dungeon, from DATA/Things path
func add_thing( path, where, start_found=false ):
	var thing = DATA.make_thing(path)
	
	$Things.add_child(thing)
	thing.setup()
	if start_found:
		thing.found = true
	
	thing.cell = where
	if thing.blocks_movement:
		$Pathfinder.dirty_cells[where] = false
		thing.connect( "cell_changed", self, "_on_blocker_cell_changed" )
	thing.connect( "kill", self, "kill_thing" )
	return thing


# Remove a Thing from the dungeon.
# Callback for Thing 'kill' signal
func kill_thing( who ):
	who.queue_free()
	yield( who, "tree_exited" )	# Ensure the Thing is gone
	call_deferred("draw_pawns") # before redrawing pawns





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


# Return array of open cells adjacent to a cell
func find_empty_cells_at( where ):
	var cells = RPG.DIRECTIONS
	var choices = []
	for cell in cells: 
		if not get_collider( cell + where ):
			choices.append(cell)
	return choices


# Special setup for spawning the PLAYER
func spawn_player( where ):
	# Spawn Player
	var obj = add_thing( "Misc/Player", where )
	
	
	# obj component init
#	obj.components.player.enter_map( self )
	obj.connect("cell_changed", self, "_on_player_cell_changed")
	obj.connect("acted", self, "_on_player_acted")
	#connect player to HUD
	var hud = $"/root/Game/Frame/Char"
	obj.fighter.connect( "hp_changed", hud, "_on_hp_changed" )
	obj.fighter.connect( "current_hp_changed", hud, "_on_current_hp_changed" )
	#Kickstart HUD
	obj.fighter.emit_signal("hp_changed", obj.fighter.hp)
	obj.fighter.emit_signal("current_hp_changed", obj.fighter.current_hp)
	
	# Kickstart FOV
	print("Spawned Player at %s" % str(where))
	_on_player_cell_changed( where, where )
	



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
			
			add_thing( "Misc/Hog", pos )






func populate_rooms( rooms ):
	for room in rooms:
		populate_room( room )


func _ready():
	RPG.map = self
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
	spawn_player( Vector2( data.start_x, data.start_y ) )
	draw_pawns()








# Callback to Notify Pathfinder node when blocking Things change cells
func _on_blocker_cell_changed( from, to ):
	#Unblock previous cell
	if typeof(from) == TYPE_VECTOR2:
		$Pathfinder.dirty_cells[from]=true
	# Block new cell
	if typeof(to) == TYPE_VECTOR2:
		$Pathfinder.dirty_cells[to]=false


var fov_cells = PoolVector2Array()
# Special callback when Player Thing changes cells
# Updates Fog and vision, finds unfound Things, and wakes sleeping AIs
func _on_player_cell_changed( from, to ):
	$Camera.position = map_to_world(to)
#	print("we moved to %s" % str(to) )
	
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
				print("found")
			if thing.ai:
				if !thing.ai.awake:
					thing.ai.wake_up( RPG.player )
#		thing.visible = thing.cell in fov_cells or (thing.found and thing.stay_visible)

# Main gameplay loop!
# Called after Player performs an action
# All other actors act in turn before Player can act again
func _on_player_acted(delta):
	print("player acted!")
	for actor in get_actors():
		if actor != RPG.player:
			if actor.ai and actor.ai.awake:
				actor.emit_signal("about_to_act", delta)


	for thing in get_fx():
		thing.components.FX.life -= 1
	# Add 5 sec to game time
	get_parent().game_time += delta
	draw_pawns()






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
	



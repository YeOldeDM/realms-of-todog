extends TileMap

#	INVENTORYMAP GRID


signal item_selected( what )


onready var InventoryActions = $"../../InventoryActions"


# Place a new Thing in the inventory grid
# If stackable, it will stack with similar
# items already in the inventory. Otherwise,
# it will find the next empty space, or 
# return an error if the inventory is full
func add_to_inventory( what ):
	# iterate through the inventory grid:
	var rect = get_used_rect()
	for y in range( rect.size.y ):
		for x in range( rect.size.x ):
			var c = Vector2(x,y)
			# flag for this cell being occupied
			var full = false
			# iterate through inventory items:
			for thing in get_children():
				# something exists in this cell:
				if thing.cell == c:
					full = true
					# If adding a stackable with an existing stack:
					if what.components.item.stackable and what.Name == thing.Name:
						thing.components.item.stack( [what] )
						return OK
					break
			# No stacking, and empty cell found:
			if !full:
				add_child( what )
				what.cell = c
				# If we fill the selected cell, make us the selected item
				if c == self.cell_selected:
					emit_signal("item_selected", what)
				return OK
	# No valid spaces found, return nasty errorses
	return ERR_BUG

func remove_from_inventory( what ):
	assert what in get_children()
	remove_child( what )
	

# Find the item living in an inventory cell
func get_item_at_cell( cell ):
	for thing in get_children():
		if thing.cell == cell:
			return thing

# Get item at selected cell, or null if empty
func get_selected_item():
	if cell_selected != null:
		return get_item_at_cell( cell_selected )


# Input handling
var map_hovered = false setget _set_map_hovered
var cell_hovered = null setget _set_cell_hovered

var cell_selected = null setget _set_cell_selected


func _ready():
	# Connect Inventory Action Buttons
	for button in InventoryActions.get_children():
		button.connect("pressed", self, "_on_InventoryAction_pressed", [button.name])

# Mouse input (from Control parent)
func _on_Inventory_gui_input( ev ):
	# Process mouse position
	if ev is InputEventMouseMotion:
		if !self.map_hovered: self.map_hovered = true
		var cell = world_to_map( ev.position )
		if cell != self.cell_hovered:
			self.cell_hovered = cell
	# Process Mouse Clicks
	elif ev is InputEventMouseButton:
		if ev.pressed and ev.button_index == BUTTON_LEFT and map_hovered:
			self.cell_selected = self.cell_hovered

# Mouse exits the InventoryMap rect
func _on_Inventory_mouse_exited():
	self.map_hovered = false
	cell_hovered = null


### Setters ###

func _set_map_hovered( what ):
	map_hovered = what
	$"../Cursor".visible = map_hovered

func _set_cell_hovered( what ):
	cell_hovered = what
	$"../Cursor".position = map_to_world( cell_hovered )


func _set_cell_selected( what ):
	cell_selected = what
	# Look for item under selected
	var selected = get_selected_item()
	if cell_selected != null:
		# Set Selection sprite
		$"../Selected".position = map_to_world( cell_selected )
		$"../Selected".show()

		# Announce item selected
		if selected:
			emit_signal("item_selected", selected)
		

	else:
		# Hide Selected sprite if no cell selected
		$"../Selected".hide()


### Signal Callbacks ###

func _on_InventoryAction_pressed( action ):
	var itm = get_selected_item()
	if itm == null:
		RPG.messageboard.message_cantdo()
		return
	match action:
		"Drop":
			# Can't drop equipped items
			if itm.is_equipped_by_player():
				RPG.messageboard.message("You must remove the %s before you can drop it." % itm.get_message_name() )
			
			elif "item" in itm.components:
				# Cant drop cursed items
				if itm.is_cursed():
					RPG.messageboard.message("You are compelled from dropping the %s" % itm.get_message_name() )
				# Item can be dropped
				else:
					itm.components.item.drop()
			

		"Equip":	
			if "equipment" in itm.components:
				itm.components.equipment.equip()
			else:
				RPG.messageboard.message_cantdo()

		"Remove":
			if "equipment" in itm.components:
				itm.components.equipment.dequip()


		"Examine":
			if itm:
				RPG.game.get_node("ExaminePanel").thing = itm

		"Throw":
			RPG.messageboard.message_cantdo()
		
		"Use":
			if "item" in itm.components:
				var used = itm.components.item.use()
#				if used:
#					RPG.messageboard.message("You use the %s" % itm.get_message_name() )
#				else:
#					RPG.messageboard.message_cancel()





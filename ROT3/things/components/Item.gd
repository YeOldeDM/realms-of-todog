extends Node2D


"""
ITEM COMPONENT
Items can:
	be picked up/dropped or thrown
	used to create different effects
	stack on top of each other

"""


# Connects to Inventory system to exchange 
# this Thing between World/Inventory
# (pass `Owner` when emitting `who`)
signal request_pickup(who)
signal request_drop(who)


onready var Owner = get_parent()

export(float) var weight = 1.0

export(bool) var stackable = false
export(bool) var throwable = true

export(int, "None", "One-Use", "Charged", "Infinite") var use_type = 0
export(int) var charges = 0
export(String) var use_effect = ""



export(Texture) var brand_sprite = null setget _set_brand_sprite


var stack = 1 setget _set_stack

func get_save_dict():
	return {
		"charges": self.charges,
		"stack": self.stack,
		}

func stack( others ):
	self.stack += others.size()
	for thing in others:
		thing.queue_free()



# Removes amt from a stack. Returns a duplicate Thing with amt stack count
func unstack( amt=1 ):
	amt = min( amt, self.stack - 1 )
	self.stack -= amt

	var itm = Owner.duplicate()
	itm.get_node("Item").stack = amt
	return itm



func pickup():
	emit_signal( "request_pickup", Owner )



func drop():
	var itm = Owner
	if stackable and self.stack > 1:
		itm = unstack(1)
	emit_signal( "request_drop", itm )


func use():
	# Do this better
	var world = RPG.game.world_map
	var used = false
	if self.use_type == 2 and self.charges < 1:
		return false
	
	if self.use_effect:
		if world.get_node("SpellEffect").has_method( self.use_effect ):
			world.get_node("SpellEffect").call( self.use_effect )
			used = yield( world.get_node("SpellEffect"), "executed" )

	if used:
		RPG.player.emit_signal("acted")
		if self.use_type == 1:
			if self.stack > 1:
				self.stack -= 1
			else:
				Owner.kill()
		elif self.use_type == 2:
			self.charges -= 1
		RPG.messageboard.message("You use the %s" % Owner.get_message_name() )
	else:
		RPG.messageboard.message_cancel()
	return used



func _ready():
	if Owner: # Subscribe to parent as Item component
		Owner.components["item"] = self
		Owner.add_to_group("items")
	
		if RPG.game:
			connect("request_pickup", RPG.game, "_on_thing_request_pickup")
			connect("request_drop", RPG.game, "_on_thing_request_drop")


func _enter_tree():
	_set_stack( self.stack )
	_set_brand_sprite( self.brand_sprite )
	if Owner:
		Owner.z_index = RPG.THING_LAYER_ITEMS


# Set our Stack count. Updates Count Label node
func _set_stack( what ):
	stack = what
	if stack > 1:
		$Count.text = str(stack)
	else:
		$Count.text = ""


# Set our Sprite image
func _set_brand_sprite( what ):
	brand_sprite = what
	if is_inside_tree():
		$Brand.texture = brand_sprite







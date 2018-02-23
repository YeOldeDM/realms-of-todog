extends Node2D
tool

const FALLBACK_SPRITE = "res://graphics/misc/todo.png"

signal map_cell_changed( from, to )
signal acted()	#Emitted when a Thing performs an action

onready var map = get_parent()

export(String, MULTILINE) var Name = "Thing"
# Sprite to use for this Thing
export(Texture) var sprite_path setget _set_sprite_path



export(bool) var blocks_movement = false	# Other things can't enter our cell
export(bool) var blocks_sight = false		# our cell blocks line of sight
export(bool) var stay_visible = false		# we stay visible to the player after being found

# goes true when we first enter player field of view
var found = false

# Current map cell property
var cell = Vector2() setget _set_cell, _get_cell

# Components dictionary
# Populated by Component children
var components = {}

#func has_component( what ):
#	return what in comp
#
#func get_component( what ):
#	if has_component( what ):
#		return comp[what]

func get_message_name():
	if "player" in self.components:
		return "you"
	else:
		return self.Name

func is_cursed():
	return "equipment" in self.components and self.components.equipment.cursed


func is_equipped_by_player():
	return self in get_node("/root/RPG").player.components.fighter.Gear.slots

func hurt( amt, from=null ):
	if "fighter" in components:
		self.components.fighter.take_damage( amt, from )

# Remove this Thing from the game
func kill():
	if self.blocks_movement or self.blocks_sight:
		# Move us to heaven!
		emit_signal("map_cell_changed", self.cell, null)
	queue_free()

func _ready():
	add_to_group("things")
	if self.blocks_movement:
		add_to_group("blockers")
	if self.blocks_sight:
		add_to_group("sightblockers")

func _enter_tree():
	$Sprite.texture = sprite_path

# Get our map cell position
func _get_cell():
	return map.world_to_map( position )

# Set our position to a map cell (upper-left)
func _set_cell( cell ):
	var old = self.cell
	self.position = map.map_to_world( cell )
	emit_signal( "map_cell_changed", old, self.cell )

# Set our Sprite image
func _set_sprite_path( what ):
	sprite_path = what
	if is_inside_tree():
		$Sprite.texture = sprite_path



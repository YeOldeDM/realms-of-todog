extends Node2D
tool

const FALLBACK_SPRITE = "res://graphics/misc/todo.png"

signal map_cell_changed( from, to )
signal acted(delta)	#Emitted when a Thing performs an action

signal about_to_act(delta) #Emitted when a Thing begins their action







onready var map = get_parent()

export(String, MULTILINE) var Name = "Thing"
export(String, MULTILINE) var description = "it's a thing."


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

var status_effects = {}

var SID # Spawn ID
var _dbpath # source Path to DataBase

func get_save_dict():
	assert self._dbpath
	var data = {
		"id": self.SID,
		"path": self._dbpath,
		"cell": {
			"x": self.cell.x,
			"y": self.cell.y,
			},
		"found": self.found,
		"components": {},
	}
	for component in self.components:
		if self.components[component].has_method("get_save_dict"):
			var comp_data = self.components[component].get_save_dict()
			data.components[component] = comp_data
	
	return data

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

#func add_status_effect( name ):
	if !Engine.editor_hint:
		if name in self.status_effects:
			return
		var stat = get_node("/root/RPG").spawn("StatusEffect/"+name)
		if stat:
			add_child(stat)
			self.status_effects[name] = stat

func _rpg_process(delta=5.0):
	for status in self.status_effects.values():
		status._rpg_process(delta)
	if "AI" in self.components:
		self.components.AI.act(delta)

func _ready():
	connect( "about_to_act", self, "_about_to_act" )
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




func _about_to_act(delta):
	_rpg_process(delta)
